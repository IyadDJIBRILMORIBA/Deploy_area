// https://nuxt.com/docs/api/configuration/nuxt-config
import tailwindcss from "@tailwindcss/vite";

export default defineNuxtConfig({
  compatibilityDate: '2025-07-15',
  devtools: { enabled: true },
  modules: [
    '@nuxt/content',
    '@nuxt/image',
    '@nuxt/ui',
    '@pinia/nuxt',
  ],
  css: ['./app/assets/css/main.css'],
  ssr: false, // Désactiver SSR pour éviter les hydration mismatches
  vite: {
    plugins: [tailwindcss()],
  },
  runtimeConfig: {
    public: {
      apiBase: 'http://localhost:8000',
    },
  },
})
