<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Service;

class AboutController extends Controller
{
    /**
     * Get information about the server and available services
     * 
     * Returns metadata about the AREA server including available services, actions, and reactions.
     *
     * @group About
     * @unauthenticated
     * 
     * @response 200 {
     *   "client": {
     *     "host": "192.168.1.100"
     *   },
     *   "server": {
     *     "current_time": 1733400000,
     *     "services": [
     *       {
     *         "name": "google",
     *         "actions": [
     *           {
     *             "name": "new_email",
     *             "description": "Triggered when a new email is received"
     *           }
     *         ],
     *         "reactions": [
     *           {
     *             "name": "send_email",
     *             "description": "Send an email via Gmail"
     *           }
     *         ]
     *       },
     *       {
     *         "name": "timer",
     *         "actions": [
     *           {
     *             "name": "timer_trigger",
     *             "description": "Triggered at specified intervals"
     *           }
     *         ],
     *         "reactions": []
     *       }
     *     ]
     *   }
     * }
     */
    public function getAbout(Request $request)
    {
        // Récupérer tous les services actifs depuis la base de données
        $services = Service::where('is_active', true)->get();
        
        // Construire le tableau des services avec leurs triggers et actions
        $servicesData = [];
        
        foreach ($services as $service) {
            $servicesData[] = [
                'name' => $service->name,
                'actions' => $this->getServiceTriggers($service->name),
                'reactions' => $this->getServiceActions($service->name),
            ];
        }
        
        return response()->json([
            'client' => [
                'host' => $request->ip()
            ],
            'server' => [
                'current_time' => time(),
                'services' => $servicesData
            ]
        ], 200);
    }

    /**
     * Get available triggers (actions) for a service
     */
    private function getServiceTriggers($serviceName)
    {
        $triggers = [
            'google' => [
                [
                    'name' => 'new_email',
                    'description' => 'Triggered when a new email is received'
                ],
                [
                    'name' => 'new_gmail_received',
                    'description' => 'Triggered when a new Gmail is received (alias)'
                ],
                [
                    'name' => 'new_calendar_event',
                    'description' => 'Triggered when a new calendar event is created'
                ]
            ],
            'timer' => [
                [
                    'name' => 'timer_trigger',
                    'description' => 'Triggered at specified intervals (cron-based)'
                ],
                [
                    'name' => 'interval',
                    'description' => 'Triggered at regular time intervals'
                ]
            ],
            'github' => [
                [
                    'name' => 'new_issue',
                    'description' => 'Triggered when a new issue is created'
                ],
                [
                    'name' => 'new_pull_request',
                    'description' => 'Triggered when a new PR is opened'
                ],
                [
                    'name' => 'new_pr',
                    'description' => 'Triggered when a new PR is opened (alias)'
                ],
                [
                    'name' => 'new_commit',
                    'description' => 'Triggered when a new commit is pushed'
                ],
                [
                    'name' => 'repo_starred',
                    'description' => 'Triggered when repository receives a star'
                ]
            ],
            'twitch' => [
                [
                    'name' => 'stream_online',
                    'description' => 'Triggered when a streamer goes live'
                ],
                [
                    'name' => 'new_follower',
                    'description' => 'Triggered when channel gets a new follower'
                ],
                [
                    'name' => 'new_clip',
                    'description' => 'Triggered when a new clip is created'
                ]
            ],
            'slack' => [
                [
                    'name' => 'new_message',
                    'description' => 'Triggered when a new message is posted in a channel'
                ],
                [
                    'name' => 'new_message_in_channel',
                    'description' => 'Triggered when a new message appears in a specific channel'
                ],
                [
                    'name' => 'message_contains',
                    'description' => 'Triggered when a message contains a specific keyword'
                ],
                [
                    'name' => 'new_member',
                    'description' => 'Triggered when a new member joins the workspace'
                ]
            ],
            'discord' => [
                [
                    'name' => 'new_message',
                    'description' => 'Triggered when a new message is posted in a channel'
                ],
                [
                    'name' => 'new_message_in_channel',
                    'description' => 'Triggered when a new message appears in a specific channel'
                ],
                [
                    'name' => 'message_contains',
                    'description' => 'Triggered when a message contains a specific keyword'
                ],
                [
                    'name' => 'user_joined',
                    'description' => 'Triggered when a new member joins the server'
                ]
            ],
            'weather' => [
                [
                    'name' => 'temperature_above',
                    'description' => 'Triggered when temperature goes above a threshold (params: city, threshold)'
                ],
                [
                    'name' => 'temperature_below',
                    'description' => 'Triggered when temperature goes below a threshold (params: city, threshold)'
                ],
                [
                    'name' => 'weather_condition',
                    'description' => 'Triggered when weather matches a specific condition (params: city, condition: rain|snow|clear|clouds)'
                ],
                [
                    'name' => 'humidity_above',
                    'description' => 'Triggered when humidity goes above a threshold (params: city, threshold)'
                ]
            ],
            'trello' => [
                [
                    'name' => 'new_card',
                    'description' => 'Triggered when a new card is created (params: board_id, list_id optional, last_card_id)'
                ],
                [
                    'name' => 'card_moved',
                    'description' => 'Triggered when a card is moved to a specific list (params: board_id, target_list_id, tracked_card_ids)'
                ],
                [
                    'name' => 'card_completed',
                    'description' => 'Triggered when a card is moved to Done list (params: board_id, done_list_name, tracked_card_ids)'
                ],
                [
                    'name' => 'card_assigned',
                    'description' => 'Triggered when a card is assigned to a member (params: board_id, member_id optional, tracked_card_ids)'
                ]
            ],
            'spotify' => [
                [
                    'name' => 'new_liked_song',
                    'description' => 'Triggered when a song is added to liked songs'
                ],
                [
                    'name' => 'playlist_updated',
                    'description' => 'Triggered when a playlist is modified'
                ]
            ],
        ];
        
        return $triggers[$serviceName] ?? [];
    }

