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
        // Table pour lister les services disponibles (Google, Discord...)
        Schema::create('services', function (Blueprint $table) {
            $table->id();
            $table->string('name'); // "google", "discord"
            $table->string('icon')->nullable();
            $table->boolean('is_active')->default(true);
            $table->timestamps();
        });

        // Table pour lier les comptes utilisateurs aux services (Tokens)
        Schema::create('user_services', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->foreignId('service_id')->constrained()->onDelete('cascade');
            $table->string('provider_id')->nullable(); // ID chez Google/Discord
            $table->text('access_token');
            $table->text('refresh_token')->nullable();
            $table->timestamp('expires_at')->nullable();
            $table->string('name')->nullable(); // ex: "Compte Perso"
            $table->timestamps();
        });

        // Table des AREAs (Automatisations)
        Schema::create('areas', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->string('name'); // ex: "Sync Calendar to Discord"
            $table->boolean('is_active')->default(true);
            // Trigger (Action)
            $table->string('trigger_service'); // "google"
            $table->string('trigger_action');  // "new_event"
            $table->json('trigger_params')->nullable(); // { "calendar_id": "primary" }
            // Action (Réaction)
            $table->string('action_service'); // "discord"
            $table->string('action_reaction'); // "send_message"
            $table->json('action_params')->nullable(); // { "channel_id": "12345" }
            $table->timestamps();
        });

        // Historique pour le Dashboard
        Schema::create('area_logs', function (Blueprint $table) {
            $table->id();
            $table->foreignId('area_id')->constrained()->onDelete('cascade');
            $table->string('status'); // "success", "error"
            $table->text('message')->nullable();
            $table->timestamps();
        });

        // Schema::create('area_tables', function (Blueprint $table) {
        //     $table->id();
        //     $table->timestamps();
        // });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        // On supprime dans l'ordre inverse de la création pour respecter les clés étrangères
        Schema::dropIfExists('area_logs');
        Schema::dropIfExists('areas');
        Schema::dropIfExists('user_services');
        Schema::dropIfExists('services');
    }
};
