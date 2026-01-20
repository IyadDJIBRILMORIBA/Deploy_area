# 🧪 Guide de Contribution - Tests

## 📝 Avant de Créer une Pull Request

Assurez-vous que :

1. ✅ **Tous les tests passent**
   ```bash
   cd backend-area
   ./run-tests.sh all
   ```

2. ✅ **Le code respecte les standards**
   ```bash
   vendor/bin/pint --test
   ```

3. ✅ **Pas d'erreurs d'analyse statique**
   ```bash
   vendor/bin/phpstan analyse app --level=5
   ```

4. ✅ **Les nouvelles fonctionnalités ont des tests**
   - Ajoutez des tests unitaires pour les nouveaux services
   - Ajoutez des tests fonctionnels pour les nouvelles routes API

---

## 🎯 Template pour Nouveaux Tests Unitaires

### Créer un test pour un nouveau service

**Fichier :** `tests/Unit/MonNouveauServiceTest.php`

```php
<?php

namespace Tests\Unit;

use Tests\TestCase;
use App\Services\MonNouveauService;
use Illuminate\Support\Facades\Http;

class MonNouveauServiceTest extends TestCase
{
    protected MonNouveauService $service;

    protected function setUp(): void
    {
        parent::setUp();
        $this->service = new MonNouveauService();
    }

    /**
     * Test que le service retourne false si les paramètres sont manquants
     */
    public function test_returns_false_when_params_missing(): void
    {
        $result = $this->service->checkTrigger('mon_action', [], null);
        
        $this->assertFalse($result);
    }

    /**
     * Test du trigger principal
     */
    public function test_trigger_works_correctly(): void
    {
        // Mock de l'API externe
        Http::fake([
            'api.example.com/*' => Http::response([
                'data' => 'test'
            ], 200)
        ]);

        $result = $this->service->checkTrigger('mon_action', [
            'param1' => 'value1'
        ], null);

        $this->assertIsArray($result);
        $this->assertArrayHasKey('data', $result);
    }

    /**
     * Test de la gestion des erreurs
     */
    public function test_handles_api_errors(): void
    {
        Http::fake([
            'api.example.com/*' => Http::response([], 500)
        ]);

        $result = $this->service->checkTrigger('mon_action', [
            'param1' => 'value1'
        ], null);

        $this->assertFalse($result);
    }
}
```

---

## 🎯 Template pour Nouveaux Tests Fonctionnels

### Créer un test pour une nouvelle route API

**Fichier :** `tests/Feature/MonFeatureTest.php`

```php
<?php

namespace Tests\Feature;

use Tests\TestCase;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;

class MonFeatureTest extends TestCase
{
    use RefreshDatabase;

    protected User $user;

    protected function setUp(): void
    {
        parent::setUp();
        
        $this->user = User::factory()->create([
            'email' => 'test@example.com'
        ]);
    }

    /**
     * Test de la création via API
     */
    public function test_can_create_resource(): void
    {
        $response = $this->actingAs($this->user)->postJson('/api/resource', [
            'name' => 'Test Resource',
            'description' => 'Description test'
        ]);

        $response->assertStatus(201)
                 ->assertJsonStructure([
                     'id',
                     'name',
                     'description'
                 ]);

        $this->assertDatabaseHas('resources', [
            'name' => 'Test Resource',
            'user_id' => $this->user->id
        ]);
    }

    /**
     * Test de l'authentification requise
     */
    public function test_requires_authentication(): void
    {
        $response = $this->postJson('/api/resource', [
            'name' => 'Test'
        ]);

        $response->assertStatus(401);
    }

    /**
     * Test de validation
     */
    public function test_validates_input(): void
    {
        $response = $this->actingAs($this->user)->postJson('/api/resource', [
            // Paramètres manquants
        ]);

        $response->assertStatus(422)
                 ->assertJsonValidationErrors(['name']);
    }
}
```

---

## 🔍 Mocking des Services Externes

### HTTP Requests
```php
use Illuminate\Support\Facades\Http;

Http::fake([
    'api.service.com/*' => Http::response([
        'data' => 'response'
    ], 200),
    
    'api.autre.com/*' => Http::response([], 404)
]);
```