    /**
     * Get available actions (reactions) for a service
     */
    private function getServiceActions($serviceName)
    {
        $actions = [
            'google' => [
                [
                    'name' => 'send_email',
                    'description' => 'Send an email via Gmail'
                ],
                [
                    'name' => 'create_calendar_event',
                    'description' => 'Create a new Google Calendar event'
                ],
                [
                    'name' => 'send_gmail',
                    'description' => 'Send a Gmail message (alias)'
                ]
            ],
            'github' => [
                [
                    'name' => 'create_issue',
                    'description' => 'Create a new GitHub issue'
                ],
                [
                    'name' => 'comment_issue',
                    'description' => 'Add a comment to an issue or PR'
                ],
                [
                    'name' => 'close_issue',
                    'description' => 'Close a GitHub issue'
                ]
            ],
            'twitch' => [
                [
                    'name' => 'send_chat_message',
                    'description' => 'Send a message to Twitch chat'
                ],
                [
                    'name' => 'update_stream_title',
                    'description' => 'Update the stream title'
                ],
                [
                    'name' => 'create_stream_marker',
                    'description' => 'Create a marker in the stream'
                ]
            ],
            'slack' => [
                [
                    'name' => 'send_message',
                    'description' => 'Send a message to a Slack channel'
                ],
                [
                    'name' => 'post_message',
                    'description' => 'Post a message to a Slack channel (alias)'
                ],
                [
                    'name' => 'send_dm',
                    'description' => 'Send a direct message to a user'
                ],
                [
                    'name' => 'add_reaction',
                    'description' => 'Add an emoji reaction to a message'
                ],
                [
                    'name' => 'create_channel',
                    'description' => 'Create a new Slack channel'
                ]
            ],
            'discord' => [
                [
                    'name' => 'send_message',
                    'description' => 'Send a message to a Discord channel'
                ],
                [
                    'name' => 'send_message_to_channel',
                    'description' => 'Send a message to a specific Discord channel (alias)'
                ],
                [
                    'name' => 'send_webhook',
                    'description' => 'Send a message via Discord webhook'
                ],
                [
                    'name' => 'add_reaction',
                    'description' => 'Add an emoji reaction to a message'
                ]
            ],
            'weather' => [
                [
                    'name' => 'get_weather_info',
                    'description' => 'Get current weather information for a location (params: city)'
                ],
                [
                    'name' => 'get_forecast',
                    'description' => 'Get weather forecast for a location (future implementation)'
                ]
            ],
            'trello' => [
                [
                    'name' => 'create_card',
                    'description' => 'Create a new Trello card (params: list_id or board_id, name, description, due_date optional, labels optional)'
                ],
                [
                    'name' => 'move_card',
                    'description' => 'Move a card to another list (params: card_id, target_list_id)'
                ],
                [
                    'name' => 'add_comment',
                    'description' => 'Add a comment to a card (params: card_id, comment with {variables} support)'
                ],
                [
                    'name' => 'archive_card',
                    'description' => 'Archive a Trello card (params: card_id)'
                ],
                [
                    'name' => 'update_card',
                    'description' => 'Update an existing card (params: card_id, name optional, description optional, due_date optional)'
                ]
            ],
            'spotify' => [
                [
                    'name' => 'add_to_playlist',
                    'description' => 'Add a track to a playlist'
                ],
                [
                    'name' => 'create_playlist',
                    'description' => 'Create a new Spotify playlist'
                ],
                [
                    'name' => 'play_track',
                    'description' => 'Play a specific track'
                ]
            ],
            'timer' => [],
        ];
        
        return $actions[$serviceName] ?? [];
    }
}
