# Architecture du Dépôt 
Ce projet regroupe trois micro-services distincts qui fonctionnent de manière indépendante mais sont orchestrés ensemble via Docker. 

## Structure des Dossiers

Voici l'organisation globale des fichiers à la racine du projet :

root/   
├── backend-area/  
│   ├── app/    
│   ├── database/   
│   ├── routes/ 
│   └── tests/  
│   
├── frontend-area/  
│   ├── assets/ 
│   ├── components/ 
│   ├── pages/  
│   └── stores/ 
│   
├── flutter_application/    
│   ├── lib/    
│   │   ├── main.dart   
│   │   └── screens/    
│   └── android/    
│   
├── docs/   
│   ├── .vitepress/ 
│   └── *.md    
│   
├── docker-compose.yml  
└── README.md   

## Détails Techniques par Composant

1. Backend (backend-area)

C'est le cœur du système. Il n'a aucune vue (pas de HTML), il ne renvoie que du JSON.

Framework : Laravel 12.

Rôle :

Gérer l'authentification (Sanctum / Socialite).

Stocker les utilisateurs et les AREAs dans la base de données.

Exécuter les tâches planifiées (Scheduler) pour vérifier les triggers.

Exposer le fichier about.json.

2. Frontend (frontend-area)

C'est l'interface pour les navigateurs.

Framework : Nuxt 3 (Vue.js).

Style : Tailwind CSS v3.

Communication : Utilise useFetch pour parler au Backend.

Particularité : Sert le fichier .apk généré pour le mobile.

3. Mobile (flutter_application)

C'est l'application native Android.

Framework : Flutter (Dart).

Communication : Utilise le package http pour parler au Backend.

Particularité : Doit permettre de configurer l'IP du serveur au lancement.

4. Infrastructure (Docker)

Le fichier docker-compose.yml est la clé de voûte. Il permet de lancer tout le projet avec une seule commande.

Il crée un réseau interne privé pour que les conteneurs se parlent.

Il expose les ports nécessaires à la machine hôte (8080, 8081, 3306).
