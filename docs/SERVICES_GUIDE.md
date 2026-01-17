# Guide d'Utilisation des Services AREA

##  Vue d'ensemble

Ce document explique comment utiliser les services implémentés dans le projet AREA.

---

## 🔧 Services Disponibles

### 1. **TimerService**

Service interne simple pour déclencher des actions basées sur le temps.

**Fichier** : `app/Services/TimerService.php`

#### Trigger : `every_minute`
- **Description** : Se déclenche toutes les minutes
- **Paramètres** : Aucun
- **Retour** : `['time' => '2025-12-06 14:30:00', 'timestamp' => 1733496600]`

#### Reaction : `log_info`
- **Description** : Écrit un message dans les logs Laravel
- **Paramètres** : 
  - `message` (string) : Le message à logger
- **Exemple** :
  ```json
  {
    "message": "Timer déclenché avec succès !"
  }
  ```

**Exemple d'AREA avec Timer** :
```
Trigger : Timer → every_minute
Reaction : Timer → log_info (message: "Une minute s'est écoulée")
```

---

### 2. **GoogleService**

Service tiers pour interagir avec Gmail.

**Fichier** : `app/Services/GoogleService.php`

#### Trigger : `new_gmail_received`
- **Description** : Détecte quand un nouvel email arrive dans Gmail
- **Paramètres** :
  - `last_email_id` (string, optionnel) : ID du dernier email traité
- **Retour** :
  ```json
  {
    "message_id": "18c5f8a3b2d1e4f0",
    "subject": "Réunion demain",
    "from": "john@example.com",
    "date": "Fri, 6 Dec 2025 14:30:00 +0100",
    "snippet": "Bonjour, je vous écris pour..."
  }
  ```

#### Reaction : `send_email`
- **Description** : Envoie un email via Gmail
- **Paramètres** :
  - `to` (string, requis) : Adresse email du destinataire
  - `subject` (string, requis) : Sujet de l'email
  - `body` (string, requis) : Corps de l'email (HTML accepté)
- **Variables dynamiques** : Vous pouvez utiliser `{trigger.xxx}` dans subject/body
  ```json
  {
    "to": "reply@example.com",
    "subject": "Re: {trigger.subject}",
    "body": "Vous avez reçu un email de {trigger.from} avec le sujet : {trigger.subject}"
  }
  ```

**Exemple d'AREA avec Google** :
```
Trigger : Google → new_gmail_received
Reaction : Google → send_email (to: "backup@example.com", subject: "Copie: {trigger.subject}", body: "Email reçu de {trigger.from}")
```

---

## Gestion des Tokens OAuth (OAuthHelper)

**Fichier** : `app/Helpers/OAuthHelper.php`

### Méthode : `getValidGoogleClient(User $user)`

Cette méthode s'occupe automatiquement de :
1. Récupérer le token Google de l'utilisateur
2. Vérifier s'il est expiré
3. Le rafraîchir automatiquement si nécessaire
4. Mettre à jour la base de données
5. Retourner un client Google prêt à l'emploi

**Avantages** :
- Pas besoin de gérer manuellement le refresh dans chaque service
- Gestion centralisée des erreurs
- Logs automatiques pour le debugging

**Utilisation dans un service** :
```php
use App\Helpers\OAuthHelper;

public function checkTrigger(string $actionName, array $params, $userToken)
{
    try {
        $client = OAuthHelper::getValidGoogleClient($userToken);
        // Utiliser le client pour appeler l'API Google
    } catch (\Exception $e) {
        Log::error("Erreur OAuth : " . $e->getMessage());
        return false;
    }
}
```

---

## Comment Tester

### Prérequis
1. Avoir un compte Gmail de test
2. Avoir configuré les clés OAuth Google dans `.env` :
   ```env
   GOOGLE_CLIENT_ID=xxx
   GOOGLE_CLIENT_SECRET=xxx
   GOOGLE_REDIRECT_URI=http://localhost:8080/auth/google/callback
   ```
