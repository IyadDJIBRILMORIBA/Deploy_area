<script setup lang="ts">
import { ref } from 'vue'
import { useAuthStore } from '~/stores/auth'
import { ChartBarIcon, BoltIcon, Square3Stack3DIcon, ClipboardDocumentListIcon, ArrowRightOnRectangleIcon } from '@heroicons/vue/24/outline'

const authStore = useAuthStore()
const filter = ref('all')
const logs = ref([
  { id: 1, area: "Gmail ➜ Discord", status: "success", time: "2 min ago", msg: "Triggered successfully" },
  { id: 2, area: "Weather ➜ Sms", status: "error", time: "15 min ago", msg: "API Error 500" },
  { id: 3, area: "Daily Timer", status: "success", time: "3 hours ago", msg: "Run completed" }
])

const logout = () => { authStore.logout() ; navigateTo('/login') }
</script>

<template>
  <div class="flex h-screen w-full bg-[#F3F4F6] font-sans text-slate-800 overflow-hidden">
    <!-- SIDEBAR (Même code) -->
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
         <NuxtLink to="/services" class="flex items-center px-3 py-2.5 rounded-lg text-gray-500 hover:bg-gray-50 hover:text-gray-900 font-medium transition-all group">
          <div class="w-6 h-6 p-1 rounded-md bg-green-50 flex items-center justify-center mr-3">
            <Square3Stack3DIcon class="w-4 h-4 text-green-500" />
          </div>
          Services
        </NuxtLink>
         <NuxtLink to="/activity" class="flex items-center px-3 py-2.5 rounded-lg bg-blue-50 text-blue-700 font-semibold transition-all group relative">
          <div class="absolute left-0 top-1 bottom-1 w-1 bg-blue-600 rounded-r-full"></div>
          <div class="w-6 h-6 p-1 rounded-md bg-orange-50 flex items-center justify-center mr-3">
            <ClipboardDocumentListIcon class="w-4 h-4 text-orange-600" />
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
      <header class="h-16 flex items-center justify-between px-8 bg-white/80 border-b border-gray-200">
        <h1 class="text-lg font-bold text-gray-800">System Activity</h1>
        <div class="flex bg-gray-100 p-1 rounded-lg">
          <button @click="filter='all'" class="px-3 py-1 text-xs font-bold rounded" :class="filter==='all' ? 'bg-white shadow text-blue-600' : 'text-gray-500'">All</button>
          <button @click="filter='success'" class="px-3 py-1 text-xs font-bold rounded" :class="filter==='success' ? 'bg-white shadow text-green-600' : 'text-gray-500'">Success</button>
          <button @click="filter='error'" class="px-3 py-1 text-xs font-bold rounded" :class="filter==='error' ? 'bg-white shadow text-red-600' : 'text-gray-500'">Errors</button>
        </div>
      </header>

      <div class="flex-1 overflow-y-auto p-8 custom-scrollbar">
        <div class="max-w-4xl mx-auto space-y-4">
          <div v-for="log in logs" :key="log.id" class="bg-white p-4 rounded-lg border border-gray-200 flex items-start gap-4 shadow-sm">
            <div class="mt-1 w-2 h-2 rounded-full" :class="log.status === 'success' ? 'bg-green-500' : 'bg-red-500'"></div>
            <div class="flex-1">
              <div class="flex justify-between">
                <h4 class="font-bold text-gray-900 text-sm">{{ log.area }}</h4>
                <span class="text-xs text-gray-400 font-mono">{{ log.time }}</span>
              </div>
              <p class="text-sm text-gray-600 mt-1">{{ log.msg }}</p>
            </div>
          </div>
        </div>
      </div>
    </main>
  </div>
</template>