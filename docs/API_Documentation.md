# Documentation API AREA 

## Travail Complété

### Ce qui a été fait

1. **Installation et Configuration de Scribe**
   - Package `knuckleswtf/scribe` installé (version 5.6.0)
   - Configuration complète dans `config/scribe.php`
   - Support Bearer token activé
   - Export Postman et OpenAPI activés

2. **Annotation de tous les endpoints**
   - **Authentication** (6 endpoints)
     - POST `/api/register` - Inscription
     - POST `/api/login` - Connexion email/password
     - POST `/api/auth/google` - OAuth Google
     - GET `/api/user` - Infos utilisateur
     - PUT `/api/user/update` - Mise à jour profil
     - DELETE `/api/user/delete` - Suppression compte
     - POST `/api/logout` - Déconnexion
   
   - **Services** (1 endpoint)
     - GET `/api/calendar-events` - Événements Google Calendar
   
   - **About** (1 endpoint - NOUVEAU)
     - GET `/api/about.json` - Métadonnées du serveur et services

3. **Génération de la Documentation**
   - Documentation HTML interactive (`public/docs/index.html`)
   - Spécification OpenAPI 3.0.3 (`public/docs/openapi.yaml`)
   - Collection Postman complète (`public/docs/collection.json`)
   - Template d'environnement Postman (`public/docs/postman-environment.json`)

4. **Outils pour le Frontend**
   - Seeder `TestUserSeeder` pour créer un utilisateur de test
   - Guide complet `API_DOCUMENTATION.md`
   - Variables d'environnement Postman préconfigurées

5. **Git & Versioning**
   - Branche `docs-api` créée et pushée
   - Commit propre avec message descriptif
   - Prêt pour une Pull Request vers `dev`

---

## Accès aux Ressources

### Documentation Web
- **URL locale**: http://localhost:8080/docs
- **Fichier**: `backend-area/public/docs/index.html`

### Postman
- **Collection**: `backend-area/public/docs/collection.json`
- **Environnement**: `backend-area/public/docs/postman-environment.json`

### OpenAPI
- **Spec YAML**: `backend-area/public/docs/openapi.yaml`

### Guide Équipe Frontend
- **README complet**: `backend-area/API_DOCUMENTATION.md`

---

## Quick Start pour l'Équipe Frontend

### 1. Créer un utilisateur de test
```bash
cd backend-area
php artisan db:seed --class=TestUserSeeder
```

Credentials:
- Email: `test@area.com`
- Password: `password123`
- Token affiché dans le terminal

### 2. Importer dans Postman
1. Importer `backend-area/public/docs/collection.json`
2. Importer `backend-area/public/docs/postman-environment.json`
3. Sélectionner l'environnement "AREA Backend - Local"
4. Tester les endpoints !

### 3. Consulter la doc interactive
```bash
# Lancer le serveur Laravel
php artisan serve

# Ouvrir dans le navigateur
http://localhost:8000/docs
```

---

## Endpoints Documentés

| Groupe | Endpoints | Statut |
|--------|-----------|--------|
| **Authentication** | 7 endpoints | Documenté |
| **Services** | 1 endpoint (Calendar) | Documenté |
| **About** | 1 endpoint | Documenté |
| **AREA CRUD** | À venir | ⏳ Pas encore implémenté |
| **Services Management** | À venir | ⏳ Pas encore implémenté |

> **Note**: Les endpoints AREA CRUD et Services Management ne sont pas encore implémentés côté backend. Ils seront documentés automatiquement dès leur création grâce aux annotations Scribe.

---

## Prochaines Étapes

### Pour le Backend
1. Merger la branche `docs-api` vers `dev`
2. Implémenter les endpoints AREA CRUD (list, create, update, delete, toggle)
3. Implémenter les endpoints Services (list, connect, disconnect)
4. Annoter ces nouveaux endpoints avec Scribe
5. Régénérer la doc: `php artisan scribe:generate`

### Pour le Frontend
1. Importer la collection Postman
2. Tester le flow d'authentification complet
3. Implémenter la gestion du token (localStorage/sessionStorage)
4. Intégrer les endpoints disponibles dans les pages Flutter/Nuxt
5. Préparer les UI pour les endpoints à venir (AREA, Services)

---

## Contact

**Questions sur la documentation API ?**
- Backend Lead: Retys
- Documentation API: Méryl
- Backend Dev: Asaph

---

