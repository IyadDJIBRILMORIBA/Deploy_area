<?php

namespace App\Services;

use App\Interfaces\ServiceInterface;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Http;

class SlackService implements ServiceInterface
{
    /**
     * Vérifie si un événement Slack s'est produit
     * 
     * Note: Slack nécessite l'Events API ou l'API RTM pour les triggers en temps réel.
     * Pour simplifier, on utilise l'API Slack REST pour vérifier les nouveaux messages.
     * 
     * @param string $actionName Le nom de l'action (ex: 'new_message')
     * @param array $params Paramètres du trigger (channel_id, bot_token, etc.)
     * @param object|null $userToken Token/Bot token Slack
     * @return bool|array False si rien, ou les données de l'événement
     */
    public function checkTrigger(string $actionName, array $params, $userToken)
    {
        try {
            Log::info("[SlackService] checkTrigger START - Action: {$actionName}");
            
            // Convertir le nom du trigger en snake_case pour comparaison
            $triggerKey = strtolower(str_replace(' ', '_', $actionName));

            switch ($triggerKey) {
                case 'new_message':
                case 'new_message_in_channel':
                    return $this->checkNewMessage($params, $userToken);
                
                case 'message_contains':
                case 'message_contains_keyword':
                    return $this->checkMessageContains($params, $userToken);
                
                case 'user_joined':
                case 'new_member':
                    return $this->checkNewMember($params, $userToken);
                
                case 'reaction_added':
                    // Note: Nécessite l'Events API de Slack pour les événements en temps réel
                    Log::info("[SlackService] Trigger {$actionName} nécessite Events API");
                    return false;
                
                default:
                    Log::warning("[SlackService] Action inconnue: {$actionName}");
                    return false;
            }

        } catch (\Exception $e) {
            Log::error("[SlackService] Erreur checkTrigger: " . $e->getMessage());
            return false;
        }
    }

    /**
     * Vérifie s'il y a un nouveau message dans un canal Slack
     */
    private function checkNewMessage(array $params, $userToken): bool|array
    {
        $botToken = $params['bot_token'] ?? null;
        $channelId = $params['channel_id'] ?? null;

        if (!$botToken || !$channelId) {
            Log::error("[SlackService] bot_token ou channel_id manquant");
            return false;
        }

        try {
            // Récupérer l'historique du canal
            $response = Http::withHeaders([
                'Authorization' => "Bearer {$botToken}",
                'Content-Type' => 'application/json',
            ])->get('https://slack.com/api/conversations.history', [
                'channel' => $channelId,
                'limit' => 1, // Dernier message seulement
            ]);

            if (!$response->successful()) {
                Log::error("[SlackService] Erreur API Slack: " . $response->body());
                return false;
            }

            $data = $response->json();

            if (!$data['ok']) {
                Log::error("[SlackService] Erreur Slack API: " . ($data['error'] ?? 'Unknown error'));
                return false;
            }

            $messages = $data['messages'] ?? [];

            if (empty($messages)) {
                Log::info("[SlackService] Aucun message dans le canal {$channelId}");
                return false;
            }

            $latestMessage = $messages[0];
            $timestamp = $latestMessage['ts'] ?? null;

            if (!$timestamp) {
                return false;
            }

            // Vérifier si c'est un nouveau message
            $lastTimestamp = $params['last_timestamp'] ?? null;

            if ($lastTimestamp === $timestamp) {
                Log::info("[SlackService] Message déjà traité: {$timestamp}");
                return false;
            }

            Log::info("[SlackService] Nouveau message détecté: {$timestamp}");

            // Retourner les données du message
            return [
                'timestamp' => $timestamp,
                'text' => $latestMessage['text'] ?? '',
                'user' => $latestMessage['user'] ?? 'Unknown',
                'channel_id' => $channelId,
                'type' => $latestMessage['type'] ?? 'message',
            ];

        } catch (\Exception $e) {
            Log::error("[SlackService] Erreur checkNewMessage: " . $e->getMessage());
            return false;
        }
    }

