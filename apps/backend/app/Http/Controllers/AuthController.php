<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;
use Tymon\JWTAuth\Facades\JWTAuth;
use Tymon\JWTAuth\Exceptions\JWTException;
use Illuminate\Support\Facades\Storage;

class AuthController extends Controller
{
    private function generateApiKey(): string
    {
        do {
            $key = strtoupper(substr(str_shuffle('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'), 0, 6));
        } while (User::where('api_key', $key)->exists());

        return $key;
    }
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

        try {
            $token = JWTAuth::fromUser($user);
        } catch (\Throwable $e) {
            return response()->json([
                'success' => false,
                'message' => 'Token creation failed: ' . $e->getMessage(),
            ], 500);
        }

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
        } catch (\Throwable $e) {
            return response()->json([
                'success' => false,
                'message' => 'Authentication failed: ' . $e->getMessage(),
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
    public function logout(): JsonResponse
    {
        try {
            JWTAuth::invalidate(JWTAuth::getToken());
        } catch (\Throwable $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to logout: ' . $e->getMessage(),
            ], 500);
        }

        return response()->json([
            'success' => true,
            'message' => 'Logged out successfully',
        ]);
    }
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
    public function me(): JsonResponse
    {
        $user = auth()->user();
        if ($user) {
            $user->load(['activities' => function($query) {
                $query->orderBy('created_at', 'desc')->limit(15);
            }]);
        }

        return response()->json([
            'success' => true,
            'data'    => $user,
        ]);
    }
    public function updateProfile(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'name'          => 'sometimes|string|max:255',
            'bio'           => 'sometimes|nullable|string|max:500',
            'profile_image' => 'sometimes|nullable|image|mimes:jpeg,png,jpg,gif|max:2048',
            'remove_image'  => 'sometimes|boolean',
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

        if ($request->has('name')) {
            $user->name = $request->name;
        }
        
        if ($request->has('bio')) {
            $user->bio = $request->bio;
        }

        if ($request->boolean('remove_image')) {
            if ($user->profile_image) {
                $oldPath = str_replace(url('storage/'), '', $user->profile_image);
                Storage::disk('public')->delete($oldPath);
            }
            $user->profile_image = null;
        } elseif ($request->hasFile('profile_image')) {
            if ($user->profile_image) {
                $oldPath = str_replace(url('storage/'), '', $user->profile_image);
                Storage::disk('public')->delete($oldPath);
            }

            $path = $request->file('profile_image')->store('profile_images', 'public');
            $user->profile_image = url('storage/' . $path);
        }

        $user->save();

        return response()->json([
            'success' => true,
            'message' => 'Profile updated successfully',
            'data'    => $user->fresh(),
        ]);
    }
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
