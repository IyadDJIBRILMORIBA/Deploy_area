<?php

namespace App\Services;

use App\Interfaces\ServiceInterface;
use Illuminate\Support\Facades\Log;

class TimerService implements ServiceInterface
{
    /**
     * Vérifie si un trigger timer doit s'exécuter
     * 
     * @param string $actionName Le nom du trigger ('every_minute', 'every_hour', 'every_day')
     * @param array $params Paramètres du trigger (ex: ['time' => '09:00'] pour every_day)
     * @param object|null $userToken L'objet User (non utilisé pour les timers)
     * @return bool|array Retourne true/les données du trigger si activé, false sinon
     */
    public function checkTrigger(string $actionName, array $params, $userToken)
    {
        try {
            $now = now();
            
            // Récupérer l'intervalle depuis les paramètres
            $interval = $params['interval'] ?? null;
            
            if (!$interval) {
                Log::warning("[TimerService] Aucun intervalle spécifié dans les paramètres");
                return false;
            }

            if ($interval === 'every_minute') {
                // Toujours vrai - s'exécute chaque minute
                Log::info("[TimerService] Trigger every_minute activé");
                return [
                    'timestamp' => $now->toIso8601String(),
                    'triggered_at' => $now->format('Y-m-d H:i:s')
                ];
            }
            
            if ($interval === 'every_5_minutes') {
                // S'exécute toutes les 5 minutes (minutes 0, 5, 10, 15, etc.)
                if ($now->minute % 5 === 0) {
                    Log::info("[TimerService] Trigger every_5_minutes activé");
                    return [
                        'timestamp' => $now->toIso8601String(),
                        'triggered_at' => $now->format('Y-m-d H:i:s')
                    ];
                }
                return false;
            }

            if ($interval === 'every_hour') {
                // S'exécute à la minute 00 de chaque heure
                if ($now->minute === 0) {
                    Log::info("[TimerService] Trigger every_hour activé");
                    return [
                        'timestamp' => $now->toIso8601String(),
                        'hour' => $now->format('H'),
                        'triggered_at' => $now->format('Y-m-d H:i:s')
                    ];
                }
                return false;
            }

            if ($interval === 'every_day') {
                // S'exécute à une heure spécifique
                $targetTime = $params['time'] ?? '09:00';
                $targetParts = explode(':', $targetTime);
                $targetHour = (int) $targetParts[0];
                $targetMinute = (int) ($targetParts[1] ?? 0);

                if ($now->hour === $targetHour && $now->minute === $targetMinute) {
                    Log::info("[TimerService] Trigger every_day ({$targetTime}) activé");
                    return [
                        'timestamp' => $now->toIso8601String(),
                        'scheduled_time' => $targetTime,
                        'triggered_at' => $now->format('Y-m-d H:i:s')
                    ];
                }
                return false;
            }

            return false;

        } catch (\Exception $e) {
            Log::error("[TimerService] Erreur checkTrigger : " . $e->getMessage());
            return false;
        }
    }

    /**
     * Exécute une réaction (non utilisé pour les timers, qui se combinent avec d'autres services)
     * 
     * @param string $reactionName Le nom de la réaction
     * @param array $params Paramètres de la réaction
     * @param object|null $userToken L'objet User
     * @param array $triggerData Les données du trigger
     * @return bool True si succès, false sinon
     */
    public function executeReaction(string $reactionName, array $params, $userToken, array $triggerData)
    {
        // Les timers ne font rien seuls - ils se combinent avec d'autres services
        Log::warning("[TimerService] executeReaction appelée sur TimerService (non supporté)");
        return false;
    }
}
