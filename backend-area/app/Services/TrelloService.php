<?php

namespace App\Services;

use App\Interfaces\ServiceInterface;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

/**
 * TrelloService - Service de gestion des actions/réactions Trello
 * 
 * Ce service utilise l'API Trello pour :
 * - Détecter des événements (nouvelle carte, carte déplacée, carte complétée)
 * - Créer/modifier des cartes automatiquement
 * 
 * @author Asaph (Équipe AREA)
 * @version 1.0
 */
class TrelloService implements ServiceInterface
{
    /**
     * Clé API Trello (depuis .env)
     * @var string
     */
    private string $apiKey;

    /**
     * Token d'accès Trello (depuis .env)
     * @var string
     */
    private string $apiToken;

    /**
     * URL de base de l'API Trello
     * @var string
     */
    private string $baseUrl = 'https://api.trello.com/1';

    /**
     * Constructeur - Récupère les credentials depuis les variables d'environnement
     */
    public function __construct()
    {
        $this->apiKey = env('TRELLO_API_KEY', '');
        $this->apiToken = env('TRELLO_TOKEN', '');
        
        if (empty($this->apiKey) || empty($this->apiToken)) {
            Log::warning("[TrelloService] TRELLO_API_KEY ou TRELLO_TOKEN non configurés dans .env");
        }
    }

    /**
     * Vérifie si un trigger Trello est activé
     * 
     * Triggers supportés :
     * - new_card : Nouvelle carte créée dans un board/liste
     * - card_moved : Carte déplacée vers une liste spécifique
     * - card_completed : Carte marquée comme terminée (dans liste "Done")
     * - card_assigned : Carte assignée à un membre
     * 
     * @param string $actionName Le nom de l'action (ex: 'new_card')
     * @param array $params Paramètres du trigger (ex: ['board_id' => 'abc123', 'list_id' => 'xyz'])
     * @param object|null $userToken L'objet User (non utilisé pour Trello, credentials globaux)
     * @return bool|array Retourne false si non activé, sinon les données de la carte
     */
    public function checkTrigger(string $actionName, array $params, $userToken)
    {
        try {
            Log::info("[TrelloService] checkTrigger START - Action: {$actionName}");
            
            // Convertir le nom du trigger en snake_case pour comparaison
            $triggerKey = strtolower(str_replace(' ', '_', $actionName));

            // Valider les credentials
            if (empty($this->apiKey) || empty($this->apiToken)) {
                Log::error("[TrelloService] Credentials Trello manquants");
                return false;
            }

            // Vérifier selon le type d'action
            switch ($triggerKey) {
                case 'new_card':
                    return $this->checkNewCard($params);

                case 'card_moved':
                    return $this->checkCardMoved($params);

                case 'card_completed':
                    return $this->checkCardCompleted($params);

                case 'card_assigned':
                    return $this->checkCardAssigned($params);

                default:
                    Log::warning("[TrelloService] Action inconnue : {$actionName}");
                    return false;
            }

        } catch (\Exception $e) {
            Log::error("[TrelloService] Erreur checkTrigger : " . $e->getMessage());
            return false;
        }
    }

    /**
     * Exécute une réaction Trello
     * 
     * REActions supportées :
     * - create_card : Créer une nouvelle carte
     * - move_card : Déplacer une carte vers une autre liste
     * - add_comment : Ajouter un commentaire à une carte
     * - archive_card : Archiver une carte
     * - update_card : Mettre à jour une carte existante
     * 
     * @param string $reactionName Le nom de la réaction
     * @param array $params Paramètres de la réaction
     * @param object|null $userToken L'objet User
     * @param array $triggerData Les données du trigger qui a déclenché cette réaction
     * @return bool True si succès, false sinon
     */
    public function executeReaction(string $reactionName, array $params, $userToken, array $triggerData)
    {
        try {
            Log::info("[TrelloService] executeReaction START - Reaction: {$reactionName}");
            
            // Convertir le nom de la réaction en snake_case pour comparaison
            $actionKey = strtolower(str_replace(' ', '_', $reactionName));

            // Valider les credentials
            if (empty($this->apiKey) || empty($this->apiToken)) {
                throw new \Exception("Credentials Trello manquants");
            }

            switch ($actionKey) {
                case 'create_card':
                    return $this->createCard($params, $triggerData);

                case 'move_card':
                    return $this->moveCard($params, $triggerData);

                case 'add_comment':
                    return $this->addComment($params, $triggerData);

                case 'archive_card':
                    return $this->archiveCard($params, $triggerData);

                case 'update_card':
                    return $this->updateCard($params, $triggerData);

                default:
                    Log::warning("[TrelloService] Réaction inconnue : {$reactionName}");
                    return false;
            }

        } catch (\Exception $e) {
            Log::error("[TrelloService] Erreur executeReaction : " . $e->getMessage());
            throw $e;
        }
    }

