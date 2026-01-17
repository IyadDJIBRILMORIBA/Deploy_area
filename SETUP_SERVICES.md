# 🔧 Configuration des Services AREA

## 📋 Services Déjà Fonctionnels

✅ **Google** (Gmail) - Configuré et opérationnel  
✅ **Timer** - Aucune configuration requise

---

## 🔑 Services À Configurer

### 1. **GitHub** 🐙

**Étapes :**

1. Allez sur https://github.com/settings/developers
2. Créez une nouvelle OAuth App
3. Configurez :
   - **Application name**: AREA GitHub Integration
   - **Homepage URL**: `http://localhost:8081`
   - **Authorization callback URL**: `http://localhost:8080/auth/github/callback`
4. Copiez `Client ID` et `Client Secret`

**Ajoutez dans `.env`** :
```env
GITHUB_CLIENT_ID=your_client_id_here
GITHUB_CLIENT_SECRET=your_client_secret_here
```

---

### 2. **Discord** 💬

**Étapes :**

1. Allez sur https://discord.com/developers/applications
2. Créez une nouvelle Application
3. Dans **OAuth2** :
   - Ajoutez `http://localhost:8080/auth/discord/callback` aux redirects
   - Copiez `Client ID` et `Client Secret`
4. Dans **Bot** :
   - Créez un bot
   - Copiez le `Bot Token`
   - Activez les intents : `MESSAGE CONTENT INTENT`, `SERVER MEMBERS INTENT`

**Ajoutez dans `.env`** :
```env
DISCORD_CLIENT_ID=your_client_id
DISCORD_CLIENT_SECRET=your_client_secret
DISCORD_BOT_TOKEN=your_bot_token
```

---

### 3. **Slack** 💼

**Étapes :**

1. Allez sur https://api.slack.com/apps
2. Créez une nouvelle App
3. Dans **OAuth & Permissions** :
   - Ajoutez `http://localhost:8080/auth/slack/callback` aux redirect URLs
   - Ajoutez les scopes :
     - `channels:history`
     - `chat:write`
     - `users:read`
4. Copiez `Client ID`, `Client Secret`, et `Bot User OAuth Token`

**Ajoutez dans `.env`** :
```env
SLACK_CLIENT_ID=your_client_id
SLACK_CLIENT_SECRET=your_client_secret
SLACK_BOT_TOKEN=xoxb-your-bot-token
```

---

### 4. **Twitch** 🎮

**Étapes :**

1. Allez sur https://dev.twitch.tv/console
2. Créez une nouvelle Application
3. Configurez :
   - **OAuth Redirect URLs**: `http://localhost:8080/auth/twitch/callback`
   - **Category**: Website Integration
4. Copiez `Client ID` et `Client Secret`

**Ajoutez dans `.env`** :
```env
TWITCH_CLIENT_ID=your_client_id
TWITCH_CLIENT_SECRET=your_client_secret
```

---

### 5. **Weather** ☀️ (OpenWeatherMap)

**Étapes :**

1. Créez un compte sur https://openweathermap.org/
2. Allez sur https://home.openweathermap.org/api_keys
3. Créez une nouvelle API Key (gratuit jusqu'à 1000 appels/jour)

**Ajoutez dans `.env`** :
```env
OPENWEATHER_API_KEY=your_api_key
```

---

### 6. **Trello** 📋

**Étapes :**

1. Allez sur https://trello.com/power-ups/admin
2. Créez une nouvelle Power-Up pour obtenir une API Key
3. Générez un Token : https://trello.com/1/authorize?expiration=never&name=AREA&scope=read,write&response_type=token&key=YOUR_API_KEY

**Ajoutez dans `.env`** :
```env
TRELLO_API_KEY=your_api_key
TRELLO_TOKEN=your_token
```

---

## 🚀 Après Configuration

### 1. Ajoutez les services dans la base de données

```bash
docker exec -it area_server php artisan tinker --execute="
\$services = [
    ['name' => 'github', 'is_active' => true],
    ['name' => 'discord', 'is_active' => true],
    ['name' => 'slack', 'is_active' => true],
    ['name' => 'twitch', 'is_active' => true],
    ['name' => 'weather', 'is_active' => true],
    ['name' => 'trello', 'is_active' => true],
];

foreach(\$services as \$service) {
    App\Models\Service::updateOrCreate(['name' => \$service['name']], \$service);
    echo 'Service ' . \$service['name'] . ' ajouté' . PHP_EOL;
}
"
```

### 2. Redémarrez les containers

```bash
docker-compose restart
```

### 3. Testez les services

```bash
# Test Weather
docker exec -it area_server php artisan tinker --execute="
\$weather = new App\Services\WeatherService();
\$result = \$weather->checkTrigger('temperature_above', ['city' => 'Paris', 'temperature' => 0], null);
var_dump(\$result);
"

# Test Trello
docker exec -it area_server php artisan tinker --execute="
\$trello = new App\Services\TrelloService();
echo 'Trello Service créé avec succès';
"
```

---

## 📊 Récapitulatif

| Service  | OAuth Requis | API Key Requise | Bot Token | Status |
|----------|--------------|-----------------|-----------|--------|
| Google   | ✅           | ❌              | ❌        | ✅ Opérationnel |
| Timer    | ❌           | ❌              | ❌        | ✅ Opérationnel |
| GitHub   | ✅           | ❌              | ❌        | ⚠️ À configurer |
| Discord  | ✅           | ❌              | ✅        | ⚠️ À configurer |
| Slack    | ✅           | ❌              | ✅        | ⚠️ À configurer |
| Twitch   | ✅           | ❌              | ❌        | ⚠️ À configurer |
| Weather  | ❌           | ✅              | ❌        | ⚠️ À configurer |
| Trello   | ❌           | ✅              | ❌        | ⚠️ À configurer |

---

## 🛠️ Configuration Rapide (Mode Dev)

Pour tester rapidement sans configurer OAuth, vous pouvez :

1. **Weather** et **Trello** : Uniquement API Keys nécessaires
2. **Discord/Slack** : Utilisez des Bot Tokens dans les paramètres AREA
3. **GitHub/Twitch** : OAuth obligatoire

**Commande pour ajouter tous les services** :

```bash
docker exec -it area_server php /var/www/artisan tinker --execute="
\$services = ['github', 'discord', 'slack', 'twitch', 'weather', 'trello'];
foreach(\$services as \$name) {
    App\Models\Service::firstOrCreate(['name' => \$name], ['is_active' => true]);
}
echo 'Tous les services ajoutés !';
"
```
