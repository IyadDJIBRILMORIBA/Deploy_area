import { useAuthStore } from '~/stores/auth'

/**
 * Composable pour gérer les appels API avec authentification automatique
 * Ajoute automatiquement le token Bearer aux requêtes
 */
export const useApi = () => {
    const config = useRuntimeConfig()
    const apiBaseUrl = config.public.apiBase
    const authStore = useAuthStore()

    /**
     * Effectue un appel API avec gestion automatique du token
     * @param endpoint - L'endpoint API (ex: '/api/services')
     * @param options - Options de fetch (method, body, etc.)
     * @returns La réponse de l'API
     */
    async function apiCall<T>(
        endpoint: string,
        options?: {
            method?: 'GET' | 'POST' | 'PUT' | 'DELETE' | 'PATCH'
            body?: any
            headers?: Record<string, string>
            requiresAuth?: boolean
        }
    ): Promise<T> {
        const {
            method = 'GET',
            body,
            headers = {},
            requiresAuth = true
        } = options || {}

        // Construction des headers
        const requestHeaders: Record<string, string> = {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            ...headers,
        }

        // Ajouter le token Bearer si l'authentification est requise
        if (requiresAuth) {
            if (!authStore.token) {
                throw new Error('Non authentifié - Token manquant')
            }
            requestHeaders['Authorization'] = `Bearer ${authStore.token}`
        }

        // Construction de l'URL complète
        const url = endpoint.startsWith('http') 
            ? endpoint 
            : `${apiBaseUrl}${endpoint}`

        try {
            const response = await $fetch<T>(url, {
                method,
                headers: requestHeaders,
                body: body ? JSON.stringify(body) : undefined,
            })

            return response
        } catch (error: any) {
            // Gestion des erreurs d'authentification
            if (error?.response?.status === 401) {
                // Token invalide ou expiré - rediriger vers login
                authStore.setToken(null)
                authStore.user = null
                navigateTo('/login')
            }

            console.error('Erreur API:', error)
            throw error
        }
    }

    /**
     * Raccourci pour GET
     */
    async function get<T>(endpoint: string, options?: { requiresAuth?: boolean }): Promise<T> {
        return apiCall<T>(endpoint, { method: 'GET', ...options })
    }

    /**
     * Raccourci pour POST
     */
    async function post<T>(endpoint: string, body?: any, options?: { requiresAuth?: boolean }): Promise<T> {
        return apiCall<T>(endpoint, { method: 'POST', body, ...options })
    }

    /**
     * Raccourci pour PUT
     */
    async function put<T>(endpoint: string, body?: any, options?: { requiresAuth?: boolean }): Promise<T> {
        return apiCall<T>(endpoint, { method: 'PUT', body, ...options })
    }

    /**
     * Raccourci pour DELETE
     */
    async function del<T>(endpoint: string, options?: { requiresAuth?: boolean }): Promise<T> {
        return apiCall<T>(endpoint, { method: 'DELETE', ...options })
    }

    /**
     * Raccourci pour PATCH
     */
    async function patch<T>(endpoint: string, body?: any, options?: { requiresAuth?: boolean }): Promise<T> {
        return apiCall<T>(endpoint, { method: 'PATCH', body, ...options })
    }

    return {
        apiCall,
        get,
        post,
        put,
        del,
        patch,
    }
}
