# Tests AREA

Ce projet utilise PHPUnit pour les tests unitaires et fonctionnels.

## 📁 Structure des Tests

```
tests/
├── Feature/           # Tests d'intégration (API, workflows complets)
│   ├── AreaExecutionTest.php
│   └── AuthenticationTest.php
├── Unit/              # Tests unitaires (services individuels)
│   ├── WeatherServiceTest.php
│   ├── SlackServiceTest.php
│   └── GitHubServiceTest.php
└── TestCase.php       # Classe de base pour tous les tests
```

## 🚀 Exécuter les Tests

### Tous les tests
```bash
cd backend-area
php artisan test
# ou
vendor/bin/phpunit
```

### Tests unitaires uniquement
```bash
php artisan test --testsuite=Unit
# ou
vendor/bin/phpunit tests/Unit
```

### Tests fonctionnels uniquement
```bash
php artisan test --testsuite=Feature
# ou
vendor/bin/phpunit tests/Feature
```

### Test spécifique
```bash
php artisan test --filter WeatherServiceTest
# ou
vendor/bin/phpunit tests/Unit/WeatherServiceTest.php
```

### Avec couverture de code
```bash
vendor/bin/phpunit --coverage-html coverage/
# Ouvrir coverage/index.html dans un navigateur
```

## 📊 Tests Disponibles

### Tests Unitaires

#### WeatherServiceTest
- ✅ Vérification des paramètres manquants
- ✅ Détection de changement d'état (temperature_below)
- ✅ Skip quand déjà en dessous du seuil
- ✅ Déclenchement temperature_above
- ✅ Gestion des erreurs API

#### SlackServiceTest
- ✅ Paramètres manquants
- ✅ Détection nouveau message
- ✅ Ignore messages déjà traités
- ✅ Recherche de mots-clés
- ✅ Skip quand mot-clé absent
- ✅ Envoi de messages

#### GitHubServiceTest
- ✅ Paramètres manquants
- ✅ Détection nouvelle issue
- ✅ Ignore issues déjà traitées
- ✅ Création d'issues
- ✅ Gestion erreurs d'authentification

### Tests Fonctionnels

#### AreaExecutionTest
- ✅ Création d'une AREA
- ✅ Liste des AREAs utilisateur
- ✅ Mise à jour d'une AREA
- ✅ Suppression d'une AREA
- ✅ Sécurité (pas d'accès aux AREAs d'autres users)
- ✅ Exécution complète (weather → slack)

#### AuthenticationTest
- ✅ Inscription utilisateur
- ✅ Connexion
- ✅ Échec avec identifiants invalides
- ✅ Déconnexion
- ✅ Routes protégées
- ✅ Récupération profil

## 🎯 Bonnes Pratiques

### 1. Isolation des tests
Chaque test doit être indépendant et ne pas dépendre d'autres tests.

### 2. Mock des APIs externes
Utilisez `Http::fake()` pour simuler les appels API :
```php
Http::fake([
    'api.openweathermap.org/*' => Http::response([...], 200)
]);
```

### 3. Base de données en mémoire
Les tests utilisent SQLite en mémoire (`:memory:`) pour être rapides.

### 4. Nettoyage automatique
Utilisez `RefreshDatabase` dans les tests Feature :
```php
use Illuminate\Foundation\Testing\RefreshDatabase;

class MyTest extends TestCase
{
    use RefreshDatabase;
}
```

## 🔧 Configuration

### phpunit.xml
La configuration est dans `backend-area/phpunit.xml` :
- Base de données : SQLite en mémoire
- Cache : Array (pas de Redis/Memcached)
- Mail : Array (emails capturés, pas envoyés)
- Queue : Sync (exécution synchrone)

### Variables d'environnement de test
Modifiez dans `phpunit.xml` :
```xml
<env name="APP_ENV" value="testing"/>
<env name="DB_CONNECTION" value="sqlite"/>
<env name="DB_DATABASE" value=":memory:"/>
```

## 🤖 CI/CD

Les tests s'exécutent automatiquement via GitHub Actions :

### Workflow Laravel CI/CD
Fichier : `.github/workflows/laravel.yml`

**Déclencheurs :**
- Push sur `main`, `develop`, `dev`
- Pull requests

**Jobs :**
1. **Tests** (PHP 8.2 & 8.3)
   - Exécute tous les tests
   - Génère rapport de couverture
   - Upload vers Codecov

2. **Code Quality**
   - PHPStan (analyse statique)
   - Laravel Pint (style de code)

3. **Security**
   - Audit des dépendances Composer
   - Vérification des vulnérabilités

### Badge de statut
Ajoutez dans votre README principal :
```markdown
![Laravel Tests](https://github.com/VOTRE-REPO/workflows/Laravel%20CI%2FCD/badge.svg)
```

## 📝 Écrire de Nouveaux Tests

### Test Unitaire
```php
<?php

namespace Tests\Unit;

use Tests\TestCase;
use App\Services\MonService;

class MonServiceTest extends TestCase
{
    public function test_mon_action(): void
    {
        $service = new MonService();
        $result = $service->maMethode();
        
        $this->assertTrue($result);
    }
}
```

### Test Fonctionnel
```php
<?php

namespace Tests\Feature;

use Tests\TestCase;
use Illuminate\Foundation\Testing\RefreshDatabase;

class MonFeatureTest extends TestCase
{
    use RefreshDatabase;

    public function test_mon_endpoint(): void
    {
        $response = $this->postJson('/api/endpoint', [
            'data' => 'value'
        ]);

        $response->assertStatus(200);
    }
}
```

## 🐛 Debugging

### Mode verbose
```bash
php artisan test --verbose
```

### Afficher les détails d'erreurs
```bash
vendor/bin/phpunit --testdox
```

### Arrêter au premier échec
```bash
php artisan test --stop-on-failure
```

## 📈 Objectifs de Couverture

- **Minimum** : 60% de couverture
- **Cible** : 80% de couverture
- **Idéal** : 90%+ sur les services critiques

Vérifier la couverture :
```bash
vendor/bin/phpunit --coverage-text
```
