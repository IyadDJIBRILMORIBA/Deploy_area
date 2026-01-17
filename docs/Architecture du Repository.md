# Architecture du Repository G-DEV-500-COT-5-2-area-8

## Vue d'ensemble

Ce projet AREA (Action REAction) suit une architecture microservices conteneurisée avec trois composants principaux :
- **Backend** : API REST Laravel 12
- **Frontend Web** : Client Nuxt 4 (Vue.js)
- **Frontend Mobile** : Application Flutter

## Structure des dossiers

```
G-DEV-500-COT-5-2-area-8/
├── backend-area/          # API Laravel 12
│   ├── app/
│   │   ├── Http/
│   │   │   ├── Controllers/
│   │   │   │   ├── AuthController.php       # Authentification (email + Google OAuth)
│   │   │   │   └── CalendarController.php   # Intégration Google Calendar
│   │   │   └── Middleware/
│   │   │       └── Authenticate.php         # Middleware auth personnalisé (Sanctum)
│   │   └── Models/
│   │       └── User.php                     # Modèle utilisateur avec champs OAuth
│   ├── bootstrap/
│   │   └── app.php                          # Configuration routes API + web
│   ├── config/
│   │   ├── cors.php                         # Configuration CORS (origins, credentials)
│   │   ├── database.php                     # SQLite (dev) / MySQL (prod)
│   │   └── services.php                     # Config Google OAuth
│   ├── database/
│   │   ├── migrations/                      # Migrations (users, personal_access_tokens, etc.)
│   │   └── database.sqlite                  # Base SQLite locale
│   ├── routes/
│   │   ├── api.php                          # Routes API protégées (/register, /login, /user, /calendar-events)
│   │   └── web.php                          # Routes web (OAuth callback, CSRF cookie)
│   ├── storage/
│   │   └── logs/
│   │       └── laravel.log                  # Logs backend
│   ├── .env                                 # Variables d'environnement (clés OAuth, DB, Sanctum)
│   ├── composer.json                        # Dépendances PHP (Laravel 12, Sanctum, Socialite)
│   └── Dockerfile                           # Image Docker PHP 8.2-fpm + Laravel
│
├── frontend-area/         # Client Web Nuxt 4
│   ├── app/
│   │   ├── assets/css/
│   │   │   └── main.css                     # Tailwind CSS v4 (@import "tailwindcss")
│   │   ├── middleware/
│   │   │   └── auth.js                      # Protection routes (redirect si non auth)
│   │   ├── pages/
│   │   │   ├── index.vue                    # Page d'accueil
│   │   │   ├── login.vue                    # Connexion/Inscription (dual mode)
│   │   │   └── dashboard.vue                # Dashboard avec événements Google Calendar
│   │   └── stores/
│   │       └── auth.ts                      # Pinia store (login, register, token, CSRF)
│   ├── nuxt.config.ts                       # Config Nuxt (modules, Tailwind, apiBase)
│   ├── package.json                         # Dépendances Node (Nuxt 4, Pinia, Tailwind)
│   └── Dockerfile                           # Image Docker Node 22-alpine + build Nuxt
│
├── flutter_application/   # Client Mobile Flutter
│   ├── lib/
│   │   ├── main.dart                        # Entry point
│   │   ├── screens/                         # Écrans UI
│   │   ├── services/                        # Services (API, Auth)
│   │   └── widgets/                         # Composants réutilisables
│   ├── pubspec.yaml                         # Dépendances Flutter (http, google_sign_in, etc.)
│   └── Dockerfile                           # Build APK depuis image Flutter stable
│
├── docs/                  # Documentation projet
│   ├── Planification du Projet.md
│   ├── Organisation de l'Équipe et Processus de Travail.md
│   └── Architecture du Repository.md        # Ce fichier
│
├── docker-compose.yml     # Orchestration des services (db, server, client_web, client_mobile)
└── README.md              # Documentation générale
```

## Architecture des composants

### 1. Backend (Laravel 12)

