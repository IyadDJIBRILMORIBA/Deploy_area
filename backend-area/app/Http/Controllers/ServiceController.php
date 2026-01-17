<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Service;
use App\Models\UserService;
use Illuminate\Support\Facades\Validator;

class ServiceController extends Controller
{
    /**
     * Get all available services
     * 
     * Returns a list of all available services in the AREA platform,
     * including their connection status for the authenticated user.
     *
     * @group Services
     * @authenticated
     * 
     * @response 200 {
     *   "services": [
     *     {
     *       "id": 1,
     *       "name": "google",
     *       "description": "Google Workspace services (Gmail, Calendar, Drive)",
     *       "icon": "https://www.google.com/favicon.ico",
     *       "color": "#4285F4",
     *       "category": "productivity",
     *       "is_connected": true,
     *       "requires_auth": true
     *     },
     *     {
     *       "id": 2,
     *       "name": "timer",
     *       "description": "Schedule actions based on time intervals",
     *       "icon": "⏰",
     *       "color": "#FF6B6B",
     *       "category": "utility",
     *       "is_connected": false,
     *       "requires_auth": false
     *     }
     *   ]
     * }
     */
    public function index(Request $request)
    {
        $user = $request->user();
        
        // Récupérer tous les services actifs
        $services = Service::where('is_active', true)->get();
        
        // Vérifier quels services sont connectés ET ont un token valide
        $userServices = UserService::where('user_id', $user->id)->get();
        $validConnectedServiceIds = $userServices->filter(function ($userService) {
            // Si pas d'expiration définie, le service est connecté
            if (is_null($userService->expires_at)) {
                return true;
            }
            // expires_at est déjà un Carbon grâce au cast, on utilise isPast() au lieu de isFuture()
            // car on veut exclure les tokens expirés
            $isValid = !$userService->expires_at->isPast();
            \Log::info("[ServiceController] Service {$userService->service_id}: expires=" . $userService->expires_at->toDateTimeString() . ", now=" . now()->toDateTimeString() . ", valid=" . ($isValid ? 'OUI' : 'NON'));
            return $isValid;
        })->pluck('service_id')->toArray();
        
        $servicesWithStatus = $services->map(function ($service) use ($validConnectedServiceIds) {
            return [
                'id' => $service->id,
                'name' => $service->name,
                'description' => $service->description ?? $this->getServiceDescription($service->name),
                'icon' => $service->icon ?? $this->getServiceIcon($service->name),
                'color' => $this->getServiceColor($service->name),
                'category' => $this->getServiceCategory($service->name),
                'is_connected' => in_array($service->id, $validConnectedServiceIds),
                'requires_auth' => $this->requiresAuth($service->name),
            ];
        });
        
        return response()->json(['services' => $servicesWithStatus], 200);
    }

    /**
     * Get service details with available triggers and actions
     * 
     * Returns detailed information about a specific service including
     * all available triggers (actions that can start an automation)
     * and actions (reactions that can be executed).
     *
     * @group Services
     * @authenticated
     * 
     * @urlParam serviceId integer required The ID of the service. Example: 1
     * 
     * @response 200 {
     *   "service": {
     *     "id": 1,
     *     "name": "google",
     *     "description": "Google Workspace services",
     *     "triggers": [
     *       {
     *         "id": "new_email",
     *         "name": "New Email Received",
     *         "description": "Triggered when a new email arrives in Gmail",
     *         "config_schema": {
     *           "from": { "type": "string", "required": false, "description": "Filter by sender email" },
     *           "subject_contains": { "type": "string", "required": false, "description": "Filter by subject keywords" }
     *         }
     *       },
     *       {
     *         "id": "new_calendar_event",
     *         "name": "New Calendar Event",
     *         "description": "Triggered when a new event is created in Google Calendar",
     *         "config_schema": {
     *           "calendar_id": { "type": "string", "required": false, "default": "primary" }
     *         }
     *       }
     *     ],
     *     "actions": [
     *       {
     *         "id": "send_email",
     *         "name": "Send Email",
     *         "description": "Send an email via Gmail",
     *         "config_schema": {
     *           "to": { "type": "string", "required": true, "description": "Recipient email address" },
     *           "subject": { "type": "string", "required": true, "description": "Email subject" },
     *           "body": { "type": "string", "required": true, "description": "Email body content" }
     *         }
     *       },
     *       {
     *         "id": "create_calendar_event",
     *         "name": "Create Calendar Event",
     *         "description": "Create a new event in Google Calendar",
     *         "config_schema": {
     *           "title": { "type": "string", "required": true },
     *           "start_time": { "type": "datetime", "required": true },
     *           "end_time": { "type": "datetime", "required": true },
     *           "description": { "type": "string", "required": false }
     *         }
     *       }
     *     ]
     *   }
     * }
     * 
     * @response 404 {
     *   "message": "Service not found"
     * }
     */
    public function show(Request $request, $serviceId)
    {
        $service = Service::find($serviceId);
        
        if (!$service) {
            return response()->json(['message' => 'Service not found'], 404);
        }
        
        $serviceDetails = [
            'id' => $service->id,
            'name' => $service->name,
            'description' => $service->description ?? $this->getServiceDescription($service->name),
            'icon' => $service->icon ?? $this->getServiceIcon($service->name),
            'triggers' => $this->getServiceTriggers($service->name),
            'actions' => $this->getServiceActions($service->name),
        ];
        
        return response()->json(['service' => $serviceDetails], 200);
    }

