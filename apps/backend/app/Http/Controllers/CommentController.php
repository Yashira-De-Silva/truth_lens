<?php

namespace App\Http\Controllers;

use App\Models\ArticleComment;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class CommentController extends Controller
{
    /**
     * Format a comment for the API response.
     * Appends `is_liked` based on the authenticated user.
     */
    private function formatComment(ArticleComment $comment, int $userId): array
    {
        return [
            'id'         => $comment->id,
            'article_id' => $comment->article_id,
            'body'       => $comment->body,
            'likes'      => $comment->likes,
            'is_liked'   => $comment->likedBy()->where('user_id', $userId)->exists(),
            'created_at' => $comment->created_at->toIso8601String(),
            'updated_at' => $comment->updated_at->toIso8601String(),
            'user'       => [
                'id'            => $comment->user->id,
                'name'          => $comment->user->name,
                'profile_image' => $comment->user->profile_image,
            ],
        ];
    }

    // ── GET /api/articles/{articleId}/comments ────────────────────────────────

    /**
     * Return all comments for an article, newest first.
     *
     * GET /api/articles/{articleId}/comments
     */
    public function index(int $articleId): JsonResponse
    {
        $userId = auth()->id();

        $comments = ArticleComment::with('user')
            ->where('article_id', $articleId)
            ->orderByDesc('created_at')
            ->get();

        return response()->json([
            'success' => true,
            'data'    => $comments->map(fn($c) => $this->formatComment($c, $userId)),
        ]);
    }

    // ── POST /api/articles/{articleId}/comments ───────────────────────────────

    /**
     * Add a new comment to an article.
     *
     * POST /api/articles/{articleId}/comments
     * Body: { body }
     */
    public function store(Request $request, int $articleId): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'body' => 'required|string|max:1000',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed',
                'errors'  => $validator->errors(),
            ], 422);
        }

        $comment = ArticleComment::create([
            'article_id' => $articleId,
            'user_id'    => auth()->id(),
            'body'       => $request->body,
        ]);

        // Record the activity
        \App\Models\UserActivity::create([
            'user_id'     => auth()->id(),
            'type'        => 'comment',
            'article_id'  => $articleId,
            'reference_id' => $comment->id,
            'description' => 'Commented on article #' . $articleId,
        ]);

        $comment->load('user');

        return response()->json([
            'success' => true,
            'message' => 'Comment added',
            'data'    => $this->formatComment($comment, auth()->id()),
        ], 201);
    }

    // ── DELETE /api/comments/{commentId} ─────────────────────────────────────

    /**
     * Delete own comment.
     *
     * DELETE /api/comments/{commentId}
     */
    public function destroy(int $commentId): JsonResponse
    {
        $comment = ArticleComment::find($commentId);

        if (! $comment) {
            return response()->json([
                'success' => false,
                'message' => 'Comment not found',
            ], 404);
        }

        if ($comment->user_id !== auth()->id()) {
            return response()->json([
                'success' => false,
                'message' => 'Forbidden',
            ], 403);
        }

        $comment->delete();

        return response()->json([
            'success' => true,
            'message' => 'Comment deleted',
        ]);
    }

    // ── POST /api/comments/{commentId}/like ───────────────────────────────────

    /**
     * Toggle like/unlike on a comment.
     *
     * POST /api/comments/{commentId}/like
     * Returns updated like count and the new `is_liked` state.
     */
    public function toggleLike(int $commentId): JsonResponse
    {
        $comment = ArticleComment::find($commentId);

        if (! $comment) {
            return response()->json([
                'success' => false,
                'message' => 'Comment not found',
            ], 404);
        }

        $userId    = auth()->id();
        $alreadyLiked = $comment->likedBy()->where('user_id', $userId)->exists();

        if ($alreadyLiked) {
            $comment->likedBy()->detach($userId);
            $comment->decrement('likes');
            $isLiked = false;
        } else {
            $comment->likedBy()->attach($userId);
            $comment->increment('likes');
            $isLiked = true;
        }

        $comment->refresh();

        return response()->json([
            'success'  => true,
            'data'     => [
                'comment_id' => $comment->id,
                'likes'      => $comment->likes,
                'is_liked'   => $isLiked,
            ],
        ]);
    }
}
