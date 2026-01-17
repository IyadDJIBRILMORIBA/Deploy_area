<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use App\Models\Area;
use App\Models\AreaLog;

class ExecuteAreas extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'area:execute';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Vérifie tous les triggers et exécute les réactions';

    /**
     * Execute the console command.
     */
    public function handle()
    {
        $this->info('Démarrage du moteur AREA...');

        // 1. Récupérer toutes les AREAS actives
        $areas = Area::where('is_active', true)->get();

        foreach ($areas as $area) {
            $this->info("Vérification de l'AREA ID: {$area->id} ({$area->name})");

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
                    
                    $this->info("  -> Google connecté pour user {$user->id}");
                }

                // 4. Vérifier le Trigger
                $triggerParams = is_string($area->trigger_params) ? json_decode($area->trigger_params, true) : $area->trigger_params;
                $data = $triggerService->checkTrigger($area->trigger_action, $triggerParams ?? [], $user);

                if ($data) {
                    $this->info("  -> Trigger activé ! Exécution de la réaction...");

                    // 5. Identifier le Service Réaction
                    $reactionService = $this->getServiceInstance($area->action_service);
                    
                    if (!$reactionService) {
                        throw new \Exception("Service Réaction inconnu : {$area->action_service}");
                    }

                    // 6. Exécuter la Réaction
                    $actionParams = is_string($area->action_params) ? json_decode($area->action_params, true) : $area->action_params;
                    $reactionService->executeReaction(
                        $area->action_reaction, 
                        $actionParams ?? [], 
                        $user, // Passer l'objet User complet, pas juste le token
                        $data
                    );

                    // 7. Logger le succès
                    AreaLog::create([
                        'area_id' => $area->id,
                        'status' => 'success',
                        'message' => "Exécuté avec succès à " . now(),
                    ]);
                    
                    $this->info("  -> Réaction terminée.");
                } else {
                    $this->line("  -> Rien à signaler.");
                }

            } catch (\Exception $e) {
                $this->error("Erreur : " . $e->getMessage());
                AreaLog::create([
                    'area_id' => $area->id,
                    'status' => 'error',
                    'message' => $e->getMessage()
                ]);
            }
        }
    }

    // Petite factory méthode pour instancier le bon service
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
