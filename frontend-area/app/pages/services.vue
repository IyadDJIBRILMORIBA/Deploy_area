<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useAuthStore } from '~/stores/auth'
import { useServicesStore } from '~/stores/services'
import { ChartBarIcon, BoltIcon, Square3Stack3DIcon, ClipboardDocumentListIcon, ArrowRightOnRectangleIcon, RocketLaunchIcon } from '@heroicons/vue/24/outline'

const authStore = useAuthStore()
const servicesStore = useServicesStore()

const selectedService = ref<any>(null)
const notification = ref({ show: false, message: '', type: 'success' })

onMounted(async () => {
  await servicesStore.fetchServices()
})

const handleConnect = async (serviceId: number) => {
  try {
    await servicesStore.connectService(serviceId)
    showNotification('Service connecté avec succès!', 'success')
    // Fermer le panneau si ouvert pour rafraîchir l'état visuel
    if (selectedService.value?.id === serviceId) {
      selectedService.value.is_connected = true
    }
  } catch (error) {
    console.error('Erreur connexion service:', error)
    showNotification('Erreur lors de la connexion', 'error')
  }
}

const handleDisconnect = async (serviceId: number) => {
  if (!confirm('Êtes-vous sûr de vouloir déconnecter ce service ? Les AREAs liées pourraient ne plus fonctionner.')) {
    return
  }
  
  try {
    await servicesStore.disconnectService(serviceId)
    showNotification('Service déconnecté', 'success')
    // Mettre à jour l'état local du panneau si ouvert
    if (selectedService.value?.id === serviceId) {
      selectedService.value.is_connected = false
    }
  } catch (error) {
    console.error('Erreur déconnexion service:', error)
    showNotification('Erreur lors de la déconnexion', 'error')
  }
}

const showNotification = (message: string, type: 'success' | 'error' = 'success') => {
  notification.value = { show: true, message, type }
  setTimeout(() => {
    notification.value.show = false
  }, 3000)
}

const getServiceIcon = (name: string) => {
  const icons: Record<string, string> = {
    'google': 'https://cdn.simpleicons.org/google',
    'gmail': 'https://cdn.simpleicons.org/gmail',
    'github': 'https://cdn.simpleicons.org/github',
    'gitlab': 'https://cdn.simpleicons.org/gitlab',
    'discord': 'https://cdn.simpleicons.org/discord',
    'slack': 'https://cdn.simpleicons.org/slack',
    'spotify': 'https://cdn.simpleicons.org/spotify',
    'timer': 'https://cdn.simpleicons.org/clockify',
    'openai': 'https://cdn.simpleicons.org/openai',
    'weather': 'https://cdn.simpleicons.org/weatherapi',
    'openweathermap': 'https://cdn.simpleicons.org/openweathermap',
    'cloud': 'https://cdn.simpleicons.org/weatherapi',
    'twitch': 'https://cdn.simpleicons.org/twitch',
    'reddit': 'https://cdn.simpleicons.org/reddit',
    'trello': 'https://cdn.simpleicons.org/trello',
    'notion': 'https://cdn.simpleicons.org/notion'
  }
  return icons[name.toLowerCase()] || 'https://cdn.simpleicons.org/lightning'
}

const openDetails = (service: any) => { selectedService.value = service }
const closeDetails = () => { selectedService.value = null }

const logout = () => { authStore.logout() ; navigateTo('/login') }
</script>

