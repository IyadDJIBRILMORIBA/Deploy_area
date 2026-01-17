<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\AreaLog;
use App\Models\Area;

class ActivityController extends Controller
{
    /**
     * Récupère l'historique complet des activités (logs) de l'utilisateur
     * 
     * @return \Illuminate\Http\JsonResponse
     */
    public function index(Request $request)
    {
        $user = $request->user();
        
        // Paramètres de pagination
        $perPage = $request->input('per_page', 20);
        $page = $request->input('page', 1);
        
        // Filtres optionnels
        $status = $request->input('status'); // 'success' ou 'error'
        $areaId = $request->input('area_id');
        $startDate = $request->input('start_date');
        $endDate = $request->input('end_date');
        
        // Query de base
        $query = AreaLog::whereHas('area', function($q) use ($user) {
            $q->where('user_id', $user->id);
        })->with('area:id,name,trigger_service,action_service,trigger_action,action_reaction');
        
        // Appliquer les filtres
        if ($status) {
            $query->where('status', $status);
        }
        
        if ($areaId) {
            $query->where('area_id', $areaId);
        }
        
        if ($startDate) {
            $query->whereDate('created_at', '>=', $startDate);
        }
        
        if ($endDate) {
            $query->whereDate('created_at', '<=', $endDate);
        }
        
        // Récupérer les logs avec pagination
        $logs = $query->orderBy('created_at', 'desc')
            ->paginate($perPage, ['*'], 'page', $page);
        
        // Formater les résultats
        $formattedLogs = $logs->getCollection()->map(function($log) {
            return [
                'id' => $log->id,
                'area_id' => $log->area_id,
                'area_name' => $log->area->name ?? 'Unknown',
                'trigger_service' => $log->area->trigger_service ?? null,
                'trigger_action' => $log->area->trigger_action ?? null,
                'action_service' => $log->area->action_service ?? null,
                'action_reaction' => $log->area->action_reaction ?? null,
                'status' => $log->status,
                'message' => $log->message,
                'trigger_data' => $log->trigger_data ?? null,
                'created_at' => $log->created_at->toIso8601String(),
                'executed_at' => $log->created_at->format('d/m/Y H:i:s'),
            ];
        });
        
        return response()->json([
            'success' => true,
            'data' => $formattedLogs,
            'pagination' => [
                'current_page' => $logs->currentPage(),
                'last_page' => $logs->lastPage(),
                'per_page' => $logs->perPage(),
                'total' => $logs->total(),
                'from' => $logs->firstItem(),
                'to' => $logs->lastItem(),
            ],
        ]);
    }
    
    /**
     * Récupère les activités d'une AREA spécifique
     * 
     * @param int $areaId
     * @return \Illuminate\Http\JsonResponse
     */
    public function getAreaActivities(Request $request, $areaId)
    {
        $user = $request->user();
        
        // Vérifier que l'AREA appartient à l'utilisateur
        $area = Area::where('id', $areaId)
            ->where('user_id', $user->id)
            ->first();
        
        if (!$area) {
            return response()->json([
                'success' => false,
                'message' => 'AREA non trouvée ou accès non autorisé',
            ], 404);
        }
        
        $perPage = $request->input('per_page', 20);
        
        // Récupérer les logs de cette AREA
        $logs = AreaLog::where('area_id', $areaId)
            ->orderBy('created_at', 'desc')
            ->paginate($perPage);
        
        $formattedLogs = $logs->getCollection()->map(function($log) {
            return [
                'id' => $log->id,
                'status' => $log->status,
                'message' => $log->message,
                'trigger_data' => $log->trigger_data ?? null,
                'created_at' => $log->created_at->toIso8601String(),
                'executed_at' => $log->created_at->format('d/m/Y H:i:s'),
            ];
        });
        
        return response()->json([
            'success' => true,
            'area' => [
                'id' => $area->id,
                'name' => $area->name,
                'trigger_service' => $area->trigger_service,
                'action_service' => $area->action_service,
            ],
            'data' => $formattedLogs,
            'pagination' => [
                'current_page' => $logs->currentPage(),
                'last_page' => $logs->lastPage(),
                'per_page' => $logs->perPage(),
                'total' => $logs->total(),
            ],
        ]);
    }
    
    /**
     * Récupère les statistiques d'activité
     * 
     * @return \Illuminate\Http\JsonResponse
     */
    public function statistics(Request $request)
    {
        $user = $request->user();
        $days = $request->input('days', 30); // Par défaut 30 derniers jours
        
        $startDate = now()->subDays($days);
        
        // Total des exécutions
        $totalExecutions = AreaLog::whereHas('area', function($query) use ($user) {
            $query->where('user_id', $user->id);
        })
        ->where('created_at', '>=', $startDate)
        ->count();
        
        // Succès
        $successCount = AreaLog::whereHas('area', function($query) use ($user) {
            $query->where('user_id', $user->id);
        })
        ->where('status', 'success')
        ->where('created_at', '>=', $startDate)
        ->count();
        
        // Erreurs
        $errorCount = AreaLog::whereHas('area', function($query) use ($user) {
            $query->where('user_id', $user->id);
        })
        ->where('status', 'error')
        ->where('created_at', '>=', $startDate)
        ->count();
        
        // Taux de réussite
        $successRate = $totalExecutions > 0 
            ? round(($successCount / $totalExecutions) * 100, 1) 
            : 0;
        
        // Exécutions par jour
        $executionsPerDay = AreaLog::whereHas('area', function($query) use ($user) {
            $query->where('user_id', $user->id);
        })
        ->where('created_at', '>=', $startDate)
        ->selectRaw('DATE(created_at) as date, COUNT(*) as count, status')
        ->groupBy('date', 'status')
        ->orderBy('date', 'desc')
        ->get()
        ->groupBy('date')
        ->map(function($dayLogs, $date) {
            $success = $dayLogs->where('status', 'success')->sum('count');
            $error = $dayLogs->where('status', 'error')->sum('count');
            
            return [
                'date' => $date,
                'total' => $success + $error,
                'success' => $success,
                'error' => $error,
            ];
        })
        ->values();
        
        return response()->json([
            'success' => true,
            'data' => [
                'period_days' => $days,
                'total_executions' => $totalExecutions,
                'successful_executions' => $successCount,
                'failed_executions' => $errorCount,
                'success_rate' => $successRate,
                'executions_per_day' => $executionsPerDay,
            ],
        ]);
    }
    
    /**
     * Supprime un log d'activité spécifique
     * 
     * @param int $id
     * @return \Illuminate\Http\JsonResponse
     */
    public function destroy(Request $request, $id)
    {
        $user = $request->user();
        
        $log = AreaLog::whereHas('area', function($query) use ($user) {
            $query->where('user_id', $user->id);
        })->find($id);
        
        if (!$log) {
            return response()->json([
                'success' => false,
                'message' => 'Log non trouvé ou accès non autorisé',
            ], 404);
        }
        
        $log->delete();
        
        return response()->json([
            'success' => true,
            'message' => 'Log supprimé avec succès',
        ]);
    }
    
    /**
     * Supprime tous les logs d'activité de l'utilisateur
     * 
     * @return \Illuminate\Http\JsonResponse
     */
    public function clear(Request $request)
    {
        $user = $request->user();
        
        $deletedCount = AreaLog::whereHas('area', function($query) use ($user) {
            $query->where('user_id', $user->id);
        })->delete();
        
        return response()->json([
            'success' => true,
            'message' => "Tous les logs ont été supprimés ({$deletedCount} logs)",
            'deleted_count' => $deletedCount,
        ]);
    }
}
