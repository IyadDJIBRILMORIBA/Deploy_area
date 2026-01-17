<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Area;
use App\Models\AreaLog;
use Illuminate\Support\Facades\DB;

class DashboardController extends Controller
{
    /**
     * Récupère les statistiques du dashboard pour l'utilisateur connecté
     * 
     * @return \Illuminate\Http\JsonResponse
     */
    public function index(Request $request)
    {
        $user = $request->user();
        
        // Statistiques générales
        $totalAreas = Area::where('user_id', $user->id)->count();
        $activeAreas = Area::where('user_id', $user->id)
            ->where('is_active', true)
            ->count();
        $inactiveAreas = $totalAreas - $activeAreas;
        
        // Statistiques d'exécution (7 derniers jours)
        $sevenDaysAgo = now()->subDays(7);
        
        $totalExecutions = AreaLog::whereHas('area', function($query) use ($user) {
            $query->where('user_id', $user->id);
        })->where('created_at', '>=', $sevenDaysAgo)->count();
        
        $successfulExecutions = AreaLog::whereHas('area', function($query) use ($user) {
            $query->where('user_id', $user->id);
        })
        ->where('status', 'success')
        ->where('created_at', '>=', $sevenDaysAgo)
        ->count();
        
        $failedExecutions = AreaLog::whereHas('area', function($query) use ($user) {
            $query->where('user_id', $user->id);
        })
        ->where('status', 'error')
        ->where('created_at', '>=', $sevenDaysAgo)
        ->count();
        
        // Services connectés
        $connectedServices = $user->services()->count();
        
        // AREAs les plus actives (top 5)
        $mostActiveAreas = Area::where('user_id', $user->id)
            ->withCount(['logs' => function($query) use ($sevenDaysAgo) {
                $query->where('created_at', '>=', $sevenDaysAgo);
            }])
            ->orderBy('logs_count', 'desc')
            ->limit(5)
            ->get()
            ->map(function($area) {
                return [
                    'id' => $area->id,
                    'name' => $area->name,
                    'trigger_service' => $area->trigger_service,
                    'action_service' => $area->action_service,
                    'executions' => $area->logs_count,
                    'is_active' => $area->is_active,
                ];
            });
        
        // Activités récentes (10 dernières)
        $recentActivities = AreaLog::whereHas('area', function($query) use ($user) {
            $query->where('user_id', $user->id);
        })
        ->with('area:id,name,trigger_service,action_service')
        ->orderBy('created_at', 'desc')
        ->limit(10)
        ->get()
        ->map(function($log) {
            return [
                'id' => $log->id,
                'area_id' => $log->area_id,
                'area_name' => $log->area->name ?? 'Unknown',
                'trigger_service' => $log->area->trigger_service ?? null,
                'action_service' => $log->area->action_service ?? null,
                'status' => $log->status,
                'message' => $log->message,
                'created_at' => $log->created_at->toIso8601String(),
            ];
        });
        
        // Graphique d'activité (7 derniers jours)
        $activityChart = [];
        for ($i = 6; $i >= 0; $i--) {
            $date = now()->subDays($i)->format('Y-m-d');
            $count = AreaLog::whereHas('area', function($query) use ($user) {
                $query->where('user_id', $user->id);
            })
            ->whereDate('created_at', $date)
            ->count();
            
            $activityChart[] = [
                'date' => $date,
                'executions' => $count,
            ];
        }
        
        // Services les plus utilisés
        $topServices = Area::where('user_id', $user->id)
            ->select('trigger_service', DB::raw('count(*) as count'))
            ->groupBy('trigger_service')
            ->orderBy('count', 'desc')
            ->limit(5)
            ->get()
            ->map(function($item) {
                return [
                    'service' => $item->trigger_service,
                    'count' => $item->count,
                ];
            });
        
        return response()->json([
            'success' => true,
            'data' => [
                'statistics' => [
                    'total_areas' => $totalAreas,
                    'active_areas' => $activeAreas,
                    'inactive_areas' => $inactiveAreas,
                    'connected_services' => $connectedServices,
                    'total_executions' => $totalExecutions,
                    'successful_executions' => $successfulExecutions,
                    'failed_executions' => $failedExecutions,
                    'success_rate' => $totalExecutions > 0 
                        ? round(($successfulExecutions / $totalExecutions) * 100, 1) 
                        : 0,
                ],
                'most_active_areas' => $mostActiveAreas,
                'recent_activities' => $recentActivities,
                'activity_chart' => $activityChart,
                'top_services' => $topServices,
            ],
        ]);
    }
    
    /**
     * Récupère un résumé rapide pour la page d'accueil mobile
     * 
     * @return \Illuminate\Http\JsonResponse
     */
    public function summary(Request $request)
    {
        $user = $request->user();
        
        $totalAreas = Area::where('user_id', $user->id)->count();
        $activeAreas = Area::where('user_id', $user->id)
            ->where('is_active', true)
            ->count();
        
        $todayExecutions = AreaLog::whereHas('area', function($query) use ($user) {
            $query->where('user_id', $user->id);
        })
        ->whereDate('created_at', today())
        ->count();
        
        $connectedServices = $user->services()->count();
        
        return response()->json([
            'success' => true,
            'data' => [
                'total_areas' => $totalAreas,
                'active_areas' => $activeAreas,
                'today_executions' => $todayExecutions,
                'connected_services' => $connectedServices,
            ],
        ]);
    }
}
