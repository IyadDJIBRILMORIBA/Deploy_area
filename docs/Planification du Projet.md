## **Planification du Projet**

## **1\. Timeline du Projet**

Le projet sera divisé en trois phases principales suivies des défenses.

#### **Phase 1 : Planification (Jusqu'à la 1ère défense)**

* **Objectif :** Valider la stack technologique, mettre en place l'environnement de développement et prouver la communication.  
* **Durée Estimée :** 01 semaine  
* **Tâches Clés :**  
  * **Recherche Technologique:** Exploration des alternatives et justification des choix (Laravel, Nuxt, Flutter).  
  * **Mise en place de l'environnement de développement :**  
    * Initialisation des projets Laravel, Nuxt.js, Flutter.  
    * Création des Dockerfiles pour chaque service.  
    * Configuration du `docker-compose.yml` (server 8080, client\_web 8081, common\_volume, `depends_on`).  
  * **Développement du Proof of Concept (PoC) :**  
    * **Backend (Laravel) :**  
      * Mise en place d'une route REST simple (`/api/status` retournant `{"status": "ok"}`).  
      * Implémentation de l'endpoint `/about.json` (au moins avec les informations statiques initiales).  
    * **Client Web (Nuxt.js) :**  
      * Interface affichant le résultat de l'appel à `/api/status` et `about.json`.  
      * Configuration de la communication avec le backend via Docker Compose.  
    * **Client Mobile (Flutter) :**  
      * Application affichant le résultat de l'appel à `/api/status` et `about.json`.  
      * Configuration de la communication avec le backend via Docker Compose.  
  * **Rédaction du Document de Planification :** Ce document même (incluant, Planification, Sécurité).  
* **Livrables pour la 1ère Soutenance :**  
  * Document de planification complet.  
  * Environnement de développement fonctionnel via `docker-compose up`.  
  * Démonstration du PoC (backend, web, mobile communiquant).

#### **Phase 2 : Minimum Viable Product (MVP) (Jusqu'à la 2ème Soutenance)**

* **Objectif :** Implémenter le cœur de l'application : gestion complète des utilisateurs, une première intégration de service tiers avec des Actions/REActions fonctionnelles, et les interfaces clients associées.  
* **Durée Estimée :** 03 semaines  
* **Tâches Clés :**  
  * **Développement Backend (Laravel) :**  
    * Implémentation complète de l'API de gestion des utilisateurs (inscription, connexion par email/mot de passe).  
    * Intégration d'**OAuth2 via Laravel Socialite** pour l'authentification tierce-partie (ex: Google).  
    * API pour lier/délier des comptes de services tiers (ex: Google) aux utilisateurs.  
    * Définition et stockage des Actions et REActions pour **UN service complet (ex: Google)**.  
    * Implémentation d'une logique de "Hook" (polling ou webhook si disponible) pour au moins **1 Action et 1 REAction** fonctionnelles et inter-connectables.  
  * **Développement Clients (Nuxt.js & Flutter) :**  
    * Écrans de connexion/inscription pour l'authentification locale et via OAuth2 (Google).  
    * Interface pour afficher le statut des services liés à l'utilisateur.  
    * Interface pour lier/délier des services (ex: bouton "Connecter Google").  
    * Interface utilisateur pour créer, modifier, et visualiser une AREA (en choisissant une Action et une REAction pour le service Google).  
    * Assurer l'accessibilité de ces interfaces.  
  * **Base de Données :** Implémentation du schéma initial (Users, OAuth Providers, Services, Actions, REActions, Areas).  
* **Livrables pour la 2ème défense (MVP) :**  
  * Application fonctionnelle permettant :  
    * L'inscription et la connexion des utilisateurs (local et via Google).  
    * La liaison d'un compte Google.  
    * La création d'une AREA connectant une Action Google à une REAction Google.  
    * La démonstration d'une Action Google qui déclenche une REAction Google via le système de hook.  
  * Le `about.json` sera entièrement dynamique, reflétant les services et leurs Actions/REActions implémentés.  
  * Mise à jour du planning avec l'analyse des écarts et des modifications.

