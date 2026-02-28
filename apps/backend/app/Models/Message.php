<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Message extends Model
{
    protected $fillable = [
        'conversation_id',
        'customer_id',
        'content',
        'type',
        'attachments',
        'metadata',
        'reply_to_message_id',
        'is_edited',
        'edited_at',
        'deleted_by_users',
        'deleted_for_everyone',
        'deleted_for_everyone_at',
    ];

    protected $casts = [
        'attachments'             => 'array',
        'metadata'                => 'array',
        'deleted_by_users'        => 'array',
        'is_edited'               => 'boolean',
        'deleted_for_everyone'    => 'boolean',
        'edited_at'               => 'datetime',
        'deleted_for_everyone_at' => 'datetime',
    ];

    public function sender(): BelongsTo
    {
        return $this->belongsTo(User::class, 'customer_id');
    }

    public function conversation(): BelongsTo
    {
        return $this->belongsTo(Conversation::class, 'conversation_id');
    }

    public function replyTo(): BelongsTo
    {
        return $this->belongsTo(Message::class, 'reply_to_message_id');
    }

    /** Whether this message was soft-deleted for a specific user ID. */
    public function isDeletedForUser(int $userId): bool
    {
        return in_array($userId, $this->deleted_by_users ?? [], true);
    }
}