    /**
     * Connect a service via OAuth
     * 
     * Initiates or completes the OAuth connection process for a service.
     * Returns the OAuth URL if not yet connected, or saves the connection
     * if auth_code is provided.
     *
     * @group Services
     * @authenticated
     * 
     * @urlParam serviceId integer required The ID of the service to connect. Example: 1
     * 
     * @bodyParam auth_code string optional The OAuth authorization code (for completing connection).
     * @bodyParam access_token string optional The OAuth access token (for mobile flow).
     * @bodyParam refresh_token string optional The OAuth refresh token.
     * 
     * @response 200 {
     *   "message": "OAuth URL generated",
     *   "oauth_url": "https://accounts.google.com/o/oauth2/auth?..."
     * }
     * 
     * @response 201 {
     *   "message": "Service connected successfully",
     *   "connection": {
     *     "id": 1,
     *     "service_id": 1,
     *     "service_name": "google",
     *     "connected_at": "2025-12-06T10:30:00Z"
     *   }
     * }
     * 
     * @response 404 {
     *   "message": "Service not found"
     * }
     */
    public function connect(Request $request, $serviceId)
    {
        $user = $request->user();
        $service = Service::find($serviceId);
        
        if (!$service) {
            return response()->json(['message' => 'Service not found'], 404);
        }
        
        // Si le service ne nécessite pas d'auth (ex: Timer)
        if (!$this->requiresAuth($service->name)) {
            // Créer une connexion "virtuelle"
            $userService = UserService::updateOrCreate(
                [
                    'user_id' => $user->id,
                    'service_id' => $service->id,
                ],
                [
                    'access_token' => 'not_required',
                    'name' => $service->name . ' (Active)',
                ]
            );
            
            return response()->json([
                'message' => 'Service connected successfully',
                'connection' => [
                    'id' => $userService->id,
                    'service_id' => $service->id,
                    'service_name' => $service->name,
                    'connected_at' => $userService->created_at->toIso8601String(),
                ],
            ], 201);
        }
        
        // Si un token est fourni directement (flux mobile)
        if ($request->has('access_token')) {
            $validator = Validator::make($request->all(), [
                'access_token' => 'required|string',
                'refresh_token' => 'nullable|string',
                'expires_at' => 'nullable|integer',
            ]);
            
            if ($validator->fails()) {
                return response()->json([
                    'message' => 'Validation failed',
                    'errors' => $validator->errors()
                ], 422);
            }
            
            $userService = UserService::updateOrCreate(
                [
                    'user_id' => $user->id,
                    'service_id' => $service->id,
                ],
                [
                    'access_token' => $request->access_token,
                    'refresh_token' => $request->refresh_token,
                    'expires_at' => $request->expires_at ? now()->addSeconds($request->expires_at) : null,
                    'name' => $service->name,
                ]
            );
            
            return response()->json([
                'message' => 'Service connected successfully',
                'connection' => [
                    'id' => $userService->id,
                    'service_id' => $service->id,
                    'service_name' => $service->name,
                    'connected_at' => $userService->created_at->toIso8601String(),
                ],
            ], 201);
        }
        
        // Sinon, retourner l'URL OAuth (flux web)
        $oauthUrl = $this->getOAuthUrl($service->name, $user->id);
        
        return response()->json([
            'message' => 'OAuth URL generated',
            'oauth_url' => $oauthUrl,
        ], 200);
    }

    /**
     * Disconnect a service
     * 
     * Removes the OAuth connection between the user and the service.
     * All AREAs using this service will be deactivated.
     *
     * @group Services
     * @authenticated
     * 
     * @urlParam serviceId integer required The ID of the service to disconnect. Example: 1
     * 
     * @response 200 {
     *   "message": "Service disconnected successfully"
     * }
     * 
     * @response 404 {
     *   "message": "Service connection not found"
     * }
     */
    public function disconnect(Request $request, $serviceId)
    {
        $user = $request->user();
        
        $userService = UserService::where('user_id', $user->id)
            ->where('service_id', $serviceId)
            ->first();
        
        if (!$userService) {
            return response()->json(['message' => 'Service connection not found'], 404);
        }
        
        // Désactiver toutes les AREAs qui utilisent ce service
        \App\Models\Area::where('user_id', $user->id)
            ->where(function ($query) use ($serviceId) {
                $service = Service::find($serviceId);
                if ($service) {
                    $query->where('trigger_service', $service->name)
                          ->orWhere('action_service', $service->name);
                }
            })
            ->update(['is_active' => false]);
        
        $userService->delete();
        
        return response()->json(['message' => 'Service disconnected successfully'], 200);
    }

    /**
     * Get user's connected services
     * 
     * Returns a list of all services that the user has connected to their account.
     *
     * @group Services
     * @authenticated
     * 
     * @response 200 {
     *   "services": [
     *     {
     *       "service_id": 1,
     *       "service_name": "google",
     *       "connected_at": "2025-12-01T08:00:00Z",
     *       "status": "active"
     *     },
     *     {
     *       "service_id": 3,
     *       "service_name": "github",
     *       "connected_at": "2025-11-28T14:30:00Z",
     *       "status": "expired"
     *     }
     *   ]
     * }
     */
    public function getUserServices(Request $request)
    {
        $user = $request->user();
        
        $userServices = UserService::where('user_id', $user->id)
            ->with('service')
            ->get();
        
        $services = $userServices->map(function ($userService) {
            $status = 'active';
            
            // Vérifier si le token a expiré
            if ($userService->expires_at && $userService->expires_at->isPast()) {
                $status = 'expired';
            }
            
            return [
                'service_id' => $userService->service_id,
                'service_name' => $userService->service->name ?? 'Unknown',
                'connected_at' => $userService->created_at->toIso8601String(),
                'status' => $status,
            ];
        });
        
        return response()->json(['services' => $services], 200);
    }

    // ========== HELPER METHODS ==========

    /**
     * Get service description based on service name
     */
    private function getServiceDescription($serviceName)
    {
        $descriptions = [
            'google' => 'Google Workspace services (Gmail, Calendar, Drive)',
            'timer' => 'Schedule actions based on time intervals',
            'github' => 'GitHub repository events and actions',
            'slack' => 'Slack messaging and notifications',
            'discord' => 'Discord messaging and server management',
            'twitch' => 'Twitch streaming and channel notifications',
            'weather' => 'Weather information and alerts',
            'trello' => 'Trello board and card management',
        ];
        
        return $descriptions[$serviceName] ?? 'Third-party service integration';
    }

