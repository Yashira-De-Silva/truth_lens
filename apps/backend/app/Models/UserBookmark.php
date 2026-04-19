<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class UserBookmark extends Model
{
    protected $fillable = [
        'user_id',
        'article_id',
        'title',
        'source',
        'summary',
        'raw_data',
    ];

    protected $casts = [
        'raw_data' => 'array',
    ];

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}