### Base de Données
```php
use Illuminate\Foundation\Testing\RefreshDatabase;

class MonTest extends TestCase
{
    use RefreshDatabase; // Recrée la BDD pour chaque test
}
```

### Cache
```php
use Illuminate\Support\Facades\Cache;

Cache::shouldReceive('get')
     ->once()
     ->with('key')
     ->andReturn('value');
```

---

## 📊 Vérifier la Couverture de Code

### Générer le rapport HTML
```bash
./run-tests.sh coverage
# Ouvre automatiquement coverage/index.html
```

### Générer le rapport texte
```bash
vendor/bin/phpunit --coverage-text
```

### Vérifier une classe spécifique
```bash
vendor/bin/phpunit --coverage-filter="App\Services\MonService" --coverage-text
```

---

## 🎨 Bonnes Pratiques

### 1. Nommage des Tests
```php
// ✅ BON - Descriptif et clair
public function test_user_can_create_area_with_valid_data(): void

// ❌ MAUVAIS - Pas assez descriptif
public function test_create(): void
```

### 2. Organisation
```php
// Structure recommandée d'un test
public function test_mon_scenario(): void
{
    // 1. Arrange - Préparer les données
    $user = User::factory()->create();
    
    // 2. Act - Exécuter l'action
    $response = $this->actingAs($user)->postJson('/api/endpoint');
    
    // 3. Assert - Vérifier le résultat
    $response->assertStatus(200);
    $this->assertDatabaseHas('table', ['field' => 'value']);
}
```

### 3. Isolation
```php
// Chaque test doit être indépendant
// ✅ BON
public function test_scenario_a(): void
{
    $data = $this->createTestData();
    // test...
}

public function test_scenario_b(): void
{
    $data = $this->createTestData(); // Nouvelles données
    // test...
}
```

### 4. Assertions Claires
```php
// ✅ BON - Assertions spécifiques
$this->assertEquals(200, $response->status());
$this->assertCount(3, $results);
$this->assertArrayHasKey('data', $response);

// ❌ MAUVAIS - Assertion vague
$this->assertTrue($something);
```

---

## 🐛 Debugging des Tests

### Afficher les erreurs détaillées
```bash
php artisan test --verbose
```

### Utiliser dd() dans les tests
```php
public function test_something(): void
{
    $result = $this->service->doSomething();
    dd($result); // Dump and die
}
```

### Afficher les requêtes SQL
```php
use Illuminate\Support\Facades\DB;

DB::enableQueryLog();
// ... code qui exécute des requêtes
dd(DB::getQueryLog());
```

### Arrêter au premier échec
```bash
php artisan test --stop-on-failure
```

---

## 📋 Checklist PR

Avant de soumettre une Pull Request :

- [ ] Tous les tests passent (`./run-tests.sh all`)
- [ ] Les nouveaux fichiers ont des tests
- [ ] Couverture de code > 80% pour les nouvelles fonctionnalités
- [ ] Code formaté avec Pint (`vendor/bin/pint`)
- [ ] Pas d'erreurs PHPStan (`vendor/bin/phpstan analyse app`)
- [ ] Documentation mise à jour si nécessaire
- [ ] Commit messages clairs et descriptifs

---

## 🤝 Exemples de Contributions

### Ajouter un test pour un service existant
```bash
# 1. Créer le fichier de test
cp tests/Unit/ExampleTest.php tests/Unit/MonServiceTest.php

# 2. Adapter le contenu
# 3. Lancer les tests
./run-tests.sh unit

# 4. Vérifier la couverture
./run-tests.sh coverage
```

### Ajouter un test fonctionnel pour une route
```bash
# 1. Créer le fichier
cp tests/Feature/ExampleTest.php tests/Feature/MonEndpointTest.php

# 2. Écrire les tests
# 3. Lancer
./run-tests.sh feature
```

---

## 📞 Besoin d'Aide ?

- 📖 [Documentation Tests](README.md)
- 📖 [Guide CI/CD](../docs/CI_CD_SETUP.md)
- 📖 [Laravel Testing Docs](https://laravel.com/docs/testing)
- 📖 [PHPUnit Documentation](https://phpunit.de/documentation.html)

---

**Merci de contribuer au projet AREA ! 🚀**
