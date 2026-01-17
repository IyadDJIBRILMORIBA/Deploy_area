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
            //
            $table->string('password')->nullable()->change(); // Rendre le mdp nullable
            $table->string('google_id')->unique()->nullable();
            $table->text('google_token')->nullable();
            $table->text('google_refresh_token')->nullable();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            //
            $table->string('password')->nullable(false)->change();
            $table->dropColumn(['google_id', 'google_token', 'google_refresh_token']);
        });
    }
};
