<?php

use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| Debug Routes (PRODUCTION - À supprimer après debug)
|--------------------------------------------------------------------------
*/

Route::get('/debug/env', function () {
    if (app()->environment('production')) {
        return response()->json([
            'DB_CONNECTION' => env('DB_CONNECTION'),
            'DB_HOST' => env('DB_HOST'),
            'DB_PORT' => env('DB_PORT'),
            'DB_DATABASE' => env('DB_DATABASE'),
            'DB_USERNAME' => env('DB_USERNAME'),
            'DB_PASSWORD' => env('DB_PASSWORD') ? '***SET***' : '***NOT SET***',
            'APP_ENV' => env('APP_ENV'),
            'APP_URL' => env('APP_URL'),
        ]);
    }
    
    return response()->json(['error' => 'Only available in production']);
});

Route::get('/debug/db-test', function () {
    try {
        \DB::connection()->getPdo();
        return response()->json([
            'status' => 'success',
            'message' => 'Database connection successful',
            'driver' => config('database.default'),
            'host' => config('database.connections.pgsql.host'),
            'database' => config('database.connections.pgsql.database'),
        ]);
    } catch (\Exception $e) {
        return response()->json([
            'status' => 'error',
            'message' => $e->getMessage(),
            'driver' => config('database.default'),
            'host' => config('database.connections.pgsql.host'),
            'database' => config('database.connections.pgsql.database'),
        ], 500);
    }
});
