<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Google\Client as GoogleClient;
use Google\Service\Calendar;

class CalendarController extends Controller
{
    //
    /**
     * Récupère les 5 prochains événements Google Calendar
     * 
     * Get upcoming Google Calendar events for the authenticated user.
     *
     * @group Services
     * @authenticated
     * 
     * @response 200 {
     *   "events": [
     *     {
     *       "summary": "Team Meeting",
     *       "start": "2024-12-05T14:00:00Z",
     *       "end": "2024-12-05T15:00:00Z"
     *     }
     *   ]
     * }
     * 
     * @response 401 {
     *   "error": "Non connecté à Google"
     * }
     */
    public function getEvents(Request $request)
    {
        $user = $request->user();

        // Vérifie que l'utilisateur a un token Google
        if (!$user->google_token) {
            return response()->json(['error' => 'Non connecté à Google'], 401);
        }

        try {
            // Configure le client Google
            $client = new GoogleClient();
            $client->setAccessToken($user->google_token);

            // Si le token est expiré, le rafraîchir
            if ($client->isAccessTokenExpired()) {
                if ($user->google_refresh_token) {
                    $client->fetchAccessTokenWithRefreshToken($user->google_refresh_token);
                    $user->google_token = $client->getAccessToken();
                    $user->save();
                } else {
                    return response()->json(['error' => 'Token expiré'], 401);
                }
            }

            // Récupère les événements
            $service = new Calendar($client);
            $calendarId = 'primary';
            $optParams = [
                'maxResults' => 5,
                'orderBy' => 'startTime',
                'singleEvents' => true,
                'timeMin' => date('c'),
            ];

            $results = $service->events->listEvents($calendarId, $optParams);
            $events = $results->getItems();

            // Formate les événements pour le frontend
            $formattedEvents = array_map(function($event) {
                return [
                    'id' => $event->getId(),
                    'summary' => $event->getSummary(),
                    'start' => [
                        'dateTime' => $event->getStart()->getDateTime() ?? $event->getStart()->getDate(),
                    ],
                    'end' => [
                        'dateTime' => $event->getEnd()->getDateTime() ?? $event->getEnd()->getDate(),
                    ],
                ];
            }, $events);

            return response()->json($formattedEvents);

        } catch (\Exception $e) {
            return response()->json([
                'error' => 'Erreur lors de la récupération des événements',
                'message' => $e->getMessage()
            ], 500);
        }
    }
}