<template>
  <div class="flex h-screen w-full bg-[#F3F4F6] font-sans text-slate-800 overflow-hidden">
    
    <!-- SIDEBAR -->
    <aside class="w-64 hidden md:flex flex-col bg-white border-r border-gray-200 z-20">
      <div class="h-16 flex items-center px-6 border-b border-gray-100">
        <div class="flex items-center gap-2">
          <div class="w-8 h-8 rounded-lg bg-blue-600 flex items-center justify-center text-white font-bold shadow-sm shadow-blue-200">A</div>
          <span class="text-xl font-bold text-gray-800 tracking-tight">AREA</span>
        </div>
      </div>
      <nav class="flex-1 px-3 py-6 space-y-1">
        <NuxtLink to="/dashboard" class="flex items-center px-3 py-2.5 rounded-lg text-gray-500 hover:bg-gray-50 hover:text-gray-900 font-medium transition-all group">
          <div class="w-6 h-6 p-1 rounded-md bg-blue-50 flex items-center justify-center mr-3">
            <ChartBarIcon class="w-4 h-4 text-blue-500" />
          </div>
          Dashboard
        </NuxtLink>
        <NuxtLink to="/areas" class="flex items-center px-3 py-2.5 rounded-lg text-gray-500 hover:bg-gray-50 hover:text-gray-900 font-medium transition-all group">
          <div class="w-6 h-6 p-1 rounded-md bg-purple-50 flex items-center justify-center mr-3">
            <BoltIcon class="w-4 h-4 text-purple-500" />
          </div>
          My AREAs
        </NuxtLink>
        <NuxtLink to="/services" class="flex items-center px-3 py-2.5 rounded-lg bg-blue-50 text-blue-700 font-semibold transition-all group relative">
          <div class="absolute left-0 top-1 bottom-1 w-1 bg-blue-600 rounded-r-full"></div>
          <div class="w-6 h-6 p-1 rounded-md bg-green-50 flex items-center justify-center mr-3">
            <Square3Stack3DIcon class="w-4 h-4 text-green-600" />
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
      <div class="p-4 border-t border-gray-100 bg-gray-50/50">
        <button @click="logout" class="w-full py-2 rounded-lg border border-gray-200 bg-white text-gray-600 hover:text-red-600 hover:border-red-100 hover:bg-red-50 text-xs font-bold transition-all shadow-sm flex items-center justify-center gap-2">
          <ArrowRightOnRectangleIcon class="w-4 h-4" />
          Déconnexion
        </button>
      </div>
    </aside>

    <main class="flex-1 flex flex-col h-full overflow-hidden relative">
      <header class="h-16 flex items-center justify-between px-8 bg-white/80 backdrop-blur-sm border-b border-gray-200 sticky top-0 z-10">
        <div><h1 class="text-lg font-bold text-gray-800">Services Catalog</h1></div>
      </header>

      <!-- Notification -->
      <div v-if="notification.show" class="absolute top-20 right-8 z-50 animate-fade-in-down">
        <div class="px-4 py-3 rounded-lg shadow-lg text-white text-sm font-medium" 
          :class="notification.type === 'success' ? 'bg-green-500' : 'bg-red-500'">
          {{ notification.message }}
        </div>
      </div>

      <div class="flex-1 overflow-y-auto p-8 custom-scrollbar">
        <div v-if="servicesStore.isLoading" class="text-center py-12">
          <div class="text-gray-400 text-lg">Chargement des services...</div>
        </div>
        
        <div v-else class="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-6 pb-10">
          
          <div v-for="service in servicesStore.services" :key="service.id" 
            class="bg-white rounded-xl border border-gray-200 shadow-sm hover:border-blue-300 hover:shadow-md transition duration-200 flex flex-col relative overflow-hidden group">
            
            <!-- Indicateur visuel connecté -->
            <div v-if="service.is_connected" class="absolute top-0 left-0 w-full h-1 bg-green-500"></div>
            
            <div class="p-6">
              <div class="flex justify-between items-start mb-4">
                <div class="w-14 h-14 p-2 rounded-xl bg-gray-50 flex items-center justify-center">
                  <img :src="service.icon || getServiceIcon(service.name)" class="w-8 h-8 object-contain" />
                </div>
                <!-- Badge Connecté -->
                <div v-if="service.is_connected" class="flex flex-col items-end">
                  <span class="flex items-center text-xs font-bold text-green-600 bg-green-50 px-2 py-1 rounded-full border border-green-100">
                    ✓ Connected
                  </span>
                </div>
              </div>
              
              <h3 class="text-lg font-bold text-gray-900 group-hover:text-blue-600 transition-colors">{{ service.name }}</h3>
              <p class="text-sm text-gray-500 mt-2 min-h-[40px] leading-relaxed">{{ service.description }}</p>
            </div>
            
            <div class="px-6 py-4 bg-gray-50 border-t border-gray-100 flex items-center gap-3 mt-auto">
              <button @click="openDetails(service)" 
                class="flex-1 px-3 py-2 bg-white border border-gray-200 text-gray-700 hover:bg-gray-100 text-sm font-medium rounded-lg transition">
                Features
              </button>
              
              <!-- Bouton Connecter -->
              <button v-if="!service.is_connected" 
                @click="handleConnect(service.id)"
                :disabled="servicesStore.isLoading"
                class="flex-1 px-3 py-2 bg-blue-600 hover:bg-blue-700 text-white text-sm font-medium rounded-lg transition shadow-sm disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center gap-2">
                <div v-if="servicesStore.isLoading" class="w-4 h-4 border-2 border-white border-t-transparent rounded-full animate-spin"></div>
                <span>Connect</span>
              </button>
              
              <!-- Bouton Déconnecter -->
              <button v-else
                @click="handleDisconnect(service.id)" 
                :disabled="servicesStore.isLoading"
                class="flex-1 px-3 py-2 bg-white border border-red-200 text-red-600 hover:bg-red-50 text-sm font-medium rounded-lg transition disabled:opacity-50">
                Disconnect
              </button>
            </div>
          </div>

        </div>
      </div>
    </main>

    <!-- SLIDE-OVER (Détails) -->
    <div v-if="selectedService" class="fixed inset-0 bg-slate-900/20 backdrop-blur-sm z-40" @click="closeDetails"></div>
    <div class="fixed top-0 right-0 h-full w-full max-w-md bg-white shadow-2xl z-50 transform transition-transform duration-300" 
      :class="selectedService ? 'translate-x-0' : 'translate-x-full'">
      <div v-if="selectedService" class="flex flex-col h-full">
        <div class="px-6 py-5 border-b border-gray-100 flex justify-between items-center bg-gray-50">
          <div class="flex items-center gap-3">
            <img :src="selectedService.icon || getServiceIcon(selectedService.name)" class="w-8 h-8" />
            <h2 class="text-xl font-bold text-gray-900">{{ selectedService.name }}</h2>
          </div>
          <button @click="closeDetails" class="text-gray-400 hover:text-gray-600">
            <span class="text-2xl">×</span>
          </button>
        </div>
        
        <div class="flex-1 overflow-y-auto p-6 space-y-6">
          <div>
            <h3 class="text-xs font-bold text-gray-400 uppercase tracking-wider mb-3">Triggers</h3>
            <div class="space-y-2">
              <div v-for="t in selectedService.triggers" :key="t.name" class="flex items-start gap-3 p-3 rounded-lg border border-gray-100">
                <BoltIcon class="w-5 h-5 text-purple-500" />
                <span class="text-sm font-bold text-gray-700">{{ t.name }}</span>
              </div>
              <div v-if="!selectedService.triggers?.length" class="text-sm text-gray-400 italic">No triggers available.</div>
            </div>
          </div>
          
          <div>
            <h3 class="text-xs font-bold text-gray-400 uppercase tracking-wider mb-3">Actions</h3>
            <div class="space-y-2">
              <div v-for="a in selectedService.actions" :key="a.name" class="flex items-start gap-3 p-3 rounded-lg border border-gray-100">
                <RocketLaunchIcon class="w-5 h-5 text-green-500" />
                <span class="text-sm font-bold text-gray-700">{{ a.name }}</span>
              </div>
              <div v-if="!selectedService.actions?.length" class="text-sm text-gray-400 italic">No actions available.</div>
            </div>
          </div>
        </div>
        
        <!-- Footer du Slide-Over: Boutons Connect/Disconnect -->
        <div class="p-6 border-t border-gray-100">
          <button v-if="!selectedService.is_connected" 
            @click="handleConnect(selectedService.id)"
            class="w-full py-3 bg-blue-600 hover:bg-blue-700 text-white font-bold text-sm rounded-lg shadow-md transition">
            Connect Now
          </button>
          
          <button v-else 
            @click="handleDisconnect(selectedService.id)"
            class="w-full py-3 bg-white border border-red-200 text-red-600 hover:bg-red-50 font-bold text-sm rounded-lg shadow-sm transition">
            Disconnect Service
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
@keyframes fade-in-down {
  0% { opacity: 0; transform: translateY(-10px); }
  100% { opacity: 1; transform: translateY(0); }
}
.animate-fade-in-down { animation: fade-in-down 0.3s ease-out; }
.custom-scrollbar::-webkit-scrollbar { width: 5px; }
.custom-scrollbar::-webkit-scrollbar-track { background: transparent; }
.custom-scrollbar::-webkit-scrollbar-thumb { background: #cbd5e1; border-radius: 10px; }
</style>