#### **Phase 3 : Finalisation et Robustesse (Jusqu'à la défense Finale)**

* **Objectif :** Étendre les fonctionnalités, améliorer l'expérience utilisateur, garantir la qualité et la robustesse du produit final.  
* **Durée Estimée :** 06 semaines  
* **Tâches Clés :**  
  * **Extension des Services :** Intégration de plusieurs services tiers supplémentaires (ex: Outlook 365, OneDrive/Dropbox, GitHub) avec leurs Actions et REActions variées.  
  * **Amélioration de l'UI/UX :** Refinement des interfaces web et mobile, amélioration de la fluidité, du design et de l'ergonomie.  
  * **Tests Automatisés :**  
    * Implémentation de tests unitaires pour le backend et les clients.  
    * Mise en place de tests d'intégration pour les flux critiques (ex: création d'AREA, déclenchement de hook).  
  * **Robustesse et Gestion des Erreurs :** Amélioration de la gestion des erreurs, logging, mécanismes de retry pour les intégrations tierces.  
  * **Optimisation des Performances :** Identification et correction des goulots d'étranglement.  
  * **Finalisation de la Documentation :** Rédaction complète du `README.md` et `HOWTOCONTRIBUTE.md`, incluant les diagrammes d'architecture, d'API et les instructions de déploiement.  
  * **Accessibilité :** Audit et améliorations pour atteindre un niveau d'accessibilité élevé (référentiel WCAG).  
* **Livrables pour la Soutenance Finale :**  
  * Application complète, fonctionnelle et robuste.  
  * Documentation exhaustive et claire.  
  * Tests automatisés significatifs.  
  * Analyse des succès et difficultés rencontrées lors du projet.

### **2\. Considérations Sécurité**

La sécurité est une préoccupation majeure pour une plateforme d'automatisation manipulant des données sensibles et interagissant avec des services tiers.

* **Authentification Utilisateur :**  
  * **Locale :** Utilisation des mécanismes de hachage de mot de passe sécurisés de Laravel (Bcrypt/Argon2). Les sessions utilisateurs seront gérées par des jetons (JWT via Laravel Sanctum) pour les communications API avec les clients web et mobile.  
  * **OAuth2 pour Tiers :** Utilisation de **Laravel Socialite** pour la gestion simplifiée des flux OAuth2 avec des fournisseurs externes (Google, Facebook, etc.). Les tokens d'accès et de rafraîchissement obtenus des services tiers seront stockés de manière sécurisée et chiffrée dans notre base de données.  
  * **HTTPS (SSL/TLS) :** Toutes les communications client-serveur et serveur-tiers seront systématiquement chiffrées via HTTPS pour prévenir l'interception des données.

* **Autorisation :**  
  * Implémentation de middlewares Laravel pour contrôler l'accès aux ressources et API en fonction des rôles ou permissions de l'utilisateur.  
  * Vérification des scopes OAuth2 obtenus pour chaque service tiers avant d'effectuer des actions pour le compte de l'utilisateur.  
* **Protection des Données :**  
  * **Validation des entrées :** Validation rigoureuse de toutes les données reçues des clients pour prévenir les injections (SQL, XSS, etc.).  
  * **Encodage des sorties :** Toutes les données affichées seront correctement encodées pour éviter les vulnérabilités XSS.  
  * **Paramétrisation des requêtes :** Utilisation d'ORM (Eloquent) pour interagir avec la base de données afin de prévenir les injections SQL.  
  * **Configuration Sécurisée :** Utilisation de variables d'environnement pour stocker les clés API, identifiants de client OAuth, secrets, etc.  
* **Sécurité API :**  
  * **Rate Limiting :** Mise en place de mécanismes pour limiter le nombre de requêtes aux API afin de prévenir les attaques par déni de service et l'abus.  
  * **CORS :** Configuration stricte des Cross-Origin Resource Sharing pour n'autoriser les requêtes que depuis nos clients autorisés.

