<?php

namespace App\Services;

use App\Interfaces\ServiceInterface;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Http;

class DiscordService implements ServiceInterface
{
    /**
     * Vérifie si un événement Discord s'est produit
     * 
     * Note: Discord nécessite un bot ou des webhooks pour les triggers en temps réel.
     * Pour simplifier, on utilise l'API Discord REST pour vérifier les nouveaux messages.
     * 
     * @param string $actionName Le nom de l'action (ex: 'new_message')
     * @param array $params Paramètres du trigger (channel_id, last_message_id, etc.)
     * @param object|null $userToken Token/Bot token Discord (peut être stocké dans params)
     * @return bool|array False si rien, ou les données de l'événement
     */
    public function checkTrigger(string $actionName, array $params, $userToken)
    {
        try {
            Log::info("[DiscordService] checkTrigger START - Action: {$actionName}");
            
            // Convertir le nom du trigger en snake_case pour comparaison
            $triggerKey = strtolower(str_replace(' ', '_', $actionName));

            switch ($triggerKey) {
                case 'new_message':
                case 'new_message_in_channel':
                    return $this->checkNewMessage($params, $userToken);
                
                case 'message_contains':
                    return $this->checkMessageContains($params, $userToken);
                
                case 'user_joined':
                case 'new_member':
                    // Note: Nécessite l'API Gateway de Discord (WebSocket)
                    // Pour une implémentation complète, utiliser un bot Discord
                    Log::info("[DiscordService] Trigger {$actionName} non implémenté (nécessite WebSocket)");
                    return false;
                
                default:
                    Log::warning("[DiscordService] Action inconnue: {$actionName}");
                    return false;
            }

        } catch (\Exception $e) {
            Log::error("[DiscordService] Erreur checkTrigger: " . $e->getMessage());
            return false;
        }
    }

