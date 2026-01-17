# 🧪 Guide de Test des Services

## ✅ Configuration Complétée

Toutes les clés API sont maintenant chargées dans les conteneurs Docker !

```
✅ GITHUB_CLIENT_ID
✅ DISCORD_BOT_TOKEN  
✅ SLACK_BOT_TOKEN
✅ TWITCH_CLIENT_ID
✅ OPENWEATHER_API_KEY
✅ TRELLO_API_KEY
```

---

## 📋 Prochaines Étapes de Test

### 1️⃣ Tester le Service Weather (Le plus simple)

Le service Weather ne nécessite pas d'OAuth, juste l'API key qui est déjà configurée.

#### Créer une AREA de test :

1. **Ouvrez le frontend** : http://localhost:8081

2. **Connectez-vous** (ou créez un compte)

3. **Allez sur "Create AREA"**

4. **Créer une AREA Timer → Weather** :
   ```
   Trigger: Timer - every_minute
   Action: Weather - check_weather (si disponible)
   
   OU
   
   Trigger: Timer - every_hour
   Configuration: Vérifier météo Paris
   ```

#### Test manuel via API :

```bash
# Tester directement l'API Weather
docker exec -it area_server php artisan tinker --execute="
\$weather = new App\Services\WeatherService();
\$result = \$weather->getCurrentWeather('Paris');
print_r(\$result);
"
```

---

### 2️⃣ Tester le Service Trello

Trello nécessite une API Key ET un Token (déjà configurés).

#### Test manuel :

```bash
# Tester l'API Trello
docker exec -it area_server php artisan tinker --execute="
\$trello = new App\Services\TrelloService();
// Test de connexion basique
echo 'Trello API Key: ' . env('TRELLO_API_KEY') . PHP_EOL;
echo 'Trello Token: ' . env('TRELLO_TOKEN') . PHP_EOL;
"
```

#### Créer une AREA :
```
Trigger: Timer - every_day
Action: Trello - create_card
Configuration:
  - Board ID: (récupérer depuis Trello)
  - List ID: (récupérer depuis Trello)
  - Card Title: "Rapport quotidien"
```

---

### 3️⃣ Tester les Services OAuth (GitHub, Discord, Slack, Twitch)

Ces services nécessitent que l'utilisateur se connecte via OAuth.

#### Étape 1 : Connecter un service

1. Allez sur http://localhost:8081/services
2. Cliquez sur **"Connect"** pour GitHub/Discord/Slack/Twitch
3. Vous serez redirigé vers la page d'autorisation du service
4. Acceptez les permissions
5. Vous serez redirigé vers votre application

#### Vérifier la connexion :

```bash
# Voir les services connectés par l'utilisateur
docker exec -it area_server php artisan tinker --execute="
\$user = App\Models\User::first();
\$connected = \$user->connectedServices;
echo 'Services connectés pour ' . \$user->email . ':' . PHP_EOL;
foreach (\$connected as \$service) {
    echo '  ✅ ' . \$service->name . PHP_EOL;
}
"
```

#### Créer des AREAs de test :

**GitHub → Discord** :
```
Trigger: GitHub - new_repository
Action: Discord - send_message
Config: 
  - Channel ID: (votre channel Discord)
  - Message: "Nouveau repo créé !"
```

**Timer → Slack** :
```
Trigger: Timer - every_hour
Action: Slack - send_message
Config:
  - Channel: #general
  - Message: "Rappel horaire"
```

**Twitch → Discord** :
```
Trigger: Twitch - stream_started
Action: Discord - send_message
Config:
  - Channel ID: (votre channel)
  - Message: "Stream en ligne !"
```

---

## 🔍 Vérifier que tout fonctionne

### Vérifier les logs du scheduler :

```bash
# Voir les logs en temps réel
docker logs -f area_scheduler

# Vous devriez voir toutes les minutes :
# [2026-01-15 XX:XX:XX] Exécution des AREAs programmées...
# [2026-01-15 XX:XX:XX] Trigger every_minute activé pour l'AREA #X
```

### Vérifier les AREAs actives :

```bash
docker exec -it area_server php artisan tinker --execute="
echo '📊 STATISTIQUES DES AREAs' . PHP_EOL;
echo '=========================' . PHP_EOL;
echo PHP_EOL;

\$total = App\Models\Area::count();
\$active = App\Models\Area::where('is_active', true)->count();
\$inactive = \$total - \$active;

echo 'Total AREAs: ' . \$total . PHP_EOL;
echo 'Actives: ' . \$active . ' ✅' . PHP_EOL;
echo 'Inactives: ' . \$inactive . ' ⏸️' . PHP_EOL;
echo PHP_EOL;

echo 'Liste des AREAs actives:' . PHP_EOL;
\$areas = App\Models\Area::where('is_active', true)->with('user')->get();
foreach (\$areas as \$area) {
    echo '  • AREA #' . \$area->id . ' - ' . \$area->name . PHP_EOL;
    echo '    Trigger: ' . \$area->service_name . ' - ' . \$area->service_trigger . PHP_EOL;
    echo '    Action: ' . \$area->action_service_name . ' - ' . \$area->action_service_action . PHP_EOL;
}
"
```

