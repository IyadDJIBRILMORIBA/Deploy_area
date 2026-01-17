# 📚 Documentation API AREA - Guide Équipe Frontend

## 🎯 Accès Rapide

### Documentation Interactive (Scribe)
- **URL locale**: http://localhost:8080/docs
- **Fichiers disponibles**:
  - `public/docs/index.html` - Documentation HTML complète
  - `public/docs/openapi.yaml` - Spécification OpenAPI 3.0.3
  - `public/docs/collection.json` - Collection Postman
  - `public/docs/postman-environment.json` - Template d'environnement Postman

---

## 🚀 Quick Start avec Postman

### 1. Importer la Collection Postman

1. Ouvrir Postman
2. Cliquer sur **Import** (en haut à gauche)
3. Sélectionner le fichier `backend-area/public/docs/collection.json`
4. La collection "AREA API Documentation" sera importée avec tous les endpoints

### 2. Configurer l'Environnement

1. Dans Postman, cliquer sur **Environments** (icône ⚙️)
2. Cliquer sur **Import**
3. Sélectionner `backend-area/public/docs/postman-environment.json`
4. Ou créer manuellement un environnement avec ces variables:
   ```
   BASE_URL: http://localhost:8080/api
   AUTH_TOKEN: (laisser vide, sera rempli automatiquement après login)
   ```

### 3. Obtenir un Token d'Authentification

#### Option A: Utiliser l'utilisateur de test (recommandé pour le développement)

Exécuter le seeder pour créer un utilisateur de test:
```bash
cd backend-area
php artisan db:seed --class=TestUserSeeder
```

Vous obtiendrez:
- **Email**: `test@area.com`
- **Password**: `password123`
- **Token Bearer**: (affiché dans le terminal)

#### Option B: Créer un nouvel utilisateur via l'API

1. Dans Postman, utiliser l'endpoint **POST /api/register**
2. Body:
   ```json
   {
     "name": "Votre Nom",
     "email": "votre@email.com",
     "password": "password123",
     "password_confirmation": "password123"
   }
   ```
3. Copier le `access_token` de la réponse
4. Le coller dans la variable d'environnement `AUTH_TOKEN`

---

## 📋 Endpoints Disponibles

### Authentication (Non authentifiés)

| Méthode | Endpoint | Description |
|---------|----------|-------------|
| POST | `/api/register` | Créer un nouveau compte utilisateur |
| POST | `/api/login` | Se connecter avec email/password |
| POST | `/api/auth/google` | Se connecter avec Google OAuth |

### User Management (Authentifiés)

| Méthode | Endpoint | Description |
|---------|----------|-------------|
| GET | `/api/user` | Récupérer les infos de l'utilisateur connecté |
| PUT | `/api/user/update` | Mettre à jour le profil |
| DELETE | `/api/user/delete` | Supprimer le compte |
| POST | `/api/logout` | Se déconnecter |

### Services (Authentifiés)

| Méthode | Endpoint | Description |
|---------|----------|-------------|
| GET | `/api/calendar-events` | Récupérer les événements Google Calendar |

### About (Non authentifié)

| Méthode | Endpoint | Description |
|---------|----------|-------------|
| GET | `/api/about.json` | Infos sur les services disponibles |

---

## 🔐 Utilisation de l'Authentification Bearer

Tous les endpoints marqués **[Authentifié]** nécessitent un header:
```
Authorization: Bearer {YOUR_TOKEN}
```

Dans Postman, la collection est préconfigurée pour utiliser automatiquement la variable `{{AUTH_TOKEN}}`.

### Workflow complet:

1. **Register ou Login** → Récupérer le `access_token`
2. **Définir AUTH_TOKEN** dans l'environnement Postman
3. **Utiliser les autres endpoints** → Le token sera automatiquement inclus

---

## 📝 Exemples de Requêtes

### 1. Register
```bash
POST http://localhost:8080/api/register
Content-Type: application/json

{
  "name": "John Doe",
  "email": "john@example.com",
  "password": "secret123",
  "password_confirmation": "secret123"
}
```

**Réponse (201)**:
```json
{
  "message": "User registered successfully",
  "access_token": "1|abcdefg...",
  "token_type": "Bearer",
  "user": {
    "id": 1,
    "name": "John Doe",
    "email": "john@example.com",
    "created_at": "2024-12-05T10:00:00.000000Z"
  }
}
```

### 2. Login
```bash
POST http://localhost:8080/api/login
Content-Type: application/json

{
  "email": "test@area.com",
  "password": "password123"
}
```

### 3. Get User Info
```bash
GET http://localhost:8080/api/user
Authorization: Bearer 1|abcdefg...
```

### 4. About.json
```bash
GET http://localhost:8080/api/about.json
```

**Réponse**: Liste des services disponibles avec leurs actions et réactions.

---

## 🛠️ Développement Local

### Lancer le Backend
```bash
cd backend-area
php artisan serve
# Serveur accessible sur http://localhost:8000
```

Ou via Docker:
```bash
docker-compose up server
# Serveur accessible sur http://localhost:8080
```

### Régénérer la Documentation
Après modification des annotations dans les contrôleurs:
```bash
cd backend-area
php artisan scribe:generate
```

---

## 🐛 Debugging & Erreurs Courantes

### Erreur 401 Unauthorized
- Vérifier que le token est bien présent dans le header `Authorization`
- Le format doit être: `Bearer {token}` (avec un espace)
- Le token peut expirer, refaire un login si nécessaire

### Erreur 422 Validation Failed
- Vérifier que tous les champs requis sont présents
- Vérifier le format des données (email valide, password min 6 caractères, etc.)

### Erreur 500 Server Error
- Vérifier les logs Laravel: `backend-area/storage/logs/laravel.log`
- Vérifier que la base de données est accessible
- Vérifier les variables d'environnement dans `.env`

---

## 📞 Contact & Support

Pour toute question concernant l'API:
- **Backend Lead**: Retys
- **Backend Dev**: Méryl (documentation API)
- **Backend Dev**: Asaph

---

## 📚 Ressources Additionnelles

- **Documentation Scribe complète**: https://scribe.knuckles.wtf/laravel
- **OpenAPI Spec**: `public/docs/openapi.yaml`
- **Postman Learning**: https://learning.postman.com/

---

## ✅ Checklist pour le Frontend

- [ ] Importer la collection Postman
- [ ] Configurer l'environnement avec BASE_URL
- [ ] Créer un utilisateur de test (seeder ou API)
- [ ] Tester le flow d'authentification complet
- [ ] Vérifier `/api/about.json` pour les services disponibles
- [ ] Implémenter la gestion du token (storage local/session)
- [ ] Gérer les erreurs 401 (redirection login)
- [ ] Tester tous les endpoints utilisés dans l'app

---

**Date de création**: 5 décembre 2024  
**Version de l'API**: 1.0  
**Dernière mise à jour**: 5 décembre 2024
