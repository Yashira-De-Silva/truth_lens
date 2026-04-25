<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Support\Str;

class Conversation extends Model
{
    protected $fillable = ['conversation_id', 'user1_id', 'user2_id'];

    protected static function booted(): void
    {
        static::creating(function (Conversation $conv) {
            if (empty($conv->conversation_id)) {
                $conv->conversation_id = (string) Str::uuid();
            }
        });
    }

    public function user1(): BelongsTo
    {
        return $this->belongsTo(User::class, 'user1_id');
    }

    public function user2(): BelongsTo
    {
        return $this->belongsTo(User::class, 'user2_id');
    }

    public function messages(): HasMany
    {
        return $this->hasMany(Message::class, 'conversation_id');
    }

    public function lastMessage(): HasMany
    {
        return $this->hasMany(Message::class, 'conversation_id')
            ->orderByDesc('created_at')
            ->limit(1);
    }

    public function otherUser(int $userId): User
    {
        return $this->user1_id === $userId ? $this->user2 : $this->user1;
    }
}
