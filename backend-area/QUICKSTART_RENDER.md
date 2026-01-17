# 🚀 Quick Start - Déployer sur Render

## ⚡ Déploiement Rapide (5 minutes)

### 1️⃣ Préparer le Code

```bash
cd backend-area

# Valider la configuration
./validate-deployment.sh

# Commit et push
git add .
git commit -m "Add Render deployment configuration"
git push origin masters
```

### 2️⃣ Créer la Base de Données

**Option A : PostgreSQL sur Render (Gratuit - Recommandé)**
1. Aller sur https://dashboard.render.com
2. **New +** → **PostgreSQL**
3. Configuration :
   - Name: `area-db`
   - Database: `area_database`
   - User: `area_user`
   - Region: Frankfurt
   - Plan: **Free**
4. **Create Database**
5. 📋 Copier les informations de connexion (Internal Database URL)

**Option B : MySQL externe**
- Utiliser [PlanetScale](https://planetscale.com) (gratuit)
- Ou [Railway.io](https://railway.app) (gratuit)

### 3️⃣ Déployer le Backend

1. **New +** → **Web Service**
2. Connecter votre dépôt GitHub
3. Configuration :
   ```
   Name: area-backend
   Region: Frankfurt
   Root Directory: backend-area
   Environment: Docker
   Dockerfile Path: Dockerfile.production
   Plan: Free
   ```

### 4️⃣ Configurer les Variables d'Environnement

Copier depuis `.env.render.example` et remplacer les valeurs :

**Variables Obligatoires :**
```bash
APP_NAME=AREA
APP_ENV=production
APP_DEBUG=false
APP_URL=https://votre-service.onrender.com
APP_KEY=base64:XXXXX  # Générer avec: php artisan key:generate --show

# Database (PostgreSQL)
DB_CONNECTION=pgsql
DB_HOST=dpg-xxxxx.frankfurt-postgres.render.com
DB_PORT=5432
DB_DATABASE=area_database
DB_USERNAME=area_user
DB_PASSWORD=xxxxx

# Laravel
SESSION_DRIVER=database
CACHE_STORE=database
QUEUE_CONNECTION=database
LOG_LEVEL=error
```

**OAuth (à configurer selon vos services) :**
```bash
GOOGLE_CLIENT_ID=xxxxx
GOOGLE_CLIENT_SECRET=xxxxx
GOOGLE_REDIRECT_URI=https://votre-service.onrender.com/api/auth/google/callback

# Répéter pour MICROSOFT, SPOTIFY, GITHUB, DISCORD...
```

### 5️⃣ Déployer

1. Cliquer **Create Web Service**
2. Attendre le build (5-10 minutes)
3. Vérifier le déploiement :
   ```bash
   curl https://votre-service.onrender.com/api/health
   curl https://votre-service.onrender.com/about.json
   ```

---

## 🔑 Générer APP_KEY

**Méthode 1 - Localement :**
```bash
cd backend-area
php artisan key:generate --show
```

**Méthode 2 - Avec Docker :**
```bash
docker run --rm -v $PWD:/app -w /app composer/composer:latest \
  bash -c "php artisan key:generate --show"
```

---

## 📋 Checklist Post-Déploiement

- [ ] Service déployé avec succès
- [ ] `/api/health` retourne 200
- [ ] `/about.json` retourne les données correctes
- [ ] Base de données connectée (vérifier les logs)
- [ ] Migrations exécutées
- [ ] OAuth configuré pour chaque service
- [ ] CORS configuré pour le frontend

---

## 🐛 Dépannage Rapide

### ❌ Erreur : "Please provide a valid APP_KEY"
```bash
# Générer une nouvelle clé
php artisan key:generate --show

# Ajouter dans Render : APP_KEY=base64:xxxxx
```

### ❌ Erreur : "Connection refused" (Database)
- Vérifier que la base de données est dans la même région
- Vérifier les credentials (Host, Port, Database, Username, Password)
- Utiliser l'**Internal Database URL** fournie par Render

### ❌ Build échoue
```bash
# Vérifier les logs dans Render Dashboard
# Vérifier que composer.lock existe
cd backend-area
composer update --lock
git add composer.lock
git commit -m "Update composer.lock"
git push
```

### ❌ Migrations échouent
Dans le Shell Render :
```bash
php artisan migrate:fresh --force
```

---

## 📚 Documentation Complète

Pour plus de détails, voir :
- [`RENDER_DEPLOYMENT.md`](./RENDER_DEPLOYMENT.md) - Guide complet
- [`.env.render.example`](./.env.render.example) - Configuration complète

---

## 💡 Astuces

### Accéder au Shell
Dans Render Dashboard → Votre service → **Shell** tab
```bash
php artisan migrate:status
php artisan tinker
tail -f storage/logs/laravel.log
```

### Voir les Logs en Temps Réel
Dans Render Dashboard → Votre service → **Logs** tab

### Redéployer
```bash
# Option 1: Push automatique
git push origin masters

# Option 2: Manuel dans Render Dashboard
# Votre service → Manual Deploy → Deploy latest commit
```

---

## 🎯 URL Importantes

Après déploiement :
- **API Health**: `https://votre-service.onrender.com/api/health`
- **About.json**: `https://votre-service.onrender.com/about.json`
- **API Docs**: `https://votre-service.onrender.com/docs`

---

## ✅ Prêt pour la Production

Votre backend AREA est maintenant déployé sur Render ! 🎉

URL du backend : `https://votre-service.onrender.com`

**Note** : Le plan gratuit a un "spin down" après 15 min d'inactivité.
Pour éviter cela, upgrade vers le plan Starter ($7/mois).
