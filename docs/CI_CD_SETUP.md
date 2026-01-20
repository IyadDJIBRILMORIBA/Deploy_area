# CI/CD Configuration

## 🚀 Workflows GitHub Actions

### 1. Laravel CI/CD (`.github/workflows/laravel.yml`)

Pipeline complet pour le backend Laravel avec plusieurs jobs parallèles.

#### Jobs

##### **Tests** (Matrix: PHP 8.2 & 8.3)
- ✅ Installation des dépendances avec cache
- ✅ Base de données MariaDB 10.11
- ✅ Migrations automatiques
- ✅ Exécution de tous les tests
- ✅ Génération de la couverture de code
- ✅ Upload vers Codecov

##### **Code Quality**
- 🔍 PHPStan (analyse statique niveau 5)
- 💅 Laravel Pint (vérification du style de code)

##### **Security**
- 🔒 Audit des dépendances Composer
- 🛡️ Vérification des vulnérabilités connues

#### Déclenchement
```yaml
on:
  push:
    branches: [ main, develop, dev ]
  pull_request:
    branches: [ main, develop, dev ]
```

#### Variables d'environnement
- `DB_CONNECTION: mysql`
- `DB_HOST: 127.0.0.1`
- `DB_PORT: 3306`
- `DB_DATABASE: area_test_db`

---

### 2. Frontend CI (`.github/workflows/frontend.yml`)

Tests pour Nuxt (web) et Flutter (mobile).

#### Jobs

##### **Test Nuxt Frontend**
- 📦 Node.js 20
- 🔍 Linting
- 🏗️ Build de production
- ✅ Tests (si configurés)

##### **Test Flutter Mobile**
- 📱 Flutter 3.16.0
- 🔍 Analyse de code
- ✅ Tests Flutter
- 📦 Build APK debug

---

## 📊 Badges de Statut

Ajoutez ces badges dans votre README principal :

```markdown
![Laravel Tests](https://github.com/VOTRE-USERNAME/G-DEV-500-COT-5-2-area-8/workflows/Laravel%20CI%2FCD/badge.svg)
![Frontend CI](https://github.com/VOTRE-USERNAME/G-DEV-500-COT-5-2-area-8/workflows/Frontend%20CI/badge.svg)
[![codecov](https://codecov.io/gh/VOTRE-USERNAME/G-DEV-500-COT-5-2-area-8/branch/main/graph/badge.svg)](https://codecov.io/gh/VOTRE-USERNAME/G-DEV-500-COT-5-2-area-8)
```

---

## 🔧 Configuration Locale

### Installer les dépendances de développement

```bash
cd backend-area
composer install
composer require --dev phpstan/phpstan laravel/pint
```

### Exécuter les outils localement

#### Tests
```bash
./run-tests.sh all
```

#### PHPStan (Analyse Statique)
```bash
vendor/bin/phpstan analyse app --level=5
```

#### Laravel Pint (Style de Code)
```bash
vendor/bin/pint
# ou juste vérifier sans modifier
vendor/bin/pint --test
```

---

## 🐳 Tests avec Docker

### Exécuter les tests dans le conteneur Docker

```bash
# Avec Docker Compose
docker-compose exec server php artisan test

# ou avec le script
docker-compose exec server ./run-tests.sh unit
```

### Configuration Docker pour les tests

Le service `server` dans `docker-compose.yml` est configuré pour exécuter les tests :

```yaml
services:
  server:
    environment:
      DB_CONNECTION: mysql
      DB_HOST: db
      DB_DATABASE: area_db
```

---

## 🎯 Bonnes Pratiques CI/CD

### 1. **Commits**
- Tous les commits déclenchent les tests
- Les PRs bloquent la fusion si les tests échouent

### 2. **Branches Protégées**
Configurez GitHub pour protéger `main` :
1. Settings → Branches → Add rule
2. Branch name pattern: `main`
3. ✅ Require status checks to pass
4. ✅ Require branches to be up to date

### 3. **Cache**
Le workflow utilise le cache pour accélérer les builds :
- Cache Composer : `~/.composer/cache`
- Cache npm : `~/.npm`

### 4. **Matrix Strategy**
Les tests tournent sur plusieurs versions de PHP (8.2, 8.3) pour garantir la compatibilité.

---

## 📈 Métriques et Monitoring

### Codecov
1. Créez un compte sur [codecov.io](https://codecov.io)
2. Liez votre repo GitHub
3. Le workflow upload automatiquement la couverture

### Temps d'Exécution Typiques
- **Tests Laravel** : ~2-3 minutes
- **Code Quality** : ~1-2 minutes
- **Security Audit** : ~30 secondes
- **Frontend Tests** : ~2-3 minutes
- **Total** : ~8-10 minutes

---

## 🔍 Debugging des Workflows

### Voir les logs détaillés
1. Allez dans l'onglet "Actions" de votre repo
2. Cliquez sur un workflow
3. Consultez les logs de chaque job

### Re-exécuter un workflow
Cliquez sur "Re-run jobs" dans l'interface GitHub Actions

### Tester localement avec act
```bash
# Installer act
curl https://raw.githubusercontent.com/nektos/act/master/install.sh | sudo bash

# Exécuter le workflow Laravel localement
act -j tests
```

---

## 🚨 Notifications

### Échec de Build
GitHub envoie automatiquement des notifications par email en cas d'échec.

### Slack (optionnel)
Ajoutez à vos workflows :

```yaml
- name: Notify Slack
  if: failure()
  uses: 8398a7/action-slack@v3
  with:
    status: ${{ job.status }}
    webhook_url: ${{ secrets.SLACK_WEBHOOK }}
```

---

## 📝 Checklist Avant de Pousser

- [ ] Tous les tests passent localement
- [ ] PHPStan ne remonte pas d'erreurs
- [ ] Le code est formaté avec Pint
- [ ] Les nouvelles fonctionnalités ont des tests
- [ ] Le fichier `.env.example` est à jour
- [ ] La documentation est mise à jour

```bash
# Commande rapide pour tout vérifier
./run-tests.sh all && \
vendor/bin/phpstan analyse app --level=5 && \
vendor/bin/pint --test
```

---

## 🔐 Secrets GitHub

Configurez les secrets nécessaires dans :
**Settings → Secrets and variables → Actions**

Secrets requis (si applicable) :
- `CODECOV_TOKEN` - Pour upload de couverture
- `SLACK_WEBHOOK` - Pour notifications Slack
- `DOCKER_USERNAME` - Pour push d'images Docker
- `DOCKER_PASSWORD` - Pour authentification Docker Hub

---

## 📚 Ressources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [PHPUnit Documentation](https://phpunit.de/documentation.html)
- [Laravel Testing](https://laravel.com/docs/testing)
- [Codecov Documentation](https://docs.codecov.io/)
