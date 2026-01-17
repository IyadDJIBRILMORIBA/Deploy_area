<script setup lang="ts">
import { ref, computed } from 'vue'
import { useAuthStore } from '~/stores/auth'
import { useAreasStore } from '~/stores/areas'
import { useServicesStore } from '~/stores/services'
import { ChartBarIcon, BoltIcon, Square3Stack3DIcon, ClipboardDocumentListIcon, ArrowRightOnRectangleIcon, ClockIcon, CheckCircleIcon } from '@heroicons/vue/24/outline'

const authStore = useAuthStore()
const areasStore = useAreasStore()
const servicesStore = useServicesStore()
const router = useRouter()

onMounted(async () => {
  await servicesStore.fetchServicesWithDetails()
})

const step = ref(1)
const selectedTrigger = ref<any>(null)
const selectedAction = ref<any>(null)
const triggerConfig = ref<Record<string, any>>({})
const actionConfig = ref<Record<string, any>>({})
const areaName = ref('')

// Options Timer pour boutons radio
const timerOptions = [
  { value: 'every_minute', label: 'Every minute' },
  { value: 'every_5_minutes', label: 'Every 5 minutes' },
  { value: 'every_hour', label: 'Every hour' },
  { value: 'every_day', label: 'Every day' }
]

// Services avec fields dynamiques
// Services dynamiques depuis le store
const services = computed(() => servicesStore.services || [])

// Helper pour l'affichage des icônes (URL ou Emoji)
const isUrl = (str: string) => str && (str.startsWith('http') || str.startsWith('/'))

const handleSelectTrigger = (service: any, trigger: any) => {
  selectedTrigger.value = { service, trigger }
  triggerConfig.value = {}
  step.value = 2
}

const handleSelectAction = (service: any, action: any) => {
  selectedAction.value = { service, action }
  actionConfig.value = {}
  step.value = 4
}

const handleSubmit = async () => {
  // 1. On vérifie les variables REELLES utilisées dans le template
  if (!areaName.value || !selectedTrigger.value || !selectedAction.value) {
    alert('Veuillez remplir tous les champs obligatoires')
    return
  }

  try {
    // 2. On construit l'objet à envoyer à partir des sélections
    await areasStore.createArea({
      name: areaName.value, // Le nom saisi
      
      // IMPORTANT: Le backend attend le NOM du service (string), pas l'ID
      trigger_service: selectedTrigger.value.service.name, // "weather", "google", etc.
      trigger_action: selectedTrigger.value.trigger.name, // "temperature_above", etc.
      trigger_params: triggerConfig.value, // Les configs saisies
      
      action_service: selectedAction.value.service.name, // "google", "discord", etc.
      action_reaction: selectedAction.value.action.name, // "send_email", etc.
      action_params: actionConfig.value
    })
    
    router.push('/areas')
  } catch (error) {
    console.error('Erreur création AREA:', error)
    alert('Erreur lors de la création de l\'AREA')
  }
}

const logout = () => { authStore.logout() ; navigateTo('/login') }

