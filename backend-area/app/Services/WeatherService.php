<?php

namespace App\Services;

use App\Interfaces\ServiceInterface;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Cache;

/**
 * WeatherService - Service de gestion des actions/réactions météo
 * 
 * Ce service utilise l'API OpenWeatherMap pour :
 * - Vérifier des conditions météorologiques (triggers)
 * - Récupérer des informations météo (reactions)
 * 
 * @author Asaph (Équipe AREA)
 * @version 1.0
 */
class WeatherService implements ServiceInterface
{
    /**
     * Clé API OpenWeatherMap (depuis .env)
     * @var string
     */
    private string $apiKey;

    /**
     * URL de base de l'API OpenWeatherMap
     * @var string
     */
    private string $baseUrl = 'https://api.openweathermap.org/data/2.5';

    /**
     * Durée du cache en secondes (1 heure)
     * @var int
     */
    private int $cacheDuration = 3600;

    /**
     * Constructeur - Récupère la clé API depuis les variables d'environnement
     */
    public function __construct()
    {
        $this->apiKey = env('OPENWEATHER_API_KEY', '');
        
        if (empty($this->apiKey)) {
            Log::warning("[WeatherService] OPENWEATHER_API_KEY n'est pas configurée dans .env");
        }
    }

    /**
     * Vérifie si un trigger météo est activé
     * 
     * Triggers supportés :
     * - temperature_above : Température supérieure à un seuil
     * - temperature_below : Température inférieure à un seuil
     * - weather_condition : Condition météo spécifique (rain, snow, clear, clouds)
     * - humidity_above : Humidité supérieure à un seuil
     * 
     * @param string $actionName Le nom de l'action (ex: 'temperature_above')
     * @param array $params Paramètres du trigger (ex: ['city' => 'Paris', 'threshold' => 30])
     * @param object|null $userToken L'objet User (non utilisé pour Weather, service public)
     * @return bool|array Retourne false si non activé, sinon les données météo
     */
    public function checkTrigger(string $actionName, array $params, $userToken)
    {
        try {
            Log::info("[WeatherService] checkTrigger START - Action: {$actionName}");
            
            // Convertir le nom du trigger en snake_case pour comparaison
            $triggerKey = strtolower(str_replace(' ', '_', $actionName));

            // Valider les paramètres requis
            $city = $params['city'] ?? null;
            if (empty($city)) {
                Log::error("[WeatherService] Paramètre 'city' manquant");
                return false;
            }

            // Récupérer les données météo (avec cache)
            $weatherData = $this->getWeatherData($city);
            
            if (!$weatherData) {
                Log::error("[WeatherService] Impossible de récupérer les données météo pour {$city}");
                return false;
            }

            Log::info("[WeatherService] Données météo récupérées pour {$city}: {$weatherData['temp']}°C, {$weatherData['condition']}");

            // Vérifier selon le type d'action
            switch ($triggerKey) {
                case 'temperature_above':
                    return $this->checkTemperatureAbove($weatherData, $params);

                case 'temperature_below':
                    return $this->checkTemperatureBelow($weatherData, $params);

                case 'weather_condition':
                    return $this->checkWeatherCondition($weatherData, $params);

                case 'humidity_above':
                    return $this->checkHumidityAbove($weatherData, $params);

                default:
                    Log::warning("[WeatherService] Action inconnue : {$actionName}");
                    return false;
            }

        } catch (\Exception $e) {
            Log::error("[WeatherService] Erreur checkTrigger : " . $e->getMessage());
            return false;
        }
    }

