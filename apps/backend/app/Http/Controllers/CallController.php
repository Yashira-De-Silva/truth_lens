<?php

namespace App\Http\Controllers;

use App\Models\Call;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class CallController extends Controller
{
    public function initiate(Request $request)
    {
        $request->validate([
            'receiver_id' => 'required|integer|exists:users,id',
            'type' => 'nullable|string|in:audio,video'
        ]);

        $caller = Auth::user();
        Call::where(function($q) use ($caller, $request) {
            $q->where('caller_id', $caller->id)
              ->orWhere('receiver_id', $caller->id)
              ->orWhere('caller_id', $request->receiver_id)
              ->orWhere('receiver_id', $request->receiver_id);
        })->whereIn('status', ['ringing', 'answered'])->update(['status' => 'ended']);

        $call = Call::create([
            'caller_id' => $caller->id,
            'receiver_id' => $request->receiver_id,
            'status' => 'ringing',
            'type' => $request->type ?? 'audio',
        ]);

        $call->load(['caller', 'receiver']);

        return response()->json([
            'success' => true,
            'data' => clone $call
        ]);
    }

    public function getActive()
    {
        $user = Auth::user();

        // Check if there is an active call for this user
        $call = Call::where(function($query) use ($user) {
                $query->where('caller_id', $user->id)
                      ->orWhere('receiver_id', $user->id);
            })
            ->whereIn('status', ['ringing', 'answered'])
            ->with(['caller', 'receiver'])
            ->latest()
            ->first();

        // Also fetch recently ended calls within the last 15 seconds to allow the client to process the disconnect
        if (!$call) {
             $call = Call::where(function($query) use ($user) {
                $query->where('caller_id', $user->id)
                      ->orWhere('receiver_id', $user->id);
            })
            ->whereIn('status', ['ended', 'rejected'])
            ->where('updated_at', '>=', now()->subSeconds(15))
            ->with(['caller', 'receiver'])
            ->latest()
            ->first();
        }

        return response()->json([
            'success' => true,
            'data' => $call
        ]);
    }

    public function updateStatus(Request $request, $id)
    {
        $request->validate([
            'status' => 'required|string|in:answered,rejected,ended'
        ]);

        $call = Call::findOrFail($id);
        $user = Auth::user();

        // Only participants can update
        if ($call->caller_id !== $user->id && $call->receiver_id !== $user->id) {
            return response()->json(['success' => false, 'message' => 'Unauthorized'], 403);
        }

        $call->status = $request->status;
        $call->save();

        return response()->json([
            'success' => true,
            'data' => $call
        ]);
    }
}
