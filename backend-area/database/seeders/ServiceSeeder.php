<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Service;
use App\Models\Trigger;
use App\Models\Action;

class ServiceSeeder extends Seeder
{
    public function run(): void
    {
        // ============ TIMER SERVICE ============
        $timerService = Service::create([
            'name' => 'Timer',
            'description' => 'Trigger events on a timer',
            'icon' => '⏱️',
            'color' => '#3B82F6',
            'enabled' => true,
        ]);

        // Timer Triggers
        Trigger::create([
            'service_id' => $timerService->id,
            'name' => 'Time Interval',
            'description' => 'Trigger after a specified time interval',
            'config_schema' => json_encode([
                [
                    'name' => 'interval',
                    'label' => 'Interval',
                    'type' => 'select',
                    'required' => true,
                    'options' => [
                        'every_minute',
                        'every_5_minutes',
                        'every_hour',
                        'every_day',
                    ]
                ]
            ]),
        ]);

        // ============ WEATHER SERVICE ============
        $weatherService = Service::create([
            'name' => 'Weather',
            'description' => 'Weather-related triggers and actions',
            'icon' => '🌤️',
            'color' => '#F59E0B',
            'enabled' => true,
        ]);

        Trigger::create([
            'service_id' => $weatherService->id,
            'name' => 'Temperature Change',
            'description' => 'Trigger when temperature changes',
            'config_schema' => json_encode([
                [
                    'name' => 'temperature',
                    'label' => 'Temperature (°C)',
                    'type' => 'input',
                    'required' => true,
                ]
            ]),
        ]);

        Action::create([
            'service_id' => $weatherService->id,
            'name' => 'Send Weather Alert',
            'description' => 'Send a weather alert notification',
            'config_schema' => json_encode([
                [
                    'name' => 'message',
                    'label' => 'Message',
                    'type' => 'textarea',
                    'required' => true,
                ]
            ]),
        ]);

        // ============ EMAIL SERVICE ============
        $emailService = Service::create([
            'name' => 'Email',
            'description' => 'Send and receive emails',
            'icon' => '📧',
            'color' => '#EF4444',
            'enabled' => true,
        ]);

        Trigger::create([
            'service_id' => $emailService->id,
            'name' => 'New Email',
            'description' => 'Trigger when new email arrives',
            'config_schema' => json_encode([
                [
                    'name' => 'from',
                    'label' => 'From',
                    'type' => 'input',
                    'required' => false,
                ]
            ]),
        ]);

        Action::create([
            'service_id' => $emailService->id,
            'name' => 'Send Email',
            'description' => 'Send an email',
            'config_schema' => json_encode([
                [
                    'name' => 'to',
                    'label' => 'To',
                    'type' => 'input',
                    'required' => true,
                ],
                [
                    'name' => 'subject',
                    'label' => 'Subject',
                    'type' => 'input',
                    'required' => true,
                ],
                [
                    'name' => 'body',
                    'label' => 'Body',
                    'type' => 'textarea',
                    'required' => true,
                ]
            ]),
        ]);

        // ============ SLACK SERVICE ============
        $slackService = Service::create([
            'name' => 'Slack',
            'description' => 'Send messages to Slack',
            'icon' => '💬',
            'color' => '#7C3AED',
            'enabled' => true,
        ]);

        Trigger::create([
            'service_id' => $slackService->id,
            'name' => 'Message Received',
            'description' => 'Trigger when message is received',
            'config_schema' => json_encode([
                [
                    'name' => 'channel',
                    'label' => 'Channel',
                    'type' => 'input',
                    'required' => true,
                ]
            ]),
        ]);

        Action::create([
            'service_id' => $slackService->id,
            'name' => 'Send Message',
            'description' => 'Send a message to Slack channel',
            'config_schema' => json_encode([
                [
                    'name' => 'channel',
                    'label' => 'Channel',
                    'type' => 'input',
                    'required' => true,
                ],
                [
                    'name' => 'message',
                    'label' => 'Message',
                    'type' => 'textarea',
                    'required' => true,
                ]
            ]),
        ]);

        // ============ WEBHOOK SERVICE ============
        $webhookService = Service::create([
            'name' => 'Webhook',
            'description' => 'Trigger on webhook events',
            'icon' => '🪝',
            'color' => '#06B6D4',
            'enabled' => true,
        ]);

        Trigger::create([
            'service_id' => $webhookService->id,
            'name' => 'HTTP Request',
            'description' => 'Trigger on HTTP webhook request',
            'config_schema' => json_encode([
                [
                    'name' => 'path',
                    'label' => 'Webhook Path',
                    'type' => 'input',
                    'required' => true,
                ]
            ]),
        ]);

        Action::create([
            'service_id' => $webhookService->id,
            'name' => 'Make HTTP Request',
            'description' => 'Make an HTTP request',
            'config_schema' => json_encode([
                [
                    'name' => 'url',
                    'label' => 'URL',
                    'type' => 'input',
                    'required' => true,
                ],
                [
                    'name' => 'method',
                    'label' => 'Method',
                    'type' => 'select',
                    'required' => true,
                    'options' => ['GET', 'POST', 'PUT', 'DELETE']
                ]
            ]),
        ]);

        echo "✅ Services seeded successfully!\n";
    }
}
