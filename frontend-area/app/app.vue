<template>
  <div class="h-screen w-screen overflow-hidden bg-gray-50">
    <NuxtPage />
  </div>
</template>

<style>
/* CSS GLOBAL : Supprime les marges blanches du navigateur */
html, body, #__nuxt {
  height: 100%;
  width: 100%;
  margin: 0;
  padding: 0;
  background-color: #f9fafb; /* Correspond au gray-50 de Tailwind */
  overflow: hidden; /* Empêche le scroll sur le body (on scroll dans les composants) */
}
</style>