# Guide de Déploiement Backend AREA sur Render

## 📋 Prérequis

- Un compte [Render](https://render.com)
- Un compte GitHub avec votre repository
- Accès aux identifiants OAuth (Google, Microsoft, Spotify, GitHub, Discord)

## 🚀 Étapes de Déploiement

### 1. Préparer votre Repository

Assurez-vous que tous les fichiers de configuration sont commités :
```bash
git add .
git commit -m "Add Render deployment configuration"
git push origin masters
```

### 2. Créer une Base de Données MySQL sur Render

1. Connectez-vous à [Render Dashboard](https://dashboard.render.com)
2. Cliquez sur **"New +"** → **"PostgreSQL"** (ou MySQL si disponible)
   - **Note**: Render propose PostgreSQL gratuitement. Pour MySQL, utilisez une base externe comme PlanetScale ou Railway.io
3. Configuration de la base de données :
   - **Name**: `area-db`
   - **Database**: `area_database`
   - **User**: `area_user`
   - **Region**: Frankfurt (ou autre proche de vous)
   - **Plan**: Free
4. Cliquez sur **"Create Database"**
5. **Notez** les informations de connexion (Host, Port, Database, Username, Password)

### 3. Déployer le Backend avec Docker

#### Option A : Déploiement via Blueprint (Recommandé)

1. Dans Render Dashboard, cliquez sur **"New +"** → **"Blueprint"**
2. Connectez votre repository GitHub
3. Sélectionnez le fichier `backend-area/render.yaml`
4. Render détectera automatiquement la configuration
5. Configurez les variables d'environnement

#### Option B : Déploiement Manuel

1. Cliquez sur **"New +"** → **"Web Service"**
2. Connectez votre repository GitHub
3. Configuration du service :
   - **Name**: `area-backend`
   - **Region**: Frankfurt
   - **Branch**: `masters`
   - **Root Directory**: `backend-area`
   - **Environment**: Docker
   - **Dockerfile Path**: `Dockerfile.production`
   - **Plan**: Free

### 4. Configurer les Variables d'Environnement

Dans les paramètres du service, ajoutez ces variables :

#### Configuration de Base
```
APP_NAME=AREA
APP_ENV=production
APP_DEBUG=false
APP_URL=https://votre-service.onrender.com
APP_KEY=base64:VOTRE_CLE_GENEREE
```

#### Base de Données
```
DB_CONNECTION=mysql
DB_HOST=votre-db-host.render.com
DB_PORT=3306
DB_DATABASE=area_database
DB_USERNAME=area_user
DB_PASSWORD=votre_mot_de_passe
```

#### Configuration Laravel
```
SESSION_DRIVER=database
CACHE_STORE=database
QUEUE_CONNECTION=database
LOG_CHANNEL=stack
LOG_LEVEL=error
```

#### OAuth - Google
```
GOOGLE_CLIENT_ID=votre_google_client_id
GOOGLE_CLIENT_SECRET=votre_google_client_secret
GOOGLE_REDIRECT_URI=https://votre-service.onrender.com/api/auth/google/callback
```

#### OAuth - Microsoft
```
MICROSOFT_CLIENT_ID=votre_microsoft_client_id
MICROSOFT_CLIENT_SECRET=votre_microsoft_client_secret
MICROSOFT_REDIRECT_URI=https://votre-service.onrender.com/api/auth/microsoft/callback
```

#### OAuth - Spotify
```
SPOTIFY_CLIENT_ID=votre_spotify_client_id
SPOTIFY_CLIENT_SECRET=votre_spotify_client_secret
SPOTIFY_REDIRECT_URI=https://votre-service.onrender.com/api/auth/spotify/callback
```

#### OAuth - GitHub
```
GITHUB_CLIENT_ID=votre_github_client_id
GITHUB_CLIENT_SECRET=votre_github_client_secret
GITHUB_REDIRECT_URI=https://votre-service.onrender.com/api/auth/github/callback
```

#### OAuth - Discord
```
DISCORD_CLIENT_ID=votre_discord_client_id
DISCORD_CLIENT_SECRET=votre_discord_client_secret
DISCORD_REDIRECT_URI=https://votre-service.onrender.com/api/auth/discord/callback
```

### 5. Générer la Clé d'Application

Pour générer `APP_KEY`, vous pouvez :

**Option 1** : Localement
```bash
cd backend-area
php artisan key:generate --show
```

**Option 2** : En ligne avec Docker
```bash
docker run --rm -v $PWD/backend-area:/app -w /app composer/composer:latest \
  bash -c "composer install && php artisan key:generate --show"
```

Copiez la clé générée et ajoutez-la dans les variables d'environnement.

### 6. Déployer

1. Cliquez sur **"Create Web Service"**
2. Render va :
   - Construire l'image Docker
   - Installer les dépendances
   - Exécuter les migrations
   - Démarrer le service

### 7. Vérifier le Déploiement

Une fois déployé, testez les endpoints :

```bash
# Healthcheck
curl https://votre-service.onrender.com/api/health

# About.json (pour le frontend)
curl https://votre-service.onrender.com/about.json

# Documentation API
https://votre-service.onrender.com/docs
```

## 🔧 Configuration Avancée

### Utiliser PostgreSQL au lieu de MySQL

Si vous utilisez PostgreSQL (gratuit sur Render) :

1. Modifiez `DB_CONNECTION=pgsql` dans les variables d'environnement
2. Utilisez les informations de connexion PostgreSQL fournies par Render

### Configurer un Domaine Personnalisé

1. Dans les paramètres du service, allez à **"Custom Domains"**
2. Ajoutez votre domaine
3. Configurez les DNS selon les instructions
4. Mettez à jour `APP_URL` avec votre nouveau domaine

### Configurer les CORS

Dans `backend-area/config/cors.php`, ajoutez votre frontend :
```php
'allowed_origins' => [
    'https://votre-frontend.onrender.com',
    'https://votre-domaine.com'
],
```

## 📊 Monitoring et Logs

### Voir les Logs
Dans Render Dashboard :
- Allez dans votre service
- Cliquez sur **"Logs"**
- Vous verrez les logs en temps réel

### Exécuter des Commandes
Dans l'onglet **"Shell"** de votre service :
```bash
# Vérifier les migrations
php artisan migrate:status

# Créer un utilisateur admin
php artisan tinker

# Vider le cache
php artisan cache:clear
```

## 🐛 Dépannage

### Le service ne démarre pas
- Vérifiez les logs dans Render Dashboard
- Assurez-vous que toutes les variables d'environnement sont définies
- Vérifiez que `APP_KEY` est bien configuré

### Erreur de connexion à la base de données
- Vérifiez les credentials de la base de données
- Assurez-vous que la base est dans la même région que le service
- Testez la connexion avec les informations fournies par Render

### Les migrations échouent
- Vérifiez que la base de données est accessible
- Exécutez manuellement : `php artisan migrate:fresh --force` dans le Shell

### Les OAuth ne fonctionnent pas
- Vérifiez que les URLs de callback correspondent exactement
- Assurez-vous que les credentials OAuth sont corrects
- Vérifiez que `APP_URL` est configuré correctement

## 💰 Limites du Plan Gratuit

- **Services Web**: Démarrage lent après inactivité (spin down)
- **Base de données**: 1 Go de stockage
- **Build time**: 90 jours d'historique
- **Trafic**: Illimité

## 🚀 Passer à un Plan Payant

Pour de meilleures performances :
- **Starter ($7/mois)** : Pas de spin down, plus de ressources
- **Standard ($25/mois)** : Scaling automatique, backups automatiques

## 📚 Ressources

- [Documentation Render](https://render.com/docs)
- [Guide Docker Render](https://render.com/docs/docker)
- [Documentation Laravel](https://laravel.com/docs)
- [Configuration OAuth](../docs/OAUTH_SETUP_GUIDE.md)

## ✅ Checklist Finale

- [ ] Base de données créée et accessible
- [ ] Variables d'environnement configurées
- [ ] `APP_KEY` générée et ajoutée
- [ ] OAuth credentials configurés
- [ ] Service déployé avec succès
- [ ] Migrations exécutées
- [ ] Endpoint `/api/health` répond
- [ ] Endpoint `/about.json` retourne les bonnes données
- [ ] Documentation API accessible
- [ ] CORS configuré pour le frontend
- [ ] Domaine personnalisé configuré (optionnel)

## 🎉 C'est Terminé !

Votre backend AREA est maintenant déployé sur Render et prêt à être utilisé !

URL du backend : `https://votre-service.onrender.com`
Documentation API : `https://votre-service.onrender.com/docs`
