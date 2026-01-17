<script setup lang="ts">
import { BoltIcon, ArrowPathIcon, ShieldCheckIcon } from '@heroicons/vue/24/outline'
</script>

<template>
  <div class="min-h-screen bg-gradient-to-b from-white via-indigo-50 to-blue-50">
    
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
    <section class="pt-32 pb-20 px-4 sm:px-6 lg:px-8">
      <div class="max-w-4xl mx-auto text-center animate-fadeIn">
        
        <!-- Badge -->
        <div class="inline-flex items-center gap-2 px-4 py-2 bg-indigo-100 text-indigo-700 rounded-full border border-indigo-200 mb-6">
          <span class="w-2 h-2 rounded-full bg-green-500 animate-pulse"></span>
          Automatisation d'applications web
        </div>

        <!-- Title -->
        <h1 class="text-5xl sm:text-7xl font-bold text-gray-900 mb-6 leading-tight">
          Automatisez vos 
          <span class="bg-gradient-to-r from-indigo-600 to-blue-500 bg-clip-text text-transparent">
            tâches quotidiennes
          </span>
        </h1>

        <!-- Subtitle -->
        <p class="text-xl text-gray-600 mb-10 max-w-2xl mx-auto leading-relaxed">
          Connectez vos services favoris et créez des workflows puissants en quelques clics.
        </p>

        <!-- CTA -->
        <div class="flex flex-col sm:flex-row justify-center gap-4 mb-16">
          <NuxtLink 
            to="/login"
            class="bg-gradient-to-r from-indigo-600 to-blue-500 hover:from-indigo-700 hover:to-blue-600 text-white font-bold py-4 px-8 rounded-lg text-lg transition-all hover:scale-105 shadow-lg"
          >
            Commencer maintenant
          </NuxtLink>

          <a href="#features" class="border-2 border-gray-300 hover:border-indigo-500 text-gray-800 hover:text-indigo-600 font-bold py-4 px-8 rounded-lg text-lg transition-colors">
            En savoir plus
          </a>
        </div>

        <!-- Hero Graphic -->
        <div class="relative h-96 bg-gradient-to-br from-indigo-100 to-blue-100 rounded-2xl shadow-xl overflow-hidden">
          <div class="absolute inset-0 flex items-center justify-center opacity-40">
            <div class="text-7xl">ACTION REACTION</div>
          </div>

          <div class="absolute top-10 left-10 w-30 h-20 bg-white rounded-xl shadow-lg flex items-center justify-center text-1xl">Calendar</div>
          <div class="absolute bottom-10 left-50 w-20 h-20 bg-white rounded-xl shadow-lg flex items-center justify-center text-2xl">Sms</div>
          <div class="absolute top-1/2 right-20 w-30 h-20 bg-white rounded-xl shadow-lg flex items-center justify-center text-2xl">Focus</div>
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
@keyframes fadeIn {
  from { opacity: 0; transform: translateY(20px); }
  to { opacity: 1; transform: translateY(0); }
}
.animate-fadeIn {
  animation: fadeIn 0.8s ease-out;
}
</style>
