<?php

namespace App\Http\Controllers;

use App\Models\Conversation;
use App\Models\Message;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class ChatController extends Controller
{
    public function users(): JsonResponse
    {
        $me = auth()->id();

        $users = User::where('id', '!=', $me)
            ->select('id', 'name', 'email', 'profile_image')
            ->orderBy('name')
            ->get();

        return response()->json([
            'success' => true,
            'data'    => $users,
        ]);
    }
    public function getOrCreateConversation(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'other_user_id' => 'required|integer|exists:users,id',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors'  => $validator->errors(),
            ], 422);
        }

        $me      = auth()->id();
        $otherId = (int) $request->other_user_id;

        if ($me === $otherId) {
            return response()->json([
                'success' => false,
                'message' => 'Cannot start a conversation with yourself',
            ], 422);
        }

        [$user1Id, $user2Id] = $me < $otherId ? [$me, $otherId] : [$otherId, $me];

        $conversation = Conversation::firstOrCreate(
            ['user1_id' => $user1Id, 'user2_id' => $user2Id]
        );

        $other = User::select('id', 'name', 'email', 'profile_image')
            ->find($otherId);

        return response()->json([
            'success' => true,
            'data'    => [
                'conversation_id' => $conversation->conversation_id,
                'other_user'      => $other,
            ],
        ]);
    }
    public function conversations(): JsonResponse
    {
        $me = auth()->id();

        $conversations = Conversation::where('user1_id', $me)
            ->orWhere('user2_id', $me)
            ->with(['user1:id,name,email,profile_image', 'user2:id,name,email,profile_image'])
            ->get()
            ->map(function (Conversation $conv) use ($me) {
                $other = $conv->otherUser($me);
                $last = Message::where('conversation_id', $conv->id)
                    ->where('deleted_for_everyone', false)
                    ->where(function ($q) use ($me) {
                        $q->whereNull('deleted_by_users')
                          ->orWhereRaw("JSON_SEARCH(deleted_by_users, 'one', ?) IS NULL", [$me]);
                    })
                    ->orderByDesc('created_at')
                    ->first();
                $unread = Message::where('conversation_id', $conv->id)
                    ->where('customer_id', '!=', $me)
                    ->where('deleted_for_everyone', false)
                    ->where(function ($q) use ($me) {
                        $q->whereNull('deleted_by_users')
                          ->orWhereRaw("JSON_SEARCH(deleted_by_users, 'one', ?) IS NULL", [$me]);
                    })
                    ->whereRaw("(metadata IS NULL OR JSON_EXTRACT(metadata, '$.read_by_{$me}') IS NULL)")
                    ->count();

                return [
                    'conversation_id' => $conv->conversation_id,
                    'other_user'      => $other->only(['id', 'name', 'email', 'profile_image']),
                    'last_message'    => $last ? $this->formatMessage($last, $me) : null,
                    'unread_count'    => $unread,
                    'updated_at'      => $conv->updated_at,
                ];
            })
            ->sortByDesc(fn($c) => optional($c['last_message'])['created_at'] ?? $c['updated_at'])
            ->values();

        return response()->json([
            'success' => true,
            'data'    => $conversations,
        ]);
    }
    public function messages(string $conversationId): JsonResponse
    {
        $me   = auth()->id();
        $conv = $this->findConversationForUser($conversationId, $me);

        if (!$conv) {
            return response()->json(['success' => false, 'message' => 'Conversation not found'], 404);
        }

        $messages = Message::where('conversation_id', $conv->id)
            ->where('deleted_for_everyone', false)
            ->where(function ($q) use ($me) {
                $q->whereNull('deleted_by_users')
                  ->orWhereRaw("JSON_SEARCH(deleted_by_users, 'one', ?) IS NULL", [$me]);
            })
            ->with('replyTo')
            ->orderBy('created_at')
            ->get()
            ->map(fn($m) => $this->formatMessage($m, $me));

        Message::where('conversation_id', $conv->id)
            ->where('customer_id', '!=', $me)
            ->whereRaw("(metadata IS NULL OR JSON_EXTRACT(metadata, '$.read_by_{$me}') IS NULL)")
            ->each(function (Message $m) use ($me) {
                $meta = $m->metadata ?? [];
                $meta["read_by_{$me}"] = now()->toIso8601String();
                $m->update(['metadata' => $meta]);
            });

        return response()->json([
            'success' => true,
            'data'    => $messages,
        ]);
    }
    public function sendMessage(Request $request, string $conversationId): JsonResponse
    {
        $me   = auth()->id();
        $conv = $this->findConversationForUser($conversationId, $me);

        if (!$conv) {
            return response()->json(['success' => false, 'message' => 'Conversation not found'], 404);
        }

        $validator = Validator::make($request->all(), [
            'body'        => 'required|string|max:5000',
            'reply_to_id' => 'nullable|integer|exists:messages,id',
        ]);

        if ($validator->fails()) {
            return response()->json(['success' => false, 'errors' => $validator->errors()], 422);
        }

        $message = Message::create([
            'conversation_id'    => $conv->id,
            'customer_id'        => $me,
            'content'            => $request->body,
            'type'               => 'text',
            'reply_to_message_id'=> $request->reply_to_id,
        ]);

        // Touch conversation updated_at so list re-sorts
        $conv->touch();

        return response()->json([
            'success' => true,
            'data'    => $this->formatMessage($message->load('replyTo'), $me),
        ], 201);
    }

    // ── Delete a message ─────────────────────────────────────────────────────

    /**
     * DELETE /api/chat/messages/{messageId}
     * Body: { scope } — "me" | "everyone"
     * "everyone" only allowed within 2 hours and only by sender.
     */
    public function deleteMessage(Request $request, int $messageId): JsonResponse
    {
        $me      = auth()->id();
        $message = Message::find($messageId);

        if (!$message) {
            return response()->json(['success' => false, 'message' => 'Message not found'], 404);
        }

        // Verify user is part of this conversation
        $conv = Conversation::find($message->conversation_id);
        if (!$conv || ($conv->user1_id !== $me && $conv->user2_id !== $me)) {
            return response()->json(['success' => false, 'message' => 'Forbidden'], 403);
        }

        $scope = $request->input('scope', 'me');

        if ($scope === 'everyone') {
            if ($message->customer_id !== $me) {
                return response()->json(['success' => false, 'message' => 'Only sender can delete for everyone'], 403);
            }
            if (now()->diffInHours($message->created_at) >= 2) {
                return response()->json(['success' => false, 'message' => 'Can only delete for everyone within 2 hours'], 422);
            }
            $message->update([
                'deleted_for_everyone'    => true,
                'deleted_for_everyone_at' => now(),
            ]);
        } else {
            // Delete for me only — append user ID to deleted_by_users JSON array
            $deletedBy   = $message->deleted_by_users ?? [];
            $deletedBy[] = $me;
            $message->update(['deleted_by_users' => array_values(array_unique($deletedBy))]);
        }

        return response()->json(['success' => true]);
    }

    // ── Mark conversation as read ─────────────────────────────────────────────

    /**
     * POST /api/chat/conversations/{conversationId}/read
     */
    public function markRead(string $conversationId): JsonResponse
    {
        $me   = auth()->id();
        $conv = $this->findConversationForUser($conversationId, $me);

        if (!$conv) {
            return response()->json(['success' => false, 'message' => 'Conversation not found'], 404);
        }

        Message::where('conversation_id', $conv->id)
            ->where('customer_id', '!=', $me)
            ->whereRaw("(metadata IS NULL OR JSON_EXTRACT(metadata, '$.read_by_{$me}') IS NULL)")
            ->each(function (Message $m) use ($me) {
                $meta = $m->metadata ?? [];
                $meta["read_by_{$me}"] = now()->toIso8601String();
                $m->update(['metadata' => $meta]);
            });

        return response()->json(['success' => true]);
    }

    // ── Internal helpers ──────────────────────────────────────────────────────

    private function findConversationForUser(string $conversationUuid, int $userId): ?Conversation
    {
        return Conversation::where('conversation_id', $conversationUuid)
            ->where(function ($q) use ($userId) {
                $q->where('user1_id', $userId)->orWhere('user2_id', $userId);
            })
            ->first();
    }

    private function formatMessage(Message $m, int $me): array
    {
        return [
            'id'                    => $m->id,
            'conversation_id'       => $m->conversation_id,
            'sender_id'             => $m->customer_id,
            'body'                  => $m->content,
            'type'                  => $m->type,
            'attachments'           => $m->attachments ?? [],
            'is_read'               => isset(($m->metadata ?? [])["read_by_{$me}"]),
            'is_edited'             => $m->is_edited,
            'edited_at'             => $m->edited_at?->toIso8601String(),
            'deleted_for_me'        => $m->isDeletedForUser($me),
            'deleted_for_everyone'  => $m->deleted_for_everyone,
            'reply_to_id'           => $m->reply_to_message_id,
            'reply_to'              => $m->replyTo ? [
                'id'        => $m->replyTo->id,
                'sender_id' => $m->replyTo->customer_id,
                'body'      => $m->replyTo->content,
            ] : null,
            'created_at'            => $m->created_at->toIso8601String(),
            'updated_at'            => $m->updated_at->toIso8601String(),
        ];
    }
}
