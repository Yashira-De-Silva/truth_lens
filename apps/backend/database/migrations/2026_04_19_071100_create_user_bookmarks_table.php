<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('user_bookmarks', function (Blueprint $blueprint) {
            $blueprint->id();
            $blueprint->foreignId('user_id')->constrained()->onDelete('cascade');
            $blueprint->unsignedBigInteger('article_id'); // External ID or local news table ID
            $blueprint->string('title')->nullable();
            $blueprint->string('source')->nullable();
            $blueprint->text('summary')->nullable();
            $blueprint->json('raw_data')->nullable(); // Store more data if needed
            $blueprint->timestamps();

            $blueprint->unique(['user_id', 'article_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('user_bookmarks');
    }
};