**Rôle** : API REST centralisée fournissant :
- Authentification multi-méthode (email/password + Google OAuth)
- Gestion des tokens Sanctum (Bearer tokens pour API)
- Intégration Google Calendar API
- Base de données utilisateurs

**Technologies** :
- Framework : Laravel 12 (PHP 8.2)
- Authentification : Laravel Sanctum (tokens API stateless)
- OAuth : Laravel Socialite (Google)
- Base de données : SQLite (dev), MySQL/MariaDB (prod)
- Serveur web : PHP built-in server (dev), php-fpm (prod)

**Endpoints principaux** :
- `POST /api/register` : Inscription (email + password + confirmation)
- `POST /api/login` : Connexion (retourne access_token + user)
- `GET /api/user` : Récupération utilisateur connecté (Bearer token)
- `POST /api/logout` : Déconnexion (supprime token)
- `GET /sanctum/csrf-cookie` : Cookie CSRF pour authentification stateful
- `GET /auth/google/redirect` : Démarrage OAuth Google
- `GET /auth/google/callback` : Callback OAuth (crée/connecte user, redirige avec token)
- `GET /api/calendar-events` : Liste 5 prochains événements Google Calendar (protégé)

**Configuration Docker** :
- Image : `php:8.2-fpm`
- Port : `8000` (interne) → `8080` (exposé)
- Variables d'environnement : DB_CONNECTION, DB_HOST, APP_URL, Google credentials
- Dépendance : MariaDB (`db` service avec healthcheck)

### 2. Frontend Web (Nuxt 4)

**Rôle** : Interface web responsive pour :
- Inscription/Connexion utilisateurs
- Dashboard affichant événements Google Calendar
- Gestion session (token dans cookie `auth_token`)

**Technologies** :
- Framework : Nuxt 4 (Vue 3, SSR/SPA hybrid)
- State management : Pinia
- Styling : Tailwind CSS v4 (via @tailwindcss/vite plugin)
- HTTP : ofetch ($fetch)
- Routing : Pages auto-routing + middleware auth

**Pages clés** :
- `/` : Page d'accueil (publique)
- `/login` : Formulaire dual-mode (connexion/inscription + lien Google OAuth)
- `/dashboard` : Tableau de bord protégé (affiche événements, bouton déconnexion)

**Store Auth (Pinia)** :
- `register(data)` : Fetch CSRF cookie → POST /api/register → stocke token
- `login(credentials)` : Fetch CSRF cookie → POST /api/login → stocke token
- `checkAuth()` : Vérifie si utilisateur authentifié (Bearer token ou session)
- `fetchCalendarEvents()` : GET /api/calendar-events avec Authorization header
- `logout()` : POST /api/logout + suppression token + redirect /login

**Configuration Docker** :
- Image : `node:22-alpine` (Node >=20 requis pour Nuxt 4)
- Port : `3000` (interne) → `8081` (exposé)
- Variables d'environnement : NUXT_PUBLIC_API_BASE, API_INTERNAL_URL
- Volume partagé : `/app/public/mobile` (reçoit APK Flutter pour téléchargement)

### 3. Frontend Mobile (Flutter)

**Rôle** : Application mobile Android (APK) avec :
- Authentification (Google OAuth + email)
- Affichage événements Google Calendar
- Interface native Material Design

**Technologies** :
- Framework : Flutter (SDK >=3.0.0 <4.0.0)
- Dépendances : google_sign_in, http, flutter_secure_storage, shared_preferences

**Configuration Docker** :
- Image : `ghcr.io/cirruslabs/flutter:stable`
- Build : APK release (`flutter build apk --release`)
- Volume partagé : `/app/output` (stocke `client.apk`)
- Conteneur "one-shot" : compile APK puis s'arrête

## Flux d'authentification

### Inscription/Connexion classique (email/password)

