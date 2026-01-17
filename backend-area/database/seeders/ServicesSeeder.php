<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Service;

class ServicesSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $services = [
            [
                'name' => 'google',
                'icon' => 'https://www.google.com/favicon.ico',
                'is_active' => true,
            ],
            [
                'name' => 'timer',
                'icon' => '⏰',
                'is_active' => true,
            ],
            [
                'name' => 'github',
                'icon' => 'https://github.com/favicon.ico',
                'is_active' => true,
            ],
            [
                'name' => 'twitch',
                'icon' => 'https://static.twitchcdn.net/assets/favicon-32-e29e246c157142c94346.png',
                'is_active' => true,
            ],
            [
                'name' => 'slack',
                'icon' => 'https://slack.com/favicon.ico',
                'is_active' => true,
            ],
            [
                'name' => 'discord',
                'icon' => 'https://discord.com/assets/favicon.ico',
                'is_active' => true,
            ],
            [
                'name' => 'weather',
                'icon' => '🌤️',
                'is_active' => true,
            ],
            [
                'name' => 'trello',
                'icon' => 'https://trello.com/favicon.ico',
                'is_active' => true,
            ],
        ];

        foreach ($services as $service) {
            Service::updateOrCreate(
                ['name' => $service['name']],
                $service
            );
        }

        $this->command->info('✅ Services seeded successfully!');
    }
}
