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
      apiBase: process.env.NUXT_PUBLIC_API_BASE_URL
    },
  },
  app: {
    head: {
      htmlAttrs: {
        lang: 'en'
      },
      title: 'AREA - Automation Platform',
      meta: [
        { name: 'description', content: 'Automation platform linking services together.' }
      ]
    }
  }
})
