# 👥 CONTRIBUTORS - Projet AREA

**Action-REaction Platform**  
Équipe de développement - Epitech

---

##  Vue d'Ensemble de l'Équipe

Notre équipe de **6 développeurs** couvre l'intégralité du stack technique du projet AREA:

- **3 Backend Developers** (Laravel/PHP)
- **2 Frontend Web Developers** (Nuxt.js/Vue.js)
- **1 Mobile Developer** (Flutter/Dart)

---

## 👤 Retys - Lead Backend Developer

###  Rôle & Responsabilités

**Lead Backend Developer** - Architecture & Coordination

- ✅ Définition de l'architecture backend principale (Laravel)
- ✅ Conception et validation d'API
- ✅ Supervision du développement des modules critiques
- ✅ Coordination de l'équipe backend
- ✅ Revue de code des contributions backend
- ✅ Garantie de la performance et de la sécurité

###  Contributions Techniques

#### Infrastructure & Architecture
- Setup initial du projet Laravel
- Architecture orientée services (ServiceInterface)
- Système d'authentification OAuth2 + Sanctum
- Configuration base de données PostgreSQL

#### Services Développés
1. **GoogleService** (Gmail)
   - OAuth2 Google implementation
   - Actions: `new_email`, `specific_sender`
   - Réactions: `send_email`

2. **TimerService**
   - Actions: `interval`, `specific_time`, `specific_date`
   - Système de vérification temporelle
   - Gestion des timestamps et timezones

3. **GitHubService**
   - OAuth2 GitHub
   - Actions: `new_issue`, `new_pull_request`, `new_commit`, `new_star`
   - Réactions: `create_issue`, `add_comment`

4. **TwitchService**
   - OAuth2 Twitch
   - Actions: `stream_started`, `new_follower`, `stream_ended`
   - Réactions: `send_chat_message`, `update_stream_title`

#### Controllers & API Routes
- **DashboardController** (routes mobile)
  - `/api/mobile/dashboard`
  - Statistiques utilisateur
  - Métriques des AREA

- **ActivityController** (routes mobile)
  - `/api/mobile/activities`
  - Historique des déclenchements
  - Filtres

#### Core Commands
- `ExecuteAreas` command - Moteur principal AREA
- Système de logging et monitoring
- Gestion des erreurs et retry logic

###  Statistiques
- **Services implémentés:** 4
- **Controllers:** 2

---

## 👤 Méryl - Backend Developer

###  Rôle & Responsabilités

**Backend Developer** - Services & API

- ✅ Implémentation des fonctionnalités backend
- ✅ Développement des intégrations de services
- ✅ Développement des interactions avec la base de données
- ✅ Participation aux revues de code

###  Contributions Techniques

#### Services Développés
1. **DiscordService**
   - OAuth2 Discord implementation
   - Actions: `new_message_in_channel`, `user_joined_server`
   - Réactions: `send_message`, `create_channel`
   - Webhooks Discord

2. **SlackService**
   - OAuth2 Slack
   - Actions: `new_message_channel`, `new_direct_message`
   - Réactions: `send_message`, `create_channel`
   - Slack API integration

#### API Endpoints
- **AboutController** - `/api/about.json`
  - Création et mise à jour complète du endpoint
  - Liste exhaustive des services
  - Documentation des actions/réactions
  - Format conforme au cahier des charges

#### Base de Données
- Seeders pour Discord et Slack
- Relations entre services et users
- Optimisation des requêtes

###  Statistiques
- **Services implémentés:** 2
- **Controllers mis à jour:** 1

---

## 👤 Asaph - Backend Developer

###  Rôle & Responsabilités

**Backend Developer** - Services & Tests

- ✅ Implémentation des fonctionnalités backend
- ✅ Développement des intégrations de services
- ✅ Développement des interactions avec la base de données
- ✅ Optimisation des performances
- ✅ Participation aux revues de code

###  Contributions Techniques

#### Services Développés
1. **WeatherService**
   - Intégration OpenWeatherMap API
   - Actions: `temperature_above`, `temperature_below`, `weather_condition`
   - Système de cache pour les requêtes météo
   - Gestion des unités (Celsius/Fahrenheit)

2. **TrelloService**
   - OAuth Trello
   - Actions: `new_card`, `card_moved`, `card_due_soon`
   - Réactions: `create_card`, `move_card`, `add_comment`
   - Webhooks Trello

#### Migrations & Base de Données
- Migration `area_logs` améliorée
  - Ajout colonne `trigger_data` (JSON)
  - Index sur `area_id` pour optimisation
  - Index sur `created_at` pour tri
  - Migration de données existantes

#### Tests
- **Tests unitaires** pour WeatherService
- **Tests unitaires** pour TrelloService
- **Tests d'intégration** pour le moteur AREA
- **Coverage:** Contribution majeure à >70%

