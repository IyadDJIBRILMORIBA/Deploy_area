<?php

namespace Tests\Unit;

use Tests\TestCase;
use App\Services\WeatherService;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Cache;

class WeatherServiceTest extends TestCase
{
    protected WeatherService $weatherService;

    protected function setUp(): void
    {
        parent::setUp();
        $this->weatherService = new WeatherService();
    }

    /**
     * Test que le service retourne false si la ville est manquante
     */
    public function test_check_trigger_returns_false_when_city_missing(): void
    {
        $result = $this->weatherService->checkTrigger('temperature_below', [], null);
        
        $this->assertFalse($result);
    }

    /**
     * Test que temperature_below détecte correctement un changement d'état
     */
    public function test_temperature_below_detects_state_change(): void
    {
        // Mock de l'API OpenWeatherMap
        Http::fake([
            'api.openweathermap.org/*' => Http::response([
                'main' => [
                    'temp' => 10,
                    'humidity' => 60
                ],
                'weather' => [
                    ['main' => 'Clear', 'description' => 'clear sky']
                ],
                'name' => 'Paris'
            ], 200)
        ]);

        // Premier déclenchement : pas d'état précédent
        $result = $this->weatherService->checkTrigger('temperature_below', [
            'city' => 'Paris',
            'threshold' => 15
        ], null);

        $this->assertIsArray($result);
        $this->assertEquals(10, $result['temperature']);
        $this->assertEquals('below', $result['_last_state']);
    }

    /**
     * Test que temperature_below ne se déclenche pas si déjà en dessous
     */
    public function test_temperature_below_skips_when_already_below(): void
    {
        Http::fake([
            'api.openweathermap.org/*' => Http::response([
                'main' => [
                    'temp' => 10,
                    'humidity' => 60
                ],
                'weather' => [
                    ['main' => 'Clear', 'description' => 'clear sky']
                ],
                'name' => 'Paris'
            ], 200)
        ]);

        // Déjà en dessous du seuil
        $result = $this->weatherService->checkTrigger('temperature_below', [
            'city' => 'Paris',
            'threshold' => 15,
            '_last_state' => 'below'
        ], null);

        $this->assertIsArray($result);
        $this->assertTrue($result['_skip'] ?? false);
    }

    /**
     * Test que temperature_above fonctionne correctement
     */
    public function test_temperature_above_triggers_correctly(): void
    {
        Http::fake([
            'api.openweathermap.org/*' => Http::response([
                'main' => [
                    'temp' => 35,
                    'humidity' => 40
                ],
                'weather' => [
                    ['main' => 'Clear', 'description' => 'clear sky']
                ],
                'name' => 'Paris'
            ], 200)
        ]);

        $result = $this->weatherService->checkTrigger('temperature_above', [
            'city' => 'Paris',
            'threshold' => 30
        ], null);

        $this->assertIsArray($result);
        $this->assertEquals(35, $result['temperature']);
        $this->assertEquals('temperature_above', $result['trigger_type']);
    }

    /**
     * Test que le service gère les erreurs API
     */
    public function test_handles_api_errors_gracefully(): void
    {
        Http::fake([
            'api.openweathermap.org/*' => Http::response([], 500)
        ]);

        $result = $this->weatherService->checkTrigger('temperature_below', [
            'city' => 'Paris',
            'threshold' => 15
        ], null);

        $this->assertFalse($result);
    }
}
