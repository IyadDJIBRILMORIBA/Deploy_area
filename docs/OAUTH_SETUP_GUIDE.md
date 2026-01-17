# OAuth Setup Guide - AREA Platform

Ce guide explique comment configurer les clés OAuth pour tous les services de la plateforme AREA.

## Services OAuth Supportés

1. **Google** ✅ (Déjà configuré)
2. **GitHub** 🔧
3. **Discord** 🔧
4. **Slack** 🔧
5. **Twitch** 🔧

---

## 1. Google OAuth (✅ Configuré)

### Configuration actuelle
Le service Google est déjà configuré dans votre `.env`:
```env
GOOGLE_WEB_CLIENT_ID=votre_client_id
GOOGLE_CLIENT_SECRET=votre_secret
```

### URLs de callback
- Web: `http://192.168.100.6:8000/api/services/google/callback`
- Mobile: Utilise Google Sign-In SDK

---

## 2. GitHub OAuth

### Étape 1: Créer une OAuth App sur GitHub

1. Allez sur [GitHub Developer Settings](https://github.com/settings/developers)
2. Cliquez sur **"New OAuth App"**
3. Remplissez les informations:
   - **Application name**: AREA Platform
   - **Homepage URL**: `http://192.168.100.6:8000`
   - **Authorization callback URL**: `http://192.168.100.6:8000/api/services/github/callback`
4. Cliquez sur **"Register application"**
5. Copiez le **Client ID** et générez un **Client Secret**

### Étape 2: Ajouter au fichier .env

```env
GITHUB_CLIENT_ID=your_github_client_id
GITHUB_CLIENT_SECRET=your_github_client_secret
```

### Scopes requis
- `repo` - Accès aux repositories
- `user` - Informations utilisateur
- `notifications` - Notifications

### Documentation
- [GitHub OAuth Documentation](https://docs.github.com/en/developers/apps/building-oauth-apps/authorizing-oauth-apps)

---

## 3. Discord OAuth

### Étape 1: Créer une application Discord

1. Allez sur [Discord Developer Portal](https://discord.com/developers/applications)
2. Cliquez sur **"New Application"**
3. Donnez un nom: **AREA Platform**
4. Dans **OAuth2** → **General**:
   - Ajoutez la Redirect URL: `http://192.168.100.6:8000/api/services/discord/callback`
5. Copiez le **Client ID** et **Client Secret**

### Étape 2: Ajouter au fichier .env

```env
DISCORD_CLIENT_ID=your_discord_client_id
DISCORD_CLIENT_SECRET=your_discord_client_secret
```

### Scopes requis
- `identify` - Informations utilisateur de base
- `guilds` - Liste des serveurs
- `messages.read` - Lire les messages
- `messages.write` - Envoyer des messages

### Documentation
- [Discord OAuth2 Documentation](https://discord.com/developers/docs/topics/oauth2)

---

## 4. Slack OAuth

### Étape 1: Créer une Slack App

1. Allez sur [Slack API Applications](https://api.slack.com/apps)
2. Cliquez sur **"Create New App"** → **"From scratch"**
3. Donnez un nom: **AREA Platform**
4. Sélectionnez votre workspace de test
5. Dans **OAuth & Permissions**:
   - Ajoutez la Redirect URL: `http://192.168.100.6:8000/api/services/slack/callback`
6. Copiez le **Client ID** et **Client Secret** (dans **Basic Information**)

### Étape 2: Ajouter au fichier .env

```env
SLACK_CLIENT_ID=your_slack_client_id
SLACK_CLIENT_SECRET=your_slack_client_secret
```

### Scopes requis (Bot Token Scopes)
- `channels:read` - Voir les canaux publics
- `chat:write` - Envoyer des messages
- `users:read` - Lire les informations utilisateur
- `channels:history` - Lire l'historique des canaux

### Scopes utilisateur (User Token Scopes)
- `channels:read`
- `chat:write`

### Documentation
- [Slack OAuth Documentation](https://api.slack.com/authentication/oauth-v2)

---

## 5. Twitch OAuth

### Étape 1: Créer une application Twitch

1. Allez sur [Twitch Developers Console](https://dev.twitch.tv/console/apps)
2. Cliquez sur **"Register Your Application"**
3. Remplissez:
   - **Name**: AREA Platform
   - **OAuth Redirect URLs**: `http://192.168.100.6:8000/api/services/twitch/callback`
   - **Category**: Application Integration
4. Cliquez sur **"Create"**
5. Cliquez sur **"Manage"** pour voir le **Client ID**
6. Générez un **Client Secret**

### Étape 2: Ajouter au fichier .env

```env
TWITCH_CLIENT_ID=your_twitch_client_id
TWITCH_CLIENT_SECRET=your_twitch_client_secret
```

### Scopes requis
- `user:read:email` - Email de l'utilisateur
- `channel:read:subscriptions` - Lire les abonnements
- `moderator:read:followers` - Lire les followers
- `channel:manage:broadcast` - Gérer le stream

### Documentation
- [Twitch Authentication Documentation](https://dev.twitch.tv/docs/authentication)

---

## 6. Weather API (OpenWeatherMap)

### Étape 1: Créer un compte OpenWeatherMap

1. Allez sur [OpenWeatherMap](https://openweathermap.org/api)
2. Créez un compte gratuit
3. Allez dans **API keys**
4. Copiez votre clé API

### Étape 2: Ajouter au fichier .env

```env
WEATHER_API_KEY=your_openweathermap_api_key
```

### Documentation
- [OpenWeatherMap API Documentation](https://openweathermap.org/api)

---

## 7. Trello API

### Étape 1: Créer une Power-Up Trello

1. Allez sur [Trello Power-Ups Admin](https://trello.com/power-ups/admin)
2. Cliquez sur **"New"**
3. Remplissez les informations:
   - **Name**: AREA Platform
   - **Workspace**: Sélectionnez votre workspace
4. Obtenez votre **API Key** depuis [https://trello.com/app-key](https://trello.com/app-key)
5. Générez un **Token** avec les permissions nécessaires

### Étape 2: Ajouter au fichier .env

```env
TRELLO_API_KEY=your_trello_api_key
TRELLO_API_SECRET=your_trello_api_secret
```

### Documentation
- [Trello API Documentation](https://developer.atlassian.com/cloud/trello/)

---

## Configuration complète du fichier .env

Voici un exemple complet de toutes les variables OAuth dans votre fichier `.env`:

```env
# Google OAuth (déjà configuré)
GOOGLE_WEB_CLIENT_ID=your_google_client_id
GOOGLE_CLIENT_SECRET=your_google_secret

# GitHub OAuth
GITHUB_CLIENT_ID=your_github_client_id
GITHUB_CLIENT_SECRET=your_github_client_secret

# Discord OAuth
DISCORD_CLIENT_ID=your_discord_client_id
DISCORD_CLIENT_SECRET=your_discord_client_secret

# Slack OAuth
SLACK_CLIENT_ID=your_slack_client_id
SLACK_CLIENT_SECRET=your_slack_client_secret

# Twitch OAuth
TWITCH_CLIENT_ID=your_twitch_client_id
TWITCH_CLIENT_SECRET=your_twitch_client_secret

# Weather API
WEATHER_API_KEY=your_openweathermap_api_key

# Trello API
TRELLO_API_KEY=your_trello_api_key
TRELLO_API_SECRET=your_trello_api_secret
```

---

## Tester la configuration

### 1. Redémarrer le backend Laravel

Après avoir ajouté les variables dans `.env`, redémarrez le serveur:

```bash
cd backend-area
php artisan config:clear
php artisan cache:clear
php artisan serve --host=0.0.0.0 --port=8000
```

### 2. Tester l'URL OAuth

Pour chaque service, testez l'URL de génération OAuth:

```bash
# GitHub
curl -H "Authorization: Bearer YOUR_TOKEN" \
  http://192.168.100.6:8000/api/services/3/connect

# Discord
curl -H "Authorization: Bearer YOUR_TOKEN" \
  http://192.168.100.6:8000/api/services/4/connect

# Slack
curl -H "Authorization: Bearer YOUR_TOKEN" \
  http://192.168.100.6:8000/api/services/5/connect

# Twitch
curl -H "Authorization: Bearer YOUR_TOKEN" \
  http://192.168.100.6:8000/api/services/6/connect
```

Vous devriez recevoir une réponse avec `oauth_url`.

### 3. Tester le flow complet

1. Ouvrez l'URL OAuth dans un navigateur
2. Autorisez l'application
3. Vous serez redirigé vers le callback
4. Vérifiez que le token est sauvegardé dans `user_services`:

```bash
mysql -u root -p
use area_db;
SELECT * FROM user_services WHERE user_id = YOUR_USER_ID;
```

---

## Dépannage

### Erreur "token_exchange_failed"
- Vérifiez que les Client ID et Client Secret sont corrects
- Vérifiez que l'URL de callback est exactement celle configurée

### Erreur "invalid_redirect_uri"
- L'URL de callback doit correspondre EXACTEMENT à celle configurée dans l'application OAuth
- Utilisez `http://192.168.100.6:8000` (pas localhost)

### Erreur "unsupported_service"
- Vérifiez que le service existe dans la table `services`
- Vérifiez que le nom du service correspond (github, discord, slack, twitch en minuscules)

### Token expiré
- GitHub: Les tokens ne expirent pas par défaut
- Discord: Expire après 1 semaine, utilise le refresh token
- Slack: Expire selon la configuration de l'app
- Twitch: Expire après ~60 jours

---

## Limitations actuelles

### Mobile OAuth
Pour le moment, les services OAuth web (GitHub, Discord, Slack, Twitch) ne sont pas complètement implémentés sur mobile car ils nécessitent:
- Un WebView pour afficher la page OAuth
- Une interception du callback de redirection
- Ou l'utilisation de deep links

**Solution temporaire**: Utilisez la version web du frontend ou configurez les tokens manuellement via l'API.

**Solution future**: Implémenter `url_launcher` ou `webview_flutter` pour gérer le flow OAuth sur mobile.

---

## Prochaines étapes

1. ✅ Configuration backend OAuth (Fait)
2. 🔧 Ajouter les clés OAuth dans `.env`
3. 🔧 Tester chaque service individuellement
4. 🔧 Implémenter WebView sur mobile (optionnel)
5. 🔧 Créer des AREAs de test pour chaque service

---

## Support

Pour toute question ou problème:
- Consultez les logs Laravel: `tail -f storage/logs/laravel.log`
- Vérifiez la console mobile Flutter
- Consultez la documentation officielle de chaque service

Bon développement ! 🚀
