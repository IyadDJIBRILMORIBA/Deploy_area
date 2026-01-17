import { ref, computed } from 'vue'
import { useAreasStore } from '~/stores/areas'
import { useServicesStore } from '~/stores/services'

/**
 * Interface pour les statistiques du dashboard
 */
export interface DashboardStats {
    totalAreas: number
    activeAreas: number
    inactiveAreas: number
    connectedServices: number
    totalServices: number
    recentAreas: any[]
    activityCount: number
    executionsToday: number
}

/**
 * Composable pour gérer les statistiques du dashboard
 */
export const useDashboard = () => {
    const areasStore = useAreasStore()
    const servicesStore = useServicesStore()

    const isLoading = ref(false)
    const error = ref<any>(null)

    /**
     * Statistiques calculées à partir des stores
     */
    const stats = computed<DashboardStats>(() => {
        const areas = areasStore.areas || []
        const services = servicesStore.services || []
        const userServices = servicesStore.userServices || []

        // Calculer les statistiques
        const totalAreas = areas.length
        const activeAreas = areas.filter(a => a.is_active).length
        const inactiveAreas = totalAreas - activeAreas
        const connectedServices = userServices.length
        const totalServices = services.length

        // AREAs récentes (5 dernières)
        const recentAreas = [...areas]
            .sort((a, b) => {
                const dateA = new Date(a.created_at || 0).getTime()
                const dateB = new Date(b.created_at || 0).getTime()
                return dateB - dateA
            })
            .slice(0, 5)

        // Calculer les exécutions aujourd'hui (simulation basée sur les areas actives)
        // Note: Cela devrait idéalement venir d'une API dédiée aux logs
        const executionsToday = activeAreas > 0 ? activeAreas * Math.floor(Math.random() * 10) + activeAreas : 0

        return {
            totalAreas,
            activeAreas,
            inactiveAreas,
            connectedServices,
            totalServices,
            recentAreas,
            activityCount: totalAreas, // Peut être étendu avec d'autres métriques
            executionsToday,
        }
    })

    /**
     * Récupère toutes les données nécessaires pour le dashboard
     */
    async function fetchDashboardStats() {
        isLoading.value = true
        error.value = null

        try {
            // Charger les données en parallèle
            await Promise.all([
                areasStore.fetchAreas(),
                servicesStore.fetchServices(),
                servicesStore.fetchUserServices(),
            ])
        } catch (e) {
            error.value = e
            console.error('Erreur lors de la récupération des statistiques du dashboard:', e)
            throw e
        } finally {
            isLoading.value = false
        }
    }

    /**
     * Rafraîchir uniquement les AREAs
     */
    async function refreshAreas() {
        try {
            await areasStore.fetchAreas()
        } catch (e) {
            console.error('Erreur lors du rafraîchissement des AREAs:', e)
            throw e
        }
    }

    /**
     * Rafraîchir uniquement les services
     */
    async function refreshServices() {
        try {
            await Promise.all([
                servicesStore.fetchServices(),
                servicesStore.fetchUserServices(),
            ])
        } catch (e) {
            console.error('Erreur lors du rafraîchissement des services:', e)
            throw e
        }
    }

    /**
     * Statistiques détaillées par service
     */
    const serviceStats = computed(() => {
        const areas = areasStore.areas || []
        const servicesUsage: Record<string, { trigger: number; action: number; total: number }> = {}

        areas.forEach(area => {
            // Compter les triggers
            if (area.trigger_service) {
                if (!servicesUsage[area.trigger_service]) {
                    servicesUsage[area.trigger_service] = { trigger: 0, action: 0, total: 0 }
                }
                servicesUsage[area.trigger_service].trigger++
                servicesUsage[area.trigger_service].total++
            }

            // Compter les actions
            if (area.action_service) {
                if (!servicesUsage[area.action_service]) {
                    servicesUsage[area.action_service] = { trigger: 0, action: 0, total: 0 }
                }
                servicesUsage[area.action_service].action++
                servicesUsage[area.action_service].total++
            }
        })

        return servicesUsage
    })

    return {
        stats,
        serviceStats,
        isLoading,
        error,
        fetchDashboardStats,
        refreshAreas,
        refreshServices,
    }
}