    /**
     * Get service icon
     */
    private function getServiceIcon($serviceName)
    {
        $icons = [
            'google' => 'https://www.google.com/favicon.ico',
            'timer' => '⏰',
            'github' => 'https://github.com/favicon.ico',
            'slack' => 'https://slack.com/favicon.ico',
            'discord' => 'https://discord.com/assets/favicon.ico',
            'twitch' => 'https://static.twitchcdn.net/assets/favicon-32-e29e246c157142c94346.png',
            'weather' => '🌤️',
            'trello' => 'https://trello.com/favicon.ico',
        ];
        
        return $icons[$serviceName] ?? '🔌';
    }

    /**
     * Get service color
     */
    private function getServiceColor($serviceName)
    {
        $colors = [
            'google' => '#4285F4',
            'timer' => '#FF6B6B',
            'github' => '#181717',
            'slack' => '#4A154B',
            'discord' => '#5865F2',
            'twitch' => '#9146FF',
            'weather' => '#FFA500',
            'trello' => '#0079BF',
        ];
        
        return $colors[$serviceName] ?? '#6C757D';
    }

    /**
     * Get service category
     */
    private function getServiceCategory($serviceName)
    {
        $categories = [
            'google' => 'productivity',
            'timer' => 'utility',
            'github' => 'developer',
            'slack' => 'communication',
            'discord' => 'communication',
            'twitch' => 'entertainment',
            'weather' => 'utility',
            'trello' => 'productivity',
        ];
        
        return $categories[$serviceName] ?? 'other';
    }

    /**
     * Check if service requires authentication
     */
    private function requiresAuth($serviceName)
    {
        $noAuthServices = ['timer', 'weather', 'trello'];
        return !in_array($serviceName, $noAuthServices);
    }

    /**
     * Get available triggers for a service
     */
    private function getServiceTriggers($serviceName)
    {
        $triggers = [
            'google' => [
                [
                    'id' => 'new_email',
                    'name' => 'New Email Received',
                    'description' => 'Triggered when a new email arrives in Gmail',
                    'config_schema' => [
                        'from' => [
                            'type' => 'string',
                            'required' => false,
                            'description' => 'Filter by sender email address',
                        ],
                        'subject_contains' => [
                            'type' => 'string',
                            'required' => false,
                            'description' => 'Filter by keywords in subject',
                        ],
                    ],
                ],
                [
                    'id' => 'new_calendar_event',
                    'name' => 'New Calendar Event',
                    'description' => 'Triggered when a new event is created in Google Calendar',
                    'config_schema' => [
                        'calendar_id' => [
                            'type' => 'string',
                            'required' => false,
                            'default' => 'primary',
                            'description' => 'Google Calendar ID',
                        ],
                    ],
                ],
            ],
            'timer' => [
                [
                    'id' => 'timer_trigger',
                    'name' => 'Timer Trigger',
                    'description' => 'Triggered at specified intervals (cron-based)',
                    'config_schema' => [
                        'interval' => [
                            'type' => 'string',
                            'required' => true,
                            'enum' => ['every_minute', 'every_5_minutes', 'every_hour', 'every_day'],
                            'description' => 'Time interval for trigger',
                        ],
                    ],
                ],
            ],
            'github' => [
                [
                    'id' => 'new_issue',
                    'name' => 'New Issue Created',
                    'description' => 'Triggered when a new issue is created in a repository',
                    'config_schema' => [
                        'repository' => [
                            'type' => 'string',
                            'required' => true,
                            'description' => 'Repository name (owner/repo)',
                        ],
                    ],
                ],
                [
                    'id' => 'new_pull_request',
                    'name' => 'New Pull Request',
                    'description' => 'Triggered when a new pull request is opened',
                    'config_schema' => [
                        'repository' => [
                            'type' => 'string',
                            'required' => true,
                            'description' => 'Repository name (owner/repo)',
                        ],
                    ],
                ],
            ],
            'twitch' => [
                [
                    'id' => 'stream_online',
                    'name' => 'Stream Online',
                    'description' => 'Triggered when a streamer goes live',
                    'config_schema' => [
                        'channel_name' => [
                            'type' => 'string',
                            'required' => true,
                            'description' => 'Twitch channel name',
                        ],
                    ],
                ],
                [
                    'id' => 'new_follower',
                    'name' => 'New Follower',
                    'description' => 'Triggered when channel gets a new follower',
                    'config_schema' => [
                        'channel_name' => [
                            'type' => 'string',
                            'required' => true,
                            'description' => 'Twitch channel name',
                        ],
                    ],
                ],
                [
                    'id' => 'new_clip',
                    'name' => 'New Clip',
                    'description' => 'Triggered when a new clip is created',
                    'config_schema' => [
                        'channel_name' => [
                            'type' => 'string',
                            'required' => true,
                            'description' => 'Twitch channel name',
                        ],
                    ],
                ],
            ],
            'weather' => [
                [
                    'id' => 'temperature_above',
                    'name' => 'Temperature Above',
                    'description' => 'Triggered when temperature goes above a threshold',
                    'config_schema' => [
                        'city' => [
                            'type' => 'string',
                            'required' => true,
                            'description' => 'City name',
                        ],
                        'threshold' => [
                            'type' => 'number',
                            'required' => true,
                            'description' => 'Temperature threshold in Celsius',
                        ],
                    ],
                ],
                [
                    'id' => 'temperature_below',
                    'name' => 'Temperature Below',
                    'description' => 'Triggered when temperature goes below a threshold',
                    'config_schema' => [
                        'city' => [
                            'type' => 'string',
                            'required' => true,
                            'description' => 'City name',
                        ],
                        'threshold' => [
                            'type' => 'number',
                            'required' => true,
                            'description' => 'Temperature threshold in Celsius',
                        ],
                    ],
                ],
            ],
            'trello' => [
                [
                    'id' => 'new_card',
                    'name' => 'New Card Created',
                    'description' => 'Triggered when a new card is created on a board',
                    'config_schema' => [
                        'board_id' => [
                            'type' => 'string',
                            'required' => true,
                            'description' => 'Trello board ID',
                        ],
                        'list_id' => [
                            'type' => 'string',
                            'required' => false,
                            'description' => 'Filter by specific list ID (optional)',
                        ],
                    ],
                ],
                [
                    'id' => 'card_moved',
                    'name' => 'Card Moved',
                    'description' => 'Triggered when a card is moved to a specific list',
                    'config_schema' => [
                        'board_id' => [
                            'type' => 'string',
                            'required' => true,
                            'description' => 'Trello board ID',
                        ],
                        'target_list_id' => [
                            'type' => 'string',
                            'required' => true,
                            'description' => 'Destination list ID to watch',
                        ],
                    ],
                ],
                [
                    'id' => 'card_completed',
                    'name' => 'Card Completed',
                    'description' => 'Triggered when a card is moved to Done list',
                    'config_schema' => [
                        'board_id' => [
                            'type' => 'string',
                            'required' => true,
                            'description' => 'Trello board ID',
                        ],
                        'done_list_name' => [
                            'type' => 'string',
                            'required' => false,
                            'default' => 'Done',
                            'description' => 'Name of the Done list',
                        ],
                    ],
                ],
                [
                    'id' => 'card_assigned',
                    'name' => 'Card Assigned',
                    'description' => 'Triggered when a card is assigned to a member',
                    'config_schema' => [
                        'board_id' => [
                            'type' => 'string',
                            'required' => true,
                            'description' => 'Trello board ID',
                        ],
                        'member_id' => [
                            'type' => 'string',
                            'required' => false,
                            'description' => 'Filter by specific member ID (optional)',
                        ],
                    ],
                ],
            ],
            'trello' => [
                [
                    'id' => 'new_card',
                    'name' => 'New Card Created',
                    'description' => 'Triggered when a new card is created on a board',
                    'config_schema' => [
                        'board_id' => [
                            'type' => 'string',
                            'required' => true,
                            'description' => 'Trello board ID',
                        ],
                    ],
                ],
                [
                    'id' => 'card_moved',
                    'name' => 'Card Moved',
                    'description' => 'Triggered when a card is moved to a different list',
                    'config_schema' => [
                        'board_id' => [
                            'type' => 'string',
                            'required' => true,
                            'description' => 'Trello board ID',
                        ],
                        'list_name' => [
                            'type' => 'string',
                            'required' => false,
                            'description' => 'Filter by destination list name',
                        ],
                    ],
                ],
            ],
        ];
        
        return $triggers[$serviceName] ?? [];
    }