---

## 🎯 Tests Recommandés par Service

### Timer Service ✅
```
Status: OPÉRATIONNEL
Test: Créer une AREA avec trigger every_minute
Résultat attendu: Logs toutes les minutes dans le scheduler
```

### Google Service ✅
```
Status: OPÉRATIONNEL (si OAuth reconnecté)
Test: Créer une AREA "Timer → Send Email"
Résultat attendu: Email reçu toutes les X minutes/heures
```

### Weather Service 🌤️
```
Status: PRÊT À TESTER
Test: Vérifier météo d'une ville
Commande: 
docker exec -it area_server php artisan tinker --execute="
\$service = new App\Services\WeatherService();
print_r(\$service->getCurrentWeather('Paris'));
"
```

### Trello Service 📋
```
Status: PRÊT À TESTER
Test: Créer une carte Trello
Prérequis: Récupérer Board ID et List ID depuis Trello
```

### GitHub Service 🐙
```
Status: NÉCESSITE CONNEXION OAUTH
Test: Connecter GitHub via /services puis créer une AREA
```

### Discord Service 💬
```
Status: NÉCESSITE CONNEXION OAUTH
Test: Connecter Discord via /services puis envoyer un message
```

### Slack Service 💼
```
Status: NÉCESSITE CONNEXION OAUTH
Test: Connecter Slack via /services puis envoyer un message
```

### Twitch Service 🎮
```
Status: NÉCESSITE CONNEXION OAUTH
Test: Connecter Twitch via /services puis détecter stream
```

---

## 🚀 Ordre de Test Recommandé

1. **Timer** → Déjà fonctionnel ✅
2. **Weather** → Test direct sans OAuth 🌤️
3. **Trello** → Test avec API Key 📋
4. **Google** → Reconnexion OAuth puis test email 📧
5. **GitHub** → Connexion OAuth puis test trigger 🐙
6. **Discord** → Connexion OAuth puis test message 💬
7. **Slack** → Connexion OAuth puis test message 💼
8. **Twitch** → Connexion OAuth puis test stream 🎮

---

## 🐛 Debugging

### Si une AREA ne s'exécute pas :

```bash
# Vérifier les logs du scheduler
docker logs --tail=50 area_scheduler

# Vérifier les erreurs PHP
docker exec -it area_server tail -f storage/logs/laravel.log

# Vérifier la base de données
docker exec -it area_server php artisan tinker --execute="
\$area = App\Models\Area::find(1); // Remplacer 1 par l'ID de votre AREA
echo 'AREA: ' . \$area->name . PHP_EOL;
echo 'Active: ' . (\$area->is_active ? 'OUI' : 'NON') . PHP_EOL;
echo 'Trigger: ' . \$area->service_trigger . PHP_EOL;
echo 'Config: ' . PHP_EOL;
print_r(\$area->trigger_config);
"
```

### Si un service ne se connecte pas :

```bash
# Vérifier les variables d'environnement
docker exec -it area_server env | grep -E 'GITHUB|DISCORD|SLACK|TWITCH|WEATHER|TRELLO'

# Vérifier les tokens OAuth en BDD
docker exec -it area_server php artisan tinker --execute="
\$user = App\Models\User::first();
\$services = \$user->connectedServices()->with('pivot')->get();
foreach (\$services as \$service) {
    echo \$service->name . ':' . PHP_EOL;
    echo '  Access Token: ' . substr(\$service->pivot->access_token, 0, 20) . '...' . PHP_EOL;
    echo '  Expires: ' . \$service->pivot->token_expires_at . PHP_EOL;
}
"
```

---

## ✨ Résultat Final Attendu

Une fois tous les tests complétés, vous devriez avoir :

✅ 8 services actifs dans la base de données  
✅ Au moins 1 AREA fonctionnelle (Timer → Google)  
✅ Services OAuth connectés pour votre utilisateur  
✅ Logs du scheduler affichant les exécutions  
✅ Frontend affichant tous les services avec leurs icônes  
✅ Possibilité de créer des AREAs pour tous les services  

---

🎉 **Votre plateforme AREA est maintenant entièrement opérationnelle !**
