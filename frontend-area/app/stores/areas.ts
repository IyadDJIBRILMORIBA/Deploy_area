import { defineStore } from 'pinia'
import { ref } from 'vue'
import { useAuthStore } from './auth'

export interface Area {
    id: number
    user_id: number
    name: string
    trigger_service: string
    trigger_action: string
    trigger_params?: Record<string, any> | null
    action_service: string
    action_reaction: string
    action_params?: Record<string, any> | null
    is_active: boolean
    created_at?: string
    updated_at?: string
}

export interface CreateAreaData {
    name: string
    trigger_service: string
    trigger_action: string
    trigger_params?: Record<string, any>
    action_service: string
    action_reaction: string
    action_params?: Record<string, any>
}

export interface UpdateAreaData {
    name?: string
    trigger_service?: string
    trigger_action?: string
    trigger_params?: Record<string, any>
    action_service?: string
    action_reaction?: string
    action_params?: Record<string, any>
    is_active?: boolean
}

export const useAreasStore = defineStore('areas', () => {
    const config = useRuntimeConfig()
    const apiBaseUrl = config.public.apiBase
    const authStore = useAuthStore()

    const areas = ref<Area[]>([])
    const currentArea = ref<Area | null>(null)
    const isLoading = ref(false)
    const error = ref<any>(null)

    // -----------------------------
    // Récupérer toutes les AREAs de l'utilisateur
    // -----------------------------
    async function fetchAreas() {
        if (!authStore.token) {
            throw new Error('Non authentifié')
        }

        isLoading.value = true
        error.value = null

        try {
            const response = await $fetch<{ areas: Area[] }>(
                `${apiBaseUrl}/api/areas`,
                {
                    headers: {
                        'Authorization': `Bearer ${authStore.token}`,
                        'Accept': 'application/json',
                    },
                }
            )
            areas.value = response.areas
            return response.areas
        } catch (e) {
            error.value = e
            console.error('Erreur lors de la récupération des AREAs:', e)
            throw e
        } finally {
            isLoading.value = false
        }
    }

    // -----------------------------
    // Récupérer une AREA spécifique
    // -----------------------------
    async function fetchAreaById(id: number) {
        if (!authStore.token) {
            throw new Error('Non authentifié')
        }

        isLoading.value = true
        error.value = null

        try {
            const response = await $fetch<{ area: Area }>(
                `${apiBaseUrl}/api/areas/${id}`,
                {
                    headers: {
                        'Authorization': `Bearer ${authStore.token}`,
                        'Accept': 'application/json',
                    },
                }
            )
            currentArea.value = response.area
            return response.area
        } catch (e) {
            error.value = e
            console.error('Erreur lors de la récupération de l\'AREA:', e)
            throw e
        } finally {
            isLoading.value = false
        }
    }

    // -----------------------------
    // Créer une nouvelle AREA
    // -----------------------------
    async function createArea(data: CreateAreaData) {
        if (!authStore.token) {
            throw new Error('Non authentifié')
        }

        isLoading.value = true
        error.value = null

        try {
            const response = await $fetch<{ message: string; area: Area }>(
                `${apiBaseUrl}/api/areas`,
                {
                    method: 'POST',
                    headers: {
                        'Authorization': `Bearer ${authStore.token}`,
                        'Accept': 'application/json',
                        'Content-Type': 'application/json',
                    },
                    body: data,
                }
            )

            // Rafraîchir la liste des AREAs
            await fetchAreas()

            return response.area
        } catch (e) {
            error.value = e
            console.error('Erreur lors de la création de l\'AREA:', e)
            throw e
        } finally {
            isLoading.value = false
        }
    }

    // -----------------------------
    // Mettre à jour une AREA
    // -----------------------------
    async function updateArea(id: number, data: UpdateAreaData) {
        if (!authStore.token) {
            throw new Error('Non authentifié')
        }

        isLoading.value = true
        error.value = null

        try {
            const response = await $fetch<{ message: string; area: Area }>(
                `${apiBaseUrl}/api/areas/${id}`,
                {
                    method: 'PUT',
                    headers: {
                        'Authorization': `Bearer ${authStore.token}`,
                        'Accept': 'application/json',
                        'Content-Type': 'application/json',
                    },
                    body: data,
                }
            )

            // Mettre à jour l'AREA dans la liste
            const index = areas.value.findIndex(a => a.id === id)
            if (index !== -1) {
                areas.value[index] = response.area
            }

            // Mettre à jour currentArea si c'est celle-ci
            if (currentArea.value?.id === id) {
                currentArea.value = response.area
            }

            return response.area
        } catch (e) {
            error.value = e
            console.error('Erreur lors de la mise à jour de l\'AREA:', e)
            throw e
        } finally {
            isLoading.value = false
        }
    }

    // -----------------------------
    // Supprimer une AREA
    // -----------------------------
    async function deleteArea(id: number) {
        if (!authStore.token) {
            throw new Error('Non authentifié')
        }

        isLoading.value = true
        error.value = null

        try {
            const response = await $fetch<{ message: string }>(
                `${apiBaseUrl}/api/areas/${id}`,
                {
                    method: 'DELETE',
                    headers: {
                        'Authorization': `Bearer ${authStore.token}`,
                        'Accept': 'application/json',
                    },
                }
            )

            // Retirer l'AREA de la liste
            areas.value = areas.value.filter(a => a.id !== id)

            // Réinitialiser currentArea si c'était celle-ci
            if (currentArea.value?.id === id) {
                currentArea.value = null
            }

            return response
        } catch (e) {
            error.value = e
            console.error('Erreur lors de la suppression de l\'AREA:', e)
            throw e
        } finally {
            isLoading.value = false
        }
    }

    // -----------------------------
    // Activer/Désactiver une AREA
    // -----------------------------
    async function toggleArea(id: number) {
        if (!authStore.token) {
            throw new Error('Non authentifié')
        }

        isLoading.value = true
        error.value = null

        try {
            const response = await $fetch<{ message: string; is_active: boolean }>(
                `${apiBaseUrl}/api/areas/${id}/toggle`,
                {
                    method: 'POST',
                    headers: {
                        'Authorization': `Bearer ${authStore.token}`,
                        'Accept': 'application/json',
                    },
                }
            )

            // Mettre à jour le statut dans la liste
            const area = areas.value.find(a => a.id === id)
            if (area) {
                area.is_active = response.is_active
            }

            // Mettre à jour currentArea si c'est celle-ci
            if (currentArea.value?.id === id) {
                currentArea.value.is_active = response.is_active
            }

            return response
        } catch (e) {
            error.value = e
            console.error('Erreur lors du changement de statut de l\'AREA:', e)
            throw e
        } finally {
            isLoading.value = false
        }
    }

    return {
        areas,
        currentArea,
        isLoading,
        error,
        fetchAreas,
        fetchAreaById,
        createArea,
        updateArea,
        deleteArea,
        toggleArea,
    }
})
