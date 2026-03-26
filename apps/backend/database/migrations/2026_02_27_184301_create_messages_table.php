<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('messages', function (Blueprint $table) {
            $table->id();
            $table->foreignId('conversation_id')->constrained('conversations')->cascadeOnDelete();
            $table->foreignId('customer_id')->constrained('users')->cascadeOnDelete();   // sender
            $table->text('content');                                                       // message body
            $table->string('type')->default('text');                                       // text | image | file | etc.
            $table->json('attachments')->nullable();                                       // array of attachment objects
            $table->json('metadata')->nullable();                                          // read receipts, reactions, etc.
            $table->foreignId('reply_to_message_id')->nullable()->constrained('messages')->nullOnDelete();
            $table->boolean('is_edited')->default(false);
            $table->timestamp('edited_at')->nullable();
            $table->json('deleted_by_users')->nullable();                                  // array of user IDs who deleted for themselves
            $table->boolean('deleted_for_everyone')->default(false);
            $table->timestamp('deleted_for_everyone_at')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('messages');
    }
};
