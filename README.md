# AREA - Automation Platform

![Laravel Tests](https://github.com/VOTRE-USERNAME/G-DEV-500-COT-5-2-area-8/workflows/Laravel%20CI%2FCD/badge.svg)
![Frontend CI](https://github.com/VOTRE-USERNAME/G-DEV-500-COT-5-2-area-8/workflows/Frontend%20CI/badge.svg)

**AREA** est une suite logicielle de type SaaS (Software as a Service) permettant d'automatiser des tâches en interconnectant divers services tiers. Inspiré par IFTTT et Zapier, AREA permet aux utilisateurs de créer des workflows conditionnels appelés 
**AREAs** (Action-REAction). ---

 ## Architecture 
 
Le projet est divisé en trois micro-services orchestrés par Docker Compose : 

| Service | Technologie | Port | Description |

**Application Server** 
 Laravel 11 (PHP) | `8080` | API REST, logique métier, gestion BDD, Polling & Webhooks. | |
 
**Web Client** 
| Nuxt 3 (Vue.js) | `8081` | Interface utilisateur web, Responsive design. | | 

**Mobile Client** 
| Flutter (Android) | N/A | Application native Android (l'APK est servi par le client web). | | 

**Database** | MariaDB | `3306` | Stockage des données utilisateurs et workflows. | 
--- 
## Fonctionnalités 

- **Authentification :** 

Inscription classique et OAuth2 (Google, GitHub, etc.). 

- **Gestion des AREAs :** 

Création, suppression et activation de workflows. 

- **Services supportés :** 

- **Timer / Scheduler** 

(Actions temporelles) 

- **Google** 

(Gmail, Calendar) 

- **GitHub** 

(Issues, PRs) 

- **Discord** 

(Webhooks, Messages) 

- **Spotify** 

(Playlists, Lectures) 

- **OpenWeatherMap** 

(Météo) 

- **Trello** 

(Gestion de cartes) 

- **Cross-Platform :** 

Accessible via navigateur et mobile (Android).

---

 ## Installation & Démarrage 
 
 ### Prérequis 
 - [Docker](https://docs.docker.com/get-docker/) 
 
 - [Docker Compose](https://docs.docker.com/compose/install/) 
 
 ### 1. Cloner le projet 
 
git clone https://github.com/EpitechPGE3-2025/G-DEV-500-COT-5-2-area-8.git 
 
cd G-DEV-500-COT-5-2-area-8

2. Configuration des variables d'environnement

Le projet nécessite des clés API pour fonctionner (Google, GitHub, etc.).
Copiez les fichiers d'exemple et remplissez-les :

code Bash

downloadcontent_copy

expand_less

# Pour le Backend (Laravel)
cp backend-area/.env.example backend-area/.env # Pour le Frontend (Nuxt) si nécessaire cp frontend-area/.env.example frontend-area/.env 

Note : Assurez-vous de configurer correctement les credentials OAuth (GOOGLE_CLIENT_ID, etc.) dans le .env du backend pour que la connexion fonctionne.

3. Lancer avec Docker Compose

Tout le projet se lance avec une seule commande à la racine :

code Bash

downloadcontent_copy

expand_less

docker-compose up --build -d 

4. Accès à l'application

Une fois les conteneurs lancés :

Client Web : http://localhost:8081

Serveur API : http://localhost:8080

Documentation API (Swagger/About) : http://localhost:8080/about.json

Télécharger l'APK Mobile : http://localhost:8081/client.apk

## Compilation Mobile (Manuel)

Si vous souhaitez compiler l'application mobile manuellement sans Docker :

code Bash

downloadcontent_copy

expand_less

cd flutter_application flutter pub get flutter build apk --release 

L'APK se trouvera dans build/app/outputs/flutter-apk/app-release.apk.

## Auteurs

Projet réalisé par une équipe de 6 étudiants d'EPITECH :

AHOUANGBE Florian

Membre 2 - GitHub

Membre 3 - GitHub

Membre 4 - GitHub

Membre 5 - GitHub

Membre 6 - GitHub

## Documentation Technique

Voici les liens vers la documentation officielle des technologies utilisées dans ce projet :

- ## Backend

Laravel (Framework PHP) : https://laravel.com/docs

Sanctum (Authentification) : https://laravel.com/docs/sanctum

Socialite (OAuth) : https://laravel.com/docs/socialite

- ## Frontend

Nuxt 3 (Framework Vue) : https://nuxt.com/docs

Vue.js 3 : https://vuejs.org/guide/introduction.html

Tailwind CSS : https://tailwindcss.com/docs

Pinia (State Management) : https://pinia.vuejs.org/introduction.html

- ## Mobile

Flutter : https://docs.flutter.dev/

Dart : https://dart.dev/guides

## DevOps & Outils

Docker : https://docs.docker.com/

MariaDB : https://mariadb.com/kb/en/documentation/

---

## 🧪 Tests et CI/CD

### Tests Unitaires et Fonctionnels

Le projet dispose d'une suite complète de tests PHPUnit :

#### Tests Unitaires (`tests/Unit/`)
- ✅ WeatherServiceTest - Tests du service météo
- ✅ SlackServiceTest - Tests du service Slack  
- ✅ GitHubServiceTest - Tests du service GitHub

#### Tests Fonctionnels (`tests/Feature/`)
- ✅ AreaExecutionTest - Tests des workflows complets
- ✅ AuthenticationTest - Tests d'authentification

### Exécuter les Tests

```bash
cd backend-area

# Tous les tests
./run-tests.sh all

# Tests unitaires uniquement
./run-tests.sh unit

# Tests fonctionnels uniquement
./run-tests.sh feature

# Avec rapport de couverture
./run-tests.sh coverage
```

### CI/CD avec GitHub Actions

Deux workflows automatisés s'exécutent à chaque push :

#### 1. Laravel CI/CD (`.github/workflows/laravel.yml`)
- ✅ Tests sur PHP 8.2 & 8.3
- ✅ Base de données MariaDB
- ✅ Couverture de code (Codecov)
- ✅ Analyse statique (PHPStan)
- ✅ Vérification du style (Laravel Pint)
- ✅ Audit de sécurité

#### 2. Frontend CI (`.github/workflows/frontend.yml`)
- ✅ Build et tests Nuxt
- ✅ Build et tests Flutter
- ✅ Vérification du linting

### Documentation Complète
- 📖 [Guide des Tests](backend-area/tests/README.md)
- 📖 [Configuration CI/CD](docs/CI_CD_SETUP.md)

---