import { defineStore } from 'pinia'
import { ref } from 'vue'
import { useAuthStore } from './auth'

export interface Service {
    id: number
    name: string
    description: string
    icon: string
    color: string
    category: string
    is_connected: boolean
    requires_auth: boolean
}

export interface ServiceTrigger {
    id: string
    name: string
    description: string
    config_schema: Record<string, any>
}

export interface ServiceAction {
    id: string
    name: string
    description: string
    config_schema: Record<string, any>
}

export interface ServiceDetails extends Service {
    triggers: ServiceTrigger[]
    actions: ServiceAction[]
}

export interface UserService {
    id: number
    service_id: number
    service_name: string
    connected_at: string
}

export const useServicesStore = defineStore('services', () => {
    const config = useRuntimeConfig()
    const apiBaseUrl = config.public.apiBase
    const authStore = useAuthStore()

    const services = ref<Service[]>([])
    const userServices = ref<UserService[]>([])
    const isLoading = ref(false)
    const error = ref<any>(null)

    // -----------------------------
    // Récupérer tous les services disponibles
    // -----------------------------
    async function fetchServices() {
        if (!authStore.token) {
            throw new Error('Non authentifié')
        }

        isLoading.value = true
        error.value = null

        try {
            const response = await $fetch<{ services: Service[] }>(
                `${apiBaseUrl}/api/services`,
                {
                    headers: {
                        'Authorization': `Bearer ${authStore.token}`,
                        'Accept': 'application/json',
                    },
                }
            )
            services.value = response.services
            return response.services
        } catch (e) {
            error.value = e
            console.error('Erreur lors de la récupération des services:', e)
            throw e
        } finally {
            isLoading.value = false
        }
    }

    // -----------------------------
    // Récupérer les détails d'un service
    // -----------------------------
    async function fetchServiceById(serviceId: number) {
        if (!authStore.token) {
            throw new Error('Non authentifié')
        }

        isLoading.value = true
        error.value = null

        try {
            const response = await $fetch<{ service: ServiceDetails }>(
                `${apiBaseUrl}/api/services/${serviceId}`,
                {
                    headers: {
                        'Authorization': `Bearer ${authStore.token}`,
                        'Accept': 'application/json',
                    },
                }
            )
            return response.service
        } catch (e) {
            error.value = e
            console.error('Erreur lors de la récupération des détails du service:', e)
            throw e
        } finally {
            isLoading.value = false
        }
    }

    // -----------------------------
    // Connecter un service via OAuth
    // -----------------------------
    async function connectService(serviceId: number, params?: {
        auth_code?: string
        access_token?: string
        refresh_token?: string
    }) {
        if (!authStore.token) {
            throw new Error('Non authentifié')
        }

        isLoading.value = true
        error.value = null

        try {
            const response = await $fetch<{
                message: string
                oauth_url?: string
                connection?: UserService
            }>(
                `${apiBaseUrl}/api/services/${serviceId}/connect`,
                {
                    method: 'POST',
                    headers: {
                        'Authorization': `Bearer ${authStore.token}`,
                        'Accept': 'application/json',
                        'Content-Type': 'application/json',
                    },
                    body: params || {},
                }
            )

            // Si une URL OAuth est retournée, rediriger l'utilisateur
            if (response.oauth_url) {
                window.location.href = response.oauth_url
            }

            // Si la connexion est établie, rafraîchir la liste
            if (response.connection) {
                await fetchUserServices()
            }

            return response
        } catch (e) {
            error.value = e
            console.error('Erreur lors de la connexion au service:', e)
            throw e
        } finally {
            isLoading.value = false
        }
    }

    // -----------------------------
    // Déconnecter un service
    // -----------------------------
    async function disconnectService(serviceId: number) {
        if (!authStore.token) {
            throw new Error('Non authentifié')
        }

        isLoading.value = true
        error.value = null

        try {
            const response = await $fetch<{ message: string }>(
                `${apiBaseUrl}/api/services/${serviceId}/disconnect`,
                {
                    method: 'DELETE',
                    headers: {
                        'Authorization': `Bearer ${authStore.token}`,
                        'Accept': 'application/json',
                    },
                }
            )

            // Rafraîchir les listes
            await Promise.all([
                fetchUserServices(),
                fetchServices()
            ])

            return response
        } catch (e) {
            error.value = e
            console.error('Erreur lors de la déconnexion du service:', e)
            throw e
        } finally {
            isLoading.value = false
        }
    }

    // -----------------------------
    // Récupérer les services connectés de l'utilisateur
    // -----------------------------
    async function fetchUserServices() {
        if (!authStore.token) {
            throw new Error('Non authentifié')
        }

        isLoading.value = true
        error.value = null

        try {
            const response = await $fetch<{ services: UserService[] }>(
                `${apiBaseUrl}/api/user/services`,
                {
                    headers: {
                        'Authorization': `Bearer ${authStore.token}`,
                        'Accept': 'application/json',
                    },
                }
            )
            userServices.value = response.services
            return response.services
        } catch (e) {
            error.value = e
            console.error('Erreur lors de la récupération des services utilisateur:', e)
            throw e
        } finally {
            isLoading.value = false
        }
    }

    // -----------------------------
    // Récupérer tous les services AVEC leurs détails (Triggers/Actions)
    // -----------------------------
    async function fetchServicesWithDetails() {
        if (!authStore.token) {
            throw new Error('Non authentifié')
        }

        isLoading.value = true
        error.value = null

        try {
            // 1. Récupérer la liste de base
            const baseServices = await fetchServices()

            // 2. Pour chaque service, récupérer les détails (Triggers/Actions) en parallèle
            const detailedServicesPromises = baseServices.map(async (service) => {
                try {
                    const details = await fetchServiceById(service.id)
                    return {
                        ...service,
                        triggers: details?.triggers?.map(t => ({
                            ...t,
                            fields: mapConfigToFields(t.config_schema)
                        })) || [],
                        actions: details?.actions?.map(a => ({
                            ...a,
                            fields: mapConfigToFields(a.config_schema)
                        })) || []
                    }
                } catch (e) {
                    console.error(`Impossible de charger les détails pour ${service.name}`, e)
                    return { ...service, triggers: [], actions: [] }
                }
            })

            const fullServices = await Promise.all(detailedServicesPromises)
            services.value = fullServices
            return fullServices

        } catch (e) {
            error.value = e
            console.error('Erreur lors de la récupération complète des services:', e)
            throw e
        } finally {
            isLoading.value = false
        }
    }

    // Helper: Convertir le schema Backend en champs Frontend
    function mapConfigToFields(schema: Record<string, any> | undefined) {
        if (!schema) return []

        return Object.entries(schema).map(([key, config]) => {
            let type = 'text'
            // Mapping des types Backend -> Frontend
            if (config.type === 'integer' || config.type === 'number') type = 'number'
            if (config.type === 'boolean') type = 'checkbox'
            if (config.type === 'datetime') type = 'datetime-local'
            if (key.includes('email')) type = 'email'
            if (key.includes('url')) type = 'url'
            if (key === 'body' || key === 'message' || key === 'description') type = 'textarea'
            if (key === 'time') type = 'time'
            
            // ✅ Support des champs enum (select dropdown)
            if (config.enum && Array.isArray(config.enum)) {
                type = 'select'
            }

            return {
                name: key,
                label: config.description || key.charAt(0).toUpperCase() + key.slice(1).replace(/_/g, ' '),
                type: type,
                required: config.required ?? false,
                placeholder: config.default ? String(config.default) : '',
                options: config.enum || [], // ✅ Ajouter les options pour les selects
            }
        })
    }

    return {
        services,
        userServices,
        isLoading,
        error,
        fetchServices,
        fetchServiceById,
        fetchServicesWithDetails,
        connectService,
        disconnectService,
        fetchUserServices,
    }
})
