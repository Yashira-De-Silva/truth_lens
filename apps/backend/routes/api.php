<?php

use App\Http\Controllers\AuthController;
use App\Http\Controllers\ChatController;
use App\Http\Controllers\CommentController;
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
| Comment endpoints (protected):
|   GET    /api/articles/{articleId}/comments          – list comments
|   POST   /api/articles/{articleId}/comments          – add comment
|   DELETE /api/comments/{commentId}                   – delete own comment
|   POST   /api/comments/{commentId}/like              – toggle like
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

        // Chat
        Route::prefix('chat')->group(function () {
            Route::get('/users',                                      [ChatController::class, 'users']);
            Route::post('/conversations',                             [ChatController::class, 'getOrCreateConversation']);
            Route::get('/conversations',                              [ChatController::class, 'conversations']);
            Route::get('/conversations/{conversationId}/messages',    [ChatController::class, 'messages']);
            Route::post('/conversations/{conversationId}/messages',   [ChatController::class, 'sendMessage']);
            Route::post('/conversations/{conversationId}/read',       [ChatController::class, 'markRead']);
            Route::delete('/messages/{messageId}',                    [ChatController::class, 'deleteMessage']);
        });

        // Comments
        Route::get('/articles/{articleId}/comments',  [CommentController::class, 'index']);
        Route::post('/articles/{articleId}/comments', [CommentController::class, 'store']);
        Route::delete('/comments/{commentId}',        [CommentController::class, 'destroy']);
        Route::post('/comments/{commentId}/like',     [CommentController::class, 'toggleLike']);
    });