    /**
     * Get available actions for a service
     */
    private function getServiceActions($serviceName)
    {
        $actions = [
            'google' => [
                [
                    'id' => 'send_email',
                    'name' => 'Send Email',
                    'description' => 'Send an email via Gmail',
                    'config_schema' => [
                        'to' => [
                            'type' => 'string',
                            'required' => true,
                            'description' => 'Recipient email address',
                        ],
                        'subject' => [
                            'type' => 'string',
                            'required' => true,
                            'description' => 'Email subject',
                        ],
                        'body' => [
                            'type' => 'string',
                            'required' => true,
                            'description' => 'Email body content',
                        ],
                    ],
                ],
                [
                    'id' => 'create_calendar_event',
                    'name' => 'Create Calendar Event',
                    'description' => 'Create a new event in Google Calendar',
                    'config_schema' => [
                        'title' => [
                            'type' => 'string',
                            'required' => true,
                            'description' => 'Event title',
                        ],
                        'start_time' => [
                            'type' => 'datetime',
                            'required' => true,
                            'description' => 'Event start time (ISO 8601)',
                        ],
                        'end_time' => [
                            'type' => 'datetime',
                            'required' => true,
                            'description' => 'Event end time (ISO 8601)',
                        ],
                        'description' => [
                            'type' => 'string',
                            'required' => false,
                            'description' => 'Event description',
                        ],
                    ],
                ],
            ],
            'github' => [
                [
                    'id' => 'create_issue',
                    'name' => 'Create Issue',
                    'description' => 'Create a new issue in a GitHub repository',
                    'config_schema' => [
                        'repository' => [
                            'type' => 'string',
                            'required' => true,
                            'description' => 'Repository name (owner/repo)',
                        ],
                        'title' => [
                            'type' => 'string',
                            'required' => true,
                            'description' => 'Issue title',
                        ],
                        'body' => [
                            'type' => 'string',
                            'required' => false,
                            'description' => 'Issue description',
                        ],
                    ],
                ],
            ],
            'slack' => [
                [
                    'id' => 'send_message',
                    'name' => 'Send Message',
                    'description' => 'Send a message to a Slack channel',
                    'config_schema' => [
                        'channel' => [
                            'type' => 'string',
                            'required' => true,
                            'description' => 'Channel name or ID',
                        ],
                        'message' => [
                            'type' => 'string',
                            'required' => true,
                            'description' => 'Message content',
                        ],
                    ],
                ],
            ],
            'discord' => [
                [
                    'id' => 'send_message',
                    'name' => 'Send Message',
                    'description' => 'Send a message to a Discord channel',
                    'config_schema' => [
                        'channel_id' => [
                            'type' => 'string',
                            'required' => true,
                            'description' => 'Discord channel ID or webhook URL',
                        ],
                        'content' => [
                            'type' => 'string',
                            'required' => true,
                            'description' => 'Message content',
                        ],
                    ],
                ],
            ],
            'twitch' => [
                [
                    'id' => 'send_chat_message',
                    'name' => 'Send Chat Message',
                    'description' => 'Send a message to Twitch chat',
                    'config_schema' => [
                        'channel' => [
                            'type' => 'string',
                            'required' => true,
                            'description' => 'Twitch channel name',
                        ],
                        'message' => [
                            'type' => 'string',
                            'required' => true,
                            'description' => 'Message to send',
                        ],
                    ],
                ],
                [
                    'id' => 'update_stream_title',
                    'name' => 'Update Stream Title',
                    'description' => 'Update the title of your Twitch stream',
                    'config_schema' => [
                        'title' => [
                            'type' => 'string',
                            'required' => true,
                            'description' => 'New stream title',
                        ],
                    ],
                ],
                [
                    'id' => 'create_stream_marker',
                    'name' => 'Create Stream Marker',
                    'description' => 'Create a marker in the stream',
                    'config_schema' => [
                        'description' => [
                            'type' => 'string',
                            'required' => false,
                            'description' => 'Marker description',
                        ],
                    ],
                ],
            ],
            'weather' => [
                [
                    'id' => 'get_weather_info',
                    'name' => 'Get Weather Info',
                    'description' => 'Retrieve current weather information',
                    'config_schema' => [
                        'city' => [
                            'type' => 'string',
                            'required' => true,
                            'description' => 'City name',
                        ],
                    ],
                ],
                [
                    'id' => 'get_forecast',
                    'name' => 'Get Forecast',
                    'description' => 'Get weather forecast for a location',
                    'config_schema' => [
                        'city' => [
                            'type' => 'string',
                            'required' => true,
                            'description' => 'City name',
                        ],
                    ],
                ],
            ],
            'trello' => [
                [
                    'id' => 'create_card',
                    'name' => 'Create Card',
                    'description' => 'Create a new card on a Trello board',
                    'config_schema' => [
                        'list_id' => [
                            'type' => 'string',
                            'required' => true,
                            'description' => 'Trello list ID',
                        ],
                        'name' => [
                            'type' => 'string',
                            'required' => true,
                            'description' => 'Card title',
                        ],
                        'description' => [
                            'type' => 'string',
                            'required' => false,
                            'description' => 'Card description',
                        ],
                        'due_date' => [
                            'type' => 'string',
                            'required' => false,
                            'description' => 'Due date (ISO 8601)',
                        ],
                    ],
                ],
                [
                    'id' => 'move_card',
                    'name' => 'Move Card',
                    'description' => 'Move a card to a different list',
                    'config_schema' => [
                        'card_id' => [
                            'type' => 'string',
                            'required' => true,
                            'description' => 'Card ID',
                        ],
                        'target_list_id' => [
                            'type' => 'string',
                            'required' => true,
                            'description' => 'Destination list ID',
                        ],
                    ],
                ],
                [
                    'id' => 'add_comment',
                    'name' => 'Add Comment',
                    'description' => 'Add a comment to a card',
                    'config_schema' => [
                        'card_id' => [
                            'type' => 'string',
                            'required' => true,
                            'description' => 'Card ID',
                        ],
                        'comment' => [
                            'type' => 'string',
                            'required' => true,
                            'description' => 'Comment text (supports {variables})',
                        ],
                    ],
                ],
                [
                    'id' => 'archive_card',
                    'name' => 'Archive Card',
                    'description' => 'Archive a Trello card',
                    'config_schema' => [
                        'card_id' => [
                            'type' => 'string',
                            'required' => true,
                            'description' => 'Card ID to archive',
                        ],
                    ],
                ],
                [
                    'id' => 'update_card',
                    'name' => 'Update Card',
                    'description' => 'Update an existing card',
                    'config_schema' => [
                        'card_id' => [
                            'type' => 'string',
                            'required' => true,
                            'description' => 'Card ID',
                        ],
                        'name' => [
                            'type' => 'string',
                            'required' => false,
                            'description' => 'New card title',
                        ],
                        'description' => [
                            'type' => 'string',
                            'required' => false,
                            'description' => 'New card description',
                        ],
                    ],
                ],
            ],
        ];
        
        return $actions[$serviceName] ?? [];
    }