    /**
     * Vérifie si un message contient un mot-clé spécifique
     */
    private function checkMessageContains(array $params, $userToken): bool|array
    {
        $messageData = $this->checkNewMessage($params, $userToken);

        if (!$messageData) {
            return false;
        }

        $keyword = $params['keyword'] ?? '';
        $text = $messageData['text'] ?? '';

        // Vérifier si le mot-clé est présent dans le message
        if (empty($keyword) || stripos($text, $keyword) === false) {
            Log::info("[SlackService] Mot-clé '{$keyword}' non trouvé dans le message");
            return false;
        }

        Log::info("[SlackService] Mot-clé '{$keyword}' trouvé dans le message");
        return $messageData;
    }

    /**
     * Vérifie s'il y a un nouveau membre dans le workspace
     */
    private function checkNewMember(array $params, $userToken): bool|array
    {
        $botToken = $params['bot_token'] ?? null;

        if (!$botToken) {
            Log::error("[SlackService] bot_token manquant");
            return false;
        }

        try {
            // Récupérer la liste des utilisateurs
            $response = Http::withHeaders([
                'Authorization' => "Bearer {$botToken}",
            ])->get('https://slack.com/api/users.list');

            if (!$response->successful()) {
                Log::error("[SlackService] Erreur API Slack users.list: " . $response->body());
                return false;
            }

            $data = $response->json();

            if (!$data['ok']) {
                Log::error("[SlackService] Erreur Slack API: " . ($data['error'] ?? 'Unknown error'));
                return false;
            }

            $members = $data['members'] ?? [];

            if (empty($members)) {
                return false;
            }

            // Trier par date de création (le plus récent en premier)
            usort($members, function($a, $b) {
                return ($b['created'] ?? 0) <=> ($a['created'] ?? 0);
            });

            $latestMember = $members[0];
            $memberId = $latestMember['id'] ?? null;

            if (!$memberId) {
                return false;
            }

            // Vérifier si c'est un nouveau membre
            $lastMemberId = $params['last_member_id'] ?? null;

            if ($lastMemberId === $memberId) {
                Log::info("[SlackService] Membre déjà traité: {$memberId}");
                return false;
            }

            Log::info("[SlackService] Nouveau membre détecté: {$memberId}");

            return [
                'member_id' => $memberId,
                'name' => $latestMember['name'] ?? 'Unknown',
                'real_name' => $latestMember['real_name'] ?? '',
                'email' => $latestMember['profile']['email'] ?? '',
            ];

        } catch (\Exception $e) {
            Log::error("[SlackService] Erreur checkNewMember: " . $e->getMessage());
            return false;
        }
    }

    /**
     * Exécute une réaction Slack (envoyer un message, etc.)
     * 
     * @param string $reactionName Le nom de la réaction (ex: 'send_message')
     * @param array $params Paramètres (channel_id, text, etc.)
     * @param object|null $userToken
     * @param array $triggerData Données du trigger
     * @return bool
     */
    public function executeReaction(string $reactionName, array $params, $userToken, array $triggerData)
    {
        try {
            Log::info("[SlackService] executeReaction START - Réaction: {$reactionName}");
            
            // Convertir le nom de la réaction en snake_case pour comparaison
            $actionKey = strtolower(str_replace(' ', '_', $reactionName));

            switch ($actionKey) {
                case 'send_message':
                case 'post_message':
                case 'send_message_to_channel':
                    return $this->sendMessage($params, $triggerData);
                
                case 'send_dm':
                case 'send_direct_message':
                    return $this->sendDirectMessage($params, $triggerData);
                
                case 'add_reaction':
                    return $this->addReaction($params, $triggerData);
                
                case 'create_channel':
                    return $this->createChannel($params, $triggerData);
                
                default:
                    Log::warning("[SlackService] Réaction inconnue: {$reactionName}");
                    return false;
            }

        } catch (\Exception $e) {
            Log::error("[SlackService] Erreur executeReaction: " . $e->getMessage());
            return false;
        }
    }