```
Frontend                    Backend
   |                          |
   |--1. GET /sanctum/csrf-cookie-->| (retourne XSRF-TOKEN + session cookie)
   |<----200 + Set-Cookie---------|
   |                          |
   |--2. POST /api/register -------->| (valide, crée user, génère token Sanctum)
   |    {name, email, password,  |
   |     password_confirmation}  |
   |<----201 {access_token, user}---|
   |                          |
   |--3. Store token in cookie---|
   |    (auth_token)          |
   |                          |
   |--4. GET /api/user ------------>| (Authorization: Bearer {token})
   |<----200 {user data}----------|
```

### Authentification Google OAuth

```
Frontend                    Backend                     Google
   |                          |                          |
   |--1. Click "Se connecter avec Google"------------>|
   |                          |                          |
   |--2. GET /auth/google/redirect--->|                  |
   |                          |--3. Redirect OAuth------>|
   |                          |    (scopes: calendar)    |
   |                          |                          |
   |<------4. User consent screen (Google)-------------|
   |                          |                          |
   |                          |<----5. Callback code-----|
   |                          |    (code=...)            |
   |                          |                          |
   |                          |--6. Exchange token------>|
   |                          |<----access + refresh-----|
   |                          |                          |
   |                          |--7. firstOrCreate user---|
   |                          |    (save google_token)   |
   |                          |                          |
   |<----8. Redirect /dashboard?token=...-------------|
   |    (Sanctum token créé)  |                          |
   |                          |                          |
   |--9. Store token + GET /api/user----------------->|
   |<----200 {user data}-------------------------------|
```

## Orchestration Docker

### Services (docker-compose.yml)

```yaml
Services:
  db:             # MariaDB 10.11 (MYSQL_DATABASE=area_db)
  server:         # Laravel (port 8080, dépend de db)
  client_mobile:  # Flutter builder (compile APK, volume partagé)
  client_web:     # Nuxt (port 8081, dépend de server, monte APK)

Volumes:
  db_data:        # Persistance MySQL
  apk_volume:     # Partage APK entre mobile builder et frontend

Network:
  area_network:   # Bridge interne pour communication inter-services
```

### Commandes Docker

**Build et démarrage** :
```bash
docker-compose up --build -d
```

**Vérifier les logs** :
```bash
docker-compose logs -f server      # Backend Laravel
docker-compose logs -f client_web  # Frontend Nuxt
docker-compose logs client_mobile  # Build Flutter (one-shot)
```

**Arrêt et nettoyage** :
```bash
docker-compose down
docker-compose down -v  # Supprime aussi les volumes (perte DB)
```

**Rebuild d'un seul service** :
```bash
docker-compose up --build -d server
```

## Configuration CORS & Sanctum

### CORS (backend-area/config/cors.php)

```php
'paths' => ['api/*', 'sanctum/csrf-cookie', 'auth/*'],
'allowed_origins' => [
    env('FRONTEND_URL', 'http://localhost:3000'),
    'http://127.0.0.1:3000'
],
'supports_credentials' => true,  // Requis pour cookies CSRF
```

### Sanctum (backend-area/.env)

```env
SANCTUM_STATEFUL_DOMAINS=localhost:3000,127.0.0.1:3000
SESSION_DOMAIN=localhost
SESSION_DRIVER=cookie
```

## Base de données

### Développement (SQLite)

```env
DB_CONNECTION=sqlite
# Pas besoin de DB_HOST/DB_PORT/DB_USERNAME
```

Fichier : `backend-area/database/database.sqlite`

### Production (MySQL via Docker)

```env
DB_CONNECTION=mysql
DB_HOST=db  # Nom du service Docker
DB_PORT=3306
DB_DATABASE=area_db
DB_USERNAME=user
DB_PASSWORD=password
```

### Migrations importantes

1. **create_users_table** : Utilisateurs (email, name, password)
2. **add_google_fields_to_users_table** : Champs OAuth (google_id, google_token, google_refresh_token)
3. **create_personal_access_tokens_table** : Tokens Sanctum (pour auth API)
4. **create_cache_table** : Cache Laravel
5. **create_jobs_table** : Jobs asynchrones (queue)

## Variables d'environnement clés

### Backend (.env)

