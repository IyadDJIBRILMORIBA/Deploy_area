<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use App\Models\Area;
use App\Models\AreaLog;

class ExecuteScheduledAreas extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'areas:engine';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Vérifie tous les triggers et exécute les réactions (utilisé par Laravel Scheduler)';

    /**
     * Execute the console command.
     */
    public function handle()
    {
        // 1. Récupérer toutes les AREAS actives
        $areas = Area::where('is_active', true)->get();

        if ($areas->isEmpty()) {
            return 0; // Aucune AREA à exécuter
        }

        foreach ($areas as $area) {
            try {
                // 2. Identifier le Service Trigger
                $triggerService = $this->getServiceInstance($area->trigger_service);
                
                if (!$triggerService) {
                    throw new \Exception("Service Trigger inconnu : {$area->trigger_service}");
                }

                // 3. Récupérer l'utilisateur et vérifier la connexion Google (si besoin)
                $user = $area->user;
                $needsGoogle = in_array($area->trigger_service, ['google', 'gmail']) || in_array($area->action_service, ['google', 'gmail']);
                
                if ($needsGoogle) {
                    // Vérifier si le service Google est connecté via user_services
                    $googleService = $user->services()->where('services.name', 'google')->first();
                    
                    if (!$googleService || !$googleService->pivot->access_token) {
                        throw new \Exception("L'utilisateur n'a pas connecté son compte Google. Allez sur /services pour connecter.");
                    }
                }

                // 4. Vérifier le Trigger
                $triggerParams = is_string($area->trigger_params) ? json_decode($area->trigger_params, true) : $area->trigger_params;
                \Log::info("[ExecuteScheduledAreas] AREA #{$area->id}: Checking trigger {$area->trigger_service}/{$area->trigger_action} with params: " . json_encode($triggerParams));
                $data = $triggerService->checkTrigger($area->trigger_action, $triggerParams ?? [], $user);

                \Log::info("[ExecuteScheduledAreas] AREA #{$area->id}: Trigger result: " . ($data ? 'ACTIVATED' : 'NOT ACTIVATED'));
                
                if ($data) {
                    // 5. Identifier le Service Réaction
                    $reactionService = $this->getServiceInstance($area->action_service);
                    
                    if (!$reactionService) {
                        throw new \Exception("Service Réaction inconnu : {$area->action_service}");
                    }

                    // 6. Exécuter la Réaction
                    $actionParams = is_string($area->action_params) ? json_decode($area->action_params, true) : $area->action_params;
                    \Log::info("[ExecuteScheduledAreas] AREA #{$area->id}: Executing reaction {$area->action_service}/{$area->action_reaction} with params: " . json_encode($actionParams));
                    
                    $reactionService->executeReaction(
                        $area->action_reaction, 
                        $actionParams ?? [], 
                        $user,
                        $data
                    );
                    
                    \Log::info("[ExecuteScheduledAreas] AREA #{$area->id}: Reaction executed successfully!");

                    // 7. Mettre à jour last_email_id si c'est un trigger Gmail
                    if (in_array($area->trigger_service, ['google', 'gmail']) && isset($data['message_id'])) {
                        $updatedParams = $triggerParams ?? [];
                        $updatedParams['last_email_id'] = $data['message_id'];
                        $area->trigger_params = $updatedParams;
                        $area->save();
                        Log::info("[ExecuteScheduledAreas] last_email_id mis à jour: {$data['message_id']}");
                    }

                    // 8. Logger le succès
                    AreaLog::create([
                        'area_id' => $area->id,
                        'status' => 'success',
                        'message' => "Exécuté avec succès à " . now(),
                    ]);
                } else {
                    // Trigger non déclenché,
                }

            } catch (\Exception $e) {
                // Logger l'erreur mais continuer les autres AREAs
                AreaLog::create([
                    'area_id' => $area->id,
                    'status' => 'error',
                    'message' => $e->getMessage()
                ]);
            }
        }

        return 0;
    }

    /**
     * Obtenir une instance d'un service
     */
    private function getServiceInstance($serviceName)
    {
        return match (strtolower($serviceName)) {
            'timer' => new \App\Services\TimerService(),
            'google', 'gmail' => new \App\Services\GoogleService(),
            'github' => new \App\Services\GitHubService(),
            'discord' => new \App\Services\DiscordService(),
            'slack' => new \App\Services\SlackService(),
            'twitch' => new \App\Services\TwitchService(),
            'weather' => new \App\Services\WeatherService(),
            'trello' => new \App\Services\TrelloService(),
            default => null,
        };
    }
}
