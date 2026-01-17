# Documentation Complète du Projet AREA

## Guide Rapide

### Pour Les Pressés (TL;DR)

```bash
# 1. Configuration Google
# - Créez un projet Google Cloud : https://console.cloud.google.com
# - Activez Gmail API
# - Créez un ID client OAuth (Application Web)
# - Ajoutez les URIs : http://localhost:8080/auth/google/callback
# - Copiez Client ID et Secret dans backend-area/.env

# 2. Démarrer les serveurs
cd backend-area && php artisan serve --port=8080 &
cd frontend-area && npm run dev &

# 3. Créer une AREA
# http://localhost:8081/areas/create → Timer + Send Email

# 4. C'est automatique !
# Le cron s'exécute chaque minute
tail -f backend-area/storage/logs/area-cron.log
```

---

## Documentation Disponible

### 1. **CHANGELOG.md**
**Quoi ?** - Tous les changements apportés au projet
- Vue d'ensemble du projet
- Modifications backend détaillées
- Modifications frontend détaillées
- Architecture finale
- Changelog détaillé des 6 phases

**À lire si vous :** 
- Voulez comprendre les changements
- Participez au développement
- Faites une revue de code

### 2. **SETUP_CONFIGURATION.md**
**Comment ?** - Configuration détaillée de tout
- Configuration Google OAuth (étape par étape)
- Variables d'environnement
- Base de données
- Activation des APIs Google Cloud
- Tests de configuration
- Dépannage

**À lire si vous :**
- Mettez en place le projet pour la première fois
- Rencontrez des erreurs de configuration
- Vous connectez Google pour la première fois

### 3. **CRON_AUTOMATION.md**
**Bonus** - Automatisation avec Cron
- Vue d'ensemble du cron
- Installation et configuration
- Vérification et tests
- Monitoring
- Dépannage du cron
- Configuration avancée (Systemd)

**À lire si vous :**
- Voulez automatiser les exécutions
- Explorez les options de cron
- Mettez en place le monitoring

---

## 🚀 Pour Démarrer (En 5 Étapes)

### Étape 1 : Configuration Google (30 min)
```
Allez dans : SETUP_CONFIGURATION.md
Section : Configuration Google OAuth
```

### Étape 2 : Configurer les Variables d'Environnement (5 min)
```
Allez dans : SETUP_CONFIGURATION.md
Section : Variables d'Environnement
```

### Étape 3 : Démarrer les Serveurs (5 min)
```bash
# Terminal 1 - Backend
cd /path/to/backend-area
php artisan serve --port=8080

# Terminal 2 - Frontend
cd /path/to/frontend-area
npm run dev

# Terminal 3 - Monitoring des Logs
tail -f /path/to/backend-area/storage/logs/laravel.log
```

### Étape 4 : Tester la Configuration (10 min)
```
Allez dans : SETUP_CONFIGURATION.md
Section : Test de la Configuration
```

### Étape 5 : Configurer le Cron (10 min)
```
Allez dans : CRON_AUTOMATION.md
Section : Installation du Cron
```

---

## 🎓 Architecture du Projet

### Backend Stack
```
Laravel 11
├── HTTP Controllers
│   ├── AuthController (Authentification)
│   ├── ServiceController (Google OAuth)
│   ├── AreaController (AREA CRUD)
│   └── UserController (Profil utilisateur)
├── Services
│   ├── GoogleService (Triggers & Actions Gmail)
│   ├── TimerService (Triggers Timer)
│   └── OAuthHelper (Gestion des tokens)
├── Console Commands
│   └── ExecuteAreas (Moteur d'exécution)
└── Models
    ├── User
    ├── Area
    ├── UserService (Tokens OAuth)
    └── AreaLog (Historique)
```

### Frontend Stack
```
Nuxt 3 + Vue 3
├── Pages
│   ├── login.vue (Authentification)
│   ├── dashboard.vue (Vue d'ensemble)
│   ├── areas/ 
│   │   ├── index.vue (Liste)
│   │   ├── create.vue (Création - 4 steps)
│   │   └── [id].vue (Détails)
│   └── services.vue (Connexion des services)
├── Stores (Pinia)
│   ├── auth.ts (Gestion de l'utilisateur)
│   ├── areas.ts (Gestion des AREAs)
│   └── services.ts (Gestion des services)
├── Components
│   └── Composants réutilisables
└── Composables
    ├── useApi.ts (Appels API)
    ├── useDashboard.ts (Stats)
    └── useAbout.ts (Infos)
```

