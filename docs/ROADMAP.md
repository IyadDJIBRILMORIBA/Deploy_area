# 🗺️ ROADMAP - Projet AREA

**Action-REAction Platform**  

---

## 📅 Timeline Globale

```
Décembre 2025                    Janvier 2026
├─────────────────────────────────────────────────────────┤
│ Sprint 1    │ Sprint 2    │ Sprint 3    │ Finalisation │
│ Architecture│ Core Features│ Services    │ & Tests      │
│ 2-15 Déc    │ 16-29 Déc   │ 30 Déc-8 Jan│ 9-17 Jan     │
└─────────────────────────────────────────────────────────┘
                                           ↓              ↓
                                   Deadline 1    Deadline 2
                                   11 Janvier    17 Janvier
```

---

## 🎯 Sprint 1: Architecture & Infrastructure (2-15 Décembre 2025)

**Objectif:** Établir les fondations du projet

### Backend (Retys - Lead)
- **2-3 Déc:** Setup initial Laravel
  - Configuration Docker
  - Base de données PostgreSQL
  - Configuration OAuth2
  
- **4-6 Déc:** Architecture des services
  - Création de `ServiceInterface`
  - Implémentation du pattern Service
  - Setup du système d'authentification Sanctum

- **7-10 Déc:** Core API endpoints
  - `/api/auth/*` (login, register, logout)
  - `/api/services` (CRUD services)
  - `/api/areas` (CRUD areas)
  
- **11-15 Déc:** Base de données & Migrations
  - Tables: users, services, areas, area_logs
  - Relations & indexes
  - Seeders initiaux

### Frontend Web (Florian - Lead)
- **2-4 Déc:** Setup Nuxt.js
  - Configuration Tailwind CSS
  - Architecture des composants
  - Routing initial

- **5-8 Déc:** Pages principales
  - Page d'accueil
  - Login/Register
  - Layout principal

- **9-12 Déc:** Composants UI de base
  - Navbar
  - Footer
  - Card components
  - Form components

- **13-15 Déc:** Intégration API auth
  - Service d'authentification
  - Store Pinia pour l'état global
  - Guards de navigation

### Mobile (Iyad)
- **2-5 Déc:** Setup Flutter
  - Configuration projet Android
  - Architecture MVVM
  - Routing

- **6-10 Déc:** Écrans de base
  - Splash screen
  - Login/Register
  - Home screen

- **11-15 Déc:** Services API
  - HTTP client configuration
  - Authentification
  - Error handling

---

##  Sprint 2: Fonctionnalités Core (16-29 Décembre 2025)

**Objectif:** Implémenter les fonctionnalités essentielles

### Backend (Retys + Méryl + Asaph)

#### Retys
- **16-18 Déc:** Google Service (Gmail)
  - OAuth2 Google
  - Actions: new_email, specific_sender
  - Réactions: send_email

- **19-22 Déc:** Timer Service
  - Actions: interval, specific_time, specific_date
  - Gestion des timestamps
  - Système de vérification périodique

- **23-25 Déc:** Command ExecuteAreas
  - Moteur principal AREA
  - Boucle de vérification
  - Logging des déclenchements

- **26-29 Déc:** Dashboard & Activity Controllers
  - Routes pour mobile
  - Statistiques utilisateur
  - Historique d'activités

#### Méryl
- **16-20 Déc:** Discord Service
  - OAuth2 Discord
  - Actions: new_message_in_channel
  - Réactions: send_message, create_channel

- **21-25 Déc:** Slack Service
  - OAuth2 Slack
  - Actions: new_message_channel, new_direct_message
  - Réactions: send_message, create_channel

- **26-29 Déc:** Amélioration `/api/about.json`
  - Liste complète des services
  - Toutes les actions/réactions
  - Format conforme au cahier des charges

#### Asaph
- **16-20 Déc:** Weather Service
  - API OpenWeatherMap
  - Actions: temperature_above, temperature_below, weather_condition
  - Réactions: N/A

- **21-25 Déc:** Amélioration area_logs
  - Migration pour trigger_data
  - Index sur area_id et created_at
  - Optimisation des requêtes

- **26-29 Déc:** Tests unitaires backend
  - Tests des services
  - Tests des controllers
  - Tests d'intégration

### Frontend Web (Florian + Prince)

