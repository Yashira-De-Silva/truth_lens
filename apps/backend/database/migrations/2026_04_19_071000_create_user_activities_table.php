<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('user_activities', function (Blueprint $blueprint) {
            $blueprint->id();
            $blueprint->foreignId('user_id')->constrained()->onDelete('cascade');
            $blueprint->string('type'); // 'read', 'bookmark', 'comment'
            $blueprint->unsignedBigInteger('article_id')->nullable();
            $blueprint->unsignedBigInteger('reference_id')->nullable(); // e.g. comment_id
            $blueprint->string('description')->nullable();
            $blueprint->timestamps();

            $blueprint->index(['user_id', 'type']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('user_activities');
    }
};