    /**
     * Vérifie si une nouvelle carte a été créée
     * 
     * Compare l'ID de la carte la plus récente avec last_card_id stocké
     * 
     * @param array $params Paramètres (board_id, list_id optionnel, last_card_id)
     * @return bool|array
     */
    private function checkNewCard(array $params)
    {
        $boardId = $params['board_id'] ?? null;
        $listId = $params['list_id'] ?? null; // Optionnel : filtrer par liste
        $lastCardId = $params['last_card_id'] ?? null; // ID dernière carte connue

        if (!$boardId) {
            Log::error("[TrelloService] board_id manquant pour new_card");
            return false;
        }

        // Récupérer les cartes du board (ou d'une liste spécifique)
        $cards = $this->getBoardCards($boardId, $listId);

        if (empty($cards)) {
            Log::info("[TrelloService] Aucune carte trouvée");
            return false;
        }

        // Trier par date de création (plus récent en premier)
        usort($cards, function($a, $b) {
            return strtotime($b['dateLastActivity']) - strtotime($a['dateLastActivity']);
        });

        $latestCard = $cards[0];

        // Vérifier si c'est une nouvelle carte
        if ($lastCardId && $latestCard['id'] === $lastCardId) {
            Log::info("[TrelloService] ❌ Pas de nouvelle carte (last: {$lastCardId})");
            return false;
        }

        Log::info("[TrelloService] ✅ Nouvelle carte détectée : {$latestCard['name']} ({$latestCard['id']})");

        return [
            'card_id' => $latestCard['id'],
            'card_name' => $latestCard['name'],
            'card_url' => $latestCard['url'],
            'card_short_url' => $latestCard['shortUrl'],
            'list_id' => $latestCard['idList'],
            'board_id' => $boardId,
            'description' => $latestCard['desc'] ?? '',
            'due_date' => $latestCard['due'] ?? null,
            'labels' => array_map(fn($l) => $l['name'], $latestCard['labels'] ?? []),
            'members' => count($latestCard['idMembers'] ?? []),
            'triggered_at' => now()->toIso8601String(),
            'last_card_id' => $latestCard['id'], // Pour le prochain check
            'trigger_type' => 'new_card'
        ];
    }

    /**
     * Vérifie si une carte a été déplacée vers une liste spécifique
     * 
     * @param array $params Paramètres (board_id, target_list_id, tracked_card_ids)
     * @return bool|array
     */
    private function checkCardMoved(array $params)
    {
        $boardId = $params['board_id'] ?? null;
        $targetListId = $params['target_list_id'] ?? null;
        $trackedCardIds = $params['tracked_card_ids'] ?? []; // Cartes déjà traitées

        if (!$boardId || !$targetListId) {
            Log::error("[TrelloService] board_id ou target_list_id manquant pour card_moved");
            return false;
        }

        // Récupérer les cartes de la liste cible
        $cards = $this->getBoardCards($boardId, $targetListId);

        // Trouver une carte qui n'était pas dans tracked_card_ids
        foreach ($cards as $card) {
            if (!in_array($card['id'], $trackedCardIds)) {
                Log::info("[TrelloService] ✅ Carte déplacée : {$card['name']} vers liste {$targetListId}");

                return [
                    'card_id' => $card['id'],
                    'card_name' => $card['name'],
                    'card_url' => $card['url'],
                    'moved_to_list' => $targetListId,
                    'board_id' => $boardId,
                    'triggered_at' => now()->toIso8601String(),
                    'tracked_card_ids' => array_merge($trackedCardIds, [$card['id']]),
                    'trigger_type' => 'card_moved'
                ];
            }
        }

        Log::info("[TrelloService] ❌ Aucune nouvelle carte dans la liste cible");
        return false;
    }