    /**
     * Exécute une réaction météo
     * 
     * REActions supportées :
     * - get_weather_info : Récupère et log les informations météo actuelles
     * - get_forecast : Récupère les prévisions (future implémentation)
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
            Log::info("[WeatherService] executeReaction START - Reaction: {$reactionName}");
            
            // Convertir le nom de la réaction en snake_case pour comparaison
            $actionKey = strtolower(str_replace(' ', '_', $reactionName));

            switch ($actionKey) {
                case 'get_weather_info':
                    return $this->getWeatherInfo($params, $triggerData);

                case 'get_forecast':
                    // Future implémentation : prévisions à 5 jours
                    Log::info("[WeatherService] get_forecast non encore implémenté");
                    return true;

                default:
                    Log::warning("[WeatherService] Réaction inconnue : {$reactionName}");
                    return false;
            }

        } catch (\Exception $e) {
            Log::error("[WeatherService] Erreur executeReaction : " . $e->getMessage());
            throw $e;
        }
    }

    /**
     * Vérifie si la température est au-dessus du seuil
     * 
     * @param array $weatherData Données météo actuelles
     * @param array $params Paramètres (threshold)
     * @return bool|array
     */
    private function checkTemperatureAbove(array $weatherData, array $params)
    {
        $threshold = $params['threshold'] ?? 30;
        $currentTemp = $weatherData['temp'];

        if ($currentTemp > $threshold) {
            Log::info("[WeatherService] ✅ Trigger ACTIVÉ : Température {$currentTemp}°C > {$threshold}°C");
            return [
                'temperature' => $currentTemp,
                'threshold' => $threshold,
                'city' => $weatherData['city'],
                'condition' => $weatherData['condition'],
                'description' => $weatherData['description'],
                'triggered_at' => now()->toIso8601String(),
                'trigger_type' => 'temperature_above'
            ];
        }

        Log::info("[WeatherService] ❌ Trigger NON activé : Température {$currentTemp}°C <= {$threshold}°C");
        return false;
    }

    /**
     * Vérifie si la température est en-dessous du seuil
     * 
     * @param array $weatherData Données météo actuelles
     * @param array $params Paramètres (threshold)
     * @return bool|array
     */
    private function checkTemperatureBelow(array $weatherData, array $params)
    {
        $threshold = $params['threshold'] ?? 0;
        $currentTemp = $weatherData['temp'];

        if ($currentTemp < $threshold) {
            Log::info("[WeatherService] ✅ Trigger ACTIVÉ : Température {$currentTemp}°C < {$threshold}°C");
            return [
                'temperature' => $currentTemp,
                'threshold' => $threshold,
                'city' => $weatherData['city'],
                'condition' => $weatherData['condition'],
                'description' => $weatherData['description'],
                'triggered_at' => now()->toIso8601String(),
                'trigger_type' => 'temperature_below'
            ];
        }

        Log::info("[WeatherService] ❌ Trigger NON activé : Température {$currentTemp}°C >= {$threshold}°C");
        return false;
    }

    /**
     * Vérifie si la condition météo correspond
     * 
     * Conditions supportées :
     * - rain : Pluie
     * - snow : Neige
     * - clear : Ciel dégagé
     * - clouds : Nuageux
     * - thunderstorm : Orage
     * - drizzle : Bruine
     * - mist/fog : Brouillard
     * 
     * @param array $weatherData Données météo actuelles
     * @param array $params Paramètres (condition)
     * @return bool|array
     */
    private function checkWeatherCondition(array $weatherData, array $params)
    {
        $expectedCondition = strtolower($params['condition'] ?? 'rain');
        $actualCondition = strtolower($weatherData['condition']);

        if ($actualCondition === $expectedCondition) {
            Log::info("[WeatherService] ✅ Trigger ACTIVÉ : Condition météo = {$actualCondition}");
            return [
                'condition' => $weatherData['condition'],
                'description' => $weatherData['description'],
                'city' => $weatherData['city'],
                'temperature' => $weatherData['temp'],
                'humidity' => $weatherData['humidity'],
                'triggered_at' => now()->toIso8601String(),
                'trigger_type' => 'weather_condition'
            ];
        }

        Log::info("[WeatherService] ❌ Trigger NON activé : Condition {$actualCondition} != {$expectedCondition}");
        return false;
    }

    /**
     * Vérifie si l'humidité est au-dessus du seuil
     * 
     * @param array $weatherData Données météo actuelles
     * @param array $params Paramètres (threshold)
     * @return bool|array
     */
    private function checkHumidityAbove(array $weatherData, array $params)
    {
        $threshold = $params['threshold'] ?? 80;
        $currentHumidity = $weatherData['humidity'];

        if ($currentHumidity > $threshold) {
            Log::info("[WeatherService] ✅ Trigger ACTIVÉ : Humidité {$currentHumidity}% > {$threshold}%");
            return [
                'humidity' => $currentHumidity,
                'threshold' => $threshold,
                'city' => $weatherData['city'],
                'temperature' => $weatherData['temp'],
                'condition' => $weatherData['condition'],
                'triggered_at' => now()->toIso8601String(),
                'trigger_type' => 'humidity_above'
            ];
        }

        Log::info("[WeatherService] ❌ Trigger NON activé : Humidité {$currentHumidity}% <= {$threshold}%");
        return false;
    }

