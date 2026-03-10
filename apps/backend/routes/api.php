<?php

use App\Http\Controllers\AuthController;
use App\Http\Controllers\ChatController;
use App\Http\Controllers\ChessController;
use App\Http\Controllers\CommentController;
use App\Http\Controllers\FollowController;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| API Routes  –  Truth Lens
|--------------------------------------------------------------------------
|
| Public endpoints:
|   POST /api/register  – create account & receive JWT
|   POST /api/login     – authenticate & receive JWT
|
| Protected endpoints (require Authorization: Bearer <token>):
|   POST /api/logout    – invalidate token
|   POST /api/refresh   – get a new token
|   GET  /api/me        – return authenticated user
|   PUT  /api/profile   – update name/bio/profile_image
|
| Follow endpoints (protected):
|   POST   /api/follow/{userId}          – follow a user
|   DELETE /api/follow/{userId}          – unfollow a user
|   GET    /api/follow/status/{userId}   – follow status
|   GET    /api/followers                – my followers
|   GET    /api/following                – who I follow
|   GET    /api/users/{userId}/profile   – public profile with follow counts
|
| Chat endpoints (protected):
|   GET    /api/chat/users                                  – all users except self
|   POST   /api/chat/conversations                          – get or create conversation
|   GET    /api/chat/conversations                          – list my conversations
|   GET    /api/chat/conversations/{id}/messages            – fetch messages
|   POST   /api/chat/conversations/{id}/messages            – send message
|   POST   /api/chat/conversations/{id}/read               – mark as read
|   DELETE /api/chat/messages/{id}                         – delete a message
|
| Chess endpoints (protected):
|   POST   /api/chess/challenge/{userId}    – challenge a follower
|   GET    /api/chess/games                 – list my games
|   GET    /api/chess/games/{id}            – get a specific game
|   POST   /api/chess/games/{id}/accept     – accept a challenge
|   POST   /api/chess/games/{id}/decline    – decline a challenge
|   POST   /api/chess/games/{id}/move       – make a move
|   POST   /api/chess/games/{id}/resign     – resign
|   POST   /api/chess/games/{id}/finish     – report checkmate/draw
|
| Comment endpoints (protected):
|   GET    /api/articles/{articleId}/comments          – list comments
|   POST   /api/articles/{articleId}/comments          – add comment
|   DELETE /api/comments/{commentId}                   – delete own comment
|   POST   /api/comments/{commentId}/like              – toggle like
|
*/

// ── Public routes ─────────────────────────────────────────────────────────
Route::post('/register', [AuthController::class, 'register']);
Route::post('/login',    [AuthController::class, 'login']);

// ── Protected routes ──────────────────────────────────────────────────────
Route::middleware('auth:api')->group(function () {
    Route::post('/logout',        [AuthController::class, 'logout']);
    Route::post('/refresh',       [AuthController::class, 'refresh']);
    Route::get('/me',             [AuthController::class, 'me']);
    Route::put('/profile',        [AuthController::class, 'updateProfile']);
    Route::post('/upgrade-premium', [AuthController::class, 'upgradeToPremium']);

    // ── Follow / Social ───────────────────────────────────────────────────
    Route::post('/follow/{userId}',        [FollowController::class, 'follow']);
    Route::delete('/follow/{userId}',      [FollowController::class, 'unfollow']);
    Route::get('/follow/status/{userId}',  [FollowController::class, 'status']);
    Route::get('/followers',               [FollowController::class, 'followers']);
    Route::get('/following',               [FollowController::class, 'following']);
    Route::get('/users/{userId}/profile',  [FollowController::class, 'publicProfile']);

    // ── Chat ──────────────────────────────────────────────────────────────
    Route::prefix('chat')->group(function () {
        Route::get('/users',                                      [ChatController::class, 'users']);
        Route::post('/conversations',                             [ChatController::class, 'getOrCreateConversation']);
        Route::get('/conversations',                              [ChatController::class, 'conversations']);
        Route::get('/conversations/{conversationId}/messages',    [ChatController::class, 'messages']);
        Route::post('/conversations/{conversationId}/messages',   [ChatController::class, 'sendMessage']);
        Route::post('/conversations/{conversationId}/read',       [ChatController::class, 'markRead']);
        Route::delete('/messages/{messageId}',                    [ChatController::class, 'deleteMessage']);
    });

    // ── Chess ─────────────────────────────────────────────────────────────
    Route::prefix('chess')->group(function () {
        Route::post('/challenge/{userId}',   [ChessController::class, 'challenge']);
        Route::get('/games',                 [ChessController::class, 'games']);
        Route::get('/games/{id}',            [ChessController::class, 'show']);
        Route::post('/games/{id}/accept',    [ChessController::class, 'accept']);
        Route::post('/games/{id}/decline',   [ChessController::class, 'decline']);
        Route::post('/games/{id}/move',      [ChessController::class, 'move']);
        Route::post('/games/{id}/resign',    [ChessController::class, 'resign']);
        Route::post('/games/{id}/finish',    [ChessController::class, 'finish']);
    });

    // ── Comments ──────────────────────────────────────────────────────────
    Route::get('/articles/{articleId}/comments',  [CommentController::class, 'index']);
    Route::post('/articles/{articleId}/comments', [CommentController::class, 'store']);
    Route::delete('/comments/{commentId}',        [CommentController::class, 'destroy']);
    Route::post('/comments/{commentId}/like',     [CommentController::class, 'toggleLike']);
});