    /**
     * Generate OAuth URL for a service
     */
    private function getOAuthUrl($serviceName, $userId)
    {
        $state = base64_encode(json_encode(['user_id' => $userId]));
        
        switch ($serviceName) {
            case 'google':
                $params = http_build_query([
                    'client_id' => config('services.google.client_id'),
                    'redirect_uri' => url('/api/services/google/callback'),
                    'response_type' => 'code',
                    'scope' => 'email profile https://www.googleapis.com/auth/gmail.readonly https://www.googleapis.com/auth/gmail.send https://www.googleapis.com/auth/calendar.readonly',
                    'state' => $state,
                    'access_type' => 'offline',
                    'prompt' => 'consent',
                ]);
                return 'https://accounts.google.com/o/oauth2/v2/auth?' . $params;
                
            case 'github':
                $params = http_build_query([
                    'client_id' => env('GITHUB_CLIENT_ID'),
                    'redirect_uri' => url('/api/services/github/callback'),
                    'scope' => 'repo user notifications',
                    'state' => $state,
                ]);
                return 'https://github.com/login/oauth/authorize?' . $params;
                
            case 'discord':
                $params = http_build_query([
                    'client_id' => env('DISCORD_CLIENT_ID'),
                    'redirect_uri' => url('/api/services/discord/callback'),
                    'response_type' => 'code',
                    'scope' => 'identify guilds messages.read',
                    'state' => $state,
                ]);
                return 'https://discord.com/api/oauth2/authorize?' . $params;
                
            case 'slack':
                $params = http_build_query([
                    'client_id' => env('SLACK_CLIENT_ID'),
                    'redirect_uri' => env('SLACK_REDIRECT_URI'),
                    'scope' => 'channels:read chat:write users:read channels:history',
                    'state' => $state,
                ]);
                return 'https://slack.com/oauth/v2/authorize?' . $params;
                
            case 'twitch':
                $params = http_build_query([
                    'client_id' => env('TWITCH_CLIENT_ID'),
                    'redirect_uri' => env('TWITCH_REDIRECT_URI'),
                    'response_type' => 'code',
                    'scope' => 'user:read:email channel:read:subscriptions moderator:read:followers user:write:chat channel:manage:broadcast',
                    'state' => $state,
                ]);
                return 'https://id.twitch.tv/oauth2/authorize?' . $params;
                
            default:
                return '#';
        }
    }

