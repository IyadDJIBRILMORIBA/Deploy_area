# Guide d'utilisation de Docker pour le projet AREA

## Table des matières
1. [Introduction à Docker](#introduction-à-docker)
2. [Avantages de Docker](#avantages-de-docker)
3. [Architecture Docker du projet](#architecture-docker-du-projet)
4. [Commandes essentielles](#commandes-essentielles)
5. [Gestion des services](#gestion-des-services)
6. [Dépannage](#dépannage)
7. [Bonnes pratiques](#bonnes-pratiques)

---

## Introduction à Docker

Docker est une plateforme de conteneurisation qui permet d'empaqueter une application et toutes ses dépendances dans un conteneur isolé. Un conteneur est une unité logicielle standardisée qui contient tout ce dont l'application a besoin pour s'exécuter.

### Concepts clés

- **Image** : Modèle en lecture seule contenant l'application et ses dépendances
- **Conteneur** : Instance en cours d'exécution d'une image
- **Volume** : Système de stockage persistant pour les données
- **Docker Compose** : Outil pour définir et exécuter des applications multi-conteneurs
- **Dockerfile** : Fichier de configuration pour construire une image

---

## Avantages de Docker

### 1. **Isolation et portabilité**
- Chaque service s'exécute dans son propre environnement isolé
- "Ça marche sur ma machine" → "Ça marche partout"
- Déploiement identique en développement, test et production

### 2. **Reproductibilité**
```bash
# Même commande sur n'importe quelle machine
docker-compose up --build
```
- Environnement identique pour toute l'équipe
- Versions des dépendances figées (Node 22, PHP 8.2, MariaDB 10.11)
- Pas de "dépend de ce qui est installé sur ton système"

### 3. **Gestion simplifiée des dépendances**
- Pas besoin d'installer PHP, Node.js, MariaDB localement
- Pas de conflit entre versions (ex: projet A utilise PHP 7, projet B utilise PHP 8)
- Installation automatique des dépendances au build

### 4. **Développement rapide**
- Démarrage de toute la stack en une commande
- Hot-reload : modifications détectées automatiquement
- Pas de configuration manuelle complexe

### 5. **Scalabilité**
- Facile de dupliquer un service (ex: plusieurs instances backend)
- Ajout de nouveaux services sans impacter les existants
- Load balancing simplifié

### 6. **Sécurité**
- Isolation entre les conteneurs (un conteneur compromis n'affecte pas les autres)
- Réseau interne isolé
- Contrôle précis des permissions

### 7. **CI/CD optimisé**
- Build et tests dans des environnements identiques
- Déploiement continu simplifié
- Rollback facile en cas de problème

---

## Architecture Docker du projet

Notre projet AREA utilise **4 services** orchestrés par Docker Compose :

```
┌─────────────────────────────────────────────────────────┐
│                    Docker Network (area_network)         │
│                                                          │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │   Backend    │  │   Frontend   │  │   Database   │  │
│  │   Laravel    │  │     Nuxt     │  │   MariaDB    │  │
│  │   PHP 8.2    │  │   Node 22    │  │    10.11     │  │
│  │  Port 8080   │  │  Port 8081   │  │  Port 3306   │  │
│  └──────────────┘  └──────────────┘  └──────────────┘  │
│         │                  │                  │          │
│         └──────────────────┴──────────────────┘          │
│                            │                             │
│                   ┌──────────────┐                       │
│                   │    Mobile    │                       │
│                   │   Flutter    │                       │
│                   │ APK Builder  │                       │
│                   └──────────────┘                       │
└─────────────────────────────────────────────────────────┘
```

### Services définis

| Service | Image | Port | Description |
|---------|-------|------|-------------|
| **db** | `mariadb:10.11` | 3306 (interne) | Base de données MySQL |
| **server** | Custom (PHP 8.2-fpm) | 8080 | API Backend Laravel 12 |
| **client_web** | Custom (Node 22) | 8081 | Frontend Nuxt 4 |
| **client_mobile** | Custom (Flutter) | - | Builder APK Android |

### Volumes

| Volume | Utilisation |
|--------|-------------|
| `db_data` | Données persistantes MariaDB |
| `apk_volume` | Stockage de l'APK compilé |

---

## Commandes essentielles

### Démarrage et arrêt

```bash
# Démarrer tous les services (en arrière-plan)
docker-compose up -d

# Démarrer avec rebuild des images
docker-compose up --build -d

# Arrêter tous les services
docker-compose down

# Arrêter et supprimer les volumes (⚠️ perte de données)
docker-compose down -v
```

### Monitoring et logs

```bash
# Voir l'état des conteneurs
docker-compose ps

# Voir les logs de tous les services
docker-compose logs

# Suivre les logs en temps réel
docker-compose logs -f

# Logs d'un service spécifique
docker-compose logs server
docker-compose logs -f client_web

# Dernières 50 lignes
docker-compose logs --tail=50 server
```

### Gestion des services

```bash
# Redémarrer un service
docker-compose restart server

# Arrêter un service
docker-compose stop client_mobile

# Démarrer un service arrêté
docker-compose start client_mobile

# Reconstruire un service
docker-compose build server
docker-compose up -d --build server
```

### Exécution de commandes dans les conteneurs

```bash
# Backend Laravel
docker-compose exec server php artisan migrate
docker-compose exec server php artisan tinker
docker-compose exec server composer install

# Frontend Nuxt
docker-compose exec client_web npm install
docker-compose exec client_web npm run build

# Base de données
docker-compose exec db mysql -u root -p

# Accès shell
docker-compose exec server bash
docker-compose exec client_web sh
```

### Inspection et debug

```bash
# Inspecter un conteneur
docker inspect area_server

# Voir l'utilisation des ressources
docker stats

# Voir les réseaux Docker
docker network ls
docker network inspect g-dev-500-cot-5-2-area-8_area_network

# Voir les volumes
docker volume ls
docker volume inspect g-dev-500-cot-5-2-area-8_db_data
```

---

## Gestion des services

### Backend Laravel (server)

```bash
# Migrations de base de données
docker-compose exec server php artisan migrate

# Réinitialiser la base de données
docker-compose exec server php artisan migrate:fresh

# Créer un contrôleur
docker-compose exec server php artisan make:controller NomController

# Nettoyer le cache
docker-compose exec server php artisan cache:clear
docker-compose exec server php artisan config:clear

# Voir les routes
docker-compose exec server php artisan route:list
```

### Frontend Nuxt (client_web)

```bash
# Installer une nouvelle dépendance
docker-compose exec client_web npm install nom-package

# Rebuild du frontend
docker-compose restart client_web

# Accéder au shell
docker-compose exec client_web sh
```

### Base de données (db)

```bash
# Connexion MySQL
docker-compose exec db mysql -u root -p${MYSQL_ROOT_PASSWORD}

# Backup de la base de données
docker-compose exec db mysqldump -u root -p${MYSQL_ROOT_PASSWORD} ${MYSQL_DATABASE} > backup.sql

# Restaurer une base de données
docker-compose exec -T db mysql -u root -p${MYSQL_ROOT_PASSWORD} ${MYSQL_DATABASE} < backup.sql

# Voir les bases de données
docker-compose exec db mysql -u root -p${MYSQL_ROOT_PASSWORD} -e "SHOW DATABASES;"
```

### Mobile Flutter (client_mobile)

```bash
# Voir les logs de compilation
docker-compose logs -f client_mobile

# Récupérer l'APK compilé
sudo cp /var/lib/docker/volumes/g-dev-500-cot-5-2-area-8_apk_volume/_data/client.apk ./client.apk

# Reconstruire l'APK
docker-compose up --build client_mobile
```

---

## Dépannage

### Service ne démarre pas

```bash
# Voir les erreurs détaillées
docker-compose logs service_name

# Reconstruire l'image
docker-compose build --no-cache service_name
docker-compose up -d service_name

# Vérifier le Dockerfile
cat service_folder/Dockerfile
```

### Port déjà utilisé

```bash
# Identifier le processus utilisant le port 8080
sudo lsof -i :8080

# Tuer le processus
sudo kill -9 PID

# Ou modifier le port dans docker-compose.yml
ports:
  - "8090:8000"  # Utiliser 8090 au lieu de 8080
```

### Problèmes de permissions

```bash
# Donner les permissions au dossier
sudo chown -R $USER:$USER ./backend-area

# Dans le conteneur
docker-compose exec server chmod -R 777 storage bootstrap/cache
```

### Base de données inaccessible

```bash
# Vérifier que le conteneur db est healthy
docker-compose ps

# Vérifier les logs
docker-compose logs db

# Tester la connexion
docker-compose exec server php artisan migrate:status
```

### Rebuild complet du projet

```bash
# Arrêter et supprimer tout
docker-compose down -v

# Nettoyer les images
docker system prune -a

# Reconstruire tout
docker-compose up --build -d
```

### Problèmes de réseau

```bash
# Recréer le réseau
docker-compose down
docker network prune
docker-compose up -d

# Vérifier la connectivité entre services
docker-compose exec server ping db
docker-compose exec client_web ping server
```

---

## Bonnes pratiques

### 1. **Utiliser des variables d'environnement**

```yaml
# docker-compose.yml
environment:
  - DB_HOST=${DB_HOST:-db}
  - DB_PORT=${DB_PORT:-3306}
```

### 2. **Ne jamais commiter les fichiers sensibles**

```bash
# .gitignore
.env
*.log
db_data/
node_modules/
vendor/
```

### 3. **Optimiser les Dockerfiles**

```dockerfile
# ❌ Mauvais : plusieurs RUN
RUN apt-get update
RUN apt-get install -y package1
RUN apt-get install -y package2

# Bon : un seul RUN
RUN apt-get update && apt-get install -y \
    package1 \
    package2 \
    && rm -rf /var/lib/apt/lists/*
```

### 4. **Utiliser des tags de version précis**

```yaml
# Mauvais
image: node:latest

# Bon
image: node:22-alpine
```

### 5. **Gérer les volumes correctement**

```yaml
volumes:
  # Code source (développement)
  - ./backend-area:/var/www

  # Données persistantes
  - db_data:/var/lib/mysql

  # Éviter de monter node_modules
  - /var/www/node_modules
```

### 6. **Health checks pour la base de données**

```yaml
healthcheck:
  test: ["CMD", "mysqladmin", "ping", "-h", "localhost"]
  interval: 10s
  timeout: 5s
  retries: 5
```

### 7. **Nettoyer régulièrement**

```bash
# Supprimer les conteneurs arrêtés
docker container prune

# Supprimer les images non utilisées
docker image prune -a

# Supprimer les volumes non utilisés
docker volume prune

# Tout nettoyer
docker system prune -a --volumes
```

### 8. **Logs et monitoring**

```bash
# Limiter la taille des logs
docker-compose.yml:
  logging:
    driver: "json-file"
    options:
      max-size: "10m"
      max-file: "3"
```

---

## Workflow de développement avec Docker

### Setup initial

```bash
# 1. Cloner le projet
git clone https://github.com/EpitechPGE3-2025/G-DEV-500-COT-5-2-area-8.git
cd G-DEV-500-COT-5-2-area-8

# 2. Copier les fichiers d'environnement
cp backend-area/.env.example backend-area/.env

# 3. Démarrer Docker
docker-compose up --build -d

# 4. Vérifier que tout fonctionne
docker-compose ps
```

### Développement quotidien

```bash
# Matin : démarrer la stack
docker-compose up -d

# Développer normalement
# Les modifications sont détectées automatiquement (hot-reload)

# Voir les logs si problème
docker-compose logs -f server

# Soir : arrêter la stack
docker-compose down
```

### Tester une feature

```bash
# 1. Créer une branche
git checkout -b feature/nouvelle-fonctionnalite

# 2. Faire vos modifications

# 3. Rebuild si changement de dépendances
docker-compose up --build -d

# 4. Tester
curl http://localhost:8080/api/test

# 5. Commit et push
git add .
git commit -m "Ajout nouvelle fonctionnalité"
git push origin feature/nouvelle-fonctionnalite
```

---

## Comparaison : Avec vs Sans Docker

### ❌ Sans Docker

```bash
# Installation manuelle sur chaque machine
sudo apt install php8.2 php8.2-fpm php8.2-mysql php8.2-xml...
curl -sL https://deb.nodesource.com/setup_22.x | sudo -E bash -
sudo apt install nodejs
sudo apt install mariadb-server
# ... configuration manuelle de tout

# Problèmes courants :
# - "Ça marche chez moi mais pas chez toi"
# - Conflit de versions
# - Configuration différente entre dev et prod
# - Onboarding d'un nouveau dev = 1 journée
```

### Avec Docker

```bash
# Une seule commande
docker-compose up --build -d

# Avantages :
# Même environnement pour tous
# Setup en 5 minutes
# Pas de conflit
# Déploiement identique partout
```

---

## Ressources et références

### Documentation officielle
- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Best Practices](https://docs.docker.com/develop/dev-best-practices/)

### Images utilisées dans le projet
- [MariaDB](https://hub.docker.com/_/mariadb)
- [PHP-FPM](https://hub.docker.com/_/php)
- [Node.js](https://hub.docker.com/_/node)
- [Flutter](https://hub.docker.com/r/cirrusci/flutter)

### Commandes de référence rapide

```bash
# Démarrer
docker-compose up -d

# Arrêter
docker-compose down

# Logs
docker-compose logs -f

# Rebuild
docker-compose up --build -d

# Status
docker-compose ps

# Shell
docker-compose exec server bash

# Nettoyer
docker system prune -a
```

---

## Conclusion

Docker transforme le développement en :
- Éliminant les problèmes de "ça marche chez moi"
- Simplifiant l'onboarding des nouveaux développeurs
- Garantissant la cohérence entre environnements
- Facilitant le déploiement et la scalabilité

**Notre projet AREA bénéficie de tous ces avantages, permettant à l'équipe de se concentrer sur le code plutôt que sur la configuration.**
