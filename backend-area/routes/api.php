<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\CalendarController;
use App\Http\Controllers\AboutController;
use App\Http\Controllers\AreaController;
use App\Http\Controllers\ServiceController;
use App\Http\Controllers\DashboardController;
use App\Http\Controllers\ActivityController;

// Routes Publiques
Route::get('/health', function () {
    try {
        \DB::connection()->getPdo();
        $dbStatus = 'connected';
    } catch (\Exception $e) {
        $dbStatus = 'disconnected';
    }
    
    return response()->json([
        'status' => 'healthy',
        'service' => 'AREA Backend',
        'database' => $dbStatus,
        'timestamp' => now()->toIso8601String(),
    ]);
});

Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);
Route::post('/auth/google', [AuthController::class, 'googleAuth']); // ✅ Changé de googleMobileLogin à googleAuth

// About endpoint
Route::get('/about.json', [AboutController::class, 'getAbout']);

// OAuth callbacks pour les services (Google redirige ici, pas de token Sanctum)
Route::get('/services/{service}/callback', [ServiceController::class, 'handleServiceCallback']);

// Webhooks (public, pas de auth)
Route::post('/webhooks/github', [ServiceController::class, 'handleGithubWebhook']);

Route::middleware('auth:sanctum')->group(function () {
    Route::get('/user', [AuthController::class, 'user']);
    Route::put('/user/update', [AuthController::class, 'updateProfile']);
    Route::delete('/user/delete', [AuthController::class, 'deleteAccount']);
    Route::get('/calendar-events', [CalendarController::class, 'getEvents']);
    Route::post('/logout', [AuthController::class, 'logout']);
    
    // Services
    Route::get('/services', [ServiceController::class, 'index']);
    Route::get('/services/{serviceId}', [ServiceController::class, 'show']);
    Route::match(['get', 'post'], '/services/{serviceId}/connect', [ServiceController::class, 'connect']);
    Route::delete('/services/{serviceId}/disconnect', [ServiceController::class, 'disconnect']);
    Route::get('/user/services', [ServiceController::class, 'getUserServices']);
    
    // AREAs CRUD
    Route::get('/areas', [AreaController::class, 'index']);
    Route::post('/areas', [AreaController::class, 'store']);
    Route::get('/areas/{id}', [AreaController::class, 'show']);
    Route::put('/areas/{id}', [AreaController::class, 'update']);
    Route::delete('/areas/{id}', [AreaController::class, 'destroy']);
    Route::post('/areas/{id}/toggle', [AreaController::class, 'toggle']);
    
    // Dashboard (routes mobile)
    Route::get('/dashboard', [DashboardController::class, 'index']);
    Route::get('/dashboard/summary', [DashboardController::class, 'summary']);
    
    // Activities / Logs (routes mobile)
    Route::get('/activities', [ActivityController::class, 'index']);
    Route::get('/activities/statistics', [ActivityController::class, 'statistics']);
    Route::get('/activities/area/{areaId}', [ActivityController::class, 'getAreaActivities']);
    Route::delete('/activities/{id}', [ActivityController::class, 'destroy']);
    Route::delete('/activities', [ActivityController::class, 'clear']);
});

