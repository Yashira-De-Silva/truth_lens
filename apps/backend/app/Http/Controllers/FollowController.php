<?php

namespace App\Http\Controllers;

use App\Models\Follow;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class FollowController extends Controller
{
    // ── Follow a user ─────────────────────────────────────────────────────────

    /**
     * POST /api/follow/{userId}
     * Authenticated user follows the given user.
     */
    public function follow(int $userId): JsonResponse
    {
        $me = auth()->id();

        if ($me === $userId) {
            return response()->json(['success' => false, 'message' => 'You cannot follow yourself.'], 422);
        }

        if (!User::find($userId)) {
            return response()->json(['success' => false, 'message' => 'User not found.'], 404);
        }

        Follow::firstOrCreate([
            'follower_id'  => $me,
            'following_id' => $userId,
        ]);

        $isFollowingBack = Follow::where('follower_id', $userId)
            ->where('following_id', $me)
            ->exists();

        return response()->json([
            'success'          => true,
            'message'          => 'Followed successfully.',
            'is_following'     => true,
            'is_mutual'        => $isFollowingBack,
        ]);
    }

    // ── Unfollow a user ───────────────────────────────────────────────────────

    /**
     * DELETE /api/follow/{userId}
     * Authenticated user unfollows the given user.
     */
    public function unfollow(int $userId): JsonResponse
    {
        $me = auth()->id();

        Follow::where('follower_id', $me)
            ->where('following_id', $userId)
            ->delete();

        return response()->json([
            'success'      => true,
            'message'      => 'Unfollowed successfully.',
            'is_following' => false,
            'is_mutual'    => false,
        ]);
    }

    // ── Follow status ─────────────────────────────────────────────────────────

    /**
     * GET /api/follow/status/{userId}
     * Returns whether I follow them AND whether they follow me back.
     */
    public function status(int $userId): JsonResponse
    {
        $me = auth()->id();

        $iFollow     = Follow::where('follower_id', $me)->where('following_id', $userId)->exists();
        $theyFollow  = Follow::where('follower_id', $userId)->where('following_id', $me)->exists();

        return response()->json([
            'success'      => true,
            'is_following' => $iFollow,
            'is_mutual'    => $iFollow && $theyFollow,
        ]);
    }

    // ── My followers ──────────────────────────────────────────────────────────

    /**
     * GET /api/followers
     * Users who follow the authenticated user.
     */
    public function followers(): JsonResponse
    {
        $me = auth()->id();

        $followers = Follow::where('following_id', $me)
            ->with('follower:id,name,email,profile_image')
            ->get()
            ->map(fn($f) => $f->follower);

        return response()->json(['success' => true, 'data' => $followers]);
    }

    // ── Who I follow ──────────────────────────────────────────────────────────

    /**
     * GET /api/following
     * Users the authenticated user follows.
     */
    public function following(): JsonResponse
    {
        $me = auth()->id();

        $following = Follow::where('follower_id', $me)
            ->with('following:id,name,email,profile_image')
            ->get()
            ->map(fn($f) => $f->following);

        return response()->json(['success' => true, 'data' => $following]);
    }

    // ── Public profile ────────────────────────────────────────────────────────

    /**
     * GET /api/users/{userId}/profile
     * Returns a user's public profile including follower counts and follow status.
     */
    public function publicProfile(int $userId): JsonResponse
    {
        $user = User::select('id', 'name', 'email', 'bio', 'profile_image')->find($userId);

        if (!$user) {
            return response()->json(['success' => false, 'message' => 'User not found.'], 404);
        }

        $me             = auth()->id();
        $followersCount = Follow::where('following_id', $userId)->count();
        $followingCount = Follow::where('follower_id', $userId)->count();
        $iFollow        = Follow::where('follower_id', $me)->where('following_id', $userId)->exists();
        $theyFollow     = Follow::where('follower_id', $userId)->where('following_id', $me)->exists();

        return response()->json([
            'success' => true,
            'data'    => [
                'id'              => $user->id,
                'name'            => $user->name,
                'email'           => $user->email,
                'bio'             => $user->bio,
                'profile_image'   => $user->profile_image,
                'followers_count' => $followersCount,
                'following_count' => $followingCount,
                'is_following'    => $iFollow,
                'is_mutual'       => $iFollow && $theyFollow,
                'articles_read_count' => $user->articles_read_count,
                'comments_count'      => $user->comments_count,
                'bookmarks_count'     => $user->bookmarks_count,
                'activities'          => $user->activities()->latest()->limit(10)->get(),
            ],
        ]);
    }
}
