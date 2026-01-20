# Configuration Render - Guide étape par étape

## ⚠️ Problème actuel
Votre application ne peut pas se connecter à la base de données car la base PostgreSQL n'existe pas encore sur Render.

**Erreur**: `could not translate host name "db" to address`

## 📋 Étapes de configuration

### 1️⃣ Créer la base de données PostgreSQL

1. Connectez-vous à [Render Dashboard](https://dashboard.render.com/)
2. Cliquez sur **"New +"** → **"PostgreSQL"**
3. Configurez :
   - **Name**: `area-postgres` (⚠️ doit correspondre au nom dans render.yaml)
   - **Database**: `area_database`
   - **User**: `area_user`
   - **Region**: **Frankfurt** (même région que votre web service)
   - **PostgreSQL Version**: 16
   - **Plan**: Free
4. Cliquez sur **"Create Database"**
5. ⏳ Attendez que la base soit créée (2-3 minutes)

### 2️⃣ Vérifier que le web service est lié à la base

1. Allez dans votre service web : **area-backend**
2. Cliquez sur **"Environment"**
3. Vérifiez que ces variables existent (elles sont automatiques si render.yaml est correct) :
   - `DB_HOST`
   - `DB_PORT`
   - `DB_DATABASE`
   - `DB_USERNAME`
   - `DB_PASSWORD`

### 3️⃣ Redéployer l'application

1. Dans votre service web, cliquez sur **"Manual Deploy"** → **"Deploy latest commit"**
2. ⏳ Attendez que le déploiement se termine

### 4️⃣ Exécuter les migrations

1. Dans votre service web, allez dans **"Shell"**
2. Exécutez :
   ```bash
   php artisan migrate --force
   ```
3. Vérifiez qu'il n'y a pas d'erreurs

### 5️⃣ Configurer les variables OAuth (optionnel mais recommandé)

Dans **Environment** de votre service web, ajoutez :

**Google OAuth:**
- `GOOGLE_CLIENT_ID`: Votre Client ID
- `GOOGLE_CLIENT_SECRET`: Votre Secret
- `GOOGLE_REDIRECT_URI`: `https://deploy-area.onrender.com/auth/google/callback`

**Microsoft OAuth:**
- `MICROSOFT_CLIENT_ID`
- `MICROSOFT_CLIENT_SECRET`
- `MICROSOFT_REDIRECT_URI`: `https://deploy-area.onrender.com/auth/microsoft/callback`

**Spotify OAuth:**
- `SPOTIFY_CLIENT_ID`
- `SPOTIFY_CLIENT_SECRET`
- `SPOTIFY_REDIRECT_URI`: `https://deploy-area.onrender.com/auth/spotify/callback`

**GitHub OAuth:**
- `GITHUB_CLIENT_ID`
- `GITHUB_CLIENT_SECRET`
- `GITHUB_REDIRECT_URI`: `https://deploy-area.onrender.com/auth/github/callback`

**Discord OAuth:**
- `DISCORD_CLIENT_ID`
- `DISCORD_CLIENT_SECRET`
- `DISCORD_REDIRECT_URI`: `https://deploy-area.onrender.com/auth/discord/callback`

### 6️⃣ Tester l'application

Visitez : https://deploy-area.onrender.com

✅ Vous ne devriez plus voir l'erreur de connexion à la base de données.

## 🔧 Commandes utiles dans le Shell Render

```bash
# Vérifier la connexion à la base de données
php artisan db:show

# Voir les tables
php artisan db:table --database=pgsql

# Vider le cache
php artisan cache:clear
php artisan config:clear
php artisan route:clear

# Voir les logs
tail -f storage/logs/laravel.log
```

## ❓ Problèmes courants

### La base de données n'est pas liée
**Solution**: Vérifiez que le nom de la base dans render.yaml (`area-postgres`) correspond exactement au nom de la base créée.

### Les migrations échouent
**Solution**: 
```bash
# Dans le shell
php artisan migrate:fresh --force
```

### L'application affiche toujours des erreurs
**Solution**:
```bash
# Vérifier les logs
php artisan log:clear
tail -f storage/logs/laravel.log
```

## 📞 Besoin d'aide ?

Si vous rencontrez des problèmes, vérifiez :
1. Les logs du service web dans Render
2. Les logs de la base de données
3. Les variables d'environnement dans le service web
