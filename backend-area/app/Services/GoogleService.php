<?php

namespace App\Services;

use App\Interfaces\ServiceInterface;
use App\Helpers\OAuthHelper;
use App\Models\User;
use Google\Service\Gmail;
use Google\Service\Gmail\Message;
use Google\Service\Calendar;
use Illuminate\Support\Facades\Log;

class GoogleService implements ServiceInterface
{
    /**
     * Vérifie si un nouveau email Gmail a été reçu
     * 
     * @param string $actionName Le nom de l'action (ex: 'new_gmail_received')
     * @param array $params Paramètres du trigger (ex: ['last_email_id' => 'xyz'])
     * @param object|null $userToken L'objet User (pas UserService, mais l'utilisateur)
     * @return bool|array Retourne false si pas de nouvel email, sinon les données de l'email
     */
    public function checkTrigger(string $actionName, array $params, $userToken)
    {
        // Convertir le nom de l'action en snake_case pour comparaison
        $triggerKey = strtolower(str_replace(' ', '_', $actionName));
        Log::info("[GoogleService] checkTrigger START - actionName: '{$actionName}' (converted: '{$triggerKey}') pour user {$userToken->id}");
        
        // Trigger Gmail: Nouveau email reçu
        if (in_array($triggerKey, ['new_email', 'new_email_received', 'new_gmail_received'])) {
            return $this->checkNewEmail($params, $userToken);
        }
        
        // Trigger Calendar: Nouvel événement créé
        if (in_array($triggerKey, ['new_calendar_event', 'new_event'])) {
            return $this->checkNewCalendarEvent($params, $userToken);
        }
        
        return false;
    }

    /**
     * Vérifie si un nouvel événement Google Calendar a été créé
     * 
     * @param array $params Paramètres du trigger (calendar_id, last_event_id)
     * @param object $userToken L'objet User
     * @return bool|array Retourne false si pas de nouvel événement, sinon les données de l'événement
     */
    private function checkNewCalendarEvent(array $params, $userToken)
    {
        try {
            // 1. Récupérer le client Google valide
            $client = OAuthHelper::getValidGoogleClient($userToken);
            Log::info("[GoogleService] Client Google créé avec succès");
            
            $calendarService = new Calendar($client);
            Log::info("[GoogleService] Calendar service initialisé");

            // 2. Récupérer le calendar_id (par défaut 'primary')
            $calendarId = $params['calendar_id'] ?? 'primary';
            Log::info("[GoogleService] Calendar ID: {$calendarId}");

            // 3. Récupérer les événements récents (créés dans les dernières 5 minutes)
            $timeMin = (new \DateTime())->modify('-5 minutes')->format(\DateTime::RFC3339);
            
            $optParams = [
                'maxResults' => 10,
                'orderBy' => 'startTime',
                'singleEvents' => true,
                'timeMin' => $timeMin,
            ];

            Log::info("[GoogleService] Appel API Calendar listEvents...");
            $events = $calendarService->events->listEvents($calendarId, $optParams);
            Log::info("[GoogleService] Réponse API Calendar reçue");
            
            $eventsList = $events->getItems();

            if (empty($eventsList)) {
                Log::info("[GoogleService] Aucun nouvel événement Calendar pour user {$userToken->id}");
                return false;
            }

            Log::info("[GoogleService] " . count($eventsList) . " événement(s) trouvé(s)");

            // 4. Prendre l'événement le plus récent
            $latestEvent = $eventsList[0];
            $eventId = $latestEvent->getId();

            // 5. Vérifier si c'est un nouvel événement
            $lastEventId = $params['last_event_id'] ?? null;
            
            if ($lastEventId === $eventId) {
                Log::info("[GoogleService] Événement déjà traité (last_event_id={$lastEventId})");
                return false;
            }

            // 6. Extraire les informations de l'événement
            $summary = $latestEvent->getSummary() ?? 'Sans titre';
            $description = $latestEvent->getDescription() ?? '';
            $location = $latestEvent->getLocation() ?? '';
            
            $start = $latestEvent->getStart();
            $startDateTime = $start->getDateTime() ?? $start->getDate();
            
            $end = $latestEvent->getEnd();
            $endDateTime = $end->getDateTime() ?? $end->getDate();

            Log::info("[GoogleService] Nouvel événement Calendar détecté pour user {$userToken->id}: {$summary} (ID: {$eventId})");

            // 7. Retourner les données du nouvel événement
            return [
                'event_id' => $eventId,
                'summary' => $summary,
                'description' => $description,
                'location' => $location,
                'start' => $startDateTime,
                'end' => $endDateTime,
                'link' => $latestEvent->getHtmlLink(),
            ];

        } catch (\Exception $e) {
            Log::error("[GoogleService] Erreur checkNewCalendarEvent : " . $e->getMessage());
            Log::error("[GoogleService] Stack trace: " . $e->getTraceAsString());
            return false;
        }
    }

