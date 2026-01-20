#  Guide de Contribution - Projet AREA

Bienvenue dans le guide de contribution du projet AREA (Action-REAction). Ce document explique comment contribuer efficacement au projet selon votre domaine d'expertise.

##  Table des Matières

1. [Prérequis](#prérequis)
2. [Architecture du Projet](#architecture-du-projet)
3. [Workflow de Contribution](#workflow-de-contribution)
4. [Backend (Laravel)](#backend-laravel)
5. [Frontend Web (Nuxt.js)](#frontend-web-nuxtjs)
6. [Mobile (Flutter)](#mobile-flutter)
7. [Standards de Code](#standards-de-code)
8. [Tests](#tests)
9. [Revue de Code](#revue-de-code)

---

##  Prérequis

### Outils Requis
- **Git** (version 2.30+)
- **Docker** & **Docker Compose**
- **Node.js** (version 18+) et **npm/yarn**
- **PHP** (version 8.2+) et **Composer**
- **Flutter** (version 3.0+) - pour le développement mobile

### Configuration Initiale

```bash
# Cloner le repository
git clone git@github.com:EpitechPGE3-2025/G-DEV-500-COT-5-2-area-8.git
cd G-DEV-500-COT-5-2-area-8

# Lancer l'environnement Docker
docker-compose up -d

# Backend Setup
cd backend-area
composer update
composer install
cp .env.example .env
php artisan key:generate
php artisan migrate
php artisan db:seed

# Frontend Web Setup
cd ../frontend-area
npm install

# Mobile Setup
cd ../flutter_application
flutter pub get
```

---

##  Architecture du Projet

```
espor/
├── backend-area/       # API Laravel (Port 8000)
├── frontend-area/      # Application Web Nuxt.js (Port 3000)
├── flutter_application/ # Application Mobile Flutter
└── docs/               # Documentation technique
```

---

##  Workflow de Contribution

### 1. Créer une Branche

```bash
# Pour une nouvelle fonctionnalité
git checkout -b feature/nom-de-la-fonctionnalite

# Pour un correctif
git checkout -b fix/description-du-bug

# Pour une amélioration
git checkout -b enhancement/description
```

### 2. Développer et Tester

- Implémenter votre fonctionnalité
- Écrire les tests unitaires et d'intégration
- Tester localement avec Docker
- Vérifier le linting et le formatage

### 3. Commit et Push

```bash
# Commits atomiques et descriptifs
git add .
git commit -m "feat: description de la fonctionnalité"
git push origin feature/nom-de-la-fonctionnalite
```

**Convention de commits:**
- `feat:` Nouvelle fonctionnalité
- `fix:` Correction de bug
- `docs:` Documentation
- `style:` Formatage, linting
- `refactor:` Refactorisation
- `test:` Ajout/modification de tests
- `chore:` Tâches de maintenance

### 4. Pull Request

1. Créer une PR sur GitHub
2. Remplir le template de PR
3. Assigner les reviewers appropriés
4. Attendre la revue et l'approbation
5. Merger après validation

---

##  Backend (Laravel)

### Structure des Services

Le backend utilise une architecture orientée services. Chaque service externe (Google, Discord, GitHub, etc.) suit le pattern défini par `ServiceInterface`.

###  Créer un Nouveau Service

#### Étape 1: Créer la Classe de Service

```bash
# Créer le fichier du service
touch backend-area/app/Services/MonNouveauService.php
```

**Template de Service:**

```php
<?php

namespace App\Services;

use App\Interfaces\ServiceInterface;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class MonNouveauService implements ServiceInterface
{
    /**
     * Vérifier si une action (trigger) est déclenchée
     *
     * @param string $actionName Nom de l'action (ex: "new_event")
     * @param array $params Paramètres de configuration
     * @param mixed $userToken Token d'authentification de l'utilisateur
     * @return array|null Données du trigger ou null si non déclenché
     */
    public function checkTrigger(string $actionName, array $params, $userToken): ?array
    {
        try {
            Log::info("MonNouveauService - checkTrigger: {$actionName}");
            
            return match($actionName) {
                'mon_action' => $this->checkMonAction($params, $userToken),
                default => null,
            };
        } catch (\Exception $e) {
            Log::error("MonNouveauService - Erreur checkTrigger: " . $e->getMessage());
            return null;
        }
    }

    /**
     * Exécuter une réaction
     *
     * @param string $reactionName Nom de la réaction
     * @param array $params Paramètres de configuration
     * @param mixed $userToken Token d'authentification
     * @param array $triggerData Données du trigger qui a déclenché la réaction
     * @return bool Succès ou échec
     */
    public function executeReaction(string $reactionName, array $params, $userToken, array $triggerData): bool
    {
        try {
            Log::info("MonNouveauService - executeReaction: {$reactionName}");
            
            return match($reactionName) {
                'ma_reaction' => $this->executeMaReaction($params, $userToken, $triggerData),
                default => false,
            };
        } catch (\Exception $e) {
            Log::error("MonNouveauService - Erreur executeReaction: " . $e->getMessage());
            return false;
        }
    }

    private function checkMonAction(array $params, $userToken): ?array
    {
        // Implémenter la logique de vérification
        // Retourner les données si déclenché, null sinon
        return null;
    }

    private function executeMaReaction(array $params, $userToken, array $triggerData): bool
    {
        // Implémenter la logique d'exécution
        return true;
    }
}
```

#### Étape 2: Enregistrer dans ExecuteAreas.php

**Fichier:** `backend-area/app/Console/Commands/ExecuteAreas.php`

```php
private function getServiceInstance(string $serviceName)
{
    return match($serviceName) {
        'google', 'gmail' => new \App\Services\GoogleService(),
        'timer' => new \App\Services\TimerService(),
        'weather' => new \App\Services\WeatherService(),
        'github' => new \App\Services\GitHubService(),
        'discord' => new \App\Services\DiscordService(),
        'slack' => new \App\Services\SlackService(),
        'spotify' => new \App\Services\SpotifyService(),
        'trello' => new \App\Services\TrelloService(),
        'mon_nouveau_service' => new \App\Services\MonNouveauService(), // AJOUTER ICI
        default => null,
    };
}
```

#### Étape 3: Ajouter dans le Seeder

**Fichier:** `backend-area/database/seeders/ServicesSeeder.php`

```php
DB::table('services')->insert([
    'name' => 'mon_nouveau_service',
    'display_name' => 'Mon Nouveau Service',
    'description' => 'Description du service',
    'auth_type' => 'oauth2', // ou 'api_key', 'none'
    'icon_url' => 'https://example.com/icon.png',
    'is_active' => true,
    'created_at' => now(),
    'updated_at' => now(),
]);
```

Exécuter le seeder:

```bash
cd backend-area
php artisan db:seed --class=ServicesSeeder
```

#### Étape 4: Mettre à Jour AboutController.php

**Fichier:** `backend-area/app/Http/Controllers/AboutController.php`

Ajouter votre service dans la méthode `about()`:

```php
[
    'name' => 'mon_nouveau_service',
    'actions' => [
        [
            'name' => 'mon_action',
            'description' => 'Description de l\'action',
        ],
    ],
    'reactions' => [
        [
            'name' => 'ma_reaction',
            'description' => 'Description de la réaction',
        ],
    ],
],
```

#### Étape 5: Tester le Service

```bash
# Créer une AREA de test via l'API (Postman ou curl)
curl -X POST http://localhost:8000/api/areas \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test Mon Service",
    "action_service": "mon_nouveau_service",
    "action_name": "mon_action",
    "action_params": {},
    "reaction_service": "discord",
    "reaction_name": "send_message",
    "reaction_params": {"channel_id": "123", "message": "Test"}
  }'

# Lancer le moteur AREA
php artisan area:execute

# Vérifier les logs
tail -f storage/logs/laravel.log
```

###  Développement d'API

#### Créer une Nouvelle Route

**Fichier:** `backend-area/routes/api.php`

```php
Route::middleware('auth:sanctum')->group(function () {
    Route::get('/mon-endpoint', [MonController::class, 'index']);
    Route::post('/mon-endpoint', [MonController::class, 'store']);
});
```

#### Créer un Controller

```bash
cd backend-area
php artisan make:controller MonController
```

###  Migrations de Base de Données

```bash
# Créer une migration
php artisan make:migration create_ma_table

# Exécuter les migrations
php artisan migrate

```

###  Tests Backend

```bash
# Créer un test
php artisan make:test MonServiceTest

# Exécuter les tests
php artisan test

# Avec coverage
php artisan test --coverage
```

---

## 🌐 Frontend Web (Nuxt.js)

### Structure des Composants

```
frontend-area/
├── app/
│   ├── components/     # Composants réutilisables
│   ├── pages/          # Pages de l'application
│   ├── layouts/        # Layouts
│   ├── composables/    # Composables Vue
│   └── plugins/        # Plugins Nuxt
```

### Créer un Nouveau Composant

```bash
touch frontend-area/app/components/MonComposant.vue
```

**Template:**

```vue
<template>
  <div class="mon-composant">
    <h2>{{ titre }}</h2>
    <p>{{ description }}</p>
  </div>
</template>

<script setup lang="ts">
interface Props {
  titre: string;
  description?: string;
}

const props = withDefaults(defineProps<Props>(), {
  description: '',
});
</script>

<style scoped>
.mon-composant {
  padding: 1rem;
}
</style>
```

### Appels API

Utiliser `useFetch` ou `$fetch`:

```typescript
// Dans un composable ou une page
const { data, error } = await useFetch('/api/mon-endpoint', {
  baseURL: 'http://localhost:8000',
  headers: {
    Authorization: `Bearer ${token}`,
  },
});
```

### Tests Frontend

```bash
# Lancer les tests
npm run test

# Linter
npm run lint

# Build de production
npm run build
```

---

##  Mobile (Flutter)

### Structure de l'Application

```
flutter_application/
├── lib/
│   ├── main.dart
│   ├── models/         # Modèles de données
│   ├── screens/        # Écrans de l'application
│   ├── widgets/        # Widgets réutilisables
│   ├── services/       # Services API
│   └── utils/          # Utilitaires
```

### Créer un Nouveau Widget

```dart
import 'package:flutter/material.dart';

class MonWidget extends StatelessWidget {
  final String titre;
  final String? description;

  const MonWidget({
    Key? key,
    required this.titre,
    this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text(titre, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          if (description != null) Text(description!),
        ],
      ),
    );
  }
}
```

### Appels API

```dart
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<Map<String, dynamic>> fetchData() async {
  final response = await http.get(
    Uri.parse('http://localhost:8000/api/mon-endpoint'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Failed to load data');
  }
}
```

### Générer l'APK

```bash
cd flutter_application
flutter build apk --release
```

---

##  Standards de Code

### Backend (PHP/Laravel)

- **PSR-12** pour le style de code
- **PHPDoc** pour la documentation
- **Laravel best practices**

```bash
# Formatter le code
./vendor/bin/pint

# Analyser le code
./vendor/bin/phpstan analyse
```

### Frontend (TypeScript/Vue)

- **ESLint** + **Prettier**
- **TypeScript strict mode**
- **Composition API**

```bash
# Formatter
npm run format

# Linter
npm run lint
```

### Mobile (Dart/Flutter)

- **Dart style guide**
- **Flutter best practices**

```bash
# Analyser
flutter analyze

# Formatter
dart format lib/
```

---

##  Tests

### Backend

- **Tests unitaires** pour les services
- **Tests d'intégration** pour les API
- **Minimum 70% de couverture**

```bash
php artisan test --coverage --min=70
```

### Frontend

- **Tests unitaires** pour les composables
- **Tests de composants** avec Vue Test Utils

```bash
npm run test:unit
```

### Mobile

- **Tests unitaires** et **tests de widgets**

```bash
flutter test
```

---

##  Revue de Code

### Checklist pour Reviewers

- [ ] Le code respecte les standards
- [ ] Les tests passent
- [ ] La documentation est à jour
- [ ] Pas de credentials en dur
- [ ] Pas de console.log / dd() / dump()
- [ ] Les noms de variables sont explicites
- [ ] Les erreurs sont gérées correctement

### Pour les Contributors

- [ ] J'ai testé localement
- [ ] J'ai ajouté/mis à jour les tests
- [ ] J'ai mis à jour la documentation
- [ ] Mon code respecte les conventions
- [ ] J'ai vérifié qu'il n'y a pas de conflits

---

##  Besoin d'Aide?

### Contacts

- **Lead Backend:** Retys
- **Lead Frontend Web:** Florian
- **Mobile Developer:** Iyad

### Resources

- [Documentation Laravel](https://laravel.com/docs)
- [Documentation Nuxt.js](https://nuxt.com/docs)
- [Documentation Flutter](https://flutter.dev/docs)
- [API Documentation](./docs/API_Documentation.md)

---

##  Licence

Ce projet est développé dans le cadre du projet AREA - Epitech.

