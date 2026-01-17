# Documentation des Changements Apportés au Projet AREA

## Table des Matières
1. [Vue d'ensemble](#vue-densemble)
2. [Modifications Backend](#modifications-backend)
3. [Modifications Frontend](#modifications-frontend)
4. [Architecture Finale](#architecture-finale)
5. [Changelog Détaillé](#changelog-détaillé)

---

## Vue d'ensemble

Le projet AREA est une plateforme d'automatisation "If This Then That" (IFTTT) permettant de créer des automations basées sur :
- **Triggers (Déclencheurs)** : Gmail, Timer
- **Actions (Réactions)** : Envoyer un email via Gmail

### Pile Technologique
- **Backend** : Laravel 11, PHP 8.4.1, MySQL
- **Frontend** : Nuxt 3.x, Vue 3.5.24, Vite, TypeScript, Pinia
- **Authentification** : Google OAuth 2.0 (Sanctum Laravel)
- **Email** : Gmail API v1

---

## Modifications Backend

### 1. Services Implémentés

#### `app/Services/GoogleService.php`
**Modifications :**
- Implémenté `checkTrigger()` pour détecter les nouveaux emails
  - Accepte les triggers : `new_email`, `new_email_received`, `new_gmail_received`
  - Filtre par expéditeur (`from`) et contenu du sujet (`subject_contains`)
  - Retourne les données de l'email détecté
  
- Implémenté `executeReaction()` pour envoyer des emails
  - Authentification automatique avec rafraîchissement du token
  - Support des variables dynamiques (ex: `{trigger.subject}`)
  - Envoi via Gmail API avec signature de l'utilisateur

**Code clé :**
```php
// Triggers acceptés
if (!in_array($actionName, ['new_email', 'new_email_received', 'new_gmail_received'])) {
    return false;
}

// Filtrage Gmail
$query = 'is:unread';
if (!empty($params['from'])) {
    $query .= " from:{$params['from']}";
}
if (!empty($params['subject_contains'])) {
    $query .= " subject:{$params['subject_contains']}";
}
```

#### `app/Services/TimerService.php`
**Modifications :**
- Remplacement du code basique par une implémentation complète
- Support de 3 types de timers :
  - `every_minute` : S'exécute à chaque minute
  - `every_hour` : S'exécute à minute 00 de chaque heure
  - `every_day` : S'exécute à une heure spécifique (HH:MM)

**Code clé :**
```php
if ($actionName === 'every_minute') {
    return ['timestamp' => now()->toIso8601String(), ...];
}
if ($actionName === 'every_hour' && now()->minute === 0) {
    return ['timestamp' => now()->toIso8601String(), ...];
}
if ($actionName === 'every_day') {
    $targetTime = $params['time'] ?? '09:00';
    // Vérification de l'heure cible
}
```

### 2. Commandes Console

#### `app/Console/Commands/ExecuteAreas.php`
**Modifications :**
- Correction du passage de l'objet User complet au lieu du token string
- Simplification de la logique de vérification Google OAuth
- Décodage automatique des paramètres JSON
- Support des timers sans authentification Google

**Code clé :**
```php
// Avant : Passage du token string
$userToken = $user->google_token ?? null;
$triggerService->checkTrigger($area->trigger_action, $triggerParams, $userToken);

// Après : Passage de l'objet User complet
$needsGoogle = in_array($area->trigger_service, ['google', 'gmail']) 
            || in_array($area->action_service, ['google', 'gmail']);
if ($needsGoogle) {
    $user = $area->user;
}
$triggerService->checkTrigger($area->trigger_action, $triggerParams, $user);
```

### 3. Contrôleurs

#### `app/Http/Controllers/ServiceController.php`
**Modifications :**
- Correction du callback OAuth pour sauvegarder dans `user_services`
- Ajout des scopes Gmail requis (gmail.readonly, gmail.send)
- Synchronisation entre la table `users` et `user_services`

**Code clé :**
```php
// Sauvegarder à la fois dans users ET user_services
\DB::table('users')->where('id', $user->id)->update([
    'google_token' => $token['access_token'],
    'google_refresh_token' => $token['refresh_token']
]);

UserService::updateOrCreate(
    ['user_id' => $user->id, 'service_id' => $service->id],
    ['access_token' => $token['access_token'], 'refresh_token' => $token['refresh_token']]
);
```

### 4. Migration Supprimée
- `database/migrations/2025_12_07_140605_delete_timer_area.php`
  - Migration historique de suppression de l'AREA 4 (déjà exécutée)
  - Supprimée pour nettoyer le projet

---

## Modifications Frontend

### 1. Pages

#### `app/pages/areas/create.vue`
**Modifications :**
- Ajout du service Timer dans la liste des services disponibles
  - 3 options : Every Minute, Every Hour, Every Day
  - Champ de temps pour Every Day

- Suppression du code inutilisé :
  - Objet `form` (reactive) non utilisé
  - Computed `triggerServices`, `reactionServices`, `availableActions`, `availableReactions`

**Code clé :**
```javascript
// Nouveau service Timer ajouté
{
  id: 'timer',
  name: 'Timer',
  icon: '⏱️',
  triggers: [
    {
      id: 'every_minute',
      name: 'Every Minute',
      description: 'Triggers every minute',
      fields: []
    },
    {
      id: 'every_day',
      name: 'Every Day',
      description: 'Triggers every day at a specific time',
      fields: [
        { name: 'time', label: 'Time (HH:MM)', type: 'time', required: true, placeholder: '09:00' }
      ]
    }
  ],
  actions: []
}
```

## Architecture Finale

### Flux d'Exécution des AREAs

```
┌─────────────────────────────────────────────────────────────────┐
│                    Cron Job (Toutes les minutes)               │
│            /home/.../backend-area/run-area-execute.sh          │
└─────────────────────┬───────────────────────────────────────────┘
                      │
                      ▼
        ┌─────────────────────────────────────────┐
        │   php artisan area:execute              │
        │   (ExecuteAreas.php)                    │
        └────────────┬────────────────────────────┘
                     │
        ┌────────────▼────────────────────────────┐
        │  Récupérer toutes les AREAs actives    │
        │  (is_active = true)                     │
        └────────────┬────────────────────────────┘
                     │
     ┌───────────────┼───────────────┐
     │               │               │
     ▼               ▼               ▼
┌────────────┐ ┌────────────┐ ┌────────────┐
│  AREA 1    │ │  AREA 2    │ │  AREA N    │
│ Gmail Test │ │ Test Gmail2│ │ Timer...   │
└─────┬──────┘ └─────┬──────┘ └─────┬──────┘
      │              │              │
      ▼              ▼              ▼
  ┌─────────────────────────────────────┐
  │  checkTrigger()                     │
  │  - GoogleService::checkTrigger()   │
  │  - TimerService::checkTrigger()    │
  └────────┬────────────────────────────┘
           │
      ┌────▼─────┐
      │ Trigger  │
      │ Activé?  │
      └────┬─────┘
         ┌─┴─┐
       NON   OUI
         │    │
         │    ▼
         │  ┌──────────────────────┐
         │  │ executeReaction()    │
         │  │ - GoogleService::    │
         │  │   executeReaction()  │
         │  └──────────┬───────────┘
         │             │
         │             ▼
         │         ┌─────────────┐
         │         │ Email Sent  │
         │         │ ou autre...  │
         │         └─────────────┘
         │
         └──────────────────────────┘
              (Rien à signaler)
```

### Structure des Données AREA

```sql
CREATE TABLE areas (
  id INT PRIMARY KEY,
  user_id INT,
  name VARCHAR(255),
  
  -- Trigger
  trigger_service VARCHAR(50),      -- 'gmail', 'timer'
  trigger_action VARCHAR(50),        -- 'new_email', 'every_minute'
  trigger_params JSON,               -- {'from': '...', 'subject_contains': '...'}
  
  -- Action/Réaction
  action_service VARCHAR(50),        -- 'gmail'
  action_reaction VARCHAR(50),       -- 'send_email'
  action_params JSON,                -- {'to': '...', 'subject': '...', 'body': '...'}
  
  is_active BOOLEAN,
  created_at TIMESTAMP,
  updated_at TIMESTAMP
);
```

**Exemple d'AREA complète :**
```json
{
  "id": 1,
  "user_id": 2,
  "name": "gmail-test",
  "trigger_service": "gmail",
  "trigger_action": "new_email",
  "trigger_params": {
    "from": "florian.ahouangbe@epitech.eu",
    "subject_contains": "test"
  },
  "action_service": "gmail",
  "action_reaction": "send_email",
  "action_params": {
    "to": "florian.ahouangbe@epitech.eu",
    "subject": "test",
    "body": "blablabla blabla bla bla bla blabla"
  },
  "is_active": true
}
```

---

## Changelog Détaillé

### Phase 1 : Intégration OAuth Google
- [x] Implémentation de deux flux OAuth distincts
  - User Login : `/auth/google/redirect` → `/auth/google/callback`
  - Service Connection : `/api/services/1/connect` → `/api/services/google/callback`
- [x] Activation de Gmail API dans Google Cloud Console
- [x] Configuration des scopes : email, profile, gmail.readonly, gmail.send, calendar.readonly

### Phase 2 : Moteur d'Exécution AREA
- [x] Création de `ExecuteAreas.php`
- [x] Implémentation de `GoogleService.php`
- [x] Implémentation de `TimerService.php`
- [x] Gestion du rafraîchissement automatique du token Google
- [x] Support des logs détaillés dans `storage/logs/laravel.log`

### Phase 3 : Triggers et Actions
- [x] Trigger : Gmail - New Email Received
  - Support du filtrage par expéditeur
  - Support du filtrage par contenu du sujet
  - Retour des données de l'email détecté
  
- [x] Trigger : Timer
  - Every Minute
  - Every Hour
  - Every Day (à heure spécifique)

- [x] Action : Gmail - Send Email
  - Variables dynamiques du trigger
  - Signature avec l'email de l'utilisateur

### Phase 4 : Frontend - Création d'AREAs
- [x] Ajout du formulaire 4-step pour créer des AREAs
- [x] Support du Timer dans le formulaire

### Phase 5 : Automatisation
- [x] Création du script cron : `run-area-execute.sh`
- [x] Configuration du cron job pour exécution toutes les minutes
- [x] Logs séparés dans `storage/logs/area-cron.log`
- [x] Tests de validation du cron

### Phase 6 : Nettoyage
- [x] Suppression de la migration historique
- [x] Élimination du code dupliqué dans ExecuteAreas
- [x] Suppression des variables inutilisées dans create.vue

---

## 🔍 Tests Effectués

### Tests Manuels
- [x] Création d'une AREA Gmail → Gmail (gmail-test)
- [x] Création d'une AREA Timer → Gmail (timer-email-test)
- [x] Exécution manuelle : `php artisan area:execute`
- [x] Vérification du cron automatique toutes les minutes

### Résultats
```
Démarrage du moteur AREA...
Vérification de l'AREA ID: 1 (gmail-test)
  -> Trigger activé ! Exécution de la réaction...
  -> Réaction terminée.

Vérification de l'AREA ID: 7 (timy)
  -> Trigger activé ! Exécution de la réaction...
  -> Réaction terminée.
```

---

## Références

### Fichiers Modifiés
- Backend:
  - `app/Services/GoogleService.php`
  - `app/Services/TimerService.php`
  - `app/Console/Commands/ExecuteAreas.php`
  - `app/Http/Controllers/ServiceController.php`
  - `run-area-execute.sh` (nouveau)

- Frontend:
  - `app/pages/areas/create.vue`

- Configuration:
  - Cron système (crontab -e)

### Documentation Complète
- Voir `SETUP_CONFIGURATION.md` pour la configuration détaillée
- Voir `CRON_AUTOMATION.md` pour l'automatisation via cron

---
