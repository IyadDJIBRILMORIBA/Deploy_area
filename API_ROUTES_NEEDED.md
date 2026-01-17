# Routes API nécessaires pour l'application Flutter AREA

## Base URL
- **Development**: `http://192.168.100.6:8000`
- **Production**: À définir

---

## 🔐 Authentication Routes

### Google OAuth
- **POST** `/api/auth/google`
  - **Body**: `{ "idToken": "string" }`
  - **Response**: `{ "message": "string", "access_token": "string", "token": "string", "token_type": "Bearer", "user": { "id": int, "name": "string", "email": "string" } }`
  - **Utilisé dans**: `login_page.dart`

### Register
- **POST** `/api/register`
  - **Body**: `{ "name": "string", "email": "string", "password": "string" }`
  - **Response**: `{ "message": "string", "access_token": "string", "token_type": "Bearer", "user": { "id": int, "name": "string", "email": "string" } }`
  - **Utilisé dans**: `register_page.dart`

### Login
- **POST** `/api/login`
  - **Body**: `{ "email": "string", "password": "string" }`
  - **Response**: `{ "message": "string", "access_token": "string", "token_type": "Bearer", "user": { "id": int, "name": "string", "email": "string" } }`
  - **Utilisé dans**: `login_page.dart`

### Get User Info
- **GET** `/api/user`
  - **Headers**: `Authorization: Bearer {token}`
  - **Response**: `{ "id": int, "name": "string", "email": "string", "email_verified_at": "string|null", "created_at": "string" }`
  - **Utilisé dans**: `profile_page.dart`, `dashboard_page.dart`

### Logout
- **POST** `/api/logout`
  - **Headers**: `Authorization: Bearer {token}`
  - **Response**: `{ "message": "User logged out successfully" }`
  - **Utilisé dans**: `profile_page.dart`, `dashboard_page.dart`

---

## 📊 Dashboard Routes

### Get Dashboard Stats
- **GET** `/api/dashboard/stats`
  - **Headers**: `Authorization: Bearer {token}`
  - **Response**: 
    ```json
    {
      "totalAreas": int,
      "activeAreas": int,
      "totalExecutions": int,
      "successRate": float
    }
    ```
  - **Utilisé dans**: `dashboard_page.dart`

### Get Recent Activity (Dashboard)
- **GET** `/api/dashboard/recent-activity?limit=5`
  - **Headers**: `Authorization: Bearer {token}`
  - **Response**: 
    ```json
    {
      "activities": [
        {
          "id": int,
          "area_name": "string",
          "status": "string",
          "message": "string",
          "timestamp": "ISO8601 string",
          "is_success": boolean
        }
      ]
    }
    ```
  - **Utilisé dans**: `dashboard_page.dart`

---

## 🔗 AREA (Automation) Routes

### Get All User AREAs
- **GET** `/api/areas`
  - **Headers**: `Authorization: Bearer {token}`
  - **Query params**: `?search=string` (optional)
  - **Response**: 
    ```json
    {
      "areas": [
        {
          "id": "string",
          "name": "string",
          "description": "string",
          "trigger_service": "string",
          "trigger_name": "string",
          "trigger_config": {},
          "action_service": "string",
          "action_name": "string",
          "action_config": {},
          "is_active": boolean,
          "created_at": "ISO8601 string",
          "updated_at": "ISO8601 string"
        }
      ]
    }
    ```
  - **Utilisé dans**: `my_areas_page.dart`

### Create AREA
- **POST** `/api/areas`
  - **Headers**: `Authorization: Bearer {token}`
  - **Body**: 
    ```json
    {
      "name": "string",
      "description": "string",
      "trigger_service": "string",
      "trigger_name": "string",
      "trigger_config": {},
      "action_service": "string",
      "action_name": "string",
      "action_config": {}
    }
    ```
  - **Response**: `{ "message": "AREA created successfully", "area": {...} }`
  - **Utilisé dans**: Page de création (à venir)

