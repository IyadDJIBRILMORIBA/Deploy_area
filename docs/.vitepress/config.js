import { defineConfig } from 'vitepress'

export default defineConfig({
  title: 'AREA Documentation',
  description: 'Documentation complète du projet AREA - Plateforme d\'automatisation Action-REAction',
  base: '/',
  
  themeConfig: {
    logo: '/logo.svg',
    
    nav: [
      { text: 'Accueil', link: '/' },
      { text: 'Guide', link: '/introduction' },
      { text: 'API', link: '/API_Documentation' },
      { text: 'GitHub', link: 'https://github.com/VOTRE-USERNAME/G-DEV-500-COT-5-2-area-8' }
    ],

    sidebar: [
      {
        text: '🚀 Démarrage',
        collapsed: false,
        items: [
          { text: 'Introduction', link: '/introduction' },
          { text: 'Guide de Configuration', link: '/Guide_Configuration' },
          { text: 'Guide Docker', link: '/Guide Docker' },
        ]
      },
      {
        text: '📚 Architecture',
        collapsed: false,
        items: [
          { text: 'Architecture du Projet', link: '/architecture' },
          { text: 'Architecture du Repository', link: '/Architecture du Repository' },
          { text: 'Choix Technologiques', link: '/État de l\'Art _ Choix de la stack technologique' },
        ]
      },
      {
        text: '🔌 API & Services',
        collapsed: false,
        items: [
          { text: 'Documentation API', link: '/API_Documentation' },
          { text: 'Routes API', link: '/API_ROUTES' },
          { text: 'Guide des Services', link: '/SERVICES_GUIDE' },
          { text: 'OAuth Setup', link: '/OAUTH_SETUP_GUIDE' },
        ]
      },
      {
        text: '🧪 Tests & CI/CD',
        collapsed: false,
        items: [
          { text: 'Résumé des Tests', link: '/TESTS_SUMMARY' },
          { text: 'Configuration CI/CD', link: '/CI_CD_SETUP' },
        ]
      },
      {
        text: '⚙️ DevOps & Automatisation',
        collapsed: false,
        items: [
          { text: 'CRON & Automation', link: '/CRON_AUTOMATION' },
          { text: 'Fixes Timer & Overflow', link: '/FIXES_TIMER_AND_OVERFLOW' },
        ]
      },
      {
        text: '📖 Guides Techniques',
        collapsed: false,
        items: [
          { text: 'Documentation Technique', link: '/Documentation_Technique' },
          { text: 'Guide de Contribution', link: '/Guide_Contribution' },
        ]
      },
      {
        text: '📋 Gestion de Projet',
        collapsed: false,
        items: [
          { text: 'Planification', link: '/Planification du Projet' },
          { text: 'Roadmap', link: '/ROADMAP' },
          { text: 'Organisation de l\'Équipe', link: '/Organisation de l\'Équipe et Processus de Travail' },
          { text: 'Contributors', link: '/CONTRIBUTORS' },
          { text: 'CHANGELOG', link: '/CHANGELOG' },
        ]
      }
    ],

    socialLinks: [
      { icon: 'github', link: 'https://github.com/VOTRE-USERNAME/G-DEV-500-COT-5-2-area-8' }
    ],

    footer: {
      message: 'Publié sous licence MIT',
      copyright: 'Copyright © 2024-2026 AREA Team'
    },

    search: {
      provider: 'local'
    },

    editLink: {
      pattern: 'https://github.com/VOTRE-USERNAME/G-DEV-500-COT-5-2-area-8/edit/main/docs/:path',
      text: 'Modifier cette page sur GitHub'
    },

    lastUpdated: {
      text: 'Dernière mise à jour',
      formatOptions: {
        dateStyle: 'short',
        timeStyle: 'short'
      }
    },

    outline: {
      level: [2, 3],
      label: 'Sur cette page'
    },

    docFooter: {
      prev: 'Page précédente',
      next: 'Page suivante'
    }
  },

  markdown: {
    lineNumbers: true,
    theme: {
      light: 'github-light',
      dark: 'github-dark'
    }
  }
})
