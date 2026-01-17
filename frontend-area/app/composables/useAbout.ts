import { ref } from 'vue'

/**
 * Interface pour les données /about.json
 */
export interface AboutData {
    client: {
        host: string
    }
    server: {
        current_time: number
        services: AboutService[]
    }
}

export interface AboutService {
    name: string
    actions: AboutAction[]
    reactions: AboutReaction[]
}

export interface AboutAction {
    name: string
    description: string
}

export interface AboutReaction {
    name: string
    description: string
}

/**
 * Composable pour récupérer les informations du serveur via /about.json
 */
export const useAbout = () => {
    const config = useRuntimeConfig()
    const apiBaseUrl = config.public.apiBase

    const aboutData = ref<AboutData | null>(null)
    const isLoading = ref(false)
    const error = ref<any>(null)

    /**
     * Récupère les informations du endpoint /about.json
     * Ce endpoint est public et ne nécessite pas d'authentification
     */
    async function fetchAbout() {
        isLoading.value = true
        error.value = null

        try {
            const response = await $fetch<AboutData>(`${apiBaseUrl}/api/about.json`, {
                method: 'GET',
                headers: {
                    'Accept': 'application/json',
                },
            })

            aboutData.value = response
            return response
        } catch (e) {
            error.value = e
            console.error('Erreur lors de la récupération des informations about.json:', e)
            throw e
        } finally {
            isLoading.value = false
        }
    }

    /**
     * Récupère la liste des services disponibles depuis about.json
     */
    const services = computed(() => {
        return aboutData.value?.server?.services || []
    })

    /**
     * Récupère le timestamp du serveur
     */
    const serverTime = computed(() => {
        return aboutData.value?.server?.current_time || 0
    })

    /**
     * Récupère l'hôte du client
     */
    const clientHost = computed(() => {
        return aboutData.value?.client?.host || ''
    })

    /**
     * Trouve un service par nom
     */
    function getServiceByName(serviceName: string): AboutService | undefined {
        return services.value.find(s => s.name === serviceName)
    }

    /**
     * Récupère toutes les actions disponibles pour un service
     */
    function getServiceActions(serviceName: string): AboutAction[] {
        const service = getServiceByName(serviceName)
        return service?.actions || []
    }

    /**
     * Récupère toutes les réactions disponibles pour un service
     */
    function getServiceReactions(serviceName: string): AboutReaction[] {
        const service = getServiceByName(serviceName)
        return service?.reactions || []
    }

    /**
     * Compte le nombre total d'actions disponibles
     */
    const totalActions = computed(() => {
        return services.value.reduce((total, service) => {
            return total + (service.actions?.length || 0)
        }, 0)
    })

    /**
     * Compte le nombre total de réactions disponibles
     */
    const totalReactions = computed(() => {
        return services.value.reduce((total, service) => {
            return total + (service.reactions?.length || 0)
        }, 0)
    })

    return {
        aboutData,
        isLoading,
        error,
        services,
        serverTime,
        clientHost,
        totalActions,
        totalReactions,
        fetchAbout,
        getServiceByName,
        getServiceActions,
        getServiceReactions,
    }
}