    /**
     * Vérifie si une carte est dans la liste "Done" (complétée)
     * 
     * @param array $params Paramètres (board_id, done_list_name, tracked_card_ids)
     * @return bool|array
     */
    private function checkCardCompleted(array $params)
    {
        $boardId = $params['board_id'] ?? null;
        $doneListName = $params['done_list_name'] ?? 'Done';

        if (!$boardId) {
            Log::error("[TrelloService] board_id manquant pour card_completed");
            return false;
        }

        // Trouver l'ID de la liste "Done"
        $lists = $this->getBoardLists($boardId);
        $doneListId = null;

        foreach ($lists as $list) {
            if (stripos($list['name'], $doneListName) !== false) {
                $doneListId = $list['id'];
                Log::info("[TrelloService] Liste 'Done' trouvée : {$list['name']} ({$doneListId})");
                break;
            }
        }

        if (!$doneListId) {
            Log::warning("[TrelloService] Liste '{$doneListName}' non trouvée dans le board");
            return false;
        }

        // Utiliser checkCardMoved pour détecter les cartes dans "Done"
        return $this->checkCardMoved([
            'board_id' => $boardId,
            'target_list_id' => $doneListId,
            'tracked_card_ids' => $params['tracked_card_ids'] ?? []
        ]);
    }

    /**
     * Vérifie si une carte a été assignée à un membre
     * 
     * @param array $params Paramètres (board_id, member_id, tracked_card_ids)
     * @return bool|array
     */
    private function checkCardAssigned(array $params)
    {
        $boardId = $params['board_id'] ?? null;
        $memberId = $params['member_id'] ?? null; // Optionnel : filtrer par membre
        $trackedCardIds = $params['tracked_card_ids'] ?? [];

        if (!$boardId) {
            Log::error("[TrelloService] board_id manquant pour card_assigned");
            return false;
        }

        $cards = $this->getBoardCards($boardId);

        foreach ($cards as $card) {
            $members = $card['idMembers'] ?? [];

            // Si pas de membre spécifié, vérifier si la carte a au moins 1 membre
            $isAssigned = $memberId ? in_array($memberId, $members) : !empty($members);

            if ($isAssigned && !in_array($card['id'], $trackedCardIds)) {
                Log::info("[TrelloService] ✅ Carte assignée : {$card['name']}");

                return [
                    'card_id' => $card['id'],
                    'card_name' => $card['name'],
                    'card_url' => $card['url'],
                    'assigned_members' => $members,
                    'board_id' => $boardId,
                    'triggered_at' => now()->toIso8601String(),
                    'tracked_card_ids' => array_merge($trackedCardIds, [$card['id']]),
                    'trigger_type' => 'card_assigned'
                ];
            }
        }

        Log::info("[TrelloService] ❌ Aucune nouvelle carte assignée");
        return false;
    }

