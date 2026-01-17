// Middleware pour protéger les routes qui nécessitent une authentification
export default defineNuxtRouteMiddleware(async (to, from) => {
  // Désactiver côté serveur (SSR) car on a besoin des cookies
  if (import.meta.server) {
    return
  }

  const authStore = useAuthStore()

  console.log('🛣️ Middleware Auth - Route:', to.path)
  console.log('🔗 Query params:', to.query)

  // Ingestion éventuelle du token avant vérification (retour OAuth)
  if (to.query && to.query.token && typeof to.query.token === 'string') {
    console.log('📥 Token trouvé dans l\'URL:', to.query.token.substring(0, 20) + '...')
    authStore.setToken(to.query.token)
  }

  // Initialiser le token depuis les cookies si présent
  authStore.initToken()
  console.log('🔑 Token après init:', authStore.token ? authStore.token.substring(0, 20) + '...' : 'AUCUN')

  // Vérifier si l'utilisateur est authentifié (token ou session)
  const isAuth = await authStore.checkAuth()
  console.log('🔐 IsAuth:', isAuth)
  
  // Routes publiques autorisées sans auth
  const publicRoutes = ['/login', '/', '/auth/google/redirect', '/auth/google/callback']

  // Si pas authentifié et route privée => rediriger
  if (!isAuth && !publicRoutes.includes(to.path)) {
    console.log('🚫 Non authentifié - Redirection vers /login')
    return navigateTo('/login')
  }
})