#### Florian
- **16-19 Déc:** Dashboard utilisateur
  - Liste des AREA
  - Statistiques
  - Gestion des AREA (activate/deactivate)

- **20-23 Déc:** Page de création d'AREA
  - Sélection de service
  - Configuration actions/réactions
  - Validation du formulaire

- **24-27 Déc:** Intégration backend
  - Connexion API complète
  - Gestion des erreurs
  - Loading states

- **28-29 Déc:** Page OAuth
  - Gestion des redirections OAuth
  - Stockage des tokens
  - Refresh tokens

#### Prince
- **16-20 Déc:** Composants de services
  - Cards de services
  - Liste des actions/réactions
  - Icônes et styling

- **21-25 Déc:** Page de profil
  - Informations utilisateur
  - Services connectés
  - Gestion des tokens

- **26-29 Déc:** Page d'activités
  - Historique des déclenchements
  - Filtres et tri
  - Responsive design

### Mobile (Iyad)
- **16-20 Déc:** Écrans AREA
  - Liste des AREA
  - Détails d'une AREA
  - Création/édition

- **21-25 Déc:** Intégration services
  - Liste des services disponibles
  - Configuration OAuth
  - Gestion des tokens

- **26-29 Déc:** Dashboard mobile
  - Statistiques
  - Activités récentes
  - Navigation

---

##  Sprint 3: Services Avancés (30 Décembre 2025 - 8 Janvier 2026)

**Objectif:** Compléter tous les services requis

### Backend

#### Retys
-  **30 Déc - 2 Jan:** GitHub Service
  - OAuth2 GitHub
  - Actions: new_issue, new_pull_request, new_commit, new_star
  - Réactions: create_issue, add_comment

-  **3-6 Jan:** Spotify Service
  - OAuth2 Spotify
  - Actions: new_saved_track, new_playlist
  - Réactions: add_to_playlist, create_playlist

-  **7-8 Jan:** Optimisations backend
  - Cache Redis
  - Queue jobs
  - Rate limiting

#### Asaph
- **30 Déc - 4 Jan:** Trello Service
  - OAuth Trello
  - Actions: new_card, card_moved
  - Réactions: create_card, move_card, add_comment

- **5-8 Jan:** Tests complets
  - Coverage 70%+
  - Tests d'intégration services
  - Tests de charge

### Frontend Web

#### Florian + Prince
- **30 Déc - 3 Jan:** UI/UX améliorations
  - Animations
  - Feedback utilisateur
  - Dark mode

- **4-6 Jan:** Pages de services
  - Documentation par service
  - Exemples d'AREA
  - Guide d'utilisation

- **7-8 Jan:** Tests frontend
  - Tests unitaires composants
  - Tests E2E
  - Cross-browser testing

### Mobile

#### Iyad
- **30 Déc - 4 Jan:** Fonctionnalités avancées
  - Notifications push
  - Synchronisation offline
  - Configuration serveur

- **5-8 Jan:** Optimisations mobile
  - Performance
  - Battery optimization
  - Build APK

---

##  Phase Finale: Tests & Déploiement (9-17 Janvier 2026)

###  Deadline 1: Dimanche 11 Janvier 2026

**Objectif:** Toutes les fonctionnalités core prêtes

#### Backend (Retys, Méryl, Asaph)
- **9-10 Jan:** Revue de code complète
  - Code review mutuelle
  - Corrections bugs
  - Documentation API

- **11 Jan:** CHECKPOINT DEADLINE 1
  - ✅ Tous les services implémentés
  - ✅ API complète et documentée
  - ✅ Tests >70% coverage
  - ✅ `/api/about.json` complet

#### Frontend (Florian, Prince)
- **9-10 Jan:** Préparation frontend
  - Corrections bugs
  - Optimisations
  - Tests

- **11 Jan:** Frontend prêt pour intégration finale
  - ✅ Toutes les pages fonctionnelles
  - ✅ Intégration API backend complète
  - ✅ Responsive design

#### Mobile (Iyad)
- **9-10 Jan:** Préparation mobile
  - Corrections bugs
  - Optimisations UI
  - Tests sur différents devices

- **11 Jan:** Mobile prêt pour finalisation
  - ✅ Toutes les fonctionnalités implémentées
  - ✅ APK généré

---

###  Deadline 2: Samedi 17 Janvier 2026 (MERGE FINAL)

**Objectif:** Projet complet et déployable

