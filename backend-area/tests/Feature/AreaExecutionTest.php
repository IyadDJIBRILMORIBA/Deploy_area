<?php

namespace Tests\Feature;

use Tests\TestCase;
use App\Models\User;
use App\Models\Area;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Http;

class AreaExecutionTest extends TestCase
{
    use RefreshDatabase;

    protected User $user;

    protected function setUp(): void
    {
        parent::setUp();
        
        // Créer un utilisateur de test
        $this->user = User::factory()->create([
            'email' => 'test@example.com',
            'name' => 'Test User'
        ]);
    }

    /**
     * Test la création d'une AREA
     */
    public function test_can_create_area(): void
    {
        $response = $this->actingAs($this->user)->postJson('/api/areas', [
            'name' => 'Test Area',
            'trigger_service' => 'weather',
            'trigger_action' => 'Temperature Below',
            'trigger_params' => [
                'city' => 'Paris',
                'threshold' => 15
            ],
            'action_service' => 'slack',
            'action_reaction' => 'Send Message',
            'action_params' => [
                'channel' => '#general',
                'message' => 'Il fait froid!'
            ],
            'is_active' => true
        ]);

        $response->assertStatus(201);
        $this->assertDatabaseHas('areas', [
            'name' => 'Test Area',
            'user_id' => $this->user->id,
            'trigger_service' => 'weather'
        ]);
    }

    /**
     * Test la récupération des AREAs d'un utilisateur
     */
    public function test_can_list_user_areas(): void
    {
        // Créer quelques AREAs
        Area::factory()->count(3)->create([
            'user_id' => $this->user->id
        ]);

        $response = $this->actingAs($this->user)->getJson('/api/areas');

        $response->assertStatus(200)
                 ->assertJsonCount(3);
    }

    /**
     * Test la mise à jour d'une AREA
     */
    public function test_can_update_area(): void
    {
        $area = Area::factory()->create([
            'user_id' => $this->user->id,
            'name' => 'Old Name',
            'is_active' => true
        ]);

        $response = $this->actingAs($this->user)->putJson("/api/areas/{$area->id}", [
            'name' => 'New Name',
            'is_active' => false
        ]);

        $response->assertStatus(200);
        $this->assertDatabaseHas('areas', [
            'id' => $area->id,
            'name' => 'New Name',
            'is_active' => false
        ]);
    }

    /**
     * Test la suppression d'une AREA
     */
    public function test_can_delete_area(): void
    {
        $area = Area::factory()->create([
            'user_id' => $this->user->id
        ]);

        $response = $this->actingAs($this->user)->deleteJson("/api/areas/{$area->id}");

        $response->assertStatus(200);
        $this->assertDatabaseMissing('areas', [
            'id' => $area->id
        ]);
    }

    /**
     * Test qu'un utilisateur ne peut pas modifier l'AREA d'un autre
     */
    public function test_cannot_update_other_user_area(): void
    {
        $otherUser = User::factory()->create();
        $area = Area::factory()->create([
            'user_id' => $otherUser->id
        ]);

        $response = $this->actingAs($this->user)->putJson("/api/areas/{$area->id}", [
            'name' => 'Hacked Name'
        ]);

        $response->assertStatus(403);
    }

    /**
     * Test l'exécution d'un trigger météo
     */
    public function test_weather_trigger_execution(): void
    {
        Http::fake([
            'api.openweathermap.org/*' => Http::response([
                'main' => ['temp' => 10],
                'weather' => [['main' => 'Clear', 'description' => 'clear sky']],
                'name' => 'Paris'
            ], 200),
            'slack.com/api/*' => Http::response(['ok' => true], 200)
        ]);

        $area = Area::factory()->create([
            'user_id' => $this->user->id,
            'trigger_service' => 'weather',
            'trigger_action' => 'Temperature Below',
            'trigger_params' => ['city' => 'Paris', 'threshold' => 15],
            'action_service' => 'slack',
            'action_reaction' => 'Send Message',
            'action_params' => ['bot_token' => 'test', 'channel' => '#test', 'text' => 'Cold!'],
            'is_active' => true
        ]);

        $this->artisan('schedule:work')->assertSuccessful();
    }
}
