<?php

namespace App\Http\Controllers;

use App\Models\UserBookmark;
use App\Models\UserActivity;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class BookmarkController extends Controller
{
    public function index(): JsonResponse
    {
        $user = auth()->user();
        $bookmarks = UserBookmark::where('user_id', $user->id)
            ->orderBy('created_at', 'desc')
            ->get();

        return response()->json([
            'success' => true,
            'data'    => $bookmarks,
        ]);
    }
    public function store(Request $request): JsonResponse
    {
        $request->validate([
            'article_id' => 'required',
            'title'      => 'required|string',
            'source'     => 'nullable|string',
            'summary'    => 'nullable|string',
            'raw_data'   => 'nullable|array',
        ]);

        $user = auth()->user();

        $bookmark = UserBookmark::updateOrCreate(
            ['user_id' => $user->id, 'article_id' => $request->article_id],
            $request->only(['title', 'source', 'summary', 'raw_data'])
        );
        UserActivity::create([
            'user_id'     => $user->id,
            'type'        => 'bookmark',
            'article_id'  => $request->article_id,
            'description' => 'Bookmarked: ' . $request->title,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Bookmark saved successfully',
            'data'    => $bookmark,
        ]);
    }
    public function destroy($article_id): JsonResponse
    {
        $user = auth()->user();
        UserBookmark::where('user_id', $user->id)
            ->where('article_id', $article_id)
            ->delete();

        return response()->json([
            'success' => true,
            'message' => 'Bookmark removed successfully',
        ]);
    }
}
