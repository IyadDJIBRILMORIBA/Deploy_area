<script setup lang="ts">
import { ref, computed } from 'vue'
import { useAuthStore } from '~/stores/auth'
import { useAreasStore } from '~/stores/areas'
import { ChartBarIcon, BoltIcon, Square3Stack3DIcon, ClipboardDocumentListIcon, ArrowRightOnRectangleIcon } from '@heroicons/vue/24/outline'

const authStore = useAuthStore()
const areasStore = useAreasStore()
const searchQuery = ref('')

onMounted(async () => {
  await areasStore.fetchAreas()
})

const handleToggle = async (areaId: number) => {
  try {
    await areasStore.toggleArea(areaId)
  } catch (error) {
    console.error('Erreur toggle AREA:', error)
    alert('Erreur lors du changement de statut')
  }
}

const handleDelete = async (areaId: number) => {
  if (confirm('Supprimer cette AREA ?')) {
    try {
      await areasStore.deleteArea(areaId)
    } catch (error) {
      console.error('Erreur suppression AREA:', error)
      alert('Erreur lors de la suppression')
    }
  }
}

const logout = () => { 
  authStore.logout() 
  navigateTo('/login') 
}

// Filtre de recherche
const filteredAreas = computed(() => {
  if (!searchQuery.value) return areasStore.areas
  
  return areasStore.areas.filter((a: any) => 
    a.name.toLowerCase().includes(searchQuery.value.toLowerCase()) ||
    a.trigger_service.toLowerCase().includes(searchQuery.value.toLowerCase()) ||
    a.action_service.toLowerCase().includes(searchQuery.value.toLowerCase())
  )
})

const getServiceIcon = (name: string) => {
  const icons: Record<string, string> = {
    'Gmail': '🔵', 'GitHub': '⚫', 'Weather': '⛅', 'Discord': '🟣', 'Trello': '🟦', 'Sms': '📱'
  }
  return icons[name] || '🔌'
}
</script>