    /**
     * Vérifie s'il y a un nouveau message dans un canal Discord
     */
    private function checkNewMessage(array $params, $userToken): bool|array
    {
        // Paramètres requis
        $botToken = $params['bot_token'] ?? null;
        $channelId = $params['channel_id'] ?? null;

        if (!$botToken || !$channelId) {
            Log::error("[DiscordService] bot_token ou channel_id manquant");
            return false;
        }

        try {
            // Récupérer les messages récents du canal
            $response = Http::withHeaders([
                'Authorization' => "Bot {$botToken}",
                'Content-Type' => 'application/json',
            ])->get("https://discord.com/api/v10/channels/{$channelId}/messages", [
                'limit' => 1, // Dernier message seulement
            ]);

            if (!$response->successful()) {
                Log::error("[DiscordService] Erreur API Discord: " . $response->body());
                return false;
            }

            $messages = $response->json();

            if (empty($messages)) {
                Log::info("[DiscordService] Aucun message dans le canal {$channelId}");
                return false;
            }

            $latestMessage = $messages[0];
            $messageId = $latestMessage['id'];

            // Vérifier si c'est un nouveau message
            $lastMessageId = $params['last_message_id'] ?? null;

            if ($lastMessageId === $messageId) {
                Log::info("[DiscordService] Message déjà traité: {$messageId}");
                return false;
            }

            Log::info("[DiscordService] Nouveau message détecté: {$messageId}");

            // Retourner les données du message
            return [
                'message_id' => $messageId,
                'content' => $latestMessage['content'] ?? '',
                'author' => $latestMessage['author']['username'] ?? 'Unknown',
                'author_id' => $latestMessage['author']['id'] ?? '',
                'channel_id' => $channelId,
                'timestamp' => $latestMessage['timestamp'] ?? '',
            ];

        } catch (\Exception $e) {
            Log::error("[DiscordService] Erreur checkNewMessage: " . $e->getMessage());
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
        $content = $messageData['content'] ?? '';

        // Vérifier si le mot-clé est présent dans le message
        if (empty($keyword) || stripos($content, $keyword) === false) {
            Log::info("[DiscordService] Mot-clé '{$keyword}' non trouvé dans le message");
            return false;
        }

        Log::info("[DiscordService] Mot-clé '{$keyword}' trouvé dans le message");
        return $messageData;
    }

    /**
     * Exécute une réaction Discord (envoyer un message, etc.)
     * 
     * @param string $reactionName Le nom de la réaction (ex: 'send_message')
     * @param array $params Paramètres (channel_id, content, etc.)
     * @param object|null $userToken
     * @param array $triggerData Données du trigger
     * @return bool
     */
    public function executeReaction(string $reactionName, array $params, $userToken, array $triggerData)
    {
        try {
            Log::info("[DiscordService] executeReaction START - Réaction: {$reactionName}");
            
            // Convertir le nom de la réaction en snake_case pour comparaison
            $actionKey = strtolower(str_replace(' ', '_', $reactionName));

            switch ($actionKey) {
                case 'send_message':
                case 'send_message_to_channel':
                    return $this->sendMessage($params, $triggerData);
                
                case 'send_webhook':
                    return $this->sendWebhook($params, $triggerData);
                
                case 'add_reaction':
                    return $this->addReaction($params, $triggerData);
                
                default:
                    Log::warning("[DiscordService] Réaction inconnue: {$reactionName}");
                    return false;
            }

        } catch (\Exception $e) {
            Log::error("[DiscordService] Erreur executeReaction: " . $e->getMessage());
            return false;
        }
    }

    /**
     * Envoie un message dans un canal Discord
     */
    private function sendMessage(array $params, array $triggerData): bool
    {
        // Détecter si channel_id est en fait une URL webhook
        $channelId = $params['channel_id'] ?? null;
        
        if ($channelId && str_starts_with($channelId, 'https://discord.com/api/webhooks/')) {
            // C'est un webhook, utiliser sendWebhook à la place
            Log::info("[DiscordService] channel_id est un webhook, redirection vers sendWebhook");
            $params['webhook_url'] = $channelId;
            return $this->sendWebhook($params, $triggerData);
        }
        
        $botToken = $params['bot_token'] ?? env('DISCORD_BOT_TOKEN');
        $content = $params['content'] ?? $params['message'] ?? '';

        if (!$botToken || !$channelId || empty($content)) {
            Log::error("[DiscordService] Paramètres manquants pour send_message. botToken: " . ($botToken ? 'OK' : 'MISSING') . ", channelId: {$channelId}, content: " . (empty($content) ? 'EMPTY' : 'OK'));
            return false;
        }

        // Remplacer les variables dynamiques
        $content = $this->replaceVariables($content, $triggerData);

        try {
            $response = Http::withHeaders([
                'Authorization' => "Bot {$botToken}",
                'Content-Type' => 'application/json',
            ])->post("https://discord.com/api/v10/channels/{$channelId}/messages", [
                'content' => $content,
            ]);

            if ($response->successful()) {
                Log::info("[DiscordService] Message envoyé avec succès au canal {$channelId}");
                return true;
            } else {
                Log::error("[DiscordService] Erreur lors de l'envoi du message: " . $response->body());
                return false;
            }

        } catch (\Exception $e) {
            Log::error("[DiscordService] Erreur sendMessage: " . $e->getMessage());
            return false;
        }
    }

    /**
     * Envoie un message via un webhook Discord
     */
    private function sendWebhook(array $params, array $triggerData): bool
    {
        $webhookUrl = $params['webhook_url'] ?? null;
        $content = $params['content'] ?? $params['message'] ?? '';
        $username = $params['username'] ?? 'AREA Bot';

        if (!$webhookUrl) {
            Log::error("[DiscordService] webhook_url manquant");
            return false;
        }

        // Remplacer les variables dynamiques
        $content = $this->replaceVariables($content, $triggerData);

        try {
            $payload = [
                'username' => $username,
            ];
            
            // Ajouter le content seulement s'il n'est pas vide
            if (!empty($content)) {
                $payload['content'] = $content;
            }

            // Ajouter un embed si fourni
            $embedTitle = $params['embed_title'] ?? $params['title'] ?? null;
            if (!empty($embedTitle)) {
                $embedDescription = $params['embed_description'] ?? $params['description'] ?? '';
                $embedColor = $params['embed_color'] ?? $params['color'] ?? 5814783;
                
                // Convertir la couleur : si c'est une chaîne numérique, la convertir en entier
                if (is_string($embedColor)) {
                    // Si c'est un nombre décimal en string (ex: "3447003")
                    if (is_numeric($embedColor)) {
                        $embedColor = (int)$embedColor;
                    }
                }
                
                $payload['embeds'] = [[
                    'title' => $this->replaceVariables($embedTitle, $triggerData),
                    'description' => $this->replaceVariables($embedDescription, $triggerData),
                    'color' => $embedColor,
                ]];
            }

            Log::info("[DiscordService] Payload webhook: " . json_encode($payload));
            $response = Http::post($webhookUrl, $payload);

            if ($response->successful()) {
                Log::info("[DiscordService] Message webhook envoyé avec succès");
                return true;
            } else {
                Log::error("[DiscordService] Erreur webhook: " . $response->body());
                return false;
            }

        } catch (\Exception $e) {
            Log::error("[DiscordService] Erreur sendWebhook: " . $e->getMessage());
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
        $messageId = $params['message_id'] ?? $triggerData['message_id'] ?? null;
        $emoji = $params['emoji'] ?? '👍';

        if (!$botToken || !$channelId || !$messageId) {
            Log::error("[DiscordService] Paramètres manquants pour add_reaction");
            return false;
        }

        try {
            // Encoder l'emoji pour l'URL
            $emojiEncoded = urlencode($emoji);

            $response = Http::withHeaders([
                'Authorization' => "Bot {$botToken}",
            ])->put("https://discord.com/api/v10/channels/{$channelId}/messages/{$messageId}/reactions/{$emojiEncoded}/@me");

            if ($response->successful()) {
                Log::info("[DiscordService] Réaction {$emoji} ajoutée au message {$messageId}");
                return true;
            } else {
                Log::error("[DiscordService] Erreur add_reaction: " . $response->body());
                return false;
            }

        } catch (\Exception $e) {
            Log::error("[DiscordService] Erreur addReaction: " . $e->getMessage());
            return false;
        }
    }

    /**
     * Remplace les variables dynamiques dans un texte
     * Ex: "Message: {trigger.content}" devient "Message: Hello"
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