**Lundi 12 - Mardi 13 Janvier:**
-  Tests d'intégration complets
  - Backend ↔ Frontend
  - Backend ↔ Mobile
  - Tests end-to-end
  - Correction des bugs d'intégration

**Mercredi 14 Janvier:**
- Documentation finale
  - README.md
  - API_DOCUMENTATION.md
  - TESTING_GUIDE.md
  - Vidéo de démo

**Jeudi 15 Janvier:**
- Optimisations finales
  - Performance backend
  - Optimisation frontend
  - Optimisation mobile
  - Compression assets

**Vendredi 16 Janvier:**
- Pre-merge checks
  - Vérification Docker compose
  - Tests de déploiement
  - Vérification de tous les environnements
  - client.apk généré et testé

**Samedi 17 Janvier - DEADLINE FINALE:**
- **MERGE FINAL**
  - ✅ Merge de toutes les branches
  - ✅ Tag version 1.0.0
  - ✅ Documentation complète
  - ✅ Docker compose fonctionnel
  - ✅ APK disponible
  - ✅ Tous les tests passent
  - ✅ Prêt pour démo

---

##  Livrables Finaux (17 Janvier 2026)

### Code Source
- Repository GitHub complet
- Branches mergées sur main
- .gitignore propre (pas de credentials)

### Backend
- API REST complète
- 8+ services intégrés (Google, Timer, Weather, GitHub, Discord, Slack, Spotify, Trello)
- Moteur AREA fonctionnel
- Tests >70% coverage
- Documentation API (Swagger/Postman)

### Frontend Web
- Application Nuxt.js déployable
- Toutes les pages fonctionnelles
- Responsive design
- Dark mode
- Tests E2E

### Mobile
- Application Flutter
- APK Android généré (client.apk)
- Configuration serveur flexible
- Notifications push

### Infrastructure
- Docker compose fonctionnel
- Variables d'environnement documentées
- Scripts de déploiement
- Guide d'installation

### Documentation
- README.md principal
- API_DOCUMENTATION.md
- TESTING_GUIDE.md
- HOWTOCONTRIBUTE.md
- ROADMAP.md (ce fichier)
- CONTRIBUTORS.md
- Vidéo de démonstration

---

##  Métriques de Succès

### Technique
- ✅ Tous les tests passent
- ✅ Coverage >70%
- ✅ Pas de secrets dans le code
- ✅ Docker compose up fonctionne
- ✅ APK génère et lance sans erreur

### Fonctionnel
- ✅ Au moins 8 services intégrés
- ✅ AREA créées et déclenchées automatiquement
- ✅ Interface web complète et responsive
- ✅ Application mobile fonctionnelle
- ✅ OAuth fonctionnel pour tous les services

### Documentation
- ✅ Guide d'installation clair
- ✅ API documentée
- ✅ Exemples d'utilisation
- ✅ Guide de contribution
- ✅ Architecture documentée

---

##  Post-Launch (Après le 17 Janvier)

### Améliorations Potentielles
- [ ] Plus de services (Twitter, LinkedIn, etc.)
- [ ] Interface de création visuelle (drag & drop)
- [ ] Notifications en temps réel (WebSocket)
- [ ] Analytics avancées
- [ ] Application iOS
- [ ] Mode offline avancé
- [ ] Templates d'AREA prédéfinis
- [ ] Marketplace de services communautaires

### Optimisations
- [ ] Cache distribué
- [ ] Load balancing
- [ ] CDN pour les assets
- [ ] Optimisation base de données
- [ ] Monitoring et alerting

---

##  Notes

### Décisions Techniques
- **Backend:** Laravel 10+ avec Sanctum pour l'auth
- **Frontend:** Nuxt.js 3 avec Tailwind CSS
- **Mobile:** Flutter pour Android
- **Base de données:** PostgreSQL
- **Cache:** Redis (optionnel)
- **Queue:** Laravel Queue

### Contraintes
- Deadline stricte: 17 janvier 2026
- Équipe de 6 personnes
- Format de rendu: repository + APK + documentation

### Risques Identifiés
- ✅ OAuth complexe → Résolu avec services helper
- ✅ Intégration multi-plateforme → Communication constante équipe
- ✅ Gestion du temps → Sprints bien définis

---

**Version:** 1.0  

**Status:** ✅ PROJET LIVRÉ