<template>
  <div class="flex h-screen w-full bg-[#F3F4F6] font-sans text-slate-800 overflow-hidden">
    
    <!-- SIDEBAR (Même que Dashboard) -->
    <aside class="w-64 hidden md:flex flex-col bg-white border-r border-gray-200 z-20">
      
      <!-- Logo -->
      <div class="h-16 flex items-center px-6 border-b border-gray-100">
        <div class="flex items-center gap-2">
          <div class="w-8 h-8 rounded-lg bg-blue-600 flex items-center justify-center text-white font-bold shadow-sm shadow-blue-200">
            A
          </div>
          <span class="text-xl font-bold text-gray-800 tracking-tight">AREA</span>
        </div>
      </div>

      <!-- Navigation -->
      <nav class="flex-1 px-3 py-6 space-y-1">
        <NuxtLink to="/dashboard" class="flex items-center px-3 py-2.5 rounded-lg text-gray-500 hover:bg-gray-50 hover:text-gray-900 font-medium transition-all group">
          <div class="w-6 h-6 p-1 rounded-md bg-blue-50 flex items-center justify-center mr-3">
            <ChartBarIcon class="w-4 h-4 text-blue-500" />
          </div>
          Dashboard
        </NuxtLink>

        <!-- Menu Actif (Bleu) -->
        <NuxtLink to="/areas" class="flex items-center px-3 py-2.5 rounded-lg bg-blue-50 text-blue-700 font-semibold transition-all group relative">
          <div class="absolute left-0 top-1 bottom-1 w-1 bg-blue-600 rounded-r-full"></div>
          <div class="w-6 h-6 p-1 rounded-md bg-purple-50 flex items-center justify-center mr-3">
            <BoltIcon class="w-4 h-4 text-purple-600" />
          </div>
          My AREAs
        </NuxtLink>

        <NuxtLink to="/services" class="flex items-center px-3 py-2.5 rounded-lg text-gray-500 hover:bg-gray-50 hover:text-gray-900 font-medium transition-all group">
          <div class="w-6 h-6 p-1 rounded-md bg-green-50 flex items-center justify-center mr-3">
            <Square3Stack3DIcon class="w-4 h-4 text-green-500" />
          </div>
          Services
        </NuxtLink>

        <NuxtLink to="/activity" class="flex items-center px-3 py-2.5 rounded-lg text-gray-500 hover:bg-gray-50 hover:text-gray-900 font-medium transition-all group">
          <div class="w-6 h-6 p-1 rounded-md bg-orange-50 flex items-center justify-center mr-3">
            <ClipboardDocumentListIcon class="w-4 h-4 text-orange-500" />
          </div>
          Activity
        </NuxtLink>
      </nav>

      <!-- User Profile -->
      <div class="p-4 border-t border-gray-100 bg-gray-50/50">
        <button @click="logout" class="w-full py-2 rounded-lg border border-gray-200 bg-white text-gray-600 hover:text-red-600 hover:border-red-100 hover:bg-red-50 text-xs font-bold transition-all shadow-sm flex items-center justify-center gap-2">
          <ArrowRightOnRectangleIcon class="w-4 h-4" />
          Déconnexion
        </button>
      </div>
    </aside>

    <!-- MAIN CONTENT -->
    <main class="flex-1 flex flex-col h-full overflow-hidden relative">
      
      <!-- Header -->
      <header class="h-16 flex items-center justify-between px-8 bg-white/80 backdrop-blur-sm border-b border-gray-200 sticky top-0 z-10">
        <h1 class="text-lg font-bold text-gray-800">My Workflows</h1>
        
        <div class="flex items-center gap-4">
          <!-- Search Bar -->
          <div class="relative">
            <input 
              v-model="searchQuery" 
              type="text" 
              placeholder="Search areas..." 
              class="pl-4 pr-4 py-2 rounded-lg border border-gray-200 text-sm focus:ring-2 focus:ring-blue-500 outline-none w-64 bg-gray-50"
            >
          </div>
          
          <NuxtLink to="/areas/create" class="bg-blue-600 hover:bg-blue-700 text-white px-5 py-2 rounded-lg font-semibold text-sm shadow-md shadow-blue-200 transition">
            + New AREA
          </NuxtLink>
        </div>
      </header>

      <!-- List Content -->
      <div class="flex-1 overflow-y-auto p-8 custom-scrollbar">
        
        <!-- Empty State -->
        <div v-if="filteredAreas.length === 0" class="flex flex-col items-center justify-center py-20 text-gray-400">
          <BoltIcon class="w-16 h-16 mb-4" />
          <p>No automation found.</p>
        </div>

        <!-- Areas Grid -->
        <div v-else class="max-w-5xl mx-auto space-y-4">
          <div v-for="area in filteredAreas" :key="area.id" class="group bg-white rounded-xl border border-gray-200 shadow-sm p-5 flex items-center justify-between hover:border-blue-300 transition duration-200">
            
            <!-- Left Info -->
            <div class="flex items-center gap-4">
              <div class="w-12 h-12 rounded-lg bg-blue-50 flex items-center justify-center text-blue-600 border border-blue-100">
                <BoltIcon class="w-6 h-6" />
              </div>
              <div>
                <h3 class="font-bold text-gray-900 group-hover:text-blue-600 transition">{{ area.name }}</h3>
                <div class="flex items-center gap-2 text-xs text-gray-500 mt-1">
                  <span class="bg-gray-100 px-2 py-0.5 rounded border border-gray-200">{{ area.trigger_service }} ({{ area.trigger_action }})</span> 
                  <span class="text-gray-300">→</span> 
                  <span class="bg-gray-100 px-2 py-0.5 rounded border border-gray-200">{{ area.action_service }} ({{ area.action_reaction }})</span>
                </div>
              </div>
            </div>

            <!-- Right Actions -->
            <div class="flex items-center gap-6">
              
              <!-- Toggle Switch -->
              <label class="flex items-center gap-2 cursor-pointer">
                <input 
                  type="checkbox" 
                  :checked="area.is_active"
                  @change="handleToggle(area.id)"
                  class="sr-only"
                />
                <div 
                  class="relative inline-flex h-6 w-11 flex-shrink-0 rounded-full border-2 border-transparent transition-colors duration-200 ease-in-out" 
                  :class="area.is_active ? 'bg-green-500' : 'bg-gray-200'"
                >
                  <span 
                    class="pointer-events-none inline-block h-5 w-5 transform rounded-full bg-white shadow ring-0 transition duration-200 ease-in-out" 
                    :class="area.is_active ? 'translate-x-5' : 'translate-x-0'"
                  ></span>
                </div>
                <span class="text-xs text-gray-500">{{ area.is_active ? 'Actif' : 'Inactif' }}</span>
              </label>

              <!-- Delete Icon -->
              <button @click="handleDelete(area.id)" class="text-gray-300 hover:text-red-500 transition p-2 hover:bg-red-50 rounded-full">
                <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
                </svg>
              </button>

            </div>
          </div>
        </div>

      </div>
    </main>
  </div>
</template>

<style scoped>
/* Scrollbar */
.custom-scrollbar::-webkit-scrollbar { width: 5px; }
.custom-scrollbar::-webkit-scrollbar-track { background: transparent; }
.custom-scrollbar::-webkit-scrollbar-thumb { background: #e2e8f0; border-radius: 10px; }
.custom-scrollbar::-webkit-scrollbar-thumb:hover { background: #cbd5e1; }
</style>