### Get Single AREA
- **GET** `/api/areas/{id}`
  - **Headers**: `Authorization: Bearer {token}`
  - **Response**: `{ "area": {...} }`
  - **Utilisé dans**: Page d'édition (à venir)

### Update AREA
- **PUT** `/api/areas/{id}`
  - **Headers**: `Authorization: Bearer {token}`
  - **Body**: Même structure que POST
  - **Response**: `{ "message": "AREA updated successfully", "area": {...} }`
  - **Utilisé dans**: Page d'édition (à venir)

### Toggle AREA (Activate/Pause)
- **POST** `/api/areas/{id}/toggle`
  - **Headers**: `Authorization: Bearer {token}`
  - **Response**: `{ "message": "AREA status updated", "is_active": boolean }`
  - **Utilisé dans**: `my_areas_page.dart`

### Delete AREA
- **DELETE** `/api/areas/{id}`
  - **Headers**: `Authorization: Bearer {token}`
  - **Response**: `{ "message": "AREA deleted successfully" }`
  - **Utilisé dans**: `my_areas_page.dart`

---

## 📜 Activity/History Routes

### Get All Activities
- **GET** `/api/activities`
  - **Headers**: `Authorization: Bearer {token}`
  - **Query params**: 
    - `?filter=all|success|errors` (optional)
    - `?limit=50` (optional)
    - `?page=1` (optional)
  - **Response**: 
    ```json
    {
      "activities": [
        {
          "id": int,
          "area_id": "string",
          "area_name": "string",
          "status": "success|failed",
          "message": "string",
          "timestamp": "ISO8601 string",
          "is_success": boolean,
          "error_details": "string|null"
        }
      ],
      "pagination": {
        "current_page": int,
        "total_pages": int,
        "total_items": int
      }
    }
    ```
  - **Utilisé dans**: `activity_page.dart`

### Get Activity Details
- **GET** `/api/activities/{id}`
  - **Headers**: `Authorization: Bearer {token}`
  - **Response**: `{ "activity": {...} }`
  - **Utilisé dans**: Page de détails d'activité (à venir)

---

## 🔌 Services Routes

### Get Available Services
- **GET** `/api/services`
  - **Headers**: `Authorization: Bearer {token}` (optional si public)
  - **Response**: 
    ```json
    {
      "services": [
        {
          "id": "string",
          "name": "string",
          "description": "string",
          "icon": "string",
          "color": "string",
          "category": "string",
          "is_connected": boolean,
          "requires_auth": boolean
        }
      ]
    }
    ```
  - **Utilisé dans**: `services_page.dart`

### Get Service Details (Triggers & Actions)
- **GET** `/api/services/{serviceId}`
  - **Headers**: `Authorization: Bearer {token}`
  - **Response**: 
    ```json
    {
      "service": {
        "id": "string",
        "name": "string",
        "description": "string",
        "triggers": [
          {
            "id": "string",
            "name": "string",
            "description": "string",
            "config_schema": {}
          }
        ],
        "actions": [
          {
            "id": "string",
            "name": "string",
            "description": "string",
            "config_schema": {}
          }
        ]
      }
    }
    ```
  - **Utilisé dans**: Page de détails de service (à venir)

### Connect Service (OAuth)
- **POST** `/api/services/{serviceId}/connect`
  - **Headers**: `Authorization: Bearer {token}`
  - **Body**: `{ "auth_code": "string" }` (ou autres données OAuth)
  - **Response**: `{ "message": "Service connected successfully", "connection": {...} }`
  - **Utilisé dans**: `services_page.dart`

### Disconnect Service
- **DELETE** `/api/services/{serviceId}/disconnect`
  - **Headers**: `Authorization: Bearer {token}`
  - **Response**: `{ "message": "Service disconnected successfully" }`
  - **Utilisé dans**: `services_page.dart`

