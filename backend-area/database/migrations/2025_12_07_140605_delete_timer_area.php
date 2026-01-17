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
        // Supprimer l'AREA ID 4 (timer-email-test)
        \DB::table('areas')->where('id', 4)->delete();
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        // Restaurer l'AREA si nécessaire
        \DB::table('areas')->insert([
            'id' => 4,
            'user_id' => 2,
            'name' => 'timer-email-test',
            'trigger' => 'timer',
            'trigger_params' => json_encode(['interval' => 'every_minute']),
            'action' => 'gmail',
            'action_name' => 'send_email',
            'action_params' => json_encode(['to' => 'doloresahouangbe@gmail.com', 'subject' => 'Test Email', 'body' => 'This is a test email']),
            'created_at' => now(),
            'updated_at' => now(),
        ]);
    }
};
