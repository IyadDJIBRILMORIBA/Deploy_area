import { defineStore } from 'pinia'
import { ref, computed } from 'vue'

export interface User {
    id: number
    name: string
    email: string
    email_verified_at?: string
    google_id?: string
    created_at?: string
    updated_at?: string
}

export const useAuthStore = defineStore('auth', () => {
    const config = useRuntimeConfig()
    const apiBaseUrl = config.public.apiBase

    const user = ref<User | null>(null)
    const token = ref<string | null>(null)
    const events = ref<any[]>([])
    const isLoading = ref(false)
    const error = ref<any>(null)

    const isAuthenticated = computed(() => !!user.value)

    // Auto-initialisation du token depuis le cookie au démarrage
    if (process.client) {
        const match = document.cookie.match(/auth_token=([^;]+)/)
        if (match) {
            token.value = match[1]
            console.log('🔐 Token restauré depuis cookie')
        }
    }

    // -----------------------------
    // Initialisation du token depuis le cookie
    // -----------------------------
    function initToken() {
        if (process.client) {
            const match = document.cookie.match(/auth_token=([^;]+)/)
            if (match) {
                token.value = match[1]
            }
        }
    }

    // -----------------------------
    // Gestion du token via cookie
    // -----------------------------
    function setToken(t: string | null) {
        token.value = t
        if (process.client) {
            if (t) {
                document.cookie = `auth_token=${t}; path=/; max-age=${60 * 60 * 24}; SameSite=Lax`
            } else {
                document.cookie = `auth_token=; path=/; max-age=0`
            }
        }
    }

    // -----------------------------
    // Connexion avec email/password
    // -----------------------------
    async function login(credentials: { email: string; password: string }) {
        const response = await $fetch<{ access_token: string; user: User }>(
            `${apiBaseUrl}/api/login`,
            {
                method: 'POST',
                headers: {
                    'Accept': 'application/json',
                    'Content-Type': 'application/json'
                },
                body: credentials,
            }
        )

        setToken(response.access_token)
        user.value = response.user

        return response
    }

    // -----------------------------
    // Inscription
    // -----------------------------
    async function register(registrationData: {
        name: string
        email: string
        password: string
        role?: string
    }) {
        const response = await $fetch<{ message: string; access_token: string; user: User }>(`${apiBaseUrl}/api/register`, {
            method: 'POST',
            headers: {
                'Accept': 'application/json',
                'Content-Type': 'application/json'
            },
            body: {
                ...registrationData,
                password_confirmation: registrationData.password
            },
        })

        setToken(response.access_token)
        user.value = response.user

        return response
    }

    // -----------------------------
    // Récupérer l'utilisateur connecté via token
    // -----------------------------
    async function fetchUser() {
        if (!token.value) return

        try {
            const response = await $fetch<{ user: User }>(`${apiBaseUrl}/api/user`, {
                headers: {
                    Authorization: `Bearer ${token.value}`,
                    Accept: 'application/json',
                },
            })
            user.value = response.user
        } catch (error) {
            console.error("Erreur lors de la récupération de l'utilisateur:", error)
            setToken(null)
            user.value = null
        }
    }

    // -----------------------------
    // Vérifier si l'utilisateur est connecté (OAuth Google)
    // -----------------------------
    async function checkAuth() {
        try {
            console.log('🔐 CheckAuth - Token avant:', token.value ? `${token.value.substring(0, 20)}...` : 'AUCUN')
            
            if (!token.value) {
                console.warn('⚠️ Pas de token disponible')
                return false
            }
            
            const headers: Record<string,string> = {
                'Accept': 'application/json',
                'Authorization': `Bearer ${token.value}`
            }
            
            const response = await $fetch<{ user: User }>(`${apiBaseUrl}/api/user`, {
                headers
            })
            user.value = response.user
            console.log('✅ CheckAuth réussi - User:', response.user)
            return true
        } catch (e) {
            console.error('❌ CheckAuth échoué:', e)
            // Token invalide, on le supprime
            setToken(null)
            user.value = null
            return false
        }
    }

    // Récupérer les événements Google Calendar
    async function fetchCalendarEvents() {
        isLoading.value = true
        error.value = null

        const apiUrl = `${apiBaseUrl}/api/calendar-events`
        
        try {
            // Assurer que le token est initié avant la requête
            if (!token.value && process.client) {
                initToken()
            }

            console.log('🔍 Token actuel:', token.value ? `${token.value.substring(0, 20)}...` : 'AUCUN TOKEN')
            console.log('🍪 Cookies:', process.client ? document.cookie : 'N/A')

            const headers: Record<string,string> = {
                'Accept': 'application/json',
            }
            
            if (token.value) {
                headers['Authorization'] = `Bearer ${token.value}`
            } else {
                console.error('❌ AUCUN TOKEN - Impossible de faire la requête')
            }

            console.log('📤 Headers envoyés:', headers)

            const data = await $fetch<any>(apiUrl, {
                method: 'GET',
                headers,
                credentials: 'include'
            })
            events.value = data
            console.log('✅ Événements récupérés:', data)
        } catch (e) {
            error.value = e as any
            console.error('❌ Erreur lors de la récupération des événements:', e)
        } finally {
            isLoading.value = false
        }
    }

    // -----------------------------
    // Mise à jour du profil
    // -----------------------------
    async function updateProfile(data: { name?: string; email?: string }) {
        if (!token.value) {
            throw new Error('Non authentifié')
        }

        try {
            const response = await $fetch<{ user: User; message: string }>(
                `${apiBaseUrl}/api/user/update`,
                {
                    method: 'PUT',
                    headers: {
                        'Authorization': `Bearer ${token.value}`,
                        'Accept': 'application/json',
                        'Content-Type': 'application/json'
                    },
                    body: data,
                }
            )
            user.value = response.user
            return response
        } catch (e) {
            console.error('Erreur lors de la mise à jour du profil:', e)
            throw e
        }
    }

    // -----------------------------
    // Suppression du compte
    // -----------------------------
    async function deleteAccount() {
        if (!token.value) {
            throw new Error('Non authentifié')
        }

        try {
            await $fetch(`${apiBaseUrl}/api/user/delete`, {
                method: 'DELETE',
                headers: {
                    'Authorization': `Bearer ${token.value}`,
                    'Accept': 'application/json',
                },
            })
            
            // Nettoyer les données locales
            setToken(null)
            user.value = null
            events.value = []
            navigateTo('/login')
        } catch (e) {
            console.error('Erreur lors de la suppression du compte:', e)
            throw e
        }
    }

    // -----------------------------
    // OAuth Google (Web)
    // -----------------------------
    function redirectToGoogle() {
        window.location.href = `${apiBaseUrl}/auth/google/redirect`
    }

    // -----------------------------
    // Déconnexion
    // -----------------------------
    async function logout() {
        try {
            if (token.value) {
                await $fetch(`${apiBaseUrl}/api/logout`, {
                    method: 'POST',
                    headers: {
                        Authorization: `Bearer ${token.value}`,
                        Accept: 'application/json',
                    },
                })
            }
        } catch (e) {
            console.error('Erreur lors de la déconnexion:', e)
        } finally {
            setToken(null)
            user.value = null
            events.value = []
            navigateTo('/login')
        }
    }

    return {
        user,
        token,
        events,
        isLoading,
        error,
        isAuthenticated,
        initToken,
        setToken,
        login,
        register,
        fetchUser,
        updateProfile,
        deleteAccount,
        checkAuth,
        redirectToGoogle,
        fetchCalendarEvents,
        logout
    }
})
