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
        Schema::table('users', function (Blueprint $table) {
            // Stores the path/URL of the user's profile image (nullable)
            $table->string('profile_image')->nullable()->after('email');

            // 6-character uppercase alphanumeric API key, unique per user
            $table->string('api_key', 6)->nullable()->unique()->after('profile_image');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropColumn(['profile_image', 'api_key']);
        });
    }
};
