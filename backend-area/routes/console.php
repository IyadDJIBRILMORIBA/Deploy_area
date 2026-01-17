<?php

use Illuminate\Foundation\Inspiring;
use Illuminate\Support\Facades\Artisan;
use Illuminate\Support\Facades\Schedule;

Artisan::command('inspire', function () {
    $this->comment(Inspiring::quote());
})->purpose('Display an inspiring quote');

// AREA Scheduling : Exécute le moteur AREA TOUTES LES MINUTES
Schedule::command('areas:engine')
    ->everyMinute()
    //->withoutOverlapping() // Évite les exécutions parallèles
    //->onFailure(function () {
    //    \Log::error('[AREA Scheduler] Erreur lors de l\'exécution du scheduler');
    //})
   ->onSuccess(function () {
        //Log optionnel du succès (décommentez si souhaité)
        \Log::info('[AREA Scheduler] Exécution réussie');
   });