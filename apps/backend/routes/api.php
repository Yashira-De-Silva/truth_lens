<?php

use App\Http\Controllers\AuthController;
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
});
