<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use App\Models\User;
use Illuminate\Support\Facades\Hash;

class TestUserSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Create test user if it doesn't exist
        $testUser = User::firstOrCreate(
            ['email' => 'test@area.com'],
            [
                'name' => 'Test User',
                'password' => Hash::make('password123'),
                'email_verified_at' => now(),
            ]
        );

        // Generate token for easy testing
        $token = $testUser->createToken('test_token')->plainTextToken;

        $this->command->info('Test user created successfully!');
        $this->command->info('Email: test@area.com');
        $this->command->info('Password: password123');
        $this->command->info('Bearer Token: ' . $token);
    }
}