**Fichiers de tests créés:**
- `tests/Unit/WeatherServiceTest.php`
- `tests/Unit/TrelloServiceTest.php`
- `tests/Feature/AreaExecutionTest.php`

###  Statistiques
- **Services implémentés:** 2
- **Migrations:** 1

---

## 👤 Florian - Lead Frontend Developer (Web)

###  Rôle & Responsabilités

**Lead Frontend Developer** - Architecture Web

- ✅ Configuration Docker & docker-compose
- ✅ Définition de l'architecture du client web (Nuxt.js)
- ✅ Conception des composants UI/UX clés
- ✅ Supervision du développement frontend web
- ✅ Garantie de la communication fluide avec le backend
- ✅ Revue de code des contributions web frontend
- ✅ Cohérence visuelle et accessibilité

###  Contributions Techniques

#### Architecture Frontend
- Setup initial Nuxt.js 3
- Configuration Tailwind CSS
- Architecture des composants
- Routing et navigation
- State management (Pinia)

#### Intégration Backend
- **Service API** complet
  - Authentification
  - Gestion des tokens
  - Refresh token automatique
  - Error handling global

- **Integration complète** Backend ↔ Frontend
  - Connexion à toutes les routes API
  - Gestion des OAuth redirects
  - WebSocket pour notifications (prévu)

#### Pages Principales Développées
1. **Dashboard** (`/dashboard`)
   - Liste des AREA
   - Statistiques utilisateur
   - Activation/désactivation des AREA
   - Graphiques et métriques

2. **Création d'AREA** (`/areas/create`)
   - Sélection de service
   - Configuration action/réaction
   - Validation de formulaire
   - Preview de l'AREA

3. **Page OAuth** (`/oauth/callback`)
   - Gestion des redirections OAuth
   - Stockage sécurisé des tokens
   - Error handling

#### Composants UI Créés
- `Navbar.vue` - Navigation principale
- `AreaCard.vue` - Affichage d'une AREA
- `ServiceSelector.vue` - Sélection de service
- `ActionReactionForm.vue` - Formulaire AREA
- `LoadingSpinner.vue` - États de chargement

### 📊 Statistiques
- **Fichiers créés:** 30+
- **Composants:** 15+
- **Pages:** 10+
- **Lines of code:** ~4000+

---

## 👤 Prince - Frontend Developer (Web)

###  Rôle & Responsabilités

**Frontend Developer** - UI/UX & Composants

- ✅ Implémentation des interfaces utilisateur web
- ✅ Intégration avec les APIs backend
- ✅ Développement des fonctionnalités spécifiques
- ✅ Réactivité et accessibilité des composants
- ✅ Optimisation des performances frontend

###  Contributions Techniques

#### Pages Développées
1. **Page de Profil** (`/profile`)
   - Informations utilisateur
   - Services connectés
   - Gestion des tokens OAuth
   - Paramètres de compte

2. **Page d'Activités** (`/activities`)
   - Historique complet des déclenchements
   - Filtres (par service, date, statut)
   - Tri et pagination
   - Export des données

3. **Page Services** (`/services`)
   - Liste de tous les services disponibles
   - Documentation par service
   - Exemples d'AREA populaires
   - Guide de connexion OAuth

#### Composants Développés
- `ServiceCard.vue` - Card pour chaque service
- `ActivityTimeline.vue` - Timeline des activités
- `StatsWidget.vue` - Widgets de statistiques
- `FilterBar.vue` - Barre de filtres
- `IconService.vue` - Icônes des services

#### Styling & UX
- Dark mode implementation
- Animations et transitions
- Responsive design (mobile, tablet, desktop)
- Accessibility (ARIA labels, keyboard navigation)
- Loading states et error messages

#### Travail en Parallèle
- Développement parallèle avec Florian
- Préparation du frontend pour la deadline du 11 janvier
- Optimisations pour le merge final du 17 janvier

###  Statistiques
- **Composants:** 10+

---

## 👤 Iyad - Mobile Developer

###  Rôle & Responsabilités

**Mobile Developer** - Application Flutter

- ✅ Développement complet de l'application mobile (Flutter)
- ✅ Support Android (et Windows Mobile potentiellement)
- ✅ Intégration avec les APIs backend
- ✅ Gestion des spécificités mobiles
- ✅ Génération de l'APK
- ✅ Configuration de l'adresse du serveur
- ✅ Performance et accessibilité mobile

### 💻 Contributions Techniques

#### Architecture Mobile
- Setup projet Flutter
- Architecture MVVM (Model-View-ViewModel)
- Routing et navigation
- State management (Provider/Riverpod)
- Local storage (SharedPreferences)

