<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('news_articles', function (Blueprint $Blueprint) {
            $Blueprint->id();
            $Blueprint->string('title', 500);
            $Blueprint->text('text');
            $Blueprint->string('subject')->nullable();
            $Blueprint->string('date')->nullable();
            $Blueprint->boolean('is_fake')->default(false);
            $Blueprint->timestamps();
            
            // Optimization for the Flutter feed
            $Blueprint->index('is_fake');
            $Blueprint->index('created_at');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('news_articles');
    }
};
