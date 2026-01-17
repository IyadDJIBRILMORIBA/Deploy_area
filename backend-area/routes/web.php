<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\AboutController;

// CSRF pour le frontend Web (pas utilisé par Flutter)
Route::get('/sanctum/csrf-cookie', [\Laravel\Sanctum\Http\Controllers\CsrfCookieController::class, 'show']);

// OAuth Google (Web)
Route::get('/auth/google/redirect', [AuthController::class, 'redirectToGoogle']);
Route::get('/auth/google/callback', [AuthController::class, 'handleGoogleCallback']);

// About endpoint (accessible sans /api)
Route::get('/about.json', [AboutController::class, 'getAbout']);

Route::get('/', function () {
    return "Backend AREA OK — <a href='/auth/google/redirect'>Connexion Google Web</a>";
});
