<?php

namespace App\Http\Controllers;

use App\Models\ChessGame;
use App\Models\Follow;
use App\Models\User;
use App\Models\Conversation;
use App\Models\Message;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class ChessController extends Controller
{
    private function formatGame(ChessGame $game, int $myId): array
    {
        return [
            'id'               => $game->id,
            'white_player'     => $this->userSnippet($game->white_player_id),
            'black_player'     => $this->userSnippet($game->black_player_id),
            'my_color'         => $game->colorFor($myId),
            'fen'              => $game->fen,
            'moves'            => $game->moves ?? [],
            'status'           => $game->status,
            'winner_id'        => $game->winner_id,
            'result'           => $game->result,
            'created_at'       => $game->created_at,
            'updated_at'       => $game->updated_at,
        ];
    }

    private function userSnippet(int $userId): array
    {
        $u = User::select('id', 'name', 'profile_image')->find($userId);
        return $u ? $u->toArray() : ['id' => $userId, 'name' => 'Unknown', 'profile_image' => null];
    }
    public function challenge(int $userId): JsonResponse
    {
        $me = auth()->id();

        if ($me === $userId) {
            return response()->json(['success' => false, 'message' => 'You cannot challenge yourself.'], 422);
        }
        $iFollow = Follow::where('follower_id', $me)->where('following_id', $userId)->exists();
        if (!$iFollow) {
            return response()->json([
                'success' => false,
                'message' => 'You must follow this user to challenge them.',
            ], 403);
        }
        $existing = ChessGame::where(function ($q) use ($me, $userId) {
            $q->where('white_player_id', $me)->where('black_player_id', $userId);
        })->orWhere(function ($q) use ($me, $userId) {
            $q->where('white_player_id', $userId)->where('black_player_id', $me);
        })->whereIn('status', ['waiting', 'active'])->first();

        if ($existing) {
            return response()->json([
                'success' => true,
                'message' => 'A game already exists between you two.',
                'data'    => $this->formatGame($existing, $me),
            ]);
        }

        $game = ChessGame::create([
            'white_player_id' => $me,
            'black_player_id' => $userId,
            'status'          => 'waiting',
            'fen'             => 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1',
            'moves'           => [],
        ]);

        try {
            [$u1, $u2] = $me < $userId ? [$me, $userId] : [$userId, $me];
            $conversation = Conversation::firstOrCreate([
                'user1_id' => $u1,
                'user2_id' => $u2
            ]);

            Message::create([
                'conversation_id' => $conversation->id,
                'customer_id'     => $me,
                'content'         => "♟ I have challenged you to a game of Chess! Check your profile to accept.",
                'type'            => 'text',
            ]);
            
            $conversation->touch();
        } catch (\Exception $e) {
            \Log::error("Failed to send chess chat notification: " . $e->getMessage());
        }

        $game->load('whitePlayer', 'blackPlayer');

        return response()->json([
            'success' => true,
            'message' => 'Challenge sent!',
            'data'    => $this->formatGame($game, $me),
        ], 201);
    }
    public function accept(int $gameId): JsonResponse
    {
        $me   = auth()->id();
        $game = ChessGame::findOrFail($gameId);

        if ($game->black_player_id !== $me) {
            return response()->json(['success' => false, 'message' => 'Not your game to accept.'], 403);
        }
        if ($game->status !== 'waiting') {
            return response()->json(['success' => false, 'message' => 'Game is not in waiting state.'], 422);
        }

        $game->update(['status' => 'active']);

        return response()->json(['success' => true, 'data' => $this->formatGame($game->fresh(), $me)]);
    }
    public function decline(int $gameId): JsonResponse
    {
        $me   = auth()->id();
        $game = ChessGame::findOrFail($gameId);

        if ($game->black_player_id !== $me && $game->white_player_id !== $me) {
            return response()->json(['success' => false, 'message' => 'Not your game.'], 403);
        }

        $game->update(['status' => 'declined']);

        return response()->json(['success' => true, 'message' => 'Game declined.']);
    }
    public function games(): JsonResponse
    {
        $me = auth()->id();

        $games = ChessGame::where('white_player_id', $me)
            ->orWhere('black_player_id', $me)
            ->orderByDesc('updated_at')
            ->get();

        $formatted = $games->map(fn($g) => $this->formatGame($g, $me));

        return response()->json(['success' => true, 'data' => $formatted]);
    }

    public function show(int $gameId): JsonResponse
    {
        $me   = auth()->id();
        $game = ChessGame::findOrFail($gameId);

        if (!$game->hasPlayer($me)) {
            return response()->json(['success' => false, 'message' => 'Not your game.'], 403);
        }

        return response()->json(['success' => true, 'data' => $this->formatGame($game, $me)]);
    }
    public function move(Request $request, int $gameId): JsonResponse
    {
        $me   = auth()->id();
        $game = ChessGame::findOrFail($gameId);

        if (!$game->hasPlayer($me)) {
            return response()->json(['success' => false, 'message' => 'Not your game.'], 403);
        }
        if ($game->status !== 'active') {
            return response()->json(['success' => false, 'message' => 'Game is not active.'], 422);
        }

        $validator = Validator::make($request->all(), [
            'from' => 'required|string|size:2',
            'to'   => 'required|string|min:2|max:3',
            'fen'  => 'required|string',
        ]);

        if ($validator->fails()) {
            return response()->json(['success' => false, 'errors' => $validator->errors()], 422);
        }

        $moves   = $game->moves ?? [];
        $moves[] = $request->from . $request->to . ($request->promotion ?? '');

        $game->update([
            'fen'   => $request->fen,
            'moves' => $moves,
        ]);

        return response()->json(['success' => true, 'data' => $this->formatGame($game->fresh(), $me)]);
    }
    public function resign(int $gameId): JsonResponse
    {
        $me   = auth()->id();
        $game = ChessGame::findOrFail($gameId);

        if (!$game->hasPlayer($me)) {
            return response()->json(['success' => false, 'message' => 'Not your game.'], 403);
        }
        if ($game->status !== 'active') {
            return response()->json(['success' => false, 'message' => 'Game is not active.'], 422);
        }

        $winnerId = $game->white_player_id === $me
            ? $game->black_player_id
            : $game->white_player_id;

        $game->update([
            'status'    => 'finished',
            'winner_id' => $winnerId,
            'result'    => $game->white_player_id === $me ? 'black' : 'white',
        ]);

        return response()->json(['success' => true, 'data' => $this->formatGame($game->fresh(), $me)]);
    }
    public function finish(Request $request, int $gameId): JsonResponse
    {
        $me   = auth()->id();
        $game = ChessGame::findOrFail($gameId);

        if (!$game->hasPlayer($me)) {
            return response()->json(['success' => false, 'message' => 'Not your game.'], 403);
        }

        $result   = $request->result;
        $winnerId = null;
        if ($result === 'white')      $winnerId = $game->white_player_id;
        elseif ($result === 'black')  $winnerId = $game->black_player_id;

        $game->update([
            'status'    => 'finished',
            'winner_id' => $winnerId,
            'result'    => $result,
        ]);

        return response()->json(['success' => true, 'data' => $this->formatGame($game->fresh(), $me)]);
    }
}