```env
APP_URL=http://localhost:8080
FRONTEND_URL=http://localhost:3000

# Google OAuth
GOOGLE_CLIENT_ID=...
GOOGLE_CLIENT_SECRET=...
GOOGLE_REDIRECT_URI=http://localhost:8080/auth/google/callback

# Sanctum
SANCTUM_STATEFUL_DOMAINS=localhost:3000,127.0.0.1:3000
SESSION_DOMAIN=localhost

# Base de données (prod)
DB_CONNECTION=mysql
DB_HOST=db
DB_DATABASE=area_db
DB_USERNAME=user
DB_PASSWORD=password
```

### Frontend (.env ou nuxt.config.ts)

```env
NUXT_PUBLIC_API_BASE=http://localhost:8080
```

## Ports exposés

| Service       | Port interne | Port hôte | Description                |
|---------------|--------------|-----------|----------------------------|
| Backend       | 8000         | 8080      | API Laravel                |
| Frontend Web  | 3000         | 8081      | Client Nuxt                |
| Base de données| 3306        | (interne) | MariaDB (pas exposé)       |

## Dépendances principales

### Backend (composer.json)

```json
{
  "laravel/framework": "^12.0",
  "laravel/sanctum": "^4.2",
  "laravel/socialite": "^5.23",
  "google/apiclient": "^2.18"
}
```

### Frontend (package.json)

```json
{
  "@nuxt/ui": "^3.11.0",
  "@pinia/nuxt": "^0.9.0",
  "tailwindcss": "^4.1.12",
  "@tailwindcss/vite": "^4.1.12"
}
```

### Mobile (pubspec.yaml)

```yaml
dependencies:
  flutter_secure_storage: ^9.0.0
  google_sign_in: ^6.1.5
  http: ^1.1.0
  shared_preferences: ^2.2.2
```

## Sécurité

- **Tokens Sanctum** : Bearer tokens stockés en cookie HttpOnly (`auth_token`)
- **CSRF Protection** : Cookie `XSRF-TOKEN` pour requêtes POST/PUT/DELETE
- **Password Hashing** : Bcrypt (Laravel Hash facade)
- **Password Confirmation** : Validé côté backend (`confirmed` rule)
- **OAuth Scopes** : Limité à `calendar.readonly` (lecture seule)
- **HTTPS** : Requis en production (Let's Encrypt recommandé)
- **Secrets** : Clés OAuth et APP_KEY Laravel ne doivent JAMAIS être versionnées

## Tests

### Backend
```bash
php artisan test
```

### Frontend
```bash
npm run test
```

### Mobile
```bash
flutter test
```

## Déploiement

### Prérequis production
1. Serveur avec Docker & Docker Compose
2. Domaine avec certificat SSL (ex: Caddy, Nginx + Let's Encrypt)
3. Variables d'environnement sécurisées (.env non versionné)
4. Base de données MySQL externe (recommandé) ou conteneur persistant

### Checklist déploiement
- [ ] `APP_ENV=production` + `APP_DEBUG=false` dans backend .env
- [ ] `php artisan key:generate` exécuté
- [ ] Migrations exécutées (`php artisan migrate --force`)
- [ ] CORS configuré pour domaine production
- [ ] SANCTUM_STATEFUL_DOMAINS aligné avec domaine front
- [ ] Certificat SSL actif (HTTPS)
- [ ] Volumes Docker persistants (db_data sauvegardé)
- [ ] Logs rotatifs activés
- [ ] APK Flutter signé avec keystore production

## Ressources

- [Documentation Laravel 12](https://laravel.com/docs/12.x)
- [Documentation Nuxt 4](https://nuxt.com/)
- [Documentation Flutter](https://flutter.dev/)
- [Laravel Sanctum](https://laravel.com/docs/12.x/sanctum)
- [Tailwind CSS v4](https://tailwindcss.com/)
- [Google OAuth2 Docs](https://developers.google.com/identity/protocols/oauth2)

---

**Dernière mise à jour** : 27 novembre 2025
**Équipe** : Retys (Backend Lead), florian (Frontend Web), [autres membres]
**Version** : 1.0.0
