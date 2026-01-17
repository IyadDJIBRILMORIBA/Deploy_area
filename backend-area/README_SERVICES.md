# 📖 Documentation Services AREA - Par Asaph

Salut Retys et Meryl ! 👋

Voici toute la doc pour utiliser mes services (Google, Timer, etc.) dans vos parties du projet.

---

## 📚 Documents Disponibles

### 🎯 Pour Retys (Moteur d'exécution)
**Fichier principal** : [`DOC_COMPLETE_POUR_BINOMES.md`](./DOC_COMPLETE_POUR_BINOMES.md)

**Section importante** : "Guide pour Retys (Moteur)"
- Comment récupérer les AREAs actives
- Comment exécuter le cycle Trigger → Reaction
- Code complet du moteur d'exécution
- Planification (cron, queue, boucle)

**Exemple de commande Artisan prête à l'emploi** fournie ! 🚀

---

### 🎨 Pour Meryl (Frontend/Mobile)
**Fichier principal** : [`DOC_COMPLETE_POUR_BINOMES.md`](./DOC_COMPLETE_POUR_BINOMES.md)

**Section importante** : "Guide pour Meryl (Frontend/Mobile)"
- Endpoints API disponibles
- Structure des réponses JSON
- Flow OAuth Google
- Suggestions UI/UX pour les pages Services et Créer AREA

---

### 🧪 Tests & Validation
**Fichier** : [`TESTS_GUIDE_ASAPH.md`](./TESTS_GUIDE_ASAPH.md)

**Scripts de test** :
```bash
# Test automatique rapide
php test_services.php

# Tests interactifs
php artisan tinker
# puis copier-coller les exemples du guide
```

---

### 📖 Guide Utilisateur
**Fichier** : [`docs/SERVICES_GUIDE.md`](./docs/SERVICES_GUIDE.md)

- Documentation complète de chaque service
- Exemples d'AREAs
- Troubleshooting
- Comment ajouter un nouveau service

---

## ⚡ Quick Start

### Pour Retys - Tester le moteur rapidement

```bash
cd backend-area
php artisan tinker
```

```php
// Créer une AREA de test
$user = App\Models\User::first();
$area = App\Models\Area::create([
    'user_id' => $user->id,
    'name' => 'Test Timer',
    'is_active' => true,
    'trigger_service' => 'timer',
    'trigger_action' => 'every_minute',
    'trigger_params' => json_encode([]),
    'action_service' => 'timer',
    'action_reaction' => 'log_info',
    'action_params' => json_encode(['message' => 'Ça marche !'])
]);

// Simuler l'exécution (ce que ton moteur fera)
$timer = new App\Services\TimerService();
$triggerData = $timer->checkTrigger('every_minute', [], $user);
$timer->executeReaction('log_info', ['message' => 'Ça marche !'], $user, $triggerData);

// Vérifier le log
exit;
```

```bash
tail storage/logs/laravel.log
# Tu devrais voir : [AREA Timer] Ça marche ! - Heure du trigger : ...
```

**Code complet du moteur** dans `DOC_COMPLETE_POUR_BINOMES.md` section "Guide pour Retys" ! 📖

---

### Pour Meryl - Tester l'API Services

```bash
cd backend-area
php artisan tinker
```

```php
// Vérifier les services disponibles
App\Models\Service::all(['id', 'name', 'icon'])->toArray();

// Vérifier si un user est connecté à Google
$user = App\Models\User::first();
App\Helpers\OAuthHelper::isUserConnectedToService($user, 'google');
```

**Endpoints à créer** détaillés dans `DOC_COMPLETE_POUR_BINOMES.md` section "Guide pour Meryl" ! 📖

---

## 🗂️ Structure des Fichiers Créés

```
backend-area/
├── DOC_COMPLETE_POUR_BINOMES.md    ← 🎯 COMMENCER ICI
├── README_SERVICES_ASAPH.md        ← Ce fichier
├── TESTS_GUIDE_ASAPH.md            ← Guide tests
├── test_services.php               ← Script test auto
│
├── app/
│   ├── Helpers/
│   │   └── OAuthHelper.php         ← Gestion tokens OAuth
│   └── Services/
│       ├── GoogleService.php       ← Gmail API
│       └── TimerService.php        ← Service simple
│
└── docs/
    └── SERVICES_GUIDE.md           ← Guide utilisateur
```

---

## ✅ Ce qui est Prêt

- ✅ **TimerService** - Fonctionne sans OAuth (parfait pour tester ton moteur, Retys)
- ✅ **GoogleService** - Gmail (Trigger: nouveaux emails, Reaction: envoyer email)
- ✅ **OAuthHelper** - Refresh automatique des tokens (tu n'as rien à gérer)
- ✅ **5 Services en BDD** - google, timer, github, slack, discord
- ✅ **Tests validés** - Tout fonctionne ! ✨

---

## 🚀 Prochaines Étapes

### Retys
1. Lire `DOC_COMPLETE_POUR_BINOMES.md` section "Guide pour Retys"
2. Créer la commande `php artisan area:execute`
3. Copier-coller le code du moteur fourni
4. Tester avec TimerService (pas besoin d'OAuth)

### Meryl
1. Lire `DOC_COMPLETE_POUR_BINOMES.md` section "Guide pour Meryl"
2. Créer l'endpoint `GET /api/services`
3. Créer l'endpoint `GET /api/user/services`
4. Intégrer OAuth Google dans le frontend/mobile

---

## ❓ Questions ?

- **Fichier principal** : `DOC_COMPLETE_POUR_BINOMES.md` (tout est dedans)
- **Tests** : `TESTS_GUIDE_ASAPH.md`
- **Guide utilisateur** : `docs/SERVICES_GUIDE.md`

**Cherchez pas plus loin, tout est documenté ! 😄**

---

**Bon courage à vous ! 💪🚀**

— Asaph
