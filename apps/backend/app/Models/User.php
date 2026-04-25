<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Tymon\JWTAuth\Contracts\JWTSubject;

class User extends Authenticatable implements JWTSubject
{
    /** @use HasFactory<\Database\Factories\UserFactory> */
    use HasFactory, Notifiable;

    /**
     * The attributes that are mass assignable.
     *
     * @var list<string>
     */
    protected $fillable = [
        'name',
        'email',
        'password',
        'profile_image',
        'api_key',
        'bio',
        'is_premium',
    ];

    /**
     * The attributes that should be hidden for serialization.
     *
     * @var list<string>
     */
    protected $hidden = [
        'password',
        'remember_token',
    ];

    /**
     * Get the attributes that should be cast.
     *
     * @return array<string, string>
     */
    protected $casts = [
        'email_verified_at' => 'datetime',
        'password' => 'hashed',
        'is_premium' => 'boolean',
    ];

    protected $appends = [
        'articles_read_count',
        'comments_count',
        'bookmarks_count',
        'followers_count',
        'following_count',
    ];

    // ── Relationships ────────────────────────────────────────────────────────

    public function activities()
    {
        return $this->hasMany(UserActivity::class);
    }

    public function bookmarks()
    {
        return $this->hasMany(UserBookmark::class);
    }

    public function articleComments()
    {
        return $this->hasMany(ArticleComment::class);
    }

    public function followers()
    {
        return $this->belongsToMany(User::class, 'follows', 'following_id', 'follower_id');
    }

    public function followings()
    {
        return $this->belongsToMany(User::class, 'follows', 'follower_id', 'following_id');
    }

    // ── Accessors ────────────────────────────────────────────────────────────

    public function getArticlesReadCountAttribute(): int
    {
        return $this->activities()->where('type', 'read')->distinct('article_id')->count();
    }

    public function getCommentsCountAttribute(): int
    {
        return $this->articleComments()->count();
    }

    public function getBookmarksCountAttribute(): int
    {
        return $this->bookmarks()->count();
    }

    public function getFollowersCountAttribute(): int
    {
        return $this->followers()->count();
    }

    public function getFollowingCountAttribute(): int
    {
        return $this->followings()->count();
    }

    // ── JWTSubject ──────────────────────────────────────────────────────────

    public function getJWTIdentifier()
    {
        return $this->getKey();
    }

    public function getJWTCustomClaims(): array
    {
        return [];
    }
}
