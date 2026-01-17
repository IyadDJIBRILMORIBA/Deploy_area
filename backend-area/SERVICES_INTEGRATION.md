# Services Integration Guide

## Vue d'ensemble

Le backend AREA supporte **8 services** complètement intégrés :

1. ✅ **Google** (Gmail, Calendar, Drive)
2. ✅ **GitHub** (Issues, Pull Requests, Repositories)
3. ✅ **Discord** (Messages, Webhooks)
4. ✅ **Slack** (Messages, Channels)
5. ✅ **Twitch** (Streams, Followers, Clips)
6. ✅ **Weather** (OpenWeatherMap)
7. ✅ **Trello** (Boards, Cards, Lists)
8. ✅ **Timer** (Scheduled Tasks)

## Configuration

### 1. Variables d'environnement

Copiez `.env.example` vers `.env` et configurez les clés API :

```bash
cp .env.example .env
```

#### Google OAuth
```env
GOOGLE_WEB_CLIENT_ID=your_google_web_client_id
GOOGLE_CLIENT_SECRET=your_google_client_secret
GOOGLE_MOBILE_CLIENT_ID=your_google_mobile_client_id
```

#### GitHub OAuth
```env
GITHUB_CLIENT_ID=your_github_client_id
GITHUB_CLIENT_SECRET=your_github_client_secret
```

#### Discord
```env
DISCORD_CLIENT_ID=your_discord_client_id
DISCORD_CLIENT_SECRET=your_discord_client_secret
DISCORD_BOT_TOKEN=your_discord_bot_token
```

#### Slack
```env
SLACK_CLIENT_ID=your_slack_client_id
SLACK_CLIENT_SECRET=your_slack_client_secret
SLACK_BOT_TOKEN=your_slack_bot_token
```

#### Twitch
```env
TWITCH_CLIENT_ID=your_twitch_client_id
TWITCH_CLIENT_SECRET=your_twitch_client_secret
```

#### Weather (OpenWeatherMap)
```env
OPENWEATHER_API_KEY=your_openweathermap_api_key
```
Obtenez votre clé sur : https://openweathermap.org/api

#### Trello
```env
TRELLO_API_KEY=your_trello_api_key
TRELLO_TOKEN=your_trello_token
```
Obtenez vos credentials sur : https://trello.com/app-key

#### Frontend URL
```env
FRONTEND_URL=http://localhost:8081
```

### 2. Seeding de la base de données

Les services sont automatiquement créés lors du seeding :

```bash
php artisan migrate:fresh --seed
```

## Architecture des Services

### Structure des fichiers

```
app/Services/
├── GoogleService.php      # Google Workspace (Gmail, Calendar)
├── GitHubService.php      # GitHub repositories
├── DiscordService.php     # Discord messaging
├── SlackService.php       # Slack messaging
├── TwitchService.php      # Twitch streaming
├── WeatherService.php     # Weather data
├── TrelloService.php      # Trello boards
└── TimerService.php       # Scheduled tasks
```

### Interface ServiceInterface

Tous les services implémentent l'interface `ServiceInterface` :

```php
interface ServiceInterface
{
    /**
     * Vérifie si un trigger est activé
     * @return bool|array False ou données du trigger
     */
    public function checkTrigger(string $actionName, array $params, $userToken);

    /**
     * Exécute une réaction
     * @return bool Succès ou échec
     */
    public function executeReaction(string $reactionName, array $params, $userToken, $triggerData);
}
```

## Triggers et Actions disponibles

### 🔵 Google Service

**Triggers:**
- `new_email` - Nouvel email reçu
- `new_calendar_event` - Nouvel événement créé

**Actions:**
- `send_email` - Envoyer un email
- `create_calendar_event` - Créer un événement

### 🔵 GitHub Service

**Triggers:**
- `new_issue` - Nouvelle issue créée
- `new_pull_request` - Nouvelle PR ouverte

**Actions:**
- `create_issue` - Créer une issue

### 🟣 Discord Service

