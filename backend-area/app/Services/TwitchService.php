<?php

namespace App\Services;

use App\Interfaces\ServiceInterface;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class TwitchService implements ServiceInterface
{
    private const API_BASE = 'https://api.twitch.tv/helix';
    
    /**
     * Récupère le token Twitch de l'utilisateur
     */
    private function getAccessToken($user)
    {
        $twitchService = $user->services()
            ->where('services.name', 'twitch')
            ->first();
            
        if (!$twitchService) {
            throw new \Exception("Twitch non connecté pour user {$user->id}");
        }
        
        return $twitchService->pivot->access_token;
    }
    
    /**
     * Récupère le Client ID depuis la configuration
     */
    private function getClientId()
    {
        return config('services.twitch.client_id');
    }
    
    /**
     * Vérifie les triggers Twitch
     * 
     * @param string $actionName Le nom du trigger
     * @param array $params Paramètres (channel_name, last_stream_id, last_follower_count, etc.)
     * @param object|null $userToken L'objet User
     * @return bool|array Retourne false ou les données du trigger
     */
    public function checkTrigger(string $actionName, array $params, $userToken)
    {
        try {
            $accessToken = $this->getAccessToken($userToken);
            $clientId = $this->getClientId();
            
            // Convertir le nom du trigger en snake_case pour comparaison
            $triggerKey = strtolower(str_replace(' ', '_', $actionName));
            
            // Trigger 1: Streamer est en direct
            if ($triggerKey === 'stream_online') {
                return $this->checkStreamOnline($accessToken, $clientId, $params);
            }
            
            // Trigger 2: Nouveau follower
            if ($triggerKey === 'new_follower') {
                return $this->checkNewFollower($accessToken, $clientId, $params);
            }
            
            // Trigger 3: Clip créé
            if ($triggerKey === 'new_clip') {
                return $this->checkNewClip($accessToken, $clientId, $params);
            }
            
            return false;
            
        } catch (\Exception $e) {
            Log::error("[TwitchService] Erreur checkTrigger: " . $e->getMessage());
            return false;
        }
    }
    
    /**
     * Vérifie si un stream est en direct
     */
    private function checkStreamOnline($accessToken, $clientId, $params)
    {
        $channelName = $params['channel_name'] ?? null;
        
        if (!$channelName) {
            Log::error("[TwitchService] channel_name manquant pour stream_online");
            return false;
        }
        
        // Récupérer l'ID du broadcaster
        $userResponse = Http::withHeaders([
            'Authorization' => 'Bearer ' . $accessToken,
            'Client-Id' => $clientId,
        ])->get(self::API_BASE . '/users', [
            'login' => $channelName,
        ]);
        
        if (!$userResponse->successful() || empty($userResponse->json('data'))) {
            Log::error("[TwitchService] Utilisateur Twitch non trouvé: {$channelName}");
            return false;
        }
        
        $broadcasterId = $userResponse->json('data')[0]['id'];
        
        // Vérifier si le stream est en direct
        $streamResponse = Http::withHeaders([
            'Authorization' => 'Bearer ' . $accessToken,
            'Client-Id' => $clientId,
        ])->get(self::API_BASE . '/streams', [
            'user_id' => $broadcasterId,
        ]);
        
        if (!$streamResponse->successful()) {
            Log::error("[TwitchService] Erreur API streams: " . $streamResponse->status());
            return false;
        }
        
        $streams = $streamResponse->json('data');
        
        if (empty($streams)) {
            return false; // Pas en direct
        }
        
        $stream = $streams[0];
        $streamId = $stream['id'];
        $lastStreamId = $params['last_stream_id'] ?? null;
        
        if ($lastStreamId && $streamId === $lastStreamId) {
            return false; // Même stream, déjà notifié
        }
        
        Log::info("[TwitchService] Stream en direct: {$stream['title']} par {$channelName}");
        
        return [
            'stream_id' => $streamId,
            'stream_title' => $stream['title'],
            'game_name' => $stream['game_name'] ?? '',
            'viewer_count' => $stream['viewer_count'],
            'started_at' => $stream['started_at'],
            'channel_name' => $channelName,
            'thumbnail_url' => $stream['thumbnail_url'],
        ];
    }
    
    /**
     * Vérifie si un nouveau follower a suivi la chaîne
     */
    private function checkNewFollower($accessToken, $clientId, $params)
    {
        $channelName = $params['channel_name'] ?? null;
        
        if (!$channelName) {
            Log::error("[TwitchService] channel_name manquant pour new_follower");
            return false;
        }
        
        // Récupérer l'ID du broadcaster
        $userResponse = Http::withHeaders([
            'Authorization' => 'Bearer ' . $accessToken,
            'Client-Id' => $clientId,
        ])->get(self::API_BASE . '/users', [
            'login' => $channelName,
        ]);
        
        if (!$userResponse->successful() || empty($userResponse->json('data'))) {
            Log::error("[TwitchService] Utilisateur Twitch non trouvé: {$channelName}");
            return false;
        }
        
        $broadcasterId = $userResponse->json('data')[0]['id'];
        
        // Récupérer le nombre total de followers
        $followResponse = Http::withHeaders([
            'Authorization' => 'Bearer ' . $accessToken,
            'Client-Id' => $clientId,
        ])->get(self::API_BASE . '/channels/followers', [
            'broadcaster_id' => $broadcasterId,
            'first' => 1,
        ]);
        
        if (!$followResponse->successful()) {
            Log::error("[TwitchService] Erreur API followers: " . $followResponse->status());
            return false;
        }
        
        $total = $followResponse->json('total');
        $lastFollowerCount = $params['last_follower_count'] ?? null;
        
        if ($lastFollowerCount && $total <= $lastFollowerCount) {
            return false; // Pas de nouveau follower
        }
        
        $followers = $followResponse->json('data');
        $latestFollower = !empty($followers) ? $followers[0] : null;
        
        Log::info("[TwitchService] Nouveau follower détecté. Total: {$total}");
        
        return [
            'total_followers' => $total,
            'follower_name' => $latestFollower['user_name'] ?? 'Unknown',
            'followed_at' => $latestFollower['followed_at'] ?? now()->toIso8601String(),
            'channel_name' => $channelName,
        ];
    }
    
    /**
     * Vérifie si un nouveau clip a été créé
     */
    private function checkNewClip($accessToken, $clientId, $params)
    {
        $channelName = $params['channel_name'] ?? null;
        
        if (!$channelName) {
            Log::error("[TwitchService] channel_name manquant pour new_clip");
            return false;
        }
        
        // Récupérer l'ID du broadcaster
        $userResponse = Http::withHeaders([
            'Authorization' => 'Bearer ' . $accessToken,
            'Client-Id' => $clientId,
        ])->get(self::API_BASE . '/users', [
            'login' => $channelName,
        ]);
        
        if (!$userResponse->successful() || empty($userResponse->json('data'))) {
            Log::error("[TwitchService] Utilisateur Twitch non trouvé: {$channelName}");
            return false;
        }
        
        $broadcasterId = $userResponse->json('data')[0]['id'];
        
        // Récupérer les clips récents
        $clipResponse = Http::withHeaders([
            'Authorization' => 'Bearer ' . $accessToken,
            'Client-Id' => $clientId,
        ])->get(self::API_BASE . '/clips', [
            'broadcaster_id' => $broadcasterId,
            'first' => 1,
        ]);
        
        if (!$clipResponse->successful()) {
            Log::error("[TwitchService] Erreur API clips: " . $clipResponse->status());
            return false;
        }
        
        $clips = $clipResponse->json('data');
        
        if (empty($clips)) {
            return false;
        }
        
        $latestClip = $clips[0];
        $clipId = $latestClip['id'];
        $lastClipId = $params['last_clip_id'] ?? null;
        
        if ($lastClipId && $clipId === $lastClipId) {
            return false;
        }
        
        Log::info("[TwitchService] Nouveau clip créé: {$latestClip['title']}");
        
        return [
            'clip_id' => $clipId,
            'clip_title' => $latestClip['title'],
            'clip_url' => $latestClip['url'],
            'creator_name' => $latestClip['creator_name'],
            'view_count' => $latestClip['view_count'],
            'created_at' => $latestClip['created_at'],
            'thumbnail_url' => $latestClip['thumbnail_url'],
        ];
    }
    
    /**
     * Exécute les réactions Twitch
     * 
     * @param string $reactionName Le nom de la réaction
     * @param array $params Paramètres de la réaction
     * @param object|null $userToken L'objet User
     * @param array $triggerData Les données du trigger
     */
    public function executeReaction(string $reactionName, array $params, $userToken, array $triggerData)
    {
        try {
            $accessToken = $this->getAccessToken($userToken);
            $clientId = $this->getClientId();
            
            // Convertir le nom de la réaction en snake_case pour comparaison
            $actionKey = strtolower(str_replace(' ', '_', $reactionName));
            
            // Réaction 1: Envoyer un message dans le chat
            if ($actionKey === 'send_chat_message') {
                return $this->sendChatMessage($accessToken, $clientId, $params, $triggerData);
            }
            
            // Réaction 2: Mettre à jour le titre du stream
            if ($actionKey === 'update_stream_title') {
                return $this->updateStreamTitle($accessToken, $clientId, $params, $triggerData);
            }
            
            // Réaction 3: Créer un marqueur de stream
            if ($actionKey === 'create_stream_marker') {
                return $this->createStreamMarker($accessToken, $clientId, $params, $triggerData);
            }
            
            return false;
            
        } catch (\Exception $e) {
            Log::error("[TwitchService] Erreur executeReaction: " . $e->getMessage());
            return false;
        }
    }
    
    /**
     * Envoie un message dans le chat Twitch
     */
    private function sendChatMessage($accessToken, $clientId, $params, $triggerData)
    {
        $channelName = $params['channel_name'] ?? $params['channel'] ?? null;
        $message = $params['message'] ?? null;
        
        if (!$channelName || !$message) {
            Log::error("[TwitchService] channel_name ou message manquant");
            return false;
        }
        
        // Remplacer les variables dans le message
        $message = $this->replaceVariables($message, $triggerData);
        
        // Récupérer l'ID du broadcaster et du bot
        $userResponse = Http::withHeaders([
            'Authorization' => 'Bearer ' . $accessToken,
            'Client-Id' => $clientId,
        ])->get(self::API_BASE . '/users', [
            'login' => $channelName,
        ]);
        
        if (!$userResponse->successful() || empty($userResponse->json('data'))) {
            Log::error("[TwitchService] Utilisateur Twitch non trouvé: {$channelName}");
            return false;
        }
        
        $broadcasterId = $userResponse->json('data')[0]['id'];
        
        // Récupérer l'ID de l'utilisateur authentifié (celui qui possède le token)
        $meResponse = Http::withHeaders([
            'Authorization' => 'Bearer ' . $accessToken,
            'Client-Id' => $clientId,
        ])->get(self::API_BASE . '/users');
        
        if (!$meResponse->successful() || empty($meResponse->json('data'))) {
            Log::error("[TwitchService] Impossible de récupérer l'utilisateur authentifié");
            return false;
        }
        
        $senderId = $meResponse->json('data')[0]['id'];
        
        Log::info("[TwitchService] Tentative envoi message - Broadcaster: {$broadcasterId}, Sender: {$senderId}");
        
        $response = Http::withHeaders([
            'Authorization' => 'Bearer ' . $accessToken,
            'Client-Id' => $clientId,
            'Content-Type' => 'application/json',
        ])->post(self::API_BASE . '/chat/messages', [
            'broadcaster_id' => $broadcasterId,
            'sender_id' => $senderId,
            'message' => $message,
        ]);
        
        if ($response->successful()) {
            Log::info("[TwitchService] Message envoyé dans le chat de {$channelName}");
            return true;
        }
        
        $errorBody = $response->json();
        Log::error("[TwitchService] Erreur envoi message: " . $response->status() . " - " . json_encode($errorBody));
        return false;
    }
    
    /**
     * Met à jour le titre du stream
     */
    private function updateStreamTitle($accessToken, $clientId, $params, $triggerData)
    {
        $title = $params['title'] ?? null;
        
        if (!$title) {
            Log::error("[TwitchService] title manquant");
            return false;
        }
        
        // Remplacer les variables dans le titre
        $title = $this->replaceVariables($title, $triggerData);
        
        // Récupérer l'ID du broadcaster (utilisateur authentifié)
        $userResponse = Http::withHeaders([
            'Authorization' => 'Bearer ' . $accessToken,
            'Client-Id' => $clientId,
        ])->get(self::API_BASE . '/users');
        
        if (!$userResponse->successful() || empty($userResponse->json('data'))) {
            Log::error("[TwitchService] Impossible de récupérer l'utilisateur authentifié");
            return false;
        }
        
        $broadcasterId = $userResponse->json('data')[0]['id'];
        $channelName = $userResponse->json('data')[0]['login'];
        
        $response = Http::withHeaders([
            'Authorization' => 'Bearer ' . $accessToken,
            'Client-Id' => $clientId,
            'Content-Type' => 'application/json',
        ])->patch(self::API_BASE . '/channels', [
            'broadcaster_id' => $broadcasterId,
            'title' => $title,
        ]);
        
        if ($response->successful()) {
            Log::info("[TwitchService] Titre du stream mis à jour: {$title}");
            return true;
        }
        
        Log::error("[TwitchService] Erreur mise à jour titre: " . $response->status());
        return false;
    }
    
    /**
     * Crée un marqueur de stream
     */
    private function createStreamMarker($accessToken, $clientId, $params, $triggerData)
    {
        $description = $params['description'] ?? 'Marqueur automatique';
        
        // Remplacer les variables dans la description
        $description = $this->replaceVariables($description, $triggerData);
        
        // Récupérer l'ID du broadcaster (utilisateur authentifié)
        $userResponse = Http::withHeaders([
            'Authorization' => 'Bearer ' . $accessToken,
            'Client-Id' => $clientId,
        ])->get(self::API_BASE . '/users');
        
        if (!$userResponse->successful() || empty($userResponse->json('data'))) {
            Log::error("[TwitchService] Impossible de récupérer l'utilisateur authentifié");
            return false;
        }
        
        $broadcasterId = $userResponse->json('data')[0]['id'];
        $channelName = $userResponse->json('data')[0]['login'];
        
        Log::info("[TwitchService] Création marqueur pour broadcaster {$broadcasterId} ({$channelName})");
        
        $response = Http::withHeaders([
            'Authorization' => 'Bearer ' . $accessToken,
            'Client-Id' => $clientId,
            'Content-Type' => 'application/json',
        ])->post(self::API_BASE . '/streams/markers', [
            'user_id' => $broadcasterId,
            'description' => $description,
        ]);
        
        if ($response->successful()) {
            $markerData = $response->json();
            Log::info("[TwitchService] Marqueur créé avec succès: {$description} - Position: " . ($markerData['data'][0]['position_seconds'] ?? 'N/A') . "s");
            return true;
        }
        
        $errorBody = $response->json();
        Log::error("[TwitchService] Erreur création marqueur: " . $response->status() . " - " . json_encode($errorBody));
        return false;
    }
    
    /**
     * Remplace les variables dynamiques dans un texte
     */
    private function replaceVariables(string $text, array $data): string
    {
        foreach ($data as $key => $value) {
            if (is_string($value) || is_numeric($value)) {
                $text = str_replace("{{$key}}", $value, $text);
            }
        }
        
        return $text;
    }
}