    /**
     * Récupère et log les informations météo (REAction)
     * 
     * @param array $params Paramètres (city)
     * @param array $triggerData Données du trigger
     * @return bool
     */
    private function getWeatherInfo(array $params, array $triggerData)
    {
        $city = $params['city'] ?? $triggerData['city'] ?? 'Paris';
        $weatherData = $this->getWeatherData($city);

        if ($weatherData) {
            $message = sprintf(
                "☀️ Météo à %s : %s°C, %s (Humidité: %s%%)",
                $weatherData['city'],
                $weatherData['temp'],
                $weatherData['description'],
                $weatherData['humidity']
            );
            
            Log::info("[WeatherService] REAction get_weather_info : {$message}");
            return true;
        }

        Log::error("[WeatherService] Impossible de récupérer les infos météo pour {$city}");
        return false;
    }

    /**
     * Récupère les données météo depuis l'API OpenWeatherMap (avec cache)
     * 
     * Cette méthode implémente un système de cache pour éviter de surcharger l'API.
     * Les données sont mises en cache pendant 1 heure (configurable via $cacheDuration).
     * 
     * @param string $city Nom de la ville
     * @return array|null Données météo ou null si erreur
     */
    private function getWeatherData(string $city): ?array
    {
        try {
            // Clé de cache basée sur la ville et l'heure actuelle
            $cacheKey = "weather_" . strtolower(str_replace(' ', '_', $city)) . "_" . now()->format('YmdH');

            // Utiliser le cache Laravel pour éviter les appels API répétés
            return Cache::remember($cacheKey, $this->cacheDuration, function () use ($city) {
                return $this->callWeatherAPI($city);
            });

        } catch (\Exception $e) {
            Log::error("[WeatherService] Erreur getWeatherData : " . $e->getMessage());
            return null;
        }
    }

    /**
     * Appelle directement l'API OpenWeatherMap (sans cache)
     * 
     * @param string $city Nom de la ville
     * @return array|null Données météo ou null si erreur
     */
    private function callWeatherAPI(string $city): ?array
    {
        try {
            if (empty($this->apiKey)) {
                throw new \Exception("Clé API OpenWeatherMap non configurée");
            }

            Log::info("[WeatherService] Appel API OpenWeatherMap pour {$city}");

            $response = Http::timeout(10)->get("{$this->baseUrl}/weather", [
                'q' => $city,
                'appid' => $this->apiKey,
                'units' => 'metric',  // Celsius
                'lang' => 'fr'        // Descriptions en français
            ]);

            if (!$response->successful()) {
                $statusCode = $response->status();
                $errorBody = $response->body();
                
                Log::error("[WeatherService] API Error {$statusCode} : {$errorBody}");
                
                // Gestion des erreurs spécifiques
                if ($statusCode === 404) {
                    throw new \Exception("Ville '{$city}' non trouvée");
                } elseif ($statusCode === 401) {
                    throw new \Exception("Clé API invalide ou expirée");
                } elseif ($statusCode === 429) {
                    throw new \Exception("Limite d'appels API atteinte");
                }
                
                return null;
            }

            $data = $response->json();

            // Vérifier la structure de la réponse
            if (!isset($data['main']) || !isset($data['weather'])) {
                throw new \Exception("Réponse API invalide");
            }

            Log::info("[WeatherService] API Success : Données récupérées pour {$city}");

            return [
                'temp' => round($data['main']['temp'], 1),
                'feels_like' => round($data['main']['feels_like'], 1),
                'temp_min' => round($data['main']['temp_min'], 1),
                'temp_max' => round($data['main']['temp_max'], 1),
                'humidity' => $data['main']['humidity'],
                'pressure' => $data['main']['pressure'],
                'condition' => $data['weather'][0]['main'],           // "Rain", "Clear", "Snow", "Clouds"
                'description' => $data['weather'][0]['description'],  // "légère pluie"
                'icon' => $data['weather'][0]['icon'],                // Code icône
                'city' => $city,
                'country' => $data['sys']['country'] ?? 'Unknown',
                'wind_speed' => $data['wind']['speed'] ?? 0,
                'timestamp' => now()->toIso8601String()
            ];

        } catch (\Exception $e) {
            Log::error("[WeatherService] Erreur callWeatherAPI : " . $e->getMessage());
            return null;
        }
    }
}