    /**
     * Handle OAuth callback from Google/GitHub/Discord/Slack/Twitch after user authorizes
     */
    public function handleServiceCallback($service, Request $request)
    {
        try {
            // Log all incoming request data for debugging
            \Log::info('Service callback received', [
                'service' => $service,
                'query_params' => $request->query(),
                'has_code' => $request->has('code'),
                'has_error' => $request->has('error'),
                'error' => $request->error,
                'error_description' => $request->error_description,
            ]);

            if (!$request->has('code')) {
                \Log::error('No code in service callback', ['service' => $service]);
                return redirect(env('FRONTEND_URL', 'http://localhost:8081') . '/services?error=no_code');
            }

            // Décoder le state pour récupérer le user_id
            $state = json_decode(base64_decode($request->state), true);
            $userId = $state['user_id'] ?? null;

            if (!$userId) {
                \Log::error('No user_id in state', ['state' => $request->state]);
                return redirect(env('FRONTEND_URL', 'http://localhost:8081') . '/services?error=invalid_state');
            }

            $user = \App\Models\User::find($userId);
            if (!$user) {
                return redirect(env('FRONTEND_URL', 'http://localhost:8081') . '/services?error=user_not_found');
            }

            $accessToken = null;
            $refreshToken = null;
            $expiresAt = null;

            // Exchange code for access token based on service
            switch ($service) {
                case 'google':
                    $tokenResponse = \Http::post('https://oauth2.googleapis.com/token', [
                        'code' => $request->code,
                        'client_id' => env('GOOGLE_WEB_CLIENT_ID'),
                        'client_secret' => env('GOOGLE_CLIENT_SECRET'),
                        'redirect_uri' => url('/api/services/google/callback'),
                        'grant_type' => 'authorization_code',
                    ]);

                    if (!$tokenResponse->successful()) {
                        \Log::error('Failed to exchange code', ['response' => $tokenResponse->body()]);
                        return redirect(env('FRONTEND_URL', 'http://localhost:8081') . '/services?error=token_exchange_failed');
                    }

                    $tokenData = $tokenResponse->json();
                    $accessToken = $tokenData['access_token'];
                    $refreshToken = $tokenData['refresh_token'] ?? null;
                    $expiresAt = isset($tokenData['expires_in']) ? now()->addSeconds($tokenData['expires_in']) : null;

                    // Sauvegarder les tokens dans la table user
                    $user->update([
                        'google_token' => $accessToken,
                        'google_refresh_token' => $refreshToken,
                    ]);
                    break;

                case 'github':
                    $tokenResponse = \Http::asForm()->post('https://github.com/login/oauth/access_token', [
                        'client_id' => env('GITHUB_CLIENT_ID'),
                        'client_secret' => env('GITHUB_CLIENT_SECRET'),
                        'code' => $request->code,
                        'redirect_uri' => url('/api/services/github/callback'),
                    ]);

                    if (!$tokenResponse->successful()) {
                        \Log::error('Failed to exchange GitHub code', ['response' => $tokenResponse->body()]);
                        return redirect(env('FRONTEND_URL', 'http://localhost:8081') . '/services?error=token_exchange_failed');
                    }

                    parse_str($tokenResponse->body(), $tokenData);
                    $accessToken = $tokenData['access_token'] ?? null;
                    $refreshToken = $tokenData['refresh_token'] ?? null;
                    // GitHub tokens don't expire by default
                    $expiresAt = null;

                    if (!$accessToken) {
                        \Log::error('No access token from GitHub', ['response' => $tokenResponse->body()]);
                        return redirect(env('FRONTEND_URL', 'http://localhost:8081') . '/services?error=no_access_token');
                    }
                    break;

                case 'discord':
                    $tokenResponse = \Http::asForm()->post('https://discord.com/api/oauth2/token', [
                        'client_id' => env('DISCORD_CLIENT_ID'),
                        'client_secret' => env('DISCORD_CLIENT_SECRET'),
                        'code' => $request->code,
                        'grant_type' => 'authorization_code',
                        'redirect_uri' => url('/api/services/discord/callback'),
                    ]);

                    if (!$tokenResponse->successful()) {
                        \Log::error('Failed to exchange Discord code', ['response' => $tokenResponse->body()]);
                        return redirect(env('FRONTEND_URL', 'http://localhost:8081') . '/services?error=token_exchange_failed');
                    }

                    $tokenData = $tokenResponse->json();
                    $accessToken = $tokenData['access_token'] ?? null;
                    $refreshToken = $tokenData['refresh_token'] ?? null;
                    $expiresAt = isset($tokenData['expires_in']) ? now()->addSeconds($tokenData['expires_in']) : null;

                    if (!$accessToken) {
                        \Log::error('No access token from Discord', ['response' => $tokenResponse->body()]);
                        return redirect(env('FRONTEND_URL', 'http://localhost:8081') . '/services?error=no_access_token');
                    }
                    break;

                case 'slack':
                    $tokenResponse = \Http::asForm()->post('https://slack.com/api/oauth.v2.access', [
                        'client_id' => env('SLACK_CLIENT_ID'),
                        'client_secret' => env('SLACK_CLIENT_SECRET'),
                        'code' => $request->code,
                        'redirect_uri' => env('SLACK_REDIRECT_URI'),
                    ]);

                    if (!$tokenResponse->successful()) {
                        \Log::error('Failed to exchange Slack code', ['response' => $tokenResponse->body()]);
                        return redirect(env('FRONTEND_URL', 'http://localhost:8081') . '/services?error=token_exchange_failed');
                    }

                    $tokenData = $tokenResponse->json();
                    if (!($tokenData['ok'] ?? false)) {
                        \Log::error('Slack OAuth error', ['error' => $tokenData['error'] ?? 'unknown']);
                        return redirect(env('FRONTEND_URL', 'http://localhost:8081') . '/services?error=slack_oauth_failed');
                    }

                    $accessToken = $tokenData['access_token'] ?? null;
                    $refreshToken = $tokenData['refresh_token'] ?? null;
                    $expiresAt = isset($tokenData['expires_in']) ? now()->addSeconds($tokenData['expires_in']) : null;

                    if (!$accessToken) {
                        \Log::error('No access token from Slack', ['response' => $tokenResponse->body()]);
                        return redirect(env('FRONTEND_URL', 'http://localhost:8081') . '/services?error=no_access_token');
                    }
                    break;

                case 'twitch':
                    $tokenResponse = \Http::asForm()->post('https://id.twitch.tv/oauth2/token', [
                        'client_id' => env('TWITCH_CLIENT_ID'),
                        'client_secret' => env('TWITCH_CLIENT_SECRET'),
                        'code' => $request->code,
                        'grant_type' => 'authorization_code',
                        'redirect_uri' => env('TWITCH_REDIRECT_URI'),
                    ]);

                    if (!$tokenResponse->successful()) {
                        \Log::error('Failed to exchange Twitch code', ['response' => $tokenResponse->body()]);
                        return redirect(env('FRONTEND_URL', 'http://localhost:8081') . '/services?error=token_exchange_failed');
                    }

                    $tokenData = $tokenResponse->json();
                    $accessToken = $tokenData['access_token'] ?? null;
                    $refreshToken = $tokenData['refresh_token'] ?? null;
                    $expiresAt = isset($tokenData['expires_in']) ? now()->addSeconds($tokenData['expires_in']) : null;

                    if (!$accessToken) {
                        \Log::error('No access token from Twitch', ['response' => $tokenResponse->body()]);
                        return redirect(env('FRONTEND_URL', 'http://localhost:8081') . '/services?error=no_access_token');
                    }
                    break;

                default:
                    \Log::error('Unsupported service for OAuth', ['service' => $service]);
                    return redirect(env('FRONTEND_URL', 'http://localhost:8081') . '/services?error=unsupported_service');
            }

            // Créer/mettre à jour l'entrée dans user_services pour que le frontend le voit comme connecté
            $serviceModel = \App\Models\Service::where('name', $service)->first();
            if ($serviceModel && $accessToken) {
                \App\Models\UserService::updateOrCreate(
                    [
                        'user_id' => $userId,
                        'service_id' => $serviceModel->id,
                    ],
                    [
                        'access_token' => $accessToken,
                        'refresh_token' => $refreshToken,
                        'expires_at' => $expiresAt,
                        'name' => $service,
                    ]
                );

                \Log::info('Service connected successfully', ['user_id' => $userId, 'service' => $service]);
            }

            // Rediriger vers le deep link mobile ou le frontend web
            $isMobileRequest = $request->header('User-Agent') && 
                (str_contains($request->header('User-Agent'), 'Mobile') || 
                 str_contains($request->header('User-Agent'), 'Android'));
            
            if ($isMobileRequest) {
                // Deep link pour mobile
                return redirect('area://oauth/callback?status=connected&service=' . $service);
            } else {
                // URL web classique
                return redirect(env('FRONTEND_URL', 'http://localhost:8081') . '/services?status=connected&service=' . $service);
            }

        } catch (\Exception $e) {
            \Log::error('Service callback error', [
                'service' => $service,
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString()
            ]);
            
            $isMobileRequest = $request->header('User-Agent') && 
                (str_contains($request->header('User-Agent'), 'Mobile') || 
                 str_contains($request->header('User-Agent'), 'Android'));
            
            if ($isMobileRequest) {
                return redirect('area://oauth/callback?error=' . urlencode($e->getMessage()));
            } else {
                return redirect(env('FRONTEND_URL', 'http://localhost:8081') . '/services?error=' . urlencode($e->getMessage()));
            }
        }
    }
    