### Flux de Données
```
┌─────────────────────────────────────────┐
│         Frontend (Nuxt 3)               │
│  http://localhost:8081                  │
│                                         │
│  User crée AREA → Appel API            │
└────────────────────┬────────────────────┘
                     │ HTTP POST
                     ▼
┌─────────────────────────────────────────┐
│         Backend (Laravel 11)            │
│  http://localhost:8080                  │
│                                         │
│  POST /api/areas                        │
│  ├─ Validation                          │
│  └─ Sauvegarde en DB                    │
└────────────────────┬────────────────────┘
                     │
                     ▼
        ┌────────────────────────┐
        │   Base de Données      │
        │   (MySQL - area_db)    │
        └────────────┬───────────┘
                     │
                     ▼
        ┌────────────────────────────────┐
        │   Cron Job (Chaque minute)     │
        │   * * * * * run-area-execute.sh│
        └────────────┬───────────────────┘
                     │
                     ▼
        ┌────────────────────────────────┐
        │   php artisan area:execute     │
        │                                │
        │   ExecuteAreas.php             │
        │   ├─ Récupère AREAs           │
        │   ├─ checkTrigger()           │
        │   └─ executeReaction()        │
        └────────────┬───────────────────┘
                     │
      ┌──────────────┼──────────────┐
      │              │              │
      ▼              ▼              ▼
┌──────────────┐ ┌──────────────┐ ┌──────────────┐
│ GoogleService│ │TimerService  │ │ Other Soon   │
│              │ │              │ │              │
│ Gmail API    │ │ System Clock │ │ Slack, etc   │
│ ├─check      │ │ ├─check      │ │              │
│ └─execute    │ │ └─execute    │ │              │
└──────────────┘ └──────────────┘ └──────────────┘
      │              │              │
      └──────────────┼──────────────┘
                     │
                     ▼
        ┌────────────────────────────┐
        │   Google Gmail API         │
        │   - Récupère emails        │
        │   - Envoie emails          │
        └────────────────────────────┘
```

---

## Sécurité

### Tokens Google
- Stockés de manière sécurisée en DB
- Rafraîchissement automatique quand expirés
- Jamais loggés en clair
- Scopes limités au minimum requis

### Authentification
- Sanctum pour la validation des tokens API
- Sessions sécurisées HTTPS (en production)
- CORS configuré correctement
- CSRF protection active

### Données Utilisateur
- Isolation par user_id
- Les AREAs d'un utilisateur ne peuvent être modifiées que par lui
- Pas d'exposition de tokens dans les réponses API

---

## Fonctionnalités Actuelles

### Implémentées
- [x] Authentification Google OAuth
- [x] Création/modification d'AREAs
- [x] Trigger Gmail : Nouveau email reçu
- [x] Trigger Timer : Toutes les minutes, heures, jours
- [x] Action Gmail : Envoyer un email
- [x] Exécution automatique via Cron
- [x] Logs détaillés
- [x] Gestion des tokens avec refresh automatique

### 🔄 Prochaines Étapes (Possibles)
- [ ] Trigger : Calendrier Google (événement créé)
- [ ] Trigger : GitHub (nouveau issue/PR)
- [ ] Action : Slack (envoyer message)
- [ ] Action : Discord (envoyer message)
- [ ] Dashboard avancé (statistiques, graphiques)
- [ ] Historique des exécutions (UI)
- [ ] Webhooks personnalisés
- [ ] Support des variables conditionnelles
- [ ] Exécution parallèle des actions
- [ ] File d'attente (job queue)

---

## Chemins Utiles

### Backend
```
backend-area/
├── app/
│   ├── Http/Controllers/
│   │   ├── AuthController.php
│   │   ├── ServiceController.php
│   │   └── AreaController.php
│   ├── Services/
│   │   ├── GoogleService.php
│   │   ├── TimerService.php
│   │   └── OAuthHelper.php
│   └── Console/Commands/
│       └── ExecuteAreas.php
├── routes/
│   ├── api.php (Routes API)
│   └── web.php (Routes Web)
├── storage/
│   └── logs/
│       ├── laravel.log (Logs normaux)
│       └── area-cron.log (Logs Cron)
└── run-area-execute.sh (Script Cron)
```

