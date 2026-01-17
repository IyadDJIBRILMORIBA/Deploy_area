<script setup lang="ts">
import { ref } from 'vue'
import { 
  ChartBarIcon, 
  BoltIcon, 
  Square3Stack3DIcon, 
  ClipboardDocumentListIcon,
  ArrowRightOnRectangleIcon,
  PlusIcon
} from '@heroicons/vue/24/outline'
import {
  CheckCircleIcon,
  ExclamationCircleIcon
} from '@heroicons/vue/24/solid'

const authStore = useAuthStore()
const { stats, fetchDashboardStats } = useDashboard()
const route = useRoute()
const router = useRouter()

// Vérifier si token dans URL (retour OAuth Google)
onMounted(async () => {
  const tokenFromUrl = route.query.token as string
  
  if (tokenFromUrl) {
    console.log('📥 Token OAuth Google reçu')
    authStore.setToken(tokenFromUrl)
    // Nettoyer l'URL
    router.replace('/dashboard')
  }
  
  // Vérifier authentification
  if (!authStore.isAuthenticated) {
    const isAuth = await authStore.checkAuth()
    if (!isAuth) {
      router.push('/login')
      return
    }
  }
  
  // Charger les stats
  await fetchDashboardStats()
})

// Note: J'ai ajouté le champ "icon" correspondant au nom exact pour le CDN
const recentActivity = ref([
  { id: 1, area: "Gmail ➜ Discord", status: "success", time: "2 min ago", icon: "gmail" },
  { id: 2, area: "Weather ➜ Sms", status: "error", time: "15 min ago", icon: "openweathermap" },
  { id: 3, area: "Github ➜ Trello", status: "success", time: "1 hr ago", icon: "github" },
  { id: 4, area: "Daily Timer", status: "success", time: "3 hrs ago", icon: "clockify" },
])

const recentAreas = ref([
  { id: 1, name: "Auto-Reply Client", on: true, trigger: "Gmail", action: "OpenAI" },
  { id: 2, name: "Dev Workflow", on: true, trigger: "GitHub", action: "Slack" },
  { id: 3, name: "Rain Alert", on: false, trigger: "Weather", action: "Email" },
])

const logout = () => {
  authStore.logout()
  navigateTo('/login')
}

// ✨ LA MAGIE EST ICI : On récupère le logo officiel via CDN
const getServiceLogo = (name: string) => {
  const map: Record<string, string> = {
    'Gmail': 'gmail',
    'Google': 'google',
    'GitHub': 'github',
    'Weather': 'openweathermap',
    'OpenAI': 'openai',
    'Slack': 'slack',
    'Discord': 'discord',
    'Spotify': 'spotify',
    'Trello': 'trello',
    'Email': 'gmail', // Fallback visuel
    'Timer': 'clockify'
  }
  const slug = map[name] || 'lightning'
  // On utilise le CDN simpleicons.org
  return `https://cdn.simpleicons.org/${slug}`
}
</script>