3. Avoir seedé la base de données : `php artisan db:seed`

### Test 1 : TimerService
```bash
# Créer une AREA via l'API ou la BDD
POST /api/areas
{
  "name": "Test Timer",
  "trigger_service": "timer",
  "trigger_action": "every_minute",
  "trigger_params": {},
  "action_service": "timer",
  "action_reaction": "log_info",
  "action_params": {
    "message": "Timer test réussi !"
  }
}

# Lancer le moteur de Retys pour exécuter les AREAs
# Vérifier les logs : storage/logs/laravel.log
tail -f storage/logs/laravel.log | grep "AREA Timer"
```

### Test 2 : GoogleService - NewGmailReceived
```bash
# 1. L'utilisateur doit d'abord se connecter à Google via OAuth
# 2. Créer une AREA
POST /api/areas
{
  "name": "Gmail → Log",
  "trigger_service": "google",
  "trigger_action": "new_gmail_received",
  "trigger_params": {},
  "action_service": "timer",
  "action_reaction": "log_info",
  "action_params": {
    "message": "Nouveau Gmail reçu : {trigger.subject}"
  }
}

# 3. Envoyer un email à votre compte Gmail de test
# 4. Lancer le moteur de Retys
# 5. Vérifier les logs
tail -f storage/logs/laravel.log | grep "GoogleService"
```

### Test 3 : GoogleService - SendEmail
```bash
POST /api/areas
{
  "name": "Gmail → Send Reply",
  "trigger_service": "google",
  "trigger_action": "new_gmail_received",
  "trigger_params": {},
  "action_service": "google",
  "action_reaction": "send_email",
  "action_params": {
    "to": "test@example.com",
    "subject": "Auto-reply: {trigger.subject}",
    "body": "Merci pour votre email. Reçu de {trigger.from} le {trigger.date}"
  }
}
```

---

## 🔧 Dépannage

### Erreur : "Service Google non trouvé"
**Solution** : Lancez `php artisan db:seed` pour créer les services en BDD

### Erreur : "Token expiré et aucun refresh_token disponible"
**Solution** : L'utilisateur doit se reconnecter via OAuth Google. Assurez-vous que le flow OAuth demande `access_type=offline` et `prompt=consent`

### Erreur : "Invalid grant" lors du refresh
**Solution** : Le refresh_token peut être révoqué. L'utilisateur doit se reconnecter.

### Emails non détectés
**Solution** : 
- Vérifiez que l'email est bien dans INBOX
- Vérifiez les scopes OAuth (besoin de `https://www.googleapis.com/auth/gmail.readonly`)
- Vérifiez les logs : `tail -f storage/logs/laravel.log | grep GoogleService`

---

## Notes pour les Développeurs

### Ajouter un nouveau Service

1. Créer une classe qui implémente `ServiceInterface`
2. Implémenter `checkTrigger()` et `executeReaction()`
3. Pour les services OAuth, utiliser `OAuthHelper` pour la gestion des tokens
4. Ajouter des logs pour le debugging
5. Documenter dans ce fichier

### Bonnes Pratiques

- Toujours logger les erreurs avec `Log::error()`
- Toujours logger les succès importants avec `Log::info()`
- Gérer les exceptions avec try/catch
- Retourner `false` en cas d'erreur dans `checkTrigger()`
- Retourner `false` en cas d'erreur dans `executeReaction()`
- Utiliser des variables dynamiques `{trigger.xxx}` pour la flexibilité

---

## Prochaines Étapes

- [ ] Ajouter Discord Service
- [ ] Ajouter GitHub Service
- [ ] Ajouter Spotify Service
- [ ] Implémenter un système de retry en cas d'échec
- [ ] Ajouter des tests unitaires pour chaque service

---

**Créé par : Asaph (Intégrateur Services & OAuth)**  
**Date : 6 Décembre 2025**