    /**
     * Envoie un message dans un canal Slack
     */
    private function sendMessage(array $params, array $triggerData): bool
    {
        // Détecter si c'est un webhook URL
        $channelOrWebhook = $params['channel_id'] ?? $params['channel'] ?? $params['webhook_url'] ?? null;
        
        if (!$channelOrWebhook) {
            Log::error("[SlackService] Paramètres manquants: channel_id, channel ou webhook_url requis");
            return false;
        }
        
        // Si c'est une URL webhook, utiliser la méthode webhook
        if (str_starts_with($channelOrWebhook, 'https://hooks.slack.com/')) {
            Log::info("[SlackService] Détection d'un webhook Slack");
            return $this->sendWebhook($channelOrWebhook, $params, $triggerData);
        }
        
        // Sinon, utiliser l'API classique avec bot_token
        $botToken = $params['bot_token'] ?? env('SLACK_BOT_TOKEN');
        $channelId = $channelOrWebhook;
        $text = $params['text'] ?? $params['message'] ?? $params['content'] ?? '';

        if (!$botToken || !$channelId || empty($text)) {
            Log::error("[SlackService] Paramètres manquants pour send_message (bot_token et text requis). botToken: " . ($botToken ? 'OK' : 'MISSING') . ", channelId: {$channelId}, text: " . (empty($text) ? 'EMPTY' : 'OK'));
            return false;
        }

        // Remplacer les variables dynamiques
        $text = $this->replaceVariables($text, $triggerData);

        try {
            $payload = [
                'channel' => $channelId,
                'text' => $text,
            ];

            // Ajouter des blocks si fournis (format riche Slack)
            if (!empty($params['blocks'])) {
                $payload['blocks'] = $params['blocks'];
            }

            // Ajouter un nom d'utilisateur personnalisé si fourni
            if (!empty($params['username'])) {
                $payload['username'] = $params['username'];
            }

            // Ajouter une icône si fournie
            if (!empty($params['icon_emoji'])) {
                $payload['icon_emoji'] = $params['icon_emoji'];
            }

            $response = Http::withHeaders([
                'Authorization' => "Bearer {$botToken}",
                'Content-Type' => 'application/json',
            ])->post('https://slack.com/api/chat.postMessage', $payload);

            if ($response->successful()) {
                $data = $response->json();
                
                if ($data['ok']) {
                    Log::info("[SlackService] Message envoyé avec succès au canal {$channelId}");
                    return true;
                } else {
                    Log::error("[SlackService] Erreur Slack: " . ($data['error'] ?? 'Unknown'));
                    return false;
                }
            } else {
                Log::error("[SlackService] Erreur HTTP lors de l'envoi du message: " . $response->body());
                return false;
            }

        } catch (\Exception $e) {
            Log::error("[SlackService] Erreur sendMessage: " . $e->getMessage());
            return false;
        }
    }

    /**
     * Envoie un message direct à un utilisateur
     */
    private function sendDirectMessage(array $params, array $triggerData): bool
    {
        $botToken = $params['bot_token'] ?? null;
        $userId = $params['user_id'] ?? $triggerData['user'] ?? null;
        $text = $params['text'] ?? $params['message'] ?? '';

        if (!$botToken || !$userId || empty($text)) {
            Log::error("[SlackService] Paramètres manquants pour send_dm");
            return false;
        }

        try {
            // 1. Ouvrir une conversation DM avec l'utilisateur
            $openResponse = Http::withHeaders([
                'Authorization' => "Bearer {$botToken}",
                'Content-Type' => 'application/json',
            ])->post('https://slack.com/api/conversations.open', [
                'users' => $userId,
            ]);

            if (!$openResponse->successful()) {
                Log::error("[SlackService] Erreur ouverture DM: " . $openResponse->body());
                return false;
            }

            $openData = $openResponse->json();

            if (!$openData['ok']) {
                Log::error("[SlackService] Erreur Slack open DM: " . ($openData['error'] ?? 'Unknown'));
                return false;
            }

            $channelId = $openData['channel']['id'] ?? null;

            if (!$channelId) {
                return false;
            }

            // 2. Envoyer le message dans le canal DM
            $params['channel_id'] = $channelId;
            return $this->sendMessage($params, $triggerData);

        } catch (\Exception $e) {
            Log::error("[SlackService] Erreur sendDirectMessage: " . $e->getMessage());
            return false;
        }
    }