    /**
     * Vérifie si un nouveau email Gmail a été reçu
     * 
     * @param array $params Paramètres du trigger (last_email_id, from, subject)
     * @param object $userToken L'objet User
     * @return bool|array Retourne false si pas de nouvel email, sinon les données de l'email
     */
    private function checkNewEmail(array $params, $userToken)
    {
        try {
            // 1. Récupérer le client Google valide (avec refresh auto)
            $client = OAuthHelper::getValidGoogleClient($userToken);
            Log::info("[GoogleService] Client Google créé avec succès");
            
            $gmailService = new Gmail($client);
            Log::info("[GoogleService] Gmail service initialisé");

            // 2. Construire la requête Gmail
            $query = 'is:unread'; // Seulement les non-lus
            
            // Ajouter les filtres spécifiques si fournis
            if (!empty($params['from'])) {
                $from = $params['from'];
                $query .= " from:{$from}";
            }

            // Support de 'subject' et 'subject_contains'
            $subjectParam = $params['subject'] ?? $params['subject_contains'] ?? null;
            if (!empty($subjectParam)) {
                $query .= " subject:{$subjectParam}";
            }

            Log::info("[GoogleService] Query Gmail: {$query}");

            // 3. Récupérer les messages récents (max 5)
            $optParams = [
                'maxResults' => 5,
                'labelIds' => ['INBOX'], // Seulement la boîte de réception
                'q' => $query
            ];

            Log::info("[GoogleService] Appel API Gmail listUsersMessages...");
            $messages = $gmailService->users_messages->listUsersMessages('me', $optParams);
            Log::info("[GoogleService] Réponse API Gmail reçue");
            
            $messagesList = $messages->getMessages();

            if (empty($messagesList)) {
                Log::info("[GoogleService] Aucun nouveau message Gmail pour user {$userToken->id} avec les critères: {$query}");
                return false;
            }

            Log::info("[GoogleService] " . count($messagesList) . " message(s) trouvé(s)");

            // 4. Prendre le message le plus récent
            $latestMessage = $messagesList[0];
            $messageId = $latestMessage->getId();

            // 5. Vérifier si c'est un nouveau message (comparaison avec last_email_id)
            $lastEmailId = $params['last_email_id'] ?? null;
            
            if ($lastEmailId === $messageId) {
                // Pas de nouveau message
                Log::info("[GoogleService] Message déjà traité (last_email_id={$lastEmailId})");
                return false;
            }

            // 6. Récupérer les détails du message
            Log::info("[GoogleService] Récupération détails du message {$messageId}...");
            $message = $gmailService->users_messages->get('me', $messageId);
            $headers = $message->getPayload()->getHeaders();

            // Extraire les informations importantes
            $subject = '';
            $from = '';
            $date = '';

            foreach ($headers as $header) {
                $name = $header->getName();
                $value = $header->getValue();

                if ($name === 'Subject') {
                    $subject = $value;
                } elseif ($name === 'From') {
                    $from = $value;
                } elseif ($name === 'Date') {
                    $date = $value;
                }
            }

            Log::info("[GoogleService] Nouveau Gmail détecté pour user {$userToken->id}: From={$from}, Subject={$subject}");

            // 7. Retourner les données du nouveau message
            return [
                'message_id' => $messageId,
                'subject' => $subject,
                'from' => $from,
                'date' => $date,
                'snippet' => $message->getSnippet(), // Aperçu du contenu
            ];

        } catch (\GuzzleHttp\Exception\ConnectException $e) {
            Log::error("[GoogleService] Erreur de connexion Gmail API (timeout probable): " . $e->getMessage());
            return false;
        } catch (\GuzzleHttp\Exception\RequestException $e) {
            Log::error("[GoogleService] Erreur requête Gmail API: " . $e->getMessage());
            return false;
        } catch (\Exception $e) {
            Log::error("[GoogleService] Erreur checkTrigger Gmail : " . $e->getMessage());
            Log::error("[GoogleService] Stack trace: " . $e->getTraceAsString());
            return false;
        }
    }