### Frontend
```
frontend-area/
├── app/
│   ├── pages/ (Routes Nuxt)
│   ├── stores/ (Pinia)
│   ├── components/ (Composants)
│   └── composables/ (Logique réutilisable)
├── public/ (Assets statiques)
└── nuxt.config.ts (Config Nuxt)
```

---

## Besoin d'Aide ?

### Je vois une erreur d'authentification
→ Allez dans **SETUP_CONFIGURATION.md** → **Dépannage**

### Le cron ne s'exécute pas
→ Allez dans **CRON_AUTOMATION.md** → **Dépannage**

### Les triggers Gmail ne détectent rien
→ Allez dans **SETUP_CONFIGURATION.md** → **Test de Configuration**

### Je veux modifier les triggers/actions
→ Allez dans **CHANGELOG.md** → **Architecture Finale**

---

## Commandes Utiles

### Backend

```bash
# Démarrer le serveur
php artisan serve --port=8080

# Exécuter les migrations
php artisan migrate

# Exécuter les seeders (données de test)
php artisan db:seed

# Exécuter les AREAs (manuel)
php artisan area:execute

# Ouvrir la console interactive
php artisan tinker

# Voir les routes disponibles
php artisan route:list

# Générer une clé APP_KEY
php artisan key:generate
```

### Frontend

```bash
# Démarrer le serveur de développement
npm run dev

# Compiler pour la production
npm run build

# Démarrer en production
npm run preview

# Linter le code
npm run lint
```

### Cron

```bash
# Afficher les tâches cron
crontab -l

# Éditer les tâches cron
crontab -e

# Voir les logs cron
tail -f backend-area/storage/logs/area-cron.log

# Tester le script cron
bash backend-area/run-area-execute.sh
```

### Base de Données

```bash
# Connexion MySQL
mysql -u root area_db

# Voir les utilisateurs
SELECT * FROM users;

# Voir les AREAs
SELECT * FROM areas;

# Voir les logs des AREAs
SELECT * FROM area_logs ORDER BY created_at DESC;
```

---

## Ressources d'Apprentissage

### Laravel
- [Laravel Documentation](https://laravel.com/docs)
- [Sanctum (API Auth)](https://laravel.com/docs/sanctum)
- [Eloquent ORM](https://laravel.com/docs/eloquent)

### Vue 3 & Nuxt
- [Vue 3 Documentation](https://vuejs.org)
- [Nuxt 3 Documentation](https://nuxt.com)
- [Pinia Store](https://pinia.vuejs.org)

### Google APIs
- [Google OAuth 2.0](https://developers.google.com/identity/protocols/oauth2)
- [Gmail API](https://developers.google.com/gmail/api/guides)

### DevOps
- [Crontab Format](https://crontab.guru)
- [Systemd Timers](https://wiki.archlinux.org/title/systemd/Timers)

---

## Notes Importantes

### En Développement
- Les variables d'environnement sont stockées dans `.env`
- Les logs sont dans `storage/logs/`
- La base de données est locale (MySQL)

### Pour la Production
- Utilisez un gestionnaire de secrets (HashiCorp Vault, AWS Secrets Manager)
- Activez HTTPS
- Utilisez un CDN pour les assets
- Configurez un database backups régulier
- Utilisez une file d'attente (Redis, RabbitMQ)
- Déployez sur un serveur dédié

---

## Statut du Projet

| Domaine | Statut | Notes |
|---------|--------|-------|
| Backend API | Production Ready | Toutes les routes essentielles implémentées |
| Frontend UI | Production Ready | Formulaires complets et fonctionnels |
| Google Integration | Production Ready | OAuth et Gmail API intégrés |
| Cron Automation | Production Ready | Exécution fiable chaque minute |
| Documentation | Complète | 3 fichiers détaillés disponibles |
| Tests | Partial | Tests manuels validés, tests automatisés à venir |
| Monitoring | Logs | Logs détaillés, UI dashboard à venir |

---

## Dernière Mise à Jour

- **Date** : 7 décembre 2025
- **Version** : 1.0.0
- **Auteur** : AREA Development Team
- **Statut** : Production Ready

---