const progressPercentage = computed(() => (step.value / 4) * 100)
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
      <div class="p-4 border-t border-gray-100 bg-gray-50/50">
        <button @click="logout" class="w-full py-2 rounded-lg border border-gray-200 bg-white text-gray-600 hover:text-red-600 hover:border-red-100 hover:bg-red-50 text-xs font-bold transition-all shadow-sm flex items-center justify-center gap-2">
          <ArrowRightOnRectangleIcon class="w-4 h-4" />
          Déconnexion
        </button>
      </div>
    </aside>

    <!-- MAIN -->
    <main class="flex-1 flex flex-col h-full overflow-hidden">
      
      <!-- Header avec progression -->
      <header class="bg-white border-b border-gray-200 p-6">
        <div class="max-w-4xl mx-auto">
          <div class="flex items-center justify-between mb-4">
            <h1 class="text-2xl font-bold text-gray-900">Create New Automation</h1>
            <div class="flex items-center gap-2">
              <div v-for="s in [1,2,3,4]" :key="s" 
                class="w-10 h-10 rounded-full flex items-center justify-center font-bold text-sm transition"
                :class="s === step ? 'bg-blue-600 text-white' : s < step ? 'bg-green-500 text-white' : 'bg-gray-200 text-gray-400'">
                <CheckCircleIcon v-if="s < step" class="w-5 h-5" />
                <span v-else>{{ s }}</span>
              </div>
            </div>
          </div>
          
          <div class="flex items-center gap-3 text-sm">
            <span :class="step >= 1 ? 'text-blue-600 font-semibold' : 'text-gray-400'">Choose Trigger</span>
            <span class="text-gray-300">→</span>
            <span :class="step >= 2 ? 'text-blue-600 font-semibold' : 'text-gray-400'">Configure</span>
            <span class="text-gray-300">→</span>
            <span :class="step >= 3 ? 'text-blue-600 font-semibold' : 'text-gray-400'">Choose Action</span>
            <span class="text-gray-300">→</span>
            <span :class="step >= 4 ? 'text-blue-600 font-semibold' : 'text-gray-400'">Review</span>
          </div>
        </div>
      </header>

      <div class="flex-1 overflow-y-auto p-8">
        <div class="max-w-4xl mx-auto">
          
          <!-- STEP 1: Choose Trigger -->
          <div v-if="step === 1" class="space-y-6">
            <h2 class="text-xl font-bold text-gray-900">When this happens...</h2>
            
            <div v-for="service in services.filter(s => s.triggers && s.triggers.length > 0)" :key="service.id" class="bg-white rounded-xl shadow-sm p-6 border border-gray-200">
              <div class="flex items-center gap-3 mb-4">
                <img v-if="isUrl(service.icon)" :src="service.icon" class="w-8 h-8 object-contain" />
                <span v-else class="text-3xl">{{ service.icon }}</span>
                <h3 class="text-lg font-bold text-gray-900">{{ service.name }}</h3>
              </div>
              
              <div class="grid grid-cols-1 md:grid-cols-2 gap-3">
                <button v-for="trigger in service.triggers" :key="trigger.id"
                  @click="handleSelectTrigger(service, trigger)"
                  class="text-left p-4 rounded-lg border border-gray-200 hover:border-blue-500 hover:bg-blue-50 transition group">
                  <h4 class="font-semibold text-gray-900 group-hover:text-blue-700 mb-1">{{ trigger.name }}</h4>
                  <p class="text-sm text-gray-500">{{ trigger.description }}</p>
                </button>
              </div>
            </div>
          </div>

          <!-- STEP 2: Configure Trigger -->
          <div v-if="step === 2 && selectedTrigger" class="bg-white rounded-xl shadow-sm p-8 border border-gray-200">
            <div class="flex items-center gap-3 mb-6">
              <img v-if="isUrl(selectedTrigger.service.icon)" :src="selectedTrigger.service.icon" class="w-8 h-8 object-contain" />
              <span v-else class="text-3xl">{{ selectedTrigger.service.icon }}</span>
              <div>
                <h2 class="text-xl font-bold text-gray-900">{{ selectedTrigger.trigger.name }}</h2>
                <p class="text-sm text-gray-500">{{ selectedTrigger.trigger.description }}</p>
              </div>
            </div>

            <div v-if="selectedTrigger.trigger.fields.length > 0">
              <div v-for="field in selectedTrigger.trigger.fields" :key="field.name" class="mb-4">
                <label class="block text-sm font-semibold text-gray-700 mb-2">
                  {{ field.label }}
                  <span v-if="field.required" class="text-red-500 ml-1">*</span>
                </label>
                
                <!-- CAS SPÉCIAL : TIMER (Force l'affichage en boutons radio) -->
                <div v-if="selectedTrigger.service.name?.toLowerCase().includes('timer') || selectedTrigger.service.id === 'timer'" class="space-y-2">
                  <div class="grid grid-cols-1 sm:grid-cols-2 gap-3">
                    <button
                      v-for="option in timerOptions"
                      :key="option.value"
                      type="button"
                      @click="triggerConfig[field.name] = option.value"
                      :class="[
                        'px-4 py-3 rounded-lg border-2 font-medium transition-all text-left flex items-center justify-between',
                        triggerConfig[field.name] === option.value
                          ? 'border-blue-600 bg-blue-50 text-blue-700 shadow-sm ring-1 ring-blue-600'
                          : 'border-gray-200 bg-white text-gray-600 hover:border-blue-300 hover:bg-gray-50'
                      ]">
                      <span>{{ option.label }}</span>
                      <span v-if="triggerConfig[field.name] === option.value" class="text-blue-600 text-lg">●</span>
                      <span v-else class="text-gray-300 text-lg">○</span>
                    </button>
                  </div>
                  <!-- Champ caché pour la validation HTML5 -->
                  <input type="hidden" v-model="triggerConfig[field.name]" :required="field.required" />
                </div>
                
                <!-- CAS STANDARD : SELECT (Venant du backend) -->
                <div v-else-if="field.type === 'select'" class="space-y-2">
                  <div class="grid grid-cols-2 gap-2">
                    <button
                      v-for="option in field.options"
                      :key="option"
                      type="button"
                      @click="triggerConfig[field.name] = option"
                      :class="[
                        'px-4 py-3 rounded-lg border-2 font-medium transition-all',
                        triggerConfig[field.name] === option
                          ? 'border-blue-600 bg-blue-50 text-blue-700 shadow-sm'
                          : 'border-gray-300 bg-white text-gray-700 hover:border-blue-400 hover:bg-blue-50'
                      ]">
                      <div class="flex items-center justify-center gap-2">
                        <CheckCircleIcon v-if="triggerConfig[field.name] === option" class="w-5 h-5 text-blue-600" />
                        <span>{{ option.replace(/_/g, ' ') }}</span>
                      </div>
                    </button>
                  </div>
                  <input type="hidden" v-model="triggerConfig[field.name]" :required="field.required" />
                </div>
                
                <!-- CAS STANDARD : TEXTAREA -->
                <textarea v-else-if="field.type === 'textarea'"
                  v-model="triggerConfig[field.name]"
                  :placeholder="field.placeholder"
                  :required="field.required"
                  rows="4"
                  class="w-full px-4 py-2.5 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 outline-none resize-none transition-shadow" />
                
                <!-- CAS STANDARD : INPUT TEXT/NUMBER/URL -->
                <input v-else
                  v-model="triggerConfig[field.name]"
                  :type="field.type"
                  :placeholder="field.placeholder"
                  :required="field.required"
                  class="w-full px-4 py-2.5 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 outline-none transition-shadow" />
              </div>
            </div>
            <p v-else class="text-gray-500 text-center py-8">No configuration needed for this trigger.</p>

            <div class="flex gap-3 mt-6">
              <button @click="step = 1" class="px-6 py-2.5 border border-gray-300 text-gray-700 font-semibold rounded-lg hover:bg-gray-50">← Back</button>
              <button @click="step = 3" class="flex-1 px-6 py-2.5 bg-blue-600 text-white font-semibold rounded-lg hover:bg-blue-700">Next: Choose Action →</button>
            </div>
          </div>

          <!-- STEP 3: Choose Action -->
          <div v-if="step === 3" class="space-y-6">
            <h2 class="text-xl font-bold text-gray-900">Then do this...</h2>
            
            <div v-for="service in services.filter(s => s.actions && s.actions.length > 0)" :key="service.id" class="bg-white rounded-xl shadow-sm p-6 border border-gray-200">
              <div class="flex items-center gap-3 mb-4">
                <img v-if="isUrl(service.icon)" :src="service.icon" class="w-8 h-8 object-contain" />
                <span v-else class="text-3xl">{{ service.icon }}</span>
                <h3 class="text-lg font-bold text-gray-900">{{ service.name }}</h3>
              </div>
              
              <div class="grid grid-cols-1 md:grid-cols-2 gap-3">
                <button v-for="action in service.actions" :key="action.id"
                  @click="handleSelectAction(service, action)"
                  class="text-left p-4 rounded-lg border border-gray-200 hover:border-blue-500 hover:bg-blue-50 transition group">
                  <h4 class="font-semibold text-gray-900 group-hover:text-blue-700 mb-1">{{ action.name }}</h4>
                  <p class="text-sm text-gray-500">{{ action.description }}</p>
                </button>
              </div>
            </div>
            
            <button @click="step = 2" class="px-6 py-2.5 border border-gray-300 text-gray-700 font-semibold rounded-lg hover:bg-gray-50">← Back</button>
          </div>

          <!-- STEP 4: Configure Action & Review -->
          <div v-if="step === 4 && selectedAction" class="space-y-6">
            
            <!-- Action Config -->
            <div class="bg-white rounded-xl shadow-sm p-8 border border-gray-200">
              <div class="flex items-center gap-3 mb-6">
                <img v-if="isUrl(selectedAction.service.icon)" :src="selectedAction.service.icon" class="w-8 h-8 object-contain" />
                <span v-else class="text-3xl">{{ selectedAction.service.icon }}</span>
                <div>
                  <h2 class="text-xl font-bold text-gray-900">{{ selectedAction.action.name }}</h2>
                  <p class="text-sm text-gray-500">{{ selectedAction.action.description }}</p>
                </div>
              </div>

              <div v-for="field in selectedAction.action.fields" :key="field.name" class="mb-4">
                <label class="block text-sm font-semibold text-gray-700 mb-2">
                  {{ field.label }}
                  <span v-if="field.required" class="text-red-500 ml-1">*</span>
                </label>
                
                <!-- Boutons pour les champs select (meilleure UX) -->
                <div v-if="field.type === 'select'" class="space-y-2">
                  <div class="grid grid-cols-2 gap-2">
                    <button
                      v-for="option in field.options"
                      :key="option"
                      type="button"
                      @click="actionConfig[field.name] = option"
                      :class="[
                        'px-4 py-3 rounded-lg border-2 font-medium transition-all',
                        actionConfig[field.name] === option
                          ? 'border-blue-600 bg-blue-50 text-blue-700 shadow-sm'
                          : 'border-gray-300 bg-white text-gray-700 hover:border-blue-400 hover:bg-blue-50'
                      ]">
                      <div class="flex items-center justify-center gap-2">
                        <CheckCircleIcon v-if="actionConfig[field.name] === option" class="w-5 h-5 text-blue-600" />
                        <span>{{ option.replace(/_/g, ' ') }}</span>
                      </div>
                    </button>
                  </div>
                  <input type="hidden" v-model="actionConfig[field.name]" :required="field.required" />
                </div>
                
                <textarea v-else-if="field.type === 'textarea'"
                  v-model="actionConfig[field.name]"
                  :placeholder="field.placeholder"
                  :required="field.required"
                  rows="4"
                  class="w-full px-4 py-2.5 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 outline-none resize-none" />
                
                <input v-else
                  v-model="actionConfig[field.name]"
                  :type="field.type"
                  :placeholder="field.placeholder"
                  :required="field.required"
                  class="w-full px-4 py-2.5 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 outline-none" />
              </div>
            </div>

            <!-- Review -->
            <div class="bg-white rounded-xl shadow-sm p-8 border border-gray-200">
              <h3 class="text-lg font-bold text-gray-900 mb-4">Name your automation</h3>
              <input v-model="areaName" type="text"
                :placeholder="`${selectedTrigger.service.name} → ${selectedAction.service.name}`"
                class="w-full px-4 py-2.5 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 outline-none mb-6" />

              <div class="bg-blue-50 border border-blue-200 rounded-lg p-6">
                <h4 class="font-semibold text-blue-900 mb-3">Summary</h4>
                <div class="flex items-center gap-4 text-sm">
                  <div class="flex items-center gap-2">
                    <img v-if="isUrl(selectedTrigger.service.icon)" :src="selectedTrigger.service.icon" class="w-6 h-6 object-contain" />
                    <span v-else class="text-2xl">{{ selectedTrigger.service.icon }}</span>
                    <span class="font-medium text-gray-700">{{ selectedTrigger.trigger.name }}</span>
                  </div>
                  <span class="text-blue-600 text-xl">→</span>
                  <div class="flex items-center gap-2">
                    <img v-if="isUrl(selectedAction.service.icon)" :src="selectedAction.service.icon" class="w-6 h-6 object-contain" />
                    <span v-else class="text-2xl">{{ selectedAction.service.icon }}</span>
                    <span class="font-medium text-gray-700">{{ selectedAction.action.name }}</span>
                  </div>
                </div>
              </div>
            </div>

            <div class="flex gap-3">
              <button @click="step = 3" class="px-6 py-2.5 border border-gray-300 text-gray-700 font-semibold rounded-lg hover:bg-gray-50">← Back</button>
              <button @click="handleSubmit" class="flex-1 px-6 py-3 bg-green-600 text-white font-bold rounded-lg hover:bg-green-700 shadow-lg flex items-center justify-center gap-2">
                <CheckCircleIcon class="w-5 h-5" />
                Create Automation
              </button>
            </div>
          </div>

        </div>
      </div>
    </main>
  </div>
</template>