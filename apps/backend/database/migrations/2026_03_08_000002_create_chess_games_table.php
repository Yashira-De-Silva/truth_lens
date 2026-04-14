<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('chess_games', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('white_player_id');
            $table->unsignedBigInteger('black_player_id');
            $table->text('fen');
            $table->json('moves')->nullable();          // array of "e2e4" notation
            $table->enum('status', ['waiting', 'active', 'finished', 'declined'])->default('waiting');
            $table->unsignedBigInteger('winner_id')->nullable();
            $table->enum('result', ['white', 'black', 'draw'])->nullable();
            $table->timestamps();

            $table->foreign('white_player_id')->references('id')->on('users')->onDelete('cascade');
            $table->foreign('black_player_id')->references('id')->on('users')->onDelete('cascade');
            $table->foreign('winner_id')->references('id')->on('users')->onDelete('set null');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('chess_games');
    }
};