    /**
     * Créer une nouvelle carte Trello (REAction)
     * 
     * @param array $params Paramètres (list_id, name, description)
     * @param array $triggerData Données du trigger
     * @return bool
     */
    private function createCard(array $params, array $triggerData): bool
    {
        $name = $params['name'] ?? 'Nouvelle tâche';
        $description = $params['description'] ?? '';
        $listId = $params['list_id'] ?? null;
        $boardId = $params['board_id'] ?? null;
        $dueDate = $params['due_date'] ?? null;
        $labels = $params['labels'] ?? null; // IDs de labels (comma-separated)

        // Si pas de list_id, prendre la première liste du board
        if (!$listId && $boardId) {
            $lists = $this->getBoardLists($boardId);
            $listId = $lists[0]['id'] ?? null;
            Log::info("[TrelloService] list_id non fourni, utilisation de la première liste : {$listId}");
        }

        if (!$listId) {
            throw new \Exception("list_id ou board_id requis pour créer une carte");
        }

        // Remplacer les variables dynamiques dans name et description
        $name = $this->replaceVariables($name, $triggerData);
        $description = $this->replaceVariables($description, $triggerData);

        Log::info("[TrelloService] Création carte : '{$name}' dans liste {$listId}");
        Log::info("[TrelloService] API Key: " . substr($this->apiKey, 0, 8) . "... | Token: " . substr($this->apiToken, 0, 10) . "...");

        $data = [
            'key' => $this->apiKey,
            'token' => $this->apiToken,
            'idList' => $listId,
            'name' => $name,
            'desc' => $description,
        ];

        // Ajouter due date si fournie
        if ($dueDate) {
            $data['due'] = $dueDate;
        }

        // Ajouter labels si fournis
        if ($labels) {
            $data['idLabels'] = $labels;
        }

        $response = Http::post("{$this->baseUrl}/cards", $data);

        if ($response->successful()) {
            $card = $response->json();
            Log::info("[TrelloService] ✅ Carte créée : {$card['name']} ({$card['shortUrl']})");
            return true;
        }

        $error = $response->json()['message'] ?? $response->body();
        throw new \Exception("Échec création carte : {$error}");
    }

    /**
     * Déplacer une carte vers une autre liste (REAction)
     * 
     * @param array $params Paramètres (card_id, target_list_id)
     * @param array $triggerData Données du trigger
     * @return bool
     */
    private function moveCard(array $params, array $triggerData): bool
    {
        $cardId = $params['card_id'] ?? $triggerData['card_id'] ?? null;
        $targetListId = $params['target_list_id'] ?? null;

        if (!$cardId || !$targetListId) {
            throw new \Exception("card_id et target_list_id requis pour déplacer une carte");
        }

        Log::info("[TrelloService] Déplacement carte {$cardId} vers liste {$targetListId}");

        $response = Http::put("{$this->baseUrl}/cards/{$cardId}", [
            'key' => $this->apiKey,
            'token' => $this->apiToken,
            'idList' => $targetListId,
        ]);

        if ($response->successful()) {
            Log::info("[TrelloService] ✅ Carte déplacée avec succès");
            return true;
        }

        $error = $response->json()['message'] ?? $response->body();
        throw new \Exception("Échec déplacement carte : {$error}");
    }

    /**
     * Ajouter un commentaire à une carte (REAction)
     * 
     * @param array $params Paramètres (card_id, comment)
     * @param array $triggerData Données du trigger
     * @return bool
     */
    private function addComment(array $params, array $triggerData): bool
    {
        $cardId = $params['card_id'] ?? $triggerData['card_id'] ?? null;
        $comment = $params['comment'] ?? 'Commentaire automatique';

        if (!$cardId) {
            throw new \Exception("card_id requis pour ajouter un commentaire");
        }

        // Remplacer les variables dynamiques
        $comment = $this->replaceVariables($comment, $triggerData);

        Log::info("[TrelloService] Ajout commentaire sur carte {$cardId}");

        $response = Http::post("{$this->baseUrl}/cards/{$cardId}/actions/comments", [
            'key' => $this->apiKey,
            'token' => $this->apiToken,
            'text' => $comment,
        ]);

        if ($response->successful()) {
            Log::info("[TrelloService] ✅ Commentaire ajouté");
            return true;
        }

        $error = $response->json()['message'] ?? $response->body();
        throw new \Exception("Échec ajout commentaire : {$error}");
    }

    /**
     * Archiver une carte (REAction)
     * 
     * @param array $params Paramètres (card_id)
     * @param array $triggerData Données du trigger
     * @return bool
     */
    private function archiveCard(array $params, array $triggerData): bool
    {
        $cardId = $params['card_id'] ?? $triggerData['card_id'] ?? null;

        if (!$cardId) {
            throw new \Exception("card_id requis pour archiver une carte");
        }

        Log::info("[TrelloService] Archivage carte {$cardId}");

        $response = Http::put("{$this->baseUrl}/cards/{$cardId}", [
            'key' => $this->apiKey,
            'token' => $this->apiToken,
            'closed' => 'true',
        ]);

        if ($response->successful()) {
            Log::info("[TrelloService] ✅ Carte archivée");
            return true;
        }

        $error = $response->json()['message'] ?? $response->body();
        throw new \Exception("Échec archivage carte : {$error}");
    }