    /**
     * Envoie un email via Gmail
     * 
     * @param string $reactionName Le nom de la réaction (ex: 'send_email')
     * @param array $params Paramètres de la réaction (to, subject, body)
     * @param object|null $userToken L'objet User
     * @param array $triggerData Les données du trigger (ex: les infos de l'email reçu)
     * @return bool True si succès, false sinon
     */
    public function executeReaction(string $reactionName, array $params, $userToken, array $triggerData)
    {
        Log::info("[GoogleService] executeReaction START - reactionName: '{$reactionName}' (length: " . strlen($reactionName) . "), params: " . json_encode($params));
        
        // Convertir le nom de la réaction en snake_case pour comparaison
        $actionKey = strtolower(str_replace(' ', '_', $reactionName));
        Log::info("[GoogleService] Converted reactionName to: '{$actionKey}'");
        
        if ($actionKey === 'send_email') {
            try {
                // 1. Valider les paramètres requis
                if (empty($params['to']) || empty($params['subject']) || empty($params['body'])) {
                    Log::error("[GoogleService] Paramètres manquants pour send_email");
                    return false;
                }

                Log::info("[GoogleService] send_email - to: {$params['to']}, subject: {$params['subject']}");

                // 2. Récupérer le client Google valide
                $client = OAuthHelper::getValidGoogleClient($userToken);
                Log::info("[GoogleService] Client Google obtenu");
                
                $gmailService = new Gmail($client);
                Log::info("[GoogleService] Gmail service initialisé");

                // 3. Construire le message email
                $to = $params['to'];
                $subject = $params['subject'];
                $body = $params['body'];

                // Remplacer les variables dynamiques avec les données du trigger
                // Ex: "Sujet: {trigger.subject}" devient "Sujet: Réunion demain"
                $subject = $this->replaceVariables($subject, $triggerData);
                $body = $this->replaceVariables($body, $triggerData);

                // Créer le message au format RFC 2822
                $rawMessage = "To: {$to}\r\n";
                $rawMessage .= "Subject: {$subject}\r\n";
                $rawMessage .= "Content-Type: text/html; charset=utf-8\r\n\r\n";
                $rawMessage .= $body;

                // Encoder en base64url
                $rawMessageEncoded = rtrim(strtr(base64_encode($rawMessage), '+/', '-_'), '=');

                // 4. Créer l'objet Message
                $message = new Message();
                $message->setRaw($rawMessageEncoded);

                // 5. Envoyer l'email
                $gmailService->users_messages->send('me', $message);

                Log::info("[GoogleService] Email envoyé avec succès à {$to} pour user {$userToken->id}");
                return true;

            } catch (\Exception $e) {
                Log::error("[GoogleService] Erreur executeReaction send_email : " . $e->getMessage());
                return false;
            }
        }

        return false;
    }

    /**
     * Remplace les variables dynamiques dans un texte
     * Ex: "Sujet: {trigger.subject}" avec triggerData['subject'] = "Test"
     *     devient "Sujet: Test"
     * 
     * @param string $text
     * @param array $triggerData
     * @return string
     */
    private function replaceVariables(string $text, array $triggerData): string
    {
        foreach ($triggerData as $key => $value) {
            $text = str_replace("{trigger.{$key}}", $value, $text);
        }
        return $text;
    }
}
