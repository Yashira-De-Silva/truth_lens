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
    // ── List all users (excluding self) ───────────────────────────────────────

    /**
     * GET /api/chat/users
     * Returns every registered user except the authenticated user.
     */
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

    // ── Get or create a conversation ─────────────────────────────────────────

    /**
     * POST /api/chat/conversations
     * Body: { other_user_id }
     * Finds an existing conversation between the two users, or creates one.
     * Always stores user1_id < user2_id to avoid duplicates.
     */
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

        // Canonical ordering so (A,B) and (B,A) resolve to the same row
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

    // ── List conversations for the authenticated user ─────────────────────────

    /**
     * GET /api/chat/conversations
     * Returns all conversations involving the auth user, sorted by last message.
     */
    public function conversations(): JsonResponse
    {
        $me = auth()->id();

        $conversations = Conversation::where('user1_id', $me)
            ->orWhere('user2_id', $me)
            ->with(['user1:id,name,email,profile_image', 'user2:id,name,email,profile_image'])
            ->get()
            ->map(function (Conversation $conv) use ($me) {
                $other = $conv->otherUser($me);

                // Last visible message for this user
                $last = Message::where('conversation_id', $conv->id)
                    ->where(function ($q) use ($me) {
                        $q->where('sender_id', $me)
                            ->where('deleted_for_sender', false);
                    })
                    ->orWhere(function ($q) use ($me, $conv) {
                        $q->where('conversation_id', $conv->id)
                            ->where('sender_id', '!=', $me)
                            ->where('deleted_for_receiver', false);
                    })
                    ->orderByDesc('created_at')
                    ->first();

                // Unread count (messages sent by other user that haven't been read)
                $unread = Message::where('conversation_id', $conv->id)
                    ->where('sender_id', '!=', $me)
                    ->where('is_read', false)
                    ->where('deleted_for_receiver', false)
                    ->count();

                return [
                    'conversation_id' => $conv->conversation_id,
                    'other_user'      => $other->only(['id', 'name', 'email', 'profile_image']),
                    'last_message'    => $last ? $this->formatMessage($last, $me) : null,
                    'unread_count'    => $unread,
                    'updated_at'      => $conv->updated_at,
                ];
            })
            ->filter(fn($c) => $c['last_message'] !== null)  // only show conversations with at least one message
            ->sortByDesc(fn($c) => optional($c['last_message'])['created_at'])
            ->values();

        return response()->json([
            'success' => true,
            'data'    => $conversations,
        ]);
    }

    // ── Get messages for a conversation ───────────────────────────────────────

    /**
     * GET /api/chat/conversations/{conversationId}/messages
     * Returns paginated messages (100 most recent).
     */
    public function messages(string $conversationId): JsonResponse
    {
        $me   = auth()->id();
        $conv = $this->findConversationForUser($conversationId, $me);

        if (!$conv) {
            return response()->json(['success' => false, 'message' => 'Conversation not found'], 404);
        }

        $messages = Message::where('conversation_id', $conv->id)
            ->with('replyTo')
            ->orderBy('created_at')
            ->get()
            ->map(fn($m) => $this->formatMessage($m, $me));

        // Mark all unread messages from the other person as read
        Message::where('conversation_id', $conv->id)
            ->where('sender_id', '!=', $me)
            ->where('is_read', false)
            ->update(['is_read' => true]);

        return response()->json([
            'success' => true,
            'data'    => $messages,
        ]);
    }

    // ── Send a message ────────────────────────────────────────────────────────

    /**
     * POST /api/chat/conversations/{conversationId}/messages
     * Body: { body, reply_to_id? }
     */
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
            'conversation_id' => $conv->id,
            'sender_id'       => $me,
            'body'            => $request->body,
            'reply_to_id'     => $request->reply_to_id,
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
            if ($message->sender_id !== $me) {
                return response()->json(['success' => false, 'message' => 'Only sender can delete for everyone'], 403);
            }
            $hoursAgo = now()->diffInHours($message->created_at);
            if ($hoursAgo >= 2) {
                return response()->json(['success' => false, 'message' => 'Can only delete for everyone within 2 hours'], 422);
            }
            $message->update(['deleted_for_sender' => true, 'deleted_for_receiver' => true]);
        } else {
            // Delete for me only
            if ($message->sender_id === $me) {
                $message->update(['deleted_for_sender' => true]);
            } else {
                $message->update(['deleted_for_receiver' => true]);
            }
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
            ->where('sender_id', '!=', $me)
            ->where('is_read', false)
            ->update(['is_read' => true]);

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
        $isMe = $m->sender_id === $me;

        return [
            'id'                    => $m->id,
            'conversation_id'       => $m->conversation_id,
            'sender_id'             => $m->sender_id,
            'body'                  => $m->body,
            'is_read'               => $m->is_read,
            'is_edited'             => false,   // reserved for future
            'deleted_for_me'        => $isMe ? $m->deleted_for_sender : $m->deleted_for_receiver,
            'deleted_for_everyone'  => $m->deleted_for_sender && $m->deleted_for_receiver,
            'reply_to_id'           => $m->reply_to_id,
            'reply_to'              => $m->replyTo ? [
                'id'        => $m->replyTo->id,
                'sender_id' => $m->replyTo->sender_id,
                'body'      => $m->replyTo->body,
            ] : null,
            'created_at'            => $m->created_at->toIso8601String(),
            'updated_at'            => $m->updated_at->toIso8601String(),
        ];
    }
}