    /**
     * Mettre à jour une carte existante (REAction)
     * 
     * @param array $params Paramètres (card_id, name, description, due_date)
     * @param array $triggerData Données du trigger
     * @return bool
     */
    private function updateCard(array $params, array $triggerData): bool
    {
        $cardId = $params['card_id'] ?? $triggerData['card_id'] ?? null;

        if (!$cardId) {
            throw new \Exception("card_id requis pour mettre à jour une carte");
        }

        $data = [
            'key' => $this->apiKey,
            'token' => $this->apiToken,
        ];

        // Ajouter les champs à mettre à jour
        if (isset($params['name'])) {
            $data['name'] = $this->replaceVariables($params['name'], $triggerData);
        }
        if (isset($params['description'])) {
            $data['desc'] = $this->replaceVariables($params['description'], $triggerData);
        }
        if (isset($params['due_date'])) {
            $data['due'] = $params['due_date'];
        }

        Log::info("[TrelloService] Mise à jour carte {$cardId}");

        $response = Http::put("{$this->baseUrl}/cards/{$cardId}", $data);

        if ($response->successful()) {
            Log::info("[TrelloService] ✅ Carte mise à jour");
            return true;
        }

        $error = $response->json()['message'] ?? $response->body();
        throw new \Exception("Échec mise à jour carte : {$error}");
    }

    /**
     * Récupérer les cartes d'un board (avec filtre optionnel par liste)
     * 
     * @param string $boardId ID du board
     * @param string|null $listId ID de la liste (optionnel)
     * @return array Liste des cartes
     */
    private function getBoardCards(string $boardId, ?string $listId = null): array
    {
        $url = "{$this->baseUrl}/boards/{$boardId}/cards";

        $params = [
            'key' => $this->apiKey,
            'token' => $this->apiToken,
            'filter' => 'open', // Seulement les cartes non archivées
            'fields' => 'id,name,desc,url,shortUrl,idList,due,labels,idMembers,dateLastActivity',
        ];

        $response = Http::timeout(15)->get($url, $params);

        if (!$response->successful()) {
            $error = $response->json()['message'] ?? $response->body();
            throw new \Exception("Échec récupération cartes : {$error}");
        }

        $cards = $response->json();

        // Filtrer par liste si spécifié
        if ($listId) {
            $cards = array_filter($cards, fn($card) => $card['idList'] === $listId);
        }

        Log::info("[TrelloService] " . count($cards) . " carte(s) récupérée(s)");

        return array_values($cards);
    }

    /**
     * Récupérer les listes d'un board
     * 
     * @param string $boardId ID du board
     * @return array Liste des listes
     */
    private function getBoardLists(string $boardId): array
    {
        $response = Http::timeout(10)->get("{$this->baseUrl}/boards/{$boardId}/lists", [
            'key' => $this->apiKey,
            'token' => $this->apiToken,
            'filter' => 'open',
            'fields' => 'id,name,pos',
        ]);

        if (!$response->successful()) {
            $error = $response->json()['message'] ?? $response->body();
            throw new \Exception("Échec récupération listes : {$error}");
        }

        $lists = $response->json();
        Log::info("[TrelloService] " . count($lists) . " liste(s) récupérée(s)");

        return $lists;
    }

    /**
     * Remplacer les variables dynamiques dans un texte
     * 
     * Exemple : "Alerte : {temperature}°C" + {temperature: 32} → "Alerte : 32°C"
     * 
     * @param string $text Texte avec variables {var}
     * @param array $data Données pour remplacer les variables
     * @return string Texte avec variables remplacées
     */
    private function replaceVariables(string $text, array $data): string
    {
        foreach ($data as $key => $value) {
            if (is_scalar($value)) {
                $text = str_replace("{{$key}}", (string) $value, $text);
            } elseif (is_array($value)) {
                // Pour les arrays, convertir en string (ex: labels)
                $text = str_replace("{{$key}}", implode(', ', $value), $text);
            }
        }
        return $text;
    }
}
