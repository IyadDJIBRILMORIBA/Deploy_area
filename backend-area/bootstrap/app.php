<?php

use Illuminate\Foundation\Application;
use Illuminate\Foundation\Configuration\Exceptions;
use Illuminate\Foundation\Configuration\Middleware;

return Application::configure(basePath: dirname(__DIR__))
    ->withRouting(
        web: __DIR__.'/../routes/web.php',
        api: __DIR__.'/../routes/api.php',
        commands: __DIR__.'/../routes/console.php',
        health: '/up',
    )
    ->withMiddleware(function (Middleware $middleware) {
        // Pas de middleware EnsureFrontendRequestsAreStateful pour l'API
        // On utilise uniquement l'authentification Bearer token via Sanctum
        
        // Supprimer le throttle par défaut pour les routes API
        $middleware->api(remove: [
            \Illuminate\Routing\Middleware\ThrottleRequests::class,
        ]);
        
        $middleware->redirectGuestsTo(fn () => null); // No redirect for unauthenticated users
    })
    ->withExceptions(function (Exceptions $exceptions) {
        //
    })->create();