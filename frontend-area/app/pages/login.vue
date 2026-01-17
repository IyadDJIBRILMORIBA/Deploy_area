<template>
  <div class="flex items-center justify-center min-h-screen bg-gray-100">
    <div class="p-8 bg-white rounded-lg shadow-lg text-center max-w-md w-full space-y-8">
      <div>
        <h1 class="text-3xl font-bold mb-2">
          {{ mode === 'login' ? 'Connexion' : 'Inscription' }}
        </h1>
        <p class="text-gray-600">
          {{ mode === 'login' 
            ? 'Connectez-vous pour accéder à votre tableau de bord' 
            : 'Créez un compte pour commencer' 
          }}
        </p>
      </div>

      <div class="flex gap-2 border border-gray-200 rounded-lg p-1">
        <button
          @click="mode = 'login'"
          :class="[
            'flex-1 py-2 rounded-md text-sm font-medium transition-colors',
            mode === 'login'
              ? 'bg-indigo-600 text-white'
              : 'text-gray-600 hover:text-gray-900'
          ]"
        >
          Connexion
        </button>
        <button
          @click="mode = 'register'"
          :class="[
            'flex-1 py-2 rounded-md text-sm font-medium transition-colors',
            mode === 'register'
              ? 'bg-indigo-600 text-white'
              : 'text-gray-600 hover:text-gray-900'
          ]"
        >
          Inscription
        </button>
      </div>

      <button
        @click="handleGoogleLogin"
        type="button"
        class="bg-blue-500 hover:bg-blue-700 text-white font-bold py-3 px-6 rounded-lg inline-flex items-center justify-center transition-colors w-full"
      >
        <svg class="w-5 h-5 mr-2" fill="currentColor" viewBox="0 0 48 48">
          <path
            d="M44.5,20H24v8.5h11.8C34.7,35.9,30.1,40,24,40c-6.6,0-12-5.4-12-12s5.4-12,12-12c3.1,0,5.8,1.2,7.9,3.1L38,8.1C34.1,4.5,29.3,2,24,2C11.8,2,2,11.8,2,24s9.8,22,22,22s22-9.8,22-22C46,22.7,45.5,21.3,44.5,20z"
          />
        </svg>
        <span>Se connecter avec Google</span>
      </button>

      <div class="flex items-center gap-4">
        <div class="h-px bg-gray-200 flex-1"></div>
        <span class="text-xs text-gray-400 uppercase tracking-wide">ou</span>
        <div class="h-px bg-gray-200 flex-1"></div>
      </div>

      <form class="space-y-4 text-left" @submit.prevent="handleSubmit">
        <div v-if="mode === 'register'">
          <label class="block text-sm font-medium text-gray-700 mb-1">
            Nom complet
          </label>
          <input
            v-model="name"
            type="text"
            placeholder="Votre nom"
            required
            class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 text-sm"
          />
        </div>

        <div>
          <label class="block text-sm font-medium text-gray-700 mb-1">
            Adresse email
          </label>
          <input
            v-model="email"
            type="email"
            placeholder="vous@example.com"
            required
            class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 text-sm"
          />
        </div>

        <div>
          <label class="block text-sm font-medium text-gray-700 mb-1">
            Mot de passe
          </label>
          <input
            v-model="password"
            type="password"
            placeholder="••••••••"
            required
            minlength="6"
            class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 text-sm"
          />
        </div>

        <button
          type="submit"
          :disabled="loading"
          class="w-full bg-indigo-600 hover:bg-indigo-700 disabled:opacity-60 disabled:cursor-not-allowed text-white font-semibold py-2.5 rounded-lg text-sm transition-colors"
        >
          {{ loading 
            ? (mode === 'login' ? 'Connexion...' : 'Inscription...') 
            : (mode === 'login' ? 'Se connecter' : 'S\'inscrire') 
          }}
        </button>

        <p v-if="error" class="text-sm text-red-600 mt-2">
          {{ error }}
        </p>
        <p v-if="success" class="text-sm text-green-600 mt-2">
          {{ success }}
        </p>
      </form>

      <div>
        <NuxtLink to="/" class="text-sm text-gray-500 hover:text-gray-700">
          ← Retour à l'accueil
        </NuxtLink>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { useAuthStore } from '~/stores/auth'

const config = useRuntimeConfig()
const router = useRouter()
const authStore = useAuthStore()

const loginUrl = `${config.public.apiBase}/auth/google/redirect`

const mode = ref('login')
const name = ref('')
const email = ref('')
const password = ref('')
const loading = ref(false)
const error = ref('')
const success = ref('')

// Formulaire de connexion classique
const loginForm = reactive({
  email: '',
  password: ''
})

// Gestion de la connexion classique
const handleLogin = async () => {
  error.value = ''
  success.value = ''
  loading.value = true

  try {
    await authStore.login({
      email: email.value,
      password: password.value,
    })
    // Récupérer les infos utilisateur
    await authStore.fetchUser()
    // Redirection vers dashboard
    router.push('/dashboard')
  } catch (e: any) {
    error.value = e?.data?.message || e?.message || 'Erreur de connexion'
    console.error('Erreur de connexion:', e)
  } finally {
    loading.value = false
  }
}

// OAuth Google (Web)
const handleGoogleLogin = () => {
  authStore.redirectToGoogle()
  // Le backend redirige vers Google OAuth
  // Après succès, retour sur /dashboard?token=...
}

// Gestion de l'inscription
const handleRegister = async () => {
  error.value = ''
  success.value = ''
  loading.value = true

  try {
    await authStore.register({
      name: name.value,
      email: email.value,
      password: password.value,
    })
    success.value = 'Inscription réussie ! Vous pouvez maintenant vous connecter.'
    // Switch to login mode après inscription
    setTimeout(() => {
      mode.value = 'login'
      password.value = ''
    }, 1500)
  } catch (e: any) {
    error.value = e?.data?.message || e?.message || 'Erreur lors de l\'inscription'
  } finally {
    loading.value = false
  }
}

// Gestion du formulaire selon le mode
const handleSubmit = async () => {
  if (mode.value === 'register') {
    await handleRegister()
  } else {
    await handleLogin()
  }
}
</script>