# 🎯 Frontend - Guide d'Intégration Backend Complété

## ✅ Stores Créés

### 1. **auth.ts** - Authentification
- `login(credentials)` - Connexion email/password
- `register(data)` - Inscription
- `logout()` - Déconnexion
- `updateProfile(data)` - Mise à jour du profil
- `deleteAccount()` - Suppression du compte
- `redirectToGoogle()` - OAuth Google
- `checkAuth()` - Vérification de l'authentification
- `fetchUser()` - Récupération de l'utilisateur
- `fetchCalendarEvents()` - Événements Google Calendar

### 2. **services.ts** - Gestion des services
- `fetchServices()` - Liste tous les services (GET /api/services)
- `fetchServiceById(id)` - Détails d'un service (GET /api/services/{id})
- `connectService(id, params)` - Connecter un service (POST /api/services/{id}/connect)
- `disconnectService(id)` - Déconnecter un service (DELETE /api/services/{id}/disconnect)
- `fetchUserServices()` - Services de l'utilisateur (GET /api/user/services)

### 3. **areas.ts** - Gestion des AREAs
- `fetchAreas()` - Liste toutes les AREAs (GET /api/areas)
- `fetchAreaById(id)` - Détails d'une AREA (GET /api/areas/{id})
- `createArea(data)` - Créer une AREA (POST /api/areas)
- `updateArea(id, data)` - Modifier une AREA (PUT /api/areas/{id})
- `deleteArea(id)` - Supprimer une AREA (DELETE /api/areas/{id})
- `toggleArea(id)` - Activer/Désactiver (POST /api/areas/{id}/toggle)

## ✅ Composables Créés

### 1. **useApi.ts** - Utilitaire API
```typescript
const { apiCall, get, post, put, del } = useApi()

// Exemple
const data = await get<Service[]>('/api/services')
const result = await post('/api/areas', { name: 'Mon AREA' })
```

### 2. **useDashboard.ts** - Statistiques
```typescript
const { stats, fetchDashboardStats } = useDashboard()

// stats.value contient :
// - totalAreas
// - activeAreas
// - connectedServices
// - recentAreas
```

### 3. **useAbout.ts** - Informations serveur
```typescript
const { aboutData, fetchAbout, services } = useAbout()

await fetchAbout()
// aboutData.value = infos du endpoint /about.json
```

## ✅ Pages Mises à Jour

### 1. **/login** - Page de connexion
- Formulaire email/password
- Bouton OAuth Google
- Gestion des erreurs
- Redirection automatique

### 2. **/dashboard** - Tableau de bord
- Récupération automatique du token OAuth (query param)
- Vérification de l'authentification
- Chargement des statistiques
- Affichage des métriques

### 3. **/services** - Gestion des services
- Liste des services depuis le backend
- Connexion/Déconnexion avec le store
- Indicateurs de statut (connecté/non connecté)
- Gestion des erreurs

### 4. **/areas** - Liste des AREAs
- Affichage des AREAs depuis le backend
- Toggle actif/inactif avec `toggleArea()`
- Suppression avec `deleteArea()`
- Recherche/filtrage

### 5. **/areas/create** - Création d'AREA
- Sélection de services depuis le backend
- Actions et réactions dynamiques
- Création via `createArea()`
- Validation des champs

## ✅ Middleware

### **auth.js** - Protection des routes
- Vérification automatique de l'authentification
- Routes publiques : `/`, `/login`
- Redirection automatique vers `/login` si non authentifié
- Gestion du token OAuth dans l'URL

## 📝 Utilisation dans les Pages

### Exemple Dashboard
```vue
<script setup lang="ts">
const authStore = useAuthStore()
const { stats, fetchDashboardStats } = useDashboard()

onMounted(async () => {
  // Récupérer token OAuth si présent
  const route = useRoute()
  if (route.query.token) {
    authStore.setToken(route.query.token as string)
    router.replace('/dashboard')
  }
  
  // Charger les stats
  await fetchDashboardStats()
})
</script>

<template>
  <div>
    <h1>Dashboard</h1>
    <p>AREAs Actives: {{ stats.activeAreas }}</p>
    <p>Services: {{ stats.connectedServices }}</p>
  </div>
</template>
```

### Exemple Services
```vue
<script setup lang="ts">
const servicesStore = useServicesStore()

onMounted(async () => {
  await servicesStore.fetchServices()
})

const handleConnect = async (serviceId: number) => {
  await servicesStore.connectService(serviceId)
}
</script>

<template>
  <div v-for="service in servicesStore.services" :key="service.id">
    <button 
      v-if="!service.is_connected"
      @click="handleConnect(service.id)"
    >
      Connecter
    </button>
  </div>
</template>
```

## 🔄 Flux OAuth Google

1. Utilisateur clique sur "Se connecter avec Google"
2. `authStore.redirectToGoogle()` redirige vers `/auth/google/redirect`
3. Backend Laravel gère l'OAuth avec Google
4. Retour sur `/dashboard?token=xxxxx`
5. Middleware récupère le token et le sauvegarde
6. Dashboard charge les données

## 🎯 Prochaines Étapes

1. ✅ Tous les stores sont créés et fonctionnels
2. ✅ Tous les composables sont créés
3. ✅ Toutes les pages principales sont mises à jour
4. ✅ Middleware d'authentification est en place
5. ✅ Intégration complète avec le backend Laravel

**Le frontend est maintenant entièrement lié au backend ! 🚀**