    /**
     * Handle GitHub webhook events
     * 
     * This endpoint receives webhook events from GitHub when issues, PRs, or commits are created.
     * It triggers the corresponding AREAs that are listening for these events.
     *
     * @group Webhooks
     * @unauthenticated
     */
    public function handleGithubWebhook(Request $request)
    {
        try {
            $event = $request->header('X-GitHub-Event');
            $payload = $request->all();
            
            \Log::info('📥 GitHub Webhook received', [
                'event' => $event,
                'action' => $payload['action'] ?? 'N/A',
                'repository' => $payload['repository']['full_name'] ?? 'N/A'
            ]);
            
            // Handle different GitHub events
            if ($event === 'issues' && isset($payload['action']) && $payload['action'] === 'opened') {
                $this->handleNewIssue($payload);
            }
            elseif ($event === 'pull_request' && isset($payload['action']) && $payload['action'] === 'opened') {
                $this->handleNewPullRequest($payload);
            }
            elseif ($event === 'push') {
                $this->handlePushEvent($payload);
            }
            
            return response()->json(['status' => 'success'], 200);
            
        } catch (\Exception $e) {
            \Log::error('❌ GitHub webhook error: ' . $e->getMessage());
            return response()->json(['error' => $e->getMessage()], 500);
        }
    }
    
