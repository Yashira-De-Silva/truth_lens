<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;

class ArticleComment extends Model
{
    protected $table = 'article_comments';

    protected $fillable = [
        'article_id',
        'user_id',
        'body',
        'likes',
    ];

    protected $casts = [
        'likes' => 'integer',
    ];

    // ── Relationships ─────────────────────────────────────────────────────────

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    /** Users who liked this comment (pivot: comment_likes). */
    public function likedBy(): BelongsToMany
    {
        return $this->belongsToMany(User::class, 'comment_likes', 'comment_id', 'user_id')
                    ->withTimestamps();
    }
}
