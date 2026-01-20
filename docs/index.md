---
layout: home

hero:
  name: "AREA"
  text: "Action-REAction Platform"
  tagline: Automatisez vos tâches en interconnectant vos services préférés
  image:
    src: /hero-image.svg
    alt: AREA Platform
  actions:
    - theme: brand
      text: Démarrer
      link: /introduction
    - theme: alt
      text: Documentation API
      link: /API_Documentation
    - theme: alt
      text: Guide Docker
      link: /Guide Docker

features:
  - icon: 🔌
    title: Services Intégrés
    details: Gmail, GitHub, Slack, Discord, Weather, Trello, Twitch et plus encore
  - icon: ⚡
    title: Automatisation Puissante
    details: Créez des workflows conditionnels avec triggers et actions personnalisés
  - icon: 🐳
    title: Docker & CI/CD
    details: Déploiement avec Docker Compose + Tests automatisés via GitHub Actions
  - icon: 🔐
    title: OAuth Sécurisé
    details: Authentification via Google, GitHub et autres providers OAuth 2.0
  - icon: 🧪
    title: Tests Complets
    details: 31+ tests unitaires et fonctionnels avec PHPUnit + Couverture de code
  - icon: 📱
    title: Multi-plateforme
    details: Web (Nuxt), Mobile (Flutter) et API REST (Laravel)
  - icon: 🔄
    title: Temps Réel
    details: Polling intelligent et webhooks pour des réactions instantanées
  - icon: 📊
    title: Monitoring
    details: Logs détaillés, métriques et historique d'exécution
---

## 🚀 Démarrage Rapide

```bash
# Cloner le projet
git clone https://github.com/VOTRE-USERNAME/G-DEV-500-COT-5-2-area-8.git
cd G-DEV-500-COT-5-2-area-8

# Lancer avec Docker
docker-compose up -d

# Accéder à l'application
# Web: http://localhost:8081
# API: http://localhost:8080
```

## 📚 Documentation

<div class="tip custom-block" style="padding-top: 8px">

Explorez la documentation complète pour apprendre à :
- Configurer et déployer AREA
- Créer vos propres workflows d'automatisation
- Intégrer de nouveaux services
- Contribuer au projet

</div>

## 🏗️ Architecture

AREA est composé de 3 micro-services :

| Service | Technologie | Port | Description |
|---------|-------------|------|-------------|
| **Backend** | Laravel 11 (PHP 8.2+) | 8080 | API REST, logique métier, polling & webhooks |
| **Frontend Web** | Nuxt 3 (Vue.js) | 8081 | Interface utilisateur responsive |
| **Mobile** | Flutter | N/A | Application Android native |

## 🎯 Services Supportés

- **Timer** - Déclencheurs temporels (interval, heure fixe)
- **Google** - Gmail, Calendar
- **GitHub** - Issues, Pull Requests, Commits
- **Slack** - Messages, Channels, Reactions
- **Discord** - Messages, Webhooks
- **Weather** - OpenWeatherMap (conditions, température)
- **Trello** - Cartes, Listes, Boards
- **Twitch** - Stream online, Followers

## 💡 Exemple de Workflow

```yaml
Trigger: "Température à Paris < 15°C"
Action: "Envoyer un message Slack"

Trigger: "Nouvelle issue GitHub"
Action: "Créer une carte Trello"

Trigger: "Tous les lundis à 9h"
Action: "Envoyer un email récapitulatif"
```

# 📚 Documentation AREA

Bienvenue dans la documentation complète du projet AREA (Action-REAction).

## 📖 Documentation Principale

### Démarrage Rapide
- [README](./README.md) - Vue d'ensemble du projet
- [Guide de Configuration](./Guide_Configuration.md) - Configuration complète
- [Guide Docker](./Guide%20Docker.md) - Déploiement avec Docker

### Documentation Technique
- [Documentation Technique](./Documentation_Technique.md) - Architecture et implémentation complètes
- [Architecture](./architecture.md) - Schéma d'architecture
- [Architecture du Repository](./Architecture%20du%20Repository.md) - Structure du projet

### API et Routes
- [Documentation API](./API_Documentation.md) - Spécifications API REST
- [Routes API](./API_ROUTES.md) - Liste des endpoints disponibles
- [Guide des Services](./SERVICES_GUIDE.md) - Services intégrés (Gmail, Timer, etc.)

### Développement
- [Guide de Contribution](./Guide_Contribution.md) - Comment contribuer au projet
- [CHANGELOG](./CHANGELOG.md) - Historique des modifications
- [État de l'Art](./État%20de%20l%27Art%20_%20Choix%20de%20la%20stack%20technologique.md) - Choix techniques

### Automatisation
- [Cron Automation](./CRON_AUTOMATION.md) - Système d'automatisation des AREAs

### Gestion de Projet
- [Planification](./Planification%20du%20Projet.md) - Planning et jalons
- [Organisation de l'Équipe](./Organisation%20de%20l%27Équipe%20et%20Processus%20de%20Travail.md) - Workflow et rôles

## Liens Rapides

- **Backend** : Laravel 11 + MySQL
- **Frontend** : Nuxt 3 + Vue 3 + Tailwind CSS
- **Services** : Gmail API, Timer, OpenWeatherMap
- **Automatisation** : Laravel Scheduler + Cron

## Besoin d'Aide ?

1. Consultez le [README](./README.md) pour une vue d'ensemble
2. Suivez le [Guide de Configuration](./Guide_Configuration.md) pour l'installation
3. Lisez la [Documentation Technique](./Documentation_Technique.md) pour les détails d'implémentation
4. Consultez le [CHANGELOG](./CHANGELOG.md) pour l'historique des modifications

---

Dernière mise à jour : 8 décembre 2025