<template>
  <div class="flex h-screen w-full bg-[#F3F4F6] font-sans text-slate-800 overflow-hidden">
    
    <!-- SIDEBAR -->
    <aside class="w-64 hidden md:flex flex-col bg-white border-r border-gray-200 z-20">
      <div class="h-16 flex items-center px-6 border-b border-gray-100 bg-gradient-to-r from-white to-gray-50">
        <div class="flex items-center gap-3">
          <!-- Logo AREA -->
          <div class="relative">
            <div class="w-9 h-9 rounded-xl bg-gradient-to-br from-blue-600 to-blue-700 flex items-center justify-center text-white font-black shadow-lg shadow-blue-200">
              A
            </div>
            <div class="absolute -top-1 -right-1 w-3 h-3 bg-green-400 rounded-full border-2 border-white animate-pulse"></div>
          </div>
          <div>
            <span class="text-xl font-black text-gray-900 tracking-tight">AREA</span>
            <p class="text-[10px] text-gray-400 font-medium -mt-0.5">Automation Platform</p>
          </div>
        </div>
      </div>

      <nav class="flex-1 px-3 py-6 space-y-2">
        <NuxtLink to="/dashboard" class="flex items-center px-4 py-3 rounded-xl bg-gradient-to-r from-blue-50 to-blue-50/50 text-blue-700 font-semibold transition-all group relative hover:shadow-sm">
          <div class="absolute left-0 top-2 bottom-2 w-1 bg-blue-600 rounded-r-full"></div>
          <div class="w-8 h-8 rounded-lg bg-blue-100 flex items-center justify-center mr-3 group-hover:scale-110 transition-transform">
            <ChartBarIcon class="w-5 h-5 text-blue-600" />
          </div>
          <span>Dashboard</span>
        </NuxtLink>
        <NuxtLink to="/areas" class="flex items-center px-4 py-3 rounded-xl text-gray-600 hover:bg-gray-50 hover:text-gray-900 font-medium transition-all group hover:shadow-sm">
          <div class="w-8 h-8 rounded-lg bg-gray-100 flex items-center justify-center mr-3 group-hover:bg-purple-100 group-hover:scale-110 transition-all">
            <BoltIcon class="w-5 h-5 text-gray-600 group-hover:text-purple-600" />
          </div>
          <span>My AREAs</span>
        </NuxtLink>
        <NuxtLink to="/services" class="flex items-center px-4 py-3 rounded-xl text-gray-600 hover:bg-gray-50 hover:text-gray-900 font-medium transition-all group hover:shadow-sm">
          <div class="w-8 h-8 rounded-lg bg-gray-100 flex items-center justify-center mr-3 group-hover:bg-green-100 group-hover:scale-110 transition-all">
            <Square3Stack3DIcon class="w-5 h-5 text-gray-600 group-hover:text-green-600" />
          </div>
          <span>Services</span>
        </NuxtLink>
        <NuxtLink to="/activity" class="flex items-center px-4 py-3 rounded-xl text-gray-600 hover:bg-gray-50 hover:text-gray-900 font-medium transition-all group hover:shadow-sm">
          <div class="w-8 h-8 rounded-lg bg-gray-100 flex items-center justify-center mr-3 group-hover:bg-orange-100 group-hover:scale-110 transition-all">
            <ClipboardDocumentListIcon class="w-5 h-5 text-gray-600 group-hover:text-orange-600" />
          </div>
          <span>Activity</span>
        </NuxtLink>
      </nav>

      <div class="p-4 border-t border-gray-100 bg-gradient-to-br from-gray-50 to-white">
        <div class="flex items-center gap-3 mb-3 p-2 rounded-lg hover:bg-white/50 transition-all">
          <div class="relative">
            <div class="w-10 h-10 rounded-full bg-gradient-to-br from-blue-500 to-blue-600 flex items-center justify-center text-white font-bold text-base shadow-lg shadow-blue-200 ring-2 ring-white">
              {{ authStore.user?.name?.charAt(0).toUpperCase() || authStore.user?.email?.charAt(0).toUpperCase() || 'U' }}
            </div>
            <div class="absolute -bottom-0.5 -right-0.5 w-3 h-3 bg-green-400 rounded-full border-2 border-white"></div>
          </div>
          <div class="flex-1 overflow-hidden">
            <p class="text-sm font-bold text-gray-900 truncate">{{ authStore.user?.name || 'User' }}</p>
            <p class="text-xs text-gray-500 truncate">{{ authStore.user?.email || '' }}</p>
          </div>
        </div>
        <button @click="logout" class="w-full py-2.5 rounded-lg border border-gray-200 bg-white text-gray-700 hover:text-red-600 hover:border-red-200 hover:bg-red-50 text-sm font-semibold transition-all shadow-sm hover:shadow flex items-center justify-center gap-2">
          <ArrowRightOnRectangleIcon class="w-4 h-4" />
          <span>Déconnexion</span>
        </button>
      </div>
    </aside>

    <!-- MAIN CONTENT -->
    <main class="flex-1 flex flex-col h-full overflow-hidden relative">
      <header class="h-16 flex items-center justify-between px-8 bg-white/80 backdrop-blur-sm border-b border-gray-200 sticky top-0 z-10">
        <h1 class="text-lg font-bold text-gray-800">Dashboard</h1>
        <NuxtLink to="/areas/create" class="flex items-center gap-2 bg-blue-600 hover:bg-blue-700 text-white px-5 py-2 rounded-lg font-semibold shadow-md shadow-blue-200 transition-all transform hover:-translate-y-0.5 text-sm">
          <PlusIcon class="w-5 h-5" />
          <span>Create Automation</span>
        </NuxtLink>
      </header>

      <div class="flex-1 overflow-y-auto p-8 custom-scrollbar">
        <div class="max-w-6xl mx-auto space-y-8 pb-10">
          
          <!-- STATS -->
          <div class="grid grid-cols-1 md:grid-cols-4 gap-6">
            <div class="bg-white p-5 rounded-xl border border-gray-200 shadow-sm hover:border-green-200 hover:shadow-md transition-all">
              <div class="flex justify-between items-start mb-3">
                <span class="text-gray-500 text-xs font-bold uppercase tracking-wider">Runs Today</span>
                <div class="w-10 h-10 rounded-xl bg-gradient-to-br from-green-50 to-green-100 flex items-center justify-center">
                  <CheckCircleIcon class="w-6 h-6 text-green-600" />
                </div>
              </div>
              <p class="text-3xl font-black text-gray-900">{{ stats.executionsToday }}</p>
              <p class="text-xs text-gray-400 mt-1">Total executions</p>
            </div>
            <div class="bg-white p-5 rounded-xl border border-gray-200 shadow-sm hover:border-blue-200 hover:shadow-md transition-all">
              <div class="flex justify-between items-start mb-3">
                <span class="text-gray-500 text-xs font-bold uppercase tracking-wider">Active</span>
                <div class="w-10 h-10 rounded-xl bg-gradient-to-br from-blue-50 to-blue-100 flex items-center justify-center">
                  <BoltIcon class="w-6 h-6 text-blue-600" />
                </div>
              </div>
              <p class="text-3xl font-black text-gray-900">{{ stats.activeAreas }}</p>
              <p class="text-xs text-gray-400 mt-1">Running workflows</p>
            </div>
            <div class="bg-white p-5 rounded-xl border border-gray-200 shadow-sm hover:border-purple-200 hover:shadow-md transition-all">
              <div class="flex justify-between items-start mb-3">
                <span class="text-gray-500 text-xs font-bold uppercase tracking-wider">Services</span>
                <div class="w-10 h-10 rounded-xl bg-gradient-to-br from-purple-50 to-purple-100 flex items-center justify-center">
                  <Square3Stack3DIcon class="w-6 h-6 text-purple-600" />
                </div>
              </div>
              <p class="text-3xl font-black text-gray-900">{{ stats.connectedServices }}</p>
              <p class="text-xs text-gray-400 mt-1">Connected apps</p>
            </div>
            <div class="bg-white p-5 rounded-xl border border-gray-200 shadow-sm hover:border-orange-200 hover:shadow-md transition-all">
              <div class="flex justify-between items-start mb-3">
                <span class="text-gray-500 text-xs font-bold uppercase tracking-wider">Success Rate</span>
                <div class="w-10 h-10 rounded-xl bg-gradient-to-br from-orange-50 to-orange-100 flex items-center justify-center">
                  <ChartBarIcon class="w-6 h-6 text-orange-600" />
                </div>
              </div>
              <p class="text-3xl font-black text-gray-900">{{ stats.successRate }}%</p>
              <p class="text-xs text-gray-400 mt-1">Last 30 days</p>
            </div>
          </div>

          <!-- LISTS -->
          <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
            
            <!-- Left: Workflows -->
            <div class="lg:col-span-2 space-y-4">
              <div class="flex justify-between items-end px-1">
                <h3 class="font-bold text-lg text-gray-800">Your Workflows</h3>
              </div>

              <div class="bg-white rounded-xl p-1 shadow-sm border border-gray-200">
                <div v-for="area in recentAreas" :key="area.id" class="group flex items-center justify-between p-4 rounded-lg hover:bg-gray-50 transition border border-transparent mb-1 cursor-pointer">
                  <div class="flex items-center gap-4">
                    <!-- ICONE LOGO REEL -->
                    <div class="w-12 h-12 rounded-lg bg-gray-50 border border-gray-100 flex items-center justify-center p-2 group-hover:border-blue-200 group-hover:bg-white transition">
                      <img :src="getServiceLogo(area.trigger)" alt="Service" class="w-6 h-6 object-contain" />
                    </div>
                    
                    <div>
                      <h4 class="font-bold text-gray-900 text-sm group-hover:text-blue-700 transition">{{ area.name }}</h4>
                      <div class="flex items-center gap-2 mt-1 text-xs text-gray-500 font-medium">
                        <span class="flex items-center gap-1 bg-gray-100 px-2 py-0.5 rounded">
                           <img :src="getServiceLogo(area.trigger)" class="w-3 h-3" /> {{ area.trigger }}
                        </span>
                        <span class="text-gray-300">➜</span>
                        <span class="flex items-center gap-1 bg-gray-100 px-2 py-0.5 rounded">
                           <img :src="getServiceLogo(area.action)" class="w-3 h-3" /> {{ area.action }}
                        </span>
                      </div>
                    </div>
                  </div>
                  
                  <div class="flex items-center gap-3">
                    <div class="flex items-center gap-2 px-3 py-1 rounded-full text-[10px] font-bold border" 
                      :class="area.on ? 'bg-green-50 text-green-700 border-green-200' : 'bg-gray-50 text-gray-500 border-gray-200'">
                      <span class="w-1.5 h-1.5 rounded-full" :class="area.on ? 'bg-green-500' : 'bg-gray-400'"></span>
                      {{ area.on ? 'ACTIVE' : 'PAUSED' }}
                    </div>
                  </div>
                </div>
              </div>
            </div>

            <!-- Right: Activity Feed -->
            <div class="space-y-4">
               <div class="flex justify-between items-end px-1">
                <h3 class="font-bold text-lg text-gray-800">Live Feed</h3>
              </div>

              <div class="bg-white rounded-xl p-6 shadow-sm border border-gray-200 h-full max-h-[350px] overflow-y-auto custom-scrollbar">
                <div class="space-y-6 relative">
                  <div class="absolute left-[7px] top-2 bottom-2 w-[2px] bg-gray-100 rounded"></div>

                  <div v-for="log in recentActivity" :key="log.id" class="relative pl-6">
                    <div class="absolute left-0 top-1.5 w-4 h-4 rounded-full border-2 border-white shadow-sm"
                      :class="log.status === 'success' ? 'bg-green-500' : 'bg-red-500'"></div>
                    
                    <div class="flex justify-between items-start">
                      <div class="flex items-center gap-2">
                        <img :src="`https://cdn.simpleicons.org/${log.icon}`" class="w-3 h-3 opacity-60" />
                        <p class="text-xs font-bold text-gray-700">{{ log.area }}</p>
                      </div>
                      <span class="text-[10px] text-gray-400 font-mono">{{ log.time }}</span>
                    </div>
                    <p class="text-[11px] text-gray-500 mt-0.5">
                      {{ log.status === 'success' ? 'Triggered successfully' : 'Failed to execute action' }}
                    </p>
                  </div>
                </div>
              </div>
            </div>

          </div>
        </div>
      </div>
    </main>
  </div>
</template>

<style scoped>
.custom-scrollbar::-webkit-scrollbar { width: 5px; }
.custom-scrollbar::-webkit-scrollbar-track { background: transparent; }
.custom-scrollbar::-webkit-scrollbar-thumb { background: #e2e8f0; border-radius: 10px; }
.custom-scrollbar::-webkit-scrollbar-thumb:hover { background: #cbd5e1; }
</style>