    /**
     * Handle new GitHub issue webhook
     */
    private function handleNewIssue($payload)
    {
        $repository = $payload['repository']['full_name'];
        $issue = $payload['issue'];
        
        \Log::info('🔔 New GitHub issue', [
            'repo' => $repository,
            'issue_number' => $issue['number'],
            'title' => $issue['title']
        ]);
        
        // Find all AREAs listening for new issues on this repository
        // Les trigger_action peuvent être 'new_issue', 'New Issue Created', etc. (on les compare en snake_case)
        $areas = \App\Models\Area::where('is_active', true)
            ->where('trigger_service', 'github')
            ->get();
        
        foreach ($areas as $area) {
            // Convertir le nom du trigger en snake_case pour comparaison
            $triggerKey = strtolower(str_replace(' ', '_', $area->trigger_action));
            
            // Accepter plusieurs formats
            if (!in_array($triggerKey, ['new_issue', 'new_issues_created', 'new_issue_created'])) {
                continue;
            }
            
            $triggerParams = is_string($area->trigger_params) 
                ? json_decode($area->trigger_params, true) 
                : $area->trigger_params;
            
            // Parse repository format (handle git@github.com: or owner/repo)
            $areaRepo = $this->parseGitHubRepository($triggerParams['repository'] ?? '');
            
            if (strtolower($areaRepo) === strtolower($repository)) {
                \Log::info("✅ Triggering AREA #{$area->id}: {$area->name}");
                
                // Execute the action
                $this->executeAreaAction($area, [
                    'issue_number' => $issue['number'],
                    'issue_title' => $issue['title'],
                    'issue_body' => $issue['body'],
                    'issue_url' => $issue['html_url'],
                    'author' => $issue['user']['login']
                ]);
            }
        }
    }
    
    /**
     * Handle new pull request webhook
     */
    private function handleNewPullRequest($payload)
    {
        $repository = $payload['repository']['full_name'];
        $pr = $payload['pull_request'];
        
        \Log::info('🔔 New GitHub PR', [
            'repo' => $repository,
            'pr_number' => $pr['number'],
            'title' => $pr['title']
        ]);
        
        $areas = \App\Models\Area::where('is_active', true)
            ->where('trigger_service', 'github')
            ->get();
        
        foreach ($areas as $area) {
            // Convertir le nom du trigger en snake_case pour comparaison
            $triggerKey = strtolower(str_replace(' ', '_', $area->trigger_action));
            
            // Accepter plusieurs formats
            if (!in_array($triggerKey, ['new_pull_request', 'new_pr', 'new_pull_request_created', 'new_pr_created'])) {
                continue;
            }
            
            $triggerParams = is_string($area->trigger_params) 
                ? json_decode($area->trigger_params, true) 
                : $area->trigger_params;
            
            $areaRepo = $this->parseGitHubRepository($triggerParams['repository'] ?? '');
            
            if (strtolower($areaRepo) === strtolower($repository)) {
                \Log::info("✅ Triggering AREA #{$area->id}: {$area->name}");
                
                $this->executeAreaAction($area, [
                    'pr_number' => $pr['number'],
                    'pr_title' => $pr['title'],
                    'pr_body' => $pr['body'],
                    'pr_url' => $pr['html_url'],
                    'author' => $pr['user']['login']
                ]);
            }
        }
    }
    
    /**
     * Handle push event webhook
     */
    private function handlePushEvent($payload)
    {
        $repository = $payload['repository']['full_name'];
        $commits = $payload['commits'] ?? [];
        
        \Log::info('🔔 GitHub push event', [
            'repo' => $repository,
            'commits_count' => count($commits)
        ]);
        
        $areas = \App\Models\Area::where('is_active', true)
            ->where('trigger_service', 'github')
            ->where('trigger_action', 'push_event')
            ->get();
        
        foreach ($areas as $area) {
            $triggerParams = is_string($area->trigger_params) 
                ? json_decode($area->trigger_params, true) 
                : $area->trigger_params;
            
            $areaRepo = $this->parseGitHubRepository($triggerParams['repository'] ?? '');
            
            if (strtolower($areaRepo) === strtolower($repository)) {
                \Log::info("✅ Triggering AREA #{$area->id}: {$area->name}");
                
                $this->executeAreaAction($area, [
                    'commits_count' => count($commits),
                    'commits' => $commits,
                    'pusher' => $payload['pusher']['name'] ?? 'Unknown'
                ]);
            }
        }
    }
    
    /**
     * Execute an AREA's action
     */
    private function executeAreaAction($area, $triggerData)
    {
        try {
            $user = $area->user;
            $actionParams = is_string($area->action_params) 
                ? json_decode($area->action_params, true) 
                : $area->action_params;
            
            // Get the appropriate service
            $service = $this->getServiceInstance($area->action_service);
            
            if (!$service) {
                throw new \Exception("Unknown action service: {$area->action_service}");
            }
            
            // Execute the reaction
            $service->executeReaction(
                $area->action_reaction,
                $actionParams ?? [],
                $user,
                $triggerData
            );
            
            // Log success
            \App\Models\AreaLog::create([
                'area_id' => $area->id,
                'status' => 'success',
                'message' => 'Executed via GitHub webhook at ' . now()
            ]);
            
            \Log::info("✅ AREA #{$area->id} executed successfully");
            
        } catch (\Exception $e) {
            \Log::error("❌ Error executing AREA #{$area->id}: " . $e->getMessage());
            
            \App\Models\AreaLog::create([
                'area_id' => $area->id,
                'status' => 'error',
                'message' => $e->getMessage()
            ]);
        }
    }
    
    /**
     * Parse GitHub repository from various formats
     */
    private function parseGitHubRepository($repository)
    {
        // Already in owner/repo format
        if (preg_match('/^[a-zA-Z0-9_-]+\/[a-zA-Z0-9_.-]+$/', $repository)) {
            return $repository;
        }
        
        // SSH format: git@github.com:owner/repo.git
        if (preg_match('/git@github\.com:([a-zA-Z0-9_-]+)\/([a-zA-Z0-9_.-]+)\.git/', $repository, $matches)) {
            return "{$matches[1]}/{$matches[2]}";
        }
        
        // HTTPS format: https://github.com/owner/repo.git
        if (preg_match('/github\.com\/([a-zA-Z0-9_-]+)\/([a-zA-Z0-9_.-]+)/', $repository, $matches)) {
            return "{$matches[1]}/{$matches[2]}";
        }
        
        return $repository;
    }
    
    /**
     * Get service instance
     */
    private function getServiceInstance($serviceName)
    {
        return match (strtolower($serviceName)) {
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
