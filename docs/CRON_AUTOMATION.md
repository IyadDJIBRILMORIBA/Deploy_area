# Guide d'Automatisation avec Laravel Scheduler - AREA

## Table des Matières
1. [Vue d'ensemble](#vue-densemble)
2. [Architecture](#architecture)
3. [Configuration](#configuration)
4. [Installation du Cron](#installation-du-cron)
5. [Vérification et Tests](#vérification-et-tests)
6. [Monitoring et Logging](#monitoring-et-logging)
7. [Options de Fréquence](#options-de-fréquence)
8. [Dépannage](#dépannage)
9. [Configuration Avancée](#configuration-avancée)

---

## Vue d'ensemble

### Qu'est-ce que Laravel Scheduler ?

**Laravel Scheduler** est un système de scheduling intégré à Laravel qui remplace les scripts cron manuels. Il offre :

- Configuration en PHP (routes/console.php) au lieu de cron expressions
- Gestion automatique des exécutions chevauchantes (withoutOverlapping)
- Logging intégré des succès/erreurs
- Callbacks onSuccess/onFailure
- Plus lisible et maintenable
- Support de multiples fréquences (minute, heure, jour, etc.)

### Ancien vs Nouveau Système

#### Ancien Système (Cron Manuel)
```
1. Script shell (run-area-execute.sh)
2. Appel direct : php artisan area:execute
3. Une seule fréquence possible
4. Logs manuels difficiles à parser
```

#### Nouveau Système (Laravel Scheduler)
```
1. Cron système : php artisan schedule:run (chaque minute)
2. Dispatcher qui lit routes/console.php
3. Exécute les tâches dues
4. Logging structuré automatique
5. Logs lisibles : area-scheduler.log
```

---

## Architecture

### Flux d'Exécution

```
Cron Système (Chaque minute)
    ↓
run-area-execute.sh
    ↓
php artisan schedule:run
    ↓
Lit routes/console.php
    ↓
Évalue les conditions (everyMinute, hourly, etc.)
    ↓
Exécute les tâches dues
    ↓
php artisan areas:scheduled
    ↓
ExecuteScheduledAreas.php
    ↓
Vérifie tous les triggers
    ↓
Exécute les actions si déclenchées
    ↓
Logs dans area-scheduler.log
```

### Fichiers Impliqués

```
backend-area/
├── routes/console.php ..................... Configuration du scheduler
├── app/Console/Commands/
│   ├── ExecuteAreas.php .................. (ANCIEN - peut être retiré)
│   └── ExecuteScheduledAreas.php ......... Nouvelle commande optimisée
├── run-area-execute.sh ................... Script appelé par cron
└── storage/logs/
    └── area-scheduler.log ................ Logs du scheduler
```

---

##  Configuration

### Configuration par Défaut

**Fichier : `routes/console.php`**

```php
Schedule::command('areas:scheduled')
    ->everyMinute()                    // Exécute toutes les minutes
    ->withoutOverlapping()             // Évite les exécutions parallèles
    ->onFailure(function () {
        \Log::error('[AREA Scheduler] Erreur lors de l\'exécution');
    });
```

### Changer la Fréquence

Modifiez simplement `routes/console.php` :

#### Exemple 1 : Exécuter Toutes les 5 Minutes
```php
Schedule::command('areas:scheduled')
    ->everyFiveMinutes()
    ->withoutOverlapping();
```

#### Exemple 2 : Exécuter À 3 Heures du Matin
```php
Schedule::command('areas:scheduled')
    ->dailyAt('03:00')
    ->withoutOverlapping();
```

#### Exemple 3 : Format Cron Personnalisé
```php
Schedule::command('areas:scheduled')
    ->cron('0 */2 * * *')  // Toutes les 2 heures
    ->withoutOverlapping();
```

---

## 🔧 Installation du Cron

### Étape 1 : Vérifier le Script Cron

**Fichier : `backend-area/run-area-execute.sh`**

```bash
#!/bin/bash

PROJECT_PATH="/home/the_flowww/G-DEV-500-COT-5-2-area-8/backend-area"
cd "$PROJECT_PATH" || exit 1

# Exécute le scheduler Laravel
php artisan schedule:run >> storage/logs/area-scheduler.log 2>&1

exit 0
```

**Vérifier que le fichier est exécutable :**

```bash
chmod +x /home/the_flowww/G-DEV-500-COT-5-2-area-8/backend-area/run-area-execute.sh
```

### Étape 2 : Configurer le Cron Système

Ouvrez la configuration cron :

```bash
crontab -e
```

Ajoutez cette ligne :

```bash
* * * * * /home/the_flowww/G-DEV-500-COT-5-2-area-8/backend-area/run-area-execute.sh
```

**Explication :**
- `* * * * *` = Exécute chaque minute
- Le script appelé décide ensuite quelle(s) tâche(s) exécuter

### Étape 3 : Vérifier la Configuration

```bash
# Afficher les crons actuels
crontab -l

# Devrait afficher :
# * * * * * /home/the_flowww/G-DEV-500-COT-5-2-area-8/backend-area/run-area-execute.sh
```

---

## Vérification et Tests

### Test 1 : Exécuter la Commande Directement

```bash
cd /home/the_flowww/G-DEV-500-COT-5-2-area-8/backend-area

# Exécuter la commande AREA
php artisan areas:scheduled

# Devrait exécuter sans erreur
```

### Test 2 : Exécuter le Scheduler

```bash
cd /home/the_flowww/G-DEV-500-COT-5-2-area-8/backend-area

# Exécuter le scheduler
php artisan schedule:run

# Devrait afficher :
# Running ['artisan' areas:scheduled] .................. 162.44ms DONE
```

### Test 3 : Exécuter le Script Cron

```bash
bash /home/the_flowww/G-DEV-500-COT-5-2-area-8/backend-area/run-area-execute.sh

# Devrait exécuter sans erreur
```

### Test 4 : Attendre une Exécution Automatique

```bash
# Attendre ~1 minute et vérifier les logs
tail -f /home/the_flowww/G-DEV-500-COT-5-2-area-8/backend-area/storage/logs/area-scheduler.log

# Devrait afficher :
# 2025-12-07 14:50:08 Running ['artisan' areas:scheduled] ...... DONE
```

---

## 📊 Monitoring et Logging

### Logs du Scheduler

**Localisation : `backend-area/storage/logs/area-scheduler.log`**

```
2025-12-07 14:50:08 Running ['artisan' areas:scheduled] ............................................... 162.44ms DONE
⇂ '/home/the_flowww/.config/herd-lite/bin/php' 'artisan' areas:scheduled > '/dev/null' 2>&1
```

**Interpréter les logs :**
- `Running` = Tâche en cours d'exécution
- `162.44ms` = Temps d'exécution
- `DONE` = Exécution réussie

### Suivi en Temps Réel

```bash
# Afficher les logs en direct
tail -f /home/the_flowww/G-DEV-500-COT-5-2-area-8/backend-area/storage/logs/area-scheduler.log
```

---

## ⏰ Options de Fréquence

### Fréquences Prédéfinies

| Méthode | Fréquence |
|---------|-----------|
| `everyMinute()` | Chaque minute |
| `everyFiveMinutes()` | Toutes les 5 minutes |
| `everyTenMinutes()` | Toutes les 10 minutes |
| `everyFifteenMinutes()` | Toutes les 15 minutes |
| `everyThirtyMinutes()` | Toutes les 30 minutes |
| `hourly()` | Chaque heure |
| `daily()` | Chaque jour à minuit |
| `dailyAt('03:00')` | À une heure spécifique |
| `twiceDaily(1, 13)` | 2 fois par jour (1 AM, 1 PM) |
| `weekly()` | Chaque semaine |
| `monthly()` | Chaque mois le 1er |
| `yearly()` | Une fois par an |

---

## 🆘 Dépannage

### Problème : Le Cron Ne S'Exécute Pas

**Diagnostic :**

```bash
# 1. Vérifier que le cron existe
crontab -l | grep "run-area-execute"

# 2. Vérifier que le script est exécutable
ls -la /home/the_flowww/G-DEV-500-COT-5-2-area-8/backend-area/run-area-execute.sh

# 3. Tester le script manuellement
bash /home/the_flowww/G-DEV-500-COT-5-2-area-8/backend-area/run-area-execute.sh

# 4. Vérifier les logs cron du système
sudo journalctl -u cron --since "10 minutes ago"
```

### Problème : AREAs Ne S'Exécutent Pas

```bash
# Vérifier que les AREAs sont actives
mysql -u root area_db -e "SELECT id, name, is_active FROM areas;"

# Vérifier que l'utilisateur a un token Google (si besoin)
mysql -u root area_db -e "SELECT id, google_token FROM users;"
```

---

## 🚀 Configuration Avancée

### Ajouter du Logging Détaillé

```php
// Dans routes/console.php
Schedule::command('areas:scheduled')
    ->everyMinute()
    ->withoutOverlapping()
    ->onSuccess(function () {
        \Log::info('[AREA Scheduler] Exécution réussie - ' . now());
    })
    ->onFailure(function () {
        \Log::error('[AREA Scheduler] Erreur - ' . now());
    });
```

### Ajouter Plusieurs Tâches

```php
// Tâche 1 : Exécuter AREAs toutes les minutes
Schedule::command('areas:scheduled')
    ->everyMinute()
    ->withoutOverlapping();

// Tâche 2 : Nettoyer les vieux logs chaque jour
Schedule::command('logs:clear')
    ->daily()
    ->at('02:00');
```

---

## 📝 Commandes Utiles

```bash
# Afficher toutes les tâches programmées
php artisan schedule:list

# Exécuter le scheduler une fois
php artisan schedule:run

# Exécuter une commande spécifique
php artisan areas:scheduled

# Voir les logs
tail -f storage/logs/area-scheduler.log

# Vérifier la configuration cron
crontab -l
```

---

**Dernière mise à jour** : 7 décembre 2025  
**Version** : 2.0 (Laravel Scheduler)  
**Statut** : Production Ready
