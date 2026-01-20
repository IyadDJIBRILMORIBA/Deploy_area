<script setup lang="ts">
import { BoltIcon, ArrowPathIcon, ShieldCheckIcon } from '@heroicons/vue/24/outline'

// Animation au scroll
const { y } = useWindowScroll()
const heroScale = computed(() => Math.max(1 - y.value / 1000, 0.95))

</script>

<template>
  <div class="bg-gradient-to-b from-white via-indigo-50 to-blue-50">
    
    <!-- Navigation -->
    <nav class="fixed top-0 w-full bg-white/90 backdrop-blur shadow-sm z-50">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="flex justify-between items-center h-16">
          
          <!-- Logo -->
          <div class="flex items-center gap-3">
            <div class="flex items-center justify-center w-10 h-10 bg-gradient-to-br from-indigo-600 to-blue-500 rounded-xl shadow-md">
              <svg class="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                  d="M13 10V3L4 14h7v7l9-11h-7z"></path>
              </svg>
            </div>
            <span class="font-bold text-2xl tracking-tight text-gray-900">AREA</span>
          </div>

          <!-- Login Button -->
          <NuxtLink 
            to="/login"
            class="bg-gradient-to-r from-indigo-600 to-blue-500 hover:from-indigo-700 hover:to-blue-600 text-white font-semibold py-2 px-6 rounded-lg transition-all hover:scale-105 shadow-md"
          >
            Inscription/Connection
          </NuxtLink>
        </div>
      </div>
    </nav>

    <!-- Hero Section -->
    <section class="pt-32 pb-20 px-4 sm:px-6 lg:px-8 relative overflow-hidden">
      <!-- Background Effects -->
      <div class="absolute inset-0 overflow-hidden pointer-events-none">
        <div class="absolute -top-40 -right-40 w-96 h-96 bg-indigo-400/20 rounded-full blur-3xl animate-pulse-slow"></div>
        <div class="absolute -bottom-40 -left-40 w-96 h-96 bg-blue-400/20 rounded-full blur-3xl animate-pulse-slow" style="animation-delay: 1s"></div>
      </div>

      <div class="max-w-4xl mx-auto text-center relative z-10">
        
        <!-- Badge -->
        <div class="inline-flex items-center gap-2 px-4 py-2 bg-indigo-100 text-indigo-700 rounded-full border border-indigo-200 mb-6 animate-slide-down">
          <span class="w-2 h-2 rounded-full bg-green-500 animate-ping"></span>
          <span class="w-2 h-2 rounded-full bg-green-500 absolute animate-pulse"></span>
          Automatisation d'applications web
        </div>

        <!-- Title -->
        <h1 class="text-5xl sm:text-7xl font-bold text-gray-900 mb-6 leading-tight animate-fade-in-up">
          Automatisez vos 
          <span class="bg-gradient-to-r from-indigo-600 via-blue-500 to-purple-600 bg-clip-text text-transparent animate-gradient">
            tâches quotidiennes
          </span>
        </h1>

        <!-- Subtitle -->
        <p class="text-xl text-gray-600 mb-10 max-w-2xl mx-auto leading-relaxed animate-fade-in-up" style="animation-delay: 0.2s">
          Connectez vos services favoris et créez des workflows puissants en quelques clics.
        </p>

        <!-- CTA -->
        <div class="flex flex-col sm:flex-row justify-center gap-4 mb-8 animate-fade-in-up" style="animation-delay: 0.4s">
          <NuxtLink 
            to="/login"
            class="group bg-gradient-to-r from-indigo-600 to-blue-500 hover:from-indigo-700 hover:to-blue-600 text-white font-bold py-4 px-8 rounded-lg text-lg transition-all hover:scale-105 hover:shadow-2xl shadow-lg shadow-indigo-500/50"
          >
            <span class="flex items-center justify-center gap-2">
              Commencer maintenant
              <svg class="w-5 h-5 group-hover:translate-x-1 transition-transform" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 7l5 5m0 0l-5 5m5-5H6"></path>
              </svg>
            </span>
          </NuxtLink>

          <a href="#features" class="border-2 border-gray-300 hover:border-indigo-500 text-gray-800 hover:text-indigo-600 font-bold py-4 px-8 rounded-lg text-lg transition-all hover:scale-105 hover:shadow-xl">
            En savoir plus
          </a>
        </div>

        <!-- Bouton de téléchargement APK -->
        <div class="flex justify-center mb-16 animate-fade-in-up" style="animation-delay: 0.6s">
          <a 
            href="/mobile/client.apk" 
            download="area-client.apk"
            class="group flex items-center gap-2 px-6 py-3 bg-gradient-to-r from-green-600 to-emerald-600 hover:from-green-700 hover:to-emerald-700 text-white font-bold rounded-lg shadow-lg shadow-green-500/30 transition-all hover:scale-105 hover:shadow-2xl"
          >
            <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6 group-hover:animate-bounce" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-4l-4 4m0 0l-4-4m4 4V4" />
            </svg>
            <span>Télécharger l'app Android (.apk)</span>
          </a>
        </div>

        <!-- Hero Graphic -->
        <div class="relative h-96 bg-gradient-to-br from-indigo-100 via-blue-100 to-purple-100 rounded-2xl shadow-2xl overflow-hidden animate-fade-in-up" style="animation-delay: 0.8s">
          <div class="absolute inset-0 flex items-center justify-center opacity-10">
            <div class="text-7xl font-black tracking-wider text-gray-600">ACTION → REACTION</div>
          </div>

          <!-- Service Cards with animations -->
          <div class="absolute top-10 left-10 w-32 h-24 bg-white rounded-xl shadow-xl flex items-center justify-center text-sm font-bold border border-gray-100 hover:scale-110 transition-transform duration-300 animate-float" style="animation-delay: 0s">
            📅 Calendar
          </div>
          <div class="absolute bottom-10 left-40 w-24 h-24 bg-white rounded-xl shadow-xl flex items-center justify-center text-2xl hover:scale-110 transition-transform duration-300 animate-float" style="animation-delay: 0.5s">
            💬
          </div>
          <div class="absolute top-1/2 right-20 w-32 h-24 bg-white rounded-xl shadow-xl flex items-center justify-center text-sm font-bold border border-gray-100 hover:scale-110 transition-transform duration-300 animate-float" style="animation-delay: 1s">
            🎯 Focus
          </div>
          <div class="absolute bottom-20 right-10 w-28 h-24 bg-white rounded-xl shadow-xl flex items-center justify-center text-sm font-bold border border-gray-100 hover:scale-110 transition-transform duration-300 animate-float" style="animation-delay: 1.5s">
            ⚡ Action
          </div>
        </div>
      </div>
    </section>
   <!-- Features Section -->
    <section id="features" class="py-20 px-4 sm:px-6 lg:px-8 bg-gradient-to-b from-blue-50 to-indigo-50">
      <div class="max-w-6xl mx-auto">
        <h2 class="text-3xl sm:text-4xl font-bold text-gray-900 text-center mb-12">
          Tout ce dont tu as besoin
        </h2>

        <div class="grid gap-8 md:grid-cols-3">
          <div class="bg-white rounded-2xl shadow-md p-6 border border-indigo-50">
            <div class="w-10 h-10 rounded-xl bg-indigo-100 text-indigo-600 flex items-center justify-center mb-4">
              <BoltIcon class="w-6 h-6" />
            </div>
            <h3 class="font-semibold text-lg mb-2 text-gray-900">Automatisations rapides</h3>
            <p class="text-gray-600 text-sm">
              Crée des scénarios en quelques clics pour connecter tes applications web.
            </p>
          </div>

          <div class="bg-white rounded-2xl shadow-md p-6 border border-indigo-50">
            <div class="w-10 h-10 rounded-xl bg-blue-100 text-blue-600 flex items-center justify-center mb-4">
              <ArrowPathIcon class="w-6 h-6" />
            </div>
            <h3 class="font-semibold text-lg mb-2 text-gray-900">Workflows fiables</h3>
            <p class="text-gray-600 text-sm">
              Tes automatisations tournent en continu avec des logs clairs et détaillés.
            </p>
          </div>

          <div class="bg-white rounded-2xl shadow-md p-6 border border-indigo-50">
            <div class="w-10 h-10 rounded-xl bg-violet-100 text-violet-600 flex items-center justify-center mb-4">
              <ShieldCheckIcon class="w-6 h-6" />
            </div>
            <h3 class="font-semibold text-lg mb-2 text-gray-900">Sécurité intégrée</h3>
            <p class="text-gray-600 text-sm">
              Données protégées, permissions maîtrisées, idéal pour des intégrations d’école ou pro.
            </p>
          </div>
        </div>
      </div>
    </section>

    <!-- Footer -->
    <footer class="border-t border-indigo-100 bg-white/80 backdrop-blur py-6 mt-10">
      <div class="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8 flex flex-col sm:flex-row items-center justify-between gap-4">
        <p class="text-sm text-gray-500">
          © {{ new Date().getFullYear() }} AREA. Tous droits réservés.
        </p>
        <div class="flex gap-4 text-sm text-gray-500">
          <a href="#features" class="hover:text-indigo-600">Fonctionnalités</a>
          <NuxtLink to="/login" class="hover:text-indigo-600">Connexion</NuxtLink>
          <NuxtLink to="/dashboard" class="hover:text-indigo-600">Dashboard</NuxtLink>
        </div>
      </div>
    </footer>
  </div>