### Get User Connected Services
- **GET** `/api/user/services`
  - **Headers**: `Authorization: Bearer {token}`
  - **Response**: 
    ```json
    {
      "services": [
        {
          "service_id": "string",
          "service_name": "string",
          "connected_at": "ISO8601 string",
          "status": "active|expired"
        }
      ]
    }
    ```
  - **Utilisé dans**: `profile_page.dart`, `services_page.dart`

---

## 📅 Calendar Integration (Example)

### Get Calendar Events
- **GET** `/api/calendar-events`
  - **Headers**: `Authorization: Bearer {token}`
  - **Query params**: `?start_date=YYYY-MM-DD&end_date=YYYY-MM-DD`
  - **Response**: 
    ```json
    {
      "events": [
        {
          "id": "string",
          "title": "string",
          "start": "ISO8601 string",
          "end": "ISO8601 string",
          "description": "string"
        }
      ]
    }
    ```
  - **Utilisé dans**: Dashboard ou intégration Google Calendar

---

## 📝 Notes importantes

### Headers requis pour les routes authentifiées
```
Authorization: Bearer {access_token}
Content-Type: application/json
Accept: application/json
```

### Codes de réponse HTTP
- **200**: Succès
- **201**: Créé avec succès
- **400**: Erreur de validation
- **401**: Non authentifié
- **403**: Non autorisé
- **404**: Ressource non trouvée
- **422**: Erreur de validation (Laravel)
- **500**: Erreur serveur

### Format des erreurs
```json
{
  "error": "string",
  "message": "string",
  "errors": {
    "field": ["error message"]
  }
}
```

### Pagination standard
Pour les routes qui retournent des listes, utiliser:
- Query param: `?page=1&limit=20`
- Response include: `{ "pagination": { "current_page": 1, "total_pages": 5, "total_items": 100 } }`

---

## 🚀 Routes prioritaires à implémenter

### Phase 1 (Authentification) ✅
- [x] POST /api/auth/google
- [x] POST /api/register
- [x] POST /api/login
- [x] GET /api/user
- [x] POST /api/logout

### Phase 2 (Dashboard & AREAs) 🔄
- [ ] GET /api/dashboard/stats
- [ ] GET /api/dashboard/recent-activity
- [ ] GET /api/areas
- [ ] POST /api/areas
- [ ] POST /api/areas/{id}/toggle
- [ ] DELETE /api/areas/{id}

### Phase 3 (Activity & Services) 📋
- [ ] GET /api/activities
- [ ] GET /api/services
- [ ] GET /api/services/{serviceId}
- [ ] POST /api/services/{serviceId}/connect
- [ ] DELETE /api/services/{serviceId}/disconnect

### Phase 4 (Fonctionnalités avancées) 🎯
- [ ] PUT /api/areas/{id}
- [ ] GET /api/areas/{id}
- [ ] GET /api/user/services
- [ ] GET /api/activities/{id}

---

## 📱 Pages Flutter et leurs routes

| Page | Routes utilisées |
|------|------------------|
| `login_page.dart` | POST /api/login, POST /api/auth/google |
| `register_page.dart` | POST /api/register |
| `dashboard_page.dart` | GET /api/dashboard/stats, GET /api/dashboard/recent-activity, POST /api/logout |
| `my_areas_page.dart` | GET /api/areas, POST /api/areas/{id}/toggle, DELETE /api/areas/{id} |
| `activity_page.dart` | GET /api/activities |
| `services_page.dart` | GET /api/services, POST /api/services/{id}/connect, DELETE /api/services/{id}/disconnect |
| `profile_page.dart` | GET /api/user, GET /api/user/services, POST /api/logout |
| Create AREA (à venir) | POST /api/areas, GET /api/services/{id} |
| Edit AREA (à venir) | GET /api/areas/{id}, PUT /api/areas/{id} |