#### Écrans Développés
1. **Authentication**
   - Splash screen
   - Login screen
   - Register screen
   - Password recovery

2. **Home & Dashboard**
   - Dashboard avec statistiques
   - Liste des AREA
   - Quick actions
   - Notifications

3. **AREA Management**
   - Liste des AREA
   - Détails d'une AREA
   - Création/édition d'AREA
   - Configuration action/réaction

4. **Services & OAuth**
   - Liste des services disponibles
   - Configuration OAuth mobile
   - Gestion des tokens
   - WebView pour OAuth flow

5. **Profil & Paramètres**
   - Informations utilisateur
   - Services connectés
   - Configuration serveur
   - Paramètres de l'app

#### Fonctionnalités Spécifiques Mobile
- **Configuration serveur dynamique**
  - Changement d'URL du backend
  - Support localhost pour développement
  - Support IP pour réseau local

- **Génération APK**
  - APK de production (`client.apk`)
  - Optimisation de la taille
  - ProGuard/R8 configuration

- **Notifications**
  - Firebase Cloud Messaging (prévu)
  - Notifications locales
  - Badges et sons

- **Offline Support**
  - Cache local
  - Synchronisation automatique
  - Gestion des erreurs réseau

#### Services API
- HTTP client (Dio)
- Authentification mobile
- Gestion des tokens
- Refresh token automatique
- Error handling

#### Travail en Parallèle
- Développement parallèle avec frontend web
- Préparation pour deadline du 11 janvier
- Améliorations pour merge final du 17 janvier

###  Statistiques
- **Écrans:** 15+
- **Widgets:** 25+
- **APK généré:**  client.apk

---

##  Statistiques Globales du Projet

### Par Composant
| Composant | Contributeurs | Fichiers | Lines of Code |
|-----------|---------------|----------|---------------|
| Backend | Retys, Méryl, Asaph | ~50+ | ~10,000+ |
| Frontend Web | Florian, Prince | ~60+ | ~6,500+ |
| Mobile | Iyad | ~40+ | ~5,000+ |
| Documentation | Tous | ~15+ | ~3,000+ |
| **TOTAL** | **6** | **~165+** | **~24,500+** |

### Services Implémentés
1. **Google/Gmail** - Retys
2. **Timer** - Retys
3. **GitHub** - Retys
4. **Twitch** - Retys
5. **Discord** - Méryl
6. **Slack** - Méryl
7. **Weather** - Asaph
8. **Trello** - Asaph

**Total: 8 services** avec ~30 actions et ~20 réactions

### Tests
- **Backend:** 25+ tests unitaires et d'intégration
- **Frontend:** Tests E2E avec Playwright
- **Mobile:** Tests de widgets
- **Coverage:** >70%

---

##  Collaboration & Communication

### Outils Utilisés
- **Git/GitHub** - Versioning et collaboration
- **Discord/Slack** - Communication quotidienne
- **Trello/Notion** - Gestion de projet
- **Postman** - Tests API
- **Docker** - Environnement de développement

### Revues de Code
- **Backend:** Retys → Méryl, Asaph
- **Frontend:** Florian → Prince
- **Cross-review:** Mobile ↔ Backend, Frontend ↔ Backend

### Méthodologie
- **Sprints** de 2 semaines
- **Revues** de fin de sprint

---

##  Réalisations de l'Équipe

### Techniques
✅ Architecture scalable et maintenable  
✅ 8 services intégrés avec OAuth2  
✅ API REST complète et documentée  
✅ Application web responsive et accessible  
✅ Application mobile Android fonctionnelle  
✅ Tests automatisés (>70% coverage)  
✅ Docker compose pour déploiement facile
✅ Documentation complète

### Gestion de Projet
✅ Deadlines respectées (11 et 17 janvier)  
✅ Communication fluide entre équipes  
✅ Intégration backend ↔ frontend ↔ mobile réussie  
✅ Code reviews systématiques  
✅ Documentation à jour

### Qualité
✅ Code propre et commenté  
✅ Conventions de nommage respectées  
✅ Pas de credentials en dur  
✅ Gestion des erreurs robuste  
✅ Performance optimisée

---

##  Contact des Contributors

### Backend Team
- **Retys** (Lead) - Architecture & Core Services
- **Méryl** - Discord, Slack, About.json
- **Asaph** - Weather, Trello, Tests

### Frontend Web Team
- **Florian** (Lead) - Architecture & Intégration
- **Prince** - UI/UX & Composants

### Mobile Team
- **Iyad** - Flutter Application

---

##  Licence & Crédits

**Projet:** AREA (Action-REaction)  
**Institution:** Epitech  
**Année:** 2025-2026  
**Équipe:** 6 développeurs passionnés

---

**Version:** 1.0.0  
**Status:** Projet livré