    /**
     * Ajoute une réaction emoji à un message
     */
    private function addReaction(array $params, array $triggerData): bool
    {
        $botToken = $params['bot_token'] ?? null;
        $channelId = $params['channel_id'] ?? $triggerData['channel_id'] ?? null;
        $timestamp = $params['timestamp'] ?? $triggerData['timestamp'] ?? null;
        $emoji = $params['emoji'] ?? 'thumbsup';

        if (!$botToken || !$channelId || !$timestamp) {
            Log::error("[SlackService] Paramètres manquants pour add_reaction");
            return false;
        }

        try {
            // Enlever les ':' de l'emoji si présents
            $emoji = trim($emoji, ':');

            $response = Http::withHeaders([
                'Authorization' => "Bearer {$botToken}",
                'Content-Type' => 'application/json',
            ])->post('https://slack.com/api/reactions.add', [
                'channel' => $channelId,
                'timestamp' => $timestamp,
                'name' => $emoji,
            ]);

            if ($response->successful()) {
                $data = $response->json();
                
                if ($data['ok']) {
                    Log::info("[SlackService] Réaction {$emoji} ajoutée au message");
                    return true;
                } else {
                    Log::error("[SlackService] Erreur Slack: " . ($data['error'] ?? 'Unknown'));
                    return false;
                }
            } else {
                Log::error("[SlackService] Erreur HTTP add_reaction: " . $response->body());
                return false;
            }

        } catch (\Exception $e) {
            Log::error("[SlackService] Erreur addReaction: " . $e->getMessage());
            return false;
        }
    }

    /**
     * Crée un nouveau canal Slack
     */
    private function createChannel(array $params, array $triggerData): bool
    {
        $botToken = $params['bot_token'] ?? null;
        $channelName = $params['channel_name'] ?? $params['name'] ?? null;
        $isPrivate = $params['is_private'] ?? false;

        if (!$botToken || !$channelName) {
            Log::error("[SlackService] Paramètres manquants pour create_channel");
            return false;
        }

        // Remplacer les variables dynamiques dans le nom du canal
        $channelName = $this->replaceVariables($channelName, $triggerData);
        
        // Nettoyer le nom du canal (Slack accepte seulement minuscules, chiffres, tirets)
        $channelName = strtolower(preg_replace('/[^a-z0-9-_]/', '-', $channelName));

        try {
            $response = Http::withHeaders([
                'Authorization' => "Bearer {$botToken}",
                'Content-Type' => 'application/json',
            ])->post('https://slack.com/api/conversations.create', [
                'name' => $channelName,
                'is_private' => $isPrivate,
            ]);

            if ($response->successful()) {
                $data = $response->json();
                
                if ($data['ok']) {
                    Log::info("[SlackService] Canal {$channelName} créé avec succès");
                    return true;
                } else {
                    Log::error("[SlackService] Erreur Slack: " . ($data['error'] ?? 'Unknown'));
                    return false;
                }
            } else {
                Log::error("[SlackService] Erreur HTTP create_channel: " . $response->body());
                return false;
            }

        } catch (\Exception $e) {
            Log::error("[SlackService] Erreur createChannel: " . $e->getMessage());
            return false;
        }
    }

    /**
     * Envoie un message via un webhook Slack
     */
    private function sendWebhook(string $webhookUrl, array $params, array $triggerData): bool
    {
        $text = $params['text'] ?? $params['message'] ?? $params['content'] ?? '';
        
        if (empty($text)) {
            Log::error("[SlackService] Message vide pour webhook");
            return false;
        }
        
        // Remplacer les variables dynamiques
        $text = $this->replaceVariables($text, $triggerData);
        
        try {
            $payload = [
                'text' => $text,
            ];
            
            // Ajouter un nom d'utilisateur personnalisé si fourni
            if (!empty($params['username'])) {
                $payload['username'] = $params['username'];
            }
            
            // Ajouter une icône si fournie
            if (!empty($params['icon_emoji'])) {
                $payload['icon_emoji'] = $params['icon_emoji'];
            }
            
            Log::info("[SlackService] Envoi webhook Slack", ['url' => $webhookUrl, 'text' => $text]);
            
            $response = Http::post($webhookUrl, $payload);
            
            if ($response->successful() && $response->body() === 'ok') {
                Log::info("[SlackService] Message webhook envoyé avec succès");
                return true;
            } else {
                Log::error("[SlackService] Erreur webhook Slack: " . $response->body());
                return false;
            }
            
        } catch (\Exception $e) {
            Log::error("[SlackService] Erreur sendWebhook: " . $e->getMessage());
            return false;
        }
    }

    /**
     * Remplace les variables dynamiques dans un texte
     * Ex: "Message: {trigger.text}" devient "Message: Hello"
     */
    private function replaceVariables(string $text, array $triggerData): string
    {
        foreach ($triggerData as $key => $value) {
            if (is_string($value) || is_numeric($value)) {
                $text = str_replace("{trigger.{$key}}", $value, $text);
            }
        }
        return $text;
    }
}
