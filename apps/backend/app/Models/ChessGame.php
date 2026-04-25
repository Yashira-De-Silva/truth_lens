<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class ChessGame extends Model
{
    protected $fillable = [
        'white_player_id', 'black_player_id',
        'fen', 'moves', 'status', 'winner_id', 'result',
    ];

    protected $casts = [
        'moves' => 'array',
    ];

    public function whitePlayer(): BelongsTo
    {
        return $this->belongsTo(User::class, 'white_player_id');
    }

    public function blackPlayer(): BelongsTo
    {
        return $this->belongsTo(User::class, 'black_player_id');
    }

    public function winner(): BelongsTo
    {
        return $this->belongsTo(User::class, 'winner_id');
    }

    public function hasPlayer(int $userId): bool
    {
        return $this->white_player_id === $userId || $this->black_player_id === $userId;
    }

    /** Return 'white' | 'black' | null for the given player. */
    public function colorFor(int $userId): ?string
    {
        if ($this->white_player_id === $userId) return 'white';
        if ($this->black_player_id === $userId) return 'black';
        return null;
    }
}