**Triggers:**
- `new_message` - Nouveau message dans un channel

**Actions:**
- `send_message` - Envoyer un message

### 🟣 Slack Service

**Triggers:**
- `new_message` - Nouveau message dans un channel

**Actions:**
- `send_message` - Envoyer un message

### 🟣 Twitch Service

**Triggers:**
- `stream_started` - Stream démarré
- `new_follower` - Nouveau follower

**Actions:**
- `update_stream_title` - Mettre à jour le titre

### 🟠 Weather Service

**Triggers:**
- `temperature_change` - Changement de température
- `weather_alert` - Alerte météo

**Actions:**
- `get_weather` - Obtenir la météo actuelle

### 🟢 Trello Service

**Triggers:**
- `new_card` - Nouvelle carte créée
- `card_moved` - Carte déplacée

**Actions:**
- `create_card` - Créer une carte
- `move_card` - Déplacer une carte

### ⏰ Timer Service

**Triggers:**
- `timer_trigger` - Déclenchement programmé (cron)

**Actions:**
- Aucune (service trigger uniquement)

## Exécution des AREAs

### Commande manuelle

```bash
php artisan area:execute
```

### Commande programmée (Cron)

```bash
php artisan area:execute-scheduled
```

### Configuration du Cron

Ajoutez dans votre crontab :

```bash
* * * * * cd /path/to/backend-area && php artisan schedule:run >> /dev/null 2>&1
```

Ou utilisez le service systemd fourni :

```bash
sudo cp area-scheduler.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable area-scheduler
sudo systemctl start area-scheduler
```

## API Endpoints

### Lister tous les services

```http
GET /api/services
Authorization: Bearer {token}
```

### Détails d'un service

```http
GET /api/services/{serviceId}
Authorization: Bearer {token}
```

### Connecter un service

```http
POST /api/services/{serviceId}/connect
Authorization: Bearer {token}
Content-Type: application/json

{
    "access_token": "...",
    "refresh_token": "...",
    "expires_at": 3600
}
```

### Déconnecter un service

```http
DELETE /api/services/{serviceId}/disconnect
Authorization: Bearer {token}
```

## Intégration Frontend

Le frontend Flutter communique avec ces services via :

1. **Backend Routes** (`lib/services/backend_routes.dart`)
2. **Service Models** (`lib/models/service_model.dart`)
3. **Create Area Data** (`lib/services/create_area_data.dart`)

Les couleurs et icônes sont automatiquement mappées pour chaque service.

## Logs et Débogage

Les logs des services sont disponibles dans :

```bash
storage/logs/laravel.log
```

Chaque service préfixe ses logs avec son nom :
- `[GoogleService]`
- `[TwitchService]`
- `[WeatherService]`
- etc.

## Tests

Testez un service individuellement :

```php
$service = new \App\Services\TwitchService();
$result = $service->checkTrigger('stream_started', ['channel' => 'test'], $user);
```

## Dépannage

### Service non reconnu
Vérifiez que le service est bien enregistré dans :
- `database/seeders/ServicesSeeder.php`
- `app/Console/Commands/ExecuteAreas.php` (méthode `getServiceInstance`)
- `app/Console/Commands/ExecuteScheduledAreas.php` (méthode `getServiceInstance`)

### Token expiré
Les tokens OAuth expirent. Le système vérifie automatiquement `expires_at` dans `user_services`.

### Clés API manquantes
Vérifiez `.env` et `config/services.php`.

## Contribuer

Pour ajouter un nouveau service :

1. Créer `app/Services/YourService.php` implémentant `ServiceInterface`
2. Ajouter dans `ServicesSeeder.php`
3. Ajouter dans `getServiceInstance()` des commandes
4. Ajouter dans `ServiceController.php` (descriptions, couleurs, triggers/actions)
5. Mettre à jour le frontend Flutter

## Support

Pour toute question, consultez :
- `docs/SERVICES_GUIDE.md`
- `backend-area/README_SERVICES.md`
- API Documentation : `/docs`
