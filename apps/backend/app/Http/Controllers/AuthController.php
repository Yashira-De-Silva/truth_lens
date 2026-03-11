<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;
use Tymon\JWTAuth\Facades\JWTAuth;
use Tymon\JWTAuth\Exceptions\JWTException;

class AuthController extends Controller
{
    // ── Helpers ───────────────────────────────────────────────────────────────

    /**
     * Generate a unique 6-character uppercase alphanumeric API key.
     * Retries until the generated key is not already taken.
     */
    private function generateApiKey(): string
    {
        do {
            $key = strtoupper(substr(str_shuffle('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'), 0, 6));
        } while (User::where('api_key', $key)->exists());

        return $key;
    }

    // ── Register ─────────────────────────────────────────────────────────────

    /**
     * Register a new user.
     *
     * POST /api/register
     * Body: { name, email, password, password_confirmation }
     */
    public function register(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'name'     => 'required|string|max:255',
            'email'    => 'required|string|email|max:255|unique:users',
            'password' => 'required|string|min:8|confirmed',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed',
                'errors'  => $validator->errors(),
            ], 422);
        }

        $user = User::create([
            'name'     => $request->name,
            'email'    => $request->email,
            'password' => Hash::make($request->password),
            'api_key'  => $this->generateApiKey(),
        ]);

        $token = JWTAuth::fromUser($user);

        return response()->json([
            'success' => true,
            'message' => 'User registered successfully',
            'data'    => [
                'user'       => $user,
                'token'      => $token,
                'token_type' => 'bearer',
                'expires_in' => config('jwt.ttl') * 60,
            ],
        ], 201);
    }

    // ── Login ─────────────────────────────────────────────────────────────────

    /**
     * Authenticate the user and return a JWT.
     *
     * POST /api/login
     * Body: { email, password }
     */
    public function login(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'email'    => 'required|string|email',
            'password' => 'required|string',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed',
                'errors'  => $validator->errors(),
            ], 422);
        }

        $credentials = $request->only('email', 'password');

        try {
            if (!$token = JWTAuth::attempt($credentials)) {
                return response()->json([
                    'success' => false,
                    'message' => 'Invalid email or password',
                ], 401);
            }
        } catch (JWTException $e) {
            return response()->json([
                'success' => false,
                'message' => 'Could not create token',
            ], 500);
        }

        $user = auth()->user();

        return response()->json([
            'success' => true,
            'message' => 'Login successful',
            'data'    => [
                'user'       => $user,
                'token'      => $token,
                'token_type' => 'bearer',
                'expires_in' => config('jwt.ttl') * 60, // seconds
            ],
        ]);
    }

    // ── Logout ────────────────────────────────────────────────────────────────

    /**
     * Invalidate the current token (logout).
     *
     * POST /api/logout
     * Header: Authorization: Bearer <token>
     */
    public function logout(): JsonResponse
    {
        try {
            JWTAuth::invalidate(JWTAuth::getToken());
        } catch (JWTException $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to logout',
            ], 500);
        }

        return response()->json([
            'success' => true,
            'message' => 'Logged out successfully',
        ]);
    }

    // ── Refresh Token ─────────────────────────────────────────────────────────

    /**
     * Refresh the current JWT.
     *
     * POST /api/refresh
     * Header: Authorization: Bearer <token>
     */
    public function refresh(): JsonResponse
    {
        try {
            $newToken = JWTAuth::refresh(JWTAuth::getToken());
        } catch (JWTException $e) {
            return response()->json([
                'success' => false,
                'message' => 'Token cannot be refreshed',
            ], 401);
        }

        return response()->json([
            'success'    => true,
            'token'      => $newToken,
            'token_type' => 'bearer',
            'expires_in' => config('jwt.ttl') * 60,
        ]);
    }

    // ── Me ────────────────────────────────────────────────────────────────────

    /**
     * Return the authenticated user's profile.
     *
     * GET /api/me
     * Header: Authorization: Bearer <token>
     */
    public function me(): JsonResponse
    {
        return response()->json([
            'success' => true,
            'data'    => auth()->user(),
        ]);
    }

    // ── Update Profile ────────────────────────────────────────────────────────

    /**
     * Update name, bio, and/or profile_image for the authenticated user.
     *
     * PUT /api/profile
     * Header: Authorization: Bearer <token>
     * Body: { name?, bio?, profile_image? }
     */
    public function updateProfile(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'name'          => 'sometimes|string|max:255',
            'bio'           => 'sometimes|nullable|string|max:500',
            'profile_image' => 'sometimes|nullable|string|max:2048',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed',
                'errors'  => $validator->errors(),
            ], 422);
        }

        /** @var \App\Models\User $user */
        $user = auth()->user();

        $user->fill($request->only(['name', 'bio', 'profile_image']));
        $user->save();

        return response()->json([
            'success' => true,
            'message' => 'Profile updated successfully',
            'data'    => $user->fresh(),
        ]);
    }

    // ── Upgrade Premium ───────────────────────────────────────────────────────

    /**
     * Upgrade the authenticated user to a premium account.
     *
     * POST /api/upgrade-premium
     * Header: Authorization: Bearer <token>
     */
    public function upgradeToPremium(Request $request): JsonResponse
    {
        /** @var \App\Models\User $user */
        $user = auth()->user();

        $user->is_premium = true;
        $user->save();

        return response()->json([
            'success' => true,
            'message' => 'Successfully upgraded to premium',
            'data'    => $user->fresh(),
        ]);
    }

    // ── Cancel Premium ────────────────────────────────────────────────────────

    /**
     * Downgrade the authenticated user to a basic account.
     *
     * POST /api/cancel-premium
     * Header: Authorization: Bearer <token>
     */
    public function cancelPremium(Request $request): JsonResponse
    {
        /** @var \App\Models\User $user */
        $user = auth()->user();

        $user->is_premium = false;
        $user->save();

        return response()->json([
            'success' => true,
            'message' => 'Successfully canceled premium subscription',
            'data'    => $user->fresh(),
        ]);
    }
}
