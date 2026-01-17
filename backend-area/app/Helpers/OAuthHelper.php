<?php

namespace App\Helpers;

use App\Models\User;
use App\Models\Service;
use App\Models\UserService;
use Google\Client as GoogleClient;
use Illuminate\Support\Facades\Log;

class OAuthHelper
{
    /**
     * Récupère un client Google valide avec refresh automatique du token si expiré
     * 
     * @param User $user L'utilisateur dont on veut le client Google
     * @return GoogleClient Client Google prêt à utiliser
     * @throws \Exception Si l'utilisateur n'est pas connecté à Google ou si le refresh échoue
     */
    public static function getValidGoogleClient(User $user): GoogleClient
    {
        // 1. Récupérer le service Google depuis la BDD
        $service = Service::where('name', 'google')->first();
        
        if (!$service) {
            throw new \Exception("Service Google non trouvé. Lancez 'php artisan db:seed'");
        }

        // 2. Récupérer le UserService (relation user <-> Google avec tokens)
        $userService = UserService::where('user_id', $user->id)
            ->where('service_id', $service->id)
            ->first();

        if (!$userService || !$userService->access_token) {
            throw new \Exception("L'utilisateur n'est pas connecté à Google");
        }

        // 3. Créer le client Google avec les credentials OAuth
        $client = new GoogleClient();
        $client->setClientId(config('services.google.client_id'));
        $client->setClientSecret(config('services.google.client_secret'));
        $client->setRedirectUri(config('services.google.redirect'));
        
        // Gérer les deux formats de token : JSON (web) ou string (mobile)
        $accessTokenData = $userService->access_token;
        if (is_string($accessTokenData) && !json_decode($accessTokenData)) {
            // Format mobile : string brute, on convertit en array
            // Calculer created basé sur expires_at et expires_in (1h = 3600s)
            $expiresAt = strtotime($userService->expires_at);
            $created = $expiresAt - 3600; // Token créé 1h avant expiration
            
            $accessTokenData = [
                'access_token' => $accessTokenData,
                'expires_in' => 3600,
                'created' => $created,
            ];
            
            Log::info("[OAuthHelper] Token mobile converti - expires_at: {$userService->expires_at}, created: " . date('Y-m-d H:i:s', $created));
        } elseif (is_string($accessTokenData)) {
            // Format web : JSON encodé
            $accessTokenData = json_decode($accessTokenData, true);
        }
        
        $client->setAccessToken($accessTokenData);
        
        // Configurer les timeouts pour éviter les blocages
        $httpClient = new \GuzzleHttp\Client([
            'timeout' => 30,
            'connect_timeout' => 10,
        ]);
        $client->setHttpClient($httpClient);

        // 4. Vérifier si le token est expiré
        if ($client->isAccessTokenExpired()) {
            Log::info("[OAuthHelper] Token Google expiré pour user {$user->id}, tentative de refresh...");

            if (!$userService->refresh_token) {
                throw new \Exception("Token expiré et aucun refresh_token disponible. L'utilisateur doit se reconnecter.");
            }

            try {
                // 5. Rafraîchir le token
                $client->fetchAccessTokenWithRefreshToken($userService->refresh_token);
                $newAccessToken = $client->getAccessToken();

                if (!$newAccessToken) {
                    throw new \Exception("Échec du refresh du token Google");
                }

                // 6. Mettre à jour la BDD avec le nouveau token
                $userService->access_token = json_encode($newAccessToken);
                $userService->expires_at = now()->addSeconds($newAccessToken['expires_in'] ?? 3600);
                
                // IMPORTANT : Préserver le refresh_token s'il n'est pas dans la réponse
                // Google ne renvoie le refresh_token que lors de la première connexion
                if (!empty($newAccessToken['refresh_token'])) {
                    $userService->refresh_token = $newAccessToken['refresh_token'];
                }
                
                $userService->save();

                Log::info("[OAuthHelper] Token Google rafraîchi avec succès pour user {$user->id}. Expires: {$userService->expires_at}");

            } catch (\Exception $e) {
                Log::error("[OAuthHelper] Erreur lors du refresh du token : " . $e->getMessage());
                throw new \Exception("Impossible de rafraîchir le token Google. L'utilisateur doit se reconnecter.");
            }
        }

        return $client;
    }

    /**
     * Vérifie si un utilisateur est connecté à un service
     * 
     * @param User $user
     * @param string $serviceName Nom du service (ex: 'google', 'discord')
     * @return bool
     */
    public static function isUserConnectedToService(User $user, string $serviceName): bool
    {
        $service = Service::where('name', $serviceName)->first();
        
        if (!$service) {
            return false;
        }

        return UserService::where('user_id', $user->id)
            ->where('service_id', $service->id)
            ->whereNotNull('access_token')
            ->exists();
    }
}
