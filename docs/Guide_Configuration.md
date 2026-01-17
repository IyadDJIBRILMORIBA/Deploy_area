# Guide de Configuration du Projet AREA

## Table des Matières
1. [Configuration Google OAuth](#configuration-google-oauth)
2. [Variables d'Environnement](#variables-denvironnement)
3. [Configuration de la Base de Données](#configuration-de-la-base-de-données)
4. [Activation des APIs Google Cloud](#activation-des-apis-google-cloud)
5. [Test de la Configuration](#test-de-la-configuration)
6. [Dépannage](#dépannage)

---

## Configuration Google OAuth

### Étape 1 : Créer un Projet Google Cloud

1. Allez sur [Google Cloud Console](https://console.cloud.google.com/)
2. Cliquez sur **Créer un projet**
3. Nommez le projet (ex: "AREA Platform")
4. Cliquez sur **Créer**

### Étape 2 : Configurer l'Écran de Consentement OAuth

1. Dans le menu latéral, allez à **APIs et services** → **Écran de consentement OAuth**
2. Sélectionnez **Externe** comme type d'utilisateur
3. Cliquez sur **Créer**
4. Remplissez les informations :
   - **Nom de l'application** : "AREA Platform"
   - **Email du support** : votre email
   - **Email de contact** : votre email
5. Cliquez sur **Enregistrer et continuer**
6. Sur la page des **Étendues**, ajoutez les scopes suivants :
   - `userinfo.email`
   - `userinfo.profile`
   - `gmail.readonly`
   - `gmail.send`
   - `calendar.readonly`
7. Cliquez sur **Enregistrer et continuer**
8. Ajoutez votre email comme utilisateur test
9. Cliquez sur **Enregistrer et terminer**

### Étape 3 : Créer les Identifiants OAuth 2.0

1. Allez à **APIs et services** → **Identifiants**
2. Cliquez sur **Créer des identifiants** → **ID client OAuth**
3. Sélectionnez **Application Web**
4. Remplissez les informations :
   - **Nom** : "AREA Web App"
   
5. Sous **URI de redirection autorisés**, ajoutez :
   ```
   http://localhost:8080/auth/google/callback
   http://localhost:8080/api/services/google/callback
   http://localhost:8081/callback
   ```
   
   *(Remplacez localhost par votre domaine en production)*

6. Cliquez sur **Créer**
7. Copiez votre :
   - **Client ID**
   - **Client Secret**

### Étape 4 : Configurer les Variables d'Environnement

Créez ou modifiez le fichier `.env` dans `backend-area/` :

```bash
# Google OAuth
GOOGLE_CLIENT_ID=YOUR_CLIENT_ID_HERE
GOOGLE_CLIENT_SECRET=YOUR_CLIENT_SECRET_HERE

# Par exemple :
# GOOGLE_CLIENT_ID=521273872959-t5uavhihc3231714hksp56koj704tm6b.apps.googleusercontent.com
# GOOGLE_CLIENT_SECRET=GOCSPX-xxxxxxxxxxxxxxxxxxx
```

---

## 🌍 Variables d'Environnement

### Fichier `.env` Complet - Backend

```bash
# ===== Application =====
APP_NAME=AREA
APP_ENV=local
APP_KEY=base64:XXXXXXXXXXXXXXXXXXXXXXXXXXXXX
APP_DEBUG=true
APP_URL=http://localhost:8080

# ===== Database =====
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=area_db
DB_USERNAME=root
DB_PASSWORD=

# ===== Mail =====
MAIL_MAILER=log
MAIL_HOST=smtp.mailtrap.io
MAIL_PORT=2525
MAIL_USERNAME=
MAIL_PASSWORD=

# ===== Google OAuth =====
GOOGLE_CLIENT_ID=521273872959-t5uavhihc3231714hksp56koj704tm6b.apps.googleusercontent.com
GOOGLE_CLIENT_SECRET=GOCSPX-xxxxxxxxxxxxxxxx
GOOGLE_CALLBACK_URL=http://localhost:8080/auth/google/callback
GOOGLE_SERVICE_CALLBACK_URL=http://localhost:8080/api/services/google/callback

# ===== Autres =====
SANCTUM_STATEFUL_DOMAINS=localhost:8081
SESSION_DOMAIN=localhost
CORS_ALLOWED_ORIGINS=http://localhost:8081
```

### Fichier `nuxt.config.ts` - Frontend

```typescript
export default defineNuxtConfig({
  // Assurez-vous que le port du backend est correct
  runtimeConfig: {
    public: {
      apiBase: 'http://localhost:8080'
    }
  }
})
```

---

## 🗄️ Configuration de la Base de Données

### Créer la Base de Données

```bash
cd backend-area

# Via MySQL CLI
mysql -u root -e "CREATE DATABASE area_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"

# Via Laravel
php artisan migrate
```

### Structure Requise

```sql
-- Users table
CREATE TABLE users (
  id INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(255),
  email VARCHAR(255) UNIQUE,
  password VARCHAR(255),
  google_token LONGTEXT,
  google_refresh_token LONGTEXT,
  created_at TIMESTAMP,
  updated_at TIMESTAMP
);

-- Services table
CREATE TABLE services (
  id INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(255),
  slug VARCHAR(255) UNIQUE,
  icon VARCHAR(255),
  created_at TIMESTAMP,
  updated_at TIMESTAMP
);

-- User Services table (pour OAuth)
CREATE TABLE user_services (
  id INT PRIMARY KEY AUTO_INCREMENT,
  user_id INT,
  service_id INT,
  access_token LONGTEXT,
  refresh_token LONGTEXT,
  created_at TIMESTAMP,
  updated_at TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (service_id) REFERENCES services(id)
);

-- Areas table (Automations)
CREATE TABLE areas (
  id INT PRIMARY KEY AUTO_INCREMENT,
  user_id INT,
  name VARCHAR(255),
  
  trigger_service VARCHAR(50),
  trigger_action VARCHAR(50),
  trigger_params JSON,
  
  action_service VARCHAR(50),
  action_reaction VARCHAR(50),
  action_params JSON,
  
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP,
  updated_at TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id)
);

-- Area Logs table
CREATE TABLE area_logs (
  id INT PRIMARY KEY AUTO_INCREMENT,
  area_id INT,
  status VARCHAR(50),
  message TEXT,
  created_at TIMESTAMP,
  FOREIGN KEY (area_id) REFERENCES areas(id)
);
```

---

## 🚀 Activation des APIs Google Cloud

### 1. Gmail API

1. Allez à **APIs et services** → **Bibliothèque**
2. Recherchez **Gmail API**
3. Cliquez sur **Activer**
4. Attendez 1-2 minutes pour que l'API soit activée

### 2. Calendar API (Optionnel)

1. Recherchez **Google Calendar API**
2. Cliquez sur **Activer**

### 3. Google Workspace (Optionnel)

Pour utiliser des comptes Google Workspace, consultez la section "[Utiliser Google Workspace](#utiliser-google-workspace)"

---

## Test de la Configuration

### Test 1 : Vérifier la Connexion Google OAuth

```bash
# 1. Allez sur le frontend
open http://localhost:8081/login

# 2. Cliquez sur "Connexion avec Google"

# 3. Autorisez l'accès aux scopes

# 4. Vérifiez que vous êtes redirigé au dashboard
```

### Test 2 : Connecter un Service Google

```bash
# 1. Allez sur http://localhost:8081/services

# 2. Cliquez sur "Connecter" pour Google

# 3. Autorisez TOUTES les permissions :
#    - Afficher vos e-mails
#    - Envoyer des e-mails
#    - Consulter les agendas
#    - Informations personnelles

# 4. Vérifiez que le statut passe à "Déconnecté" (bouton doit changer)
```

### Test 3 : Créer et Exécuter une AREA

```bash
# 1. Allez sur http://localhost:8081/areas/create

# 2. Step 1 : Sélectionnez un trigger
#    Trigger: Timer / Every Minute

# 3. Step 2 : Configurez les paramètres du trigger
#    (Aucun paramètre pour Every Minute)

# 4. Step 3 : Sélectionnez une action
#    Action: Gmail / Send Email

# 5. Step 4 : Configurez l'action
#    To: votre@email.com
#    Subject: Test AREA
#    Body: Ceci est un test

# 6. Cliquez sur "Créer AREA"

# 7. Testez manuellement
php artisan area:execute

# 8. Attendez 1 minute que le cron s'exécute automatiquement
```

### Test 4 : Vérifier les Logs

```bash
# Logs Laravel
tail -f backend-area/storage/logs/laravel.log | grep -i "area\|gmail\|timer"

# Logs Cron
tail -f backend-area/storage/logs/area-cron.log
```

---

## Dépannage

### Problème : "Accès bloqué : erreur d'autorisation Missing required parameter: client_id"

**Cause** : Les variables d'environnement ne sont pas correctement configurées.

**Solution** :
```bash
# 1. Vérifiez que le fichier .env existe
cat backend-area/.env | grep GOOGLE

# 2. Vérifiez les valeurs dans Google Cloud Console
# https://console.cloud.google.com/apis/credentials

# 3. Redémarrez le serveur Laravel
# (Arrêtez php artisan serve et relancez)
```

### Problème : "The redirect URI does not match the one registered"

**Cause** : L'URI de redirection n'est pas configurée dans Google Cloud Console.

**Solution** :
```bash
# 1. Allez à Google Cloud Console → Identifiants
# 2. Cliquez sur votre ID client OAuth
# 3. Sous "URI de redirection autorisés", assurez-vous que ces URIs sont présentes :
#    - http://localhost:8080/auth/google/callback
#    - http://localhost:8080/api/services/google/callback
# 4. Cliquez sur "Enregistrer"
```

### Problème : "L'utilisateur n'a pas connecté son compte Google"

**Cause** : Le token Google n'a pas été sauvegardé correctement.

**Solution** :
```bash
# 1. Déconnectez le service Google (http://localhost:8081/services)
# 2. Reconnectez le service Google
# 3. Assurez-vous d'autoriser TOUS les scopes
# 4. Vérifiez dans la base de données :
#    mysql> SELECT * FROM user_services WHERE user_id = 2;
#    La colonne access_token doit avoir une valeur
```

### Problème : "Aucun nouveau message Gmail pour user X"

**Cause** : Pas d'emails non-lus correspondant aux critères du trigger.

**Solution** :
```bash
# 1. Vérifiez que vous avez des emails non-lus dans Gmail
# 2. Vérifiez les critères du trigger :
#    - From : l'expéditeur correct ?
#    - Subject contains : le mot-clé correct ?
# 3. Testez avec un trigger sans critères (depuis n'importe qui)
# 4. Vérifiez les logs :
#    tail -f backend-area/storage/logs/laravel.log | grep GoogleService
```

### Problème : "Email envoyé avec succès" mais l'email ne reçoit rien

**Cause** : Possibles problèmes Gmail API.

**Solution** :
```bash
# 1. Vérifiez que gmail.send scope est autorisé
#    Allez sur https://myaccount.google.com/permissions
#    Cherchez "AREA" et vérifiez les scopes

# 2. Vérifiez les logs d'erreur :
#    grep -i "error" backend-area/storage/logs/laravel.log

# 3. Réautorisez l'application :
#    - Allez à https://myaccount.google.com/permissions
#    - Supprimez "AREA"
#    - Reconnectez le service
```

### Problème : Le cron ne s'exécute pas

Voir la section [Dépannage Cron](#dépannage-cron) dans `CRON_AUTOMATION.md`

---

## Ressources Utiles

- [Google Cloud Console](https://console.cloud.google.com/)
- [Google OAuth 2.0 Documentation](https://developers.google.com/identity/protocols/oauth2)
- [Gmail API Documentation](https://developers.google.com/gmail/api/guides)
- [Laravel Google Auth Package](https://github.com/SocialiteProviders/Google)

---

## Meilleures Pratiques

### 1. Gérer les Tokens Google
```php
// Ne jamais logguer les tokens complets
Log::info("Token refresh réussi pour user " . $user->id);
// Mauvais :
Log::info("Token: " . $token); 

// Bon :
Log::info("Token refresh réussi");
```

### 2. Tester les AREAs
```bash
# Avant de créer une AREA, testez manuellement la connexion :
php artisan tinker
> $user = User::find(2);
> OAuthHelper::getValidGoogleClient($user);
// Si pas d'erreur, la connexion est OK
```

### 3. Sauvegarder les Logs
```bash
# Archivez régulièrement les logs
tar -czf logs-backup-$(date +%Y%m%d).tar.gz backend-area/storage/logs/
```

---

**Dernière mise à jour** : 7 décembre 2025
**Version** : 1.0.0
**Statut** : Production Ready