</template>

<style scoped>
/* Animations personnalisées */
@keyframes fadeIn {
  from { opacity: 0; transform: translateY(20px); }
  to { opacity: 1; transform: translateY(0); }
}

@keyframes fade-in-up {
  from { 
    opacity: 0; 
    transform: translateY(30px); 
  }
  to { 
    opacity: 1; 
    transform: translateY(0); 
  }
}

@keyframes slide-down {
  from {
    opacity: 0;
    transform: translateY(-20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

@keyframes float {
  0%, 100% {
    transform: translateY(0px);
  }
  50% {
    transform: translateY(-20px);
  }
}

@keyframes pulse-slow {
  0%, 100% {
    opacity: 0.6;
    transform: scale(1);
  }
  50% {
    opacity: 0.8;
    transform: scale(1.05);
  }
}

@keyframes gradient {
  0%, 100% {
    background-position: 0% 50%;
  }
  50% {
    background-position: 100% 50%;
  }
}

.animate-fadeIn {
  animation: fadeIn 0.8s ease-out;
}

.animate-fade-in-up {
  animation: fade-in-up 0.8s ease-out forwards;
  opacity: 0;
}

.animate-slide-down {
  animation: slide-down 0.6s ease-out;
}

.animate-float {
  animation: float 3s ease-in-out infinite;
}

.animate-pulse-slow {
  animation: pulse-slow 4s ease-in-out infinite;
}

.animate-gradient {
  background-size: 200% 200%;
  animation: gradient 3s ease infinite;
}
</style>
