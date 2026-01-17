## **Organisation de l'Équipe**

## **1\. Introduction**

Ce document détaille notre structure d'équipe, nos outils de collaboration, notre workflow Git, notre gestion des tâches et notre approche des désaccords techniques.

### **2\. Composition de l'Équipe et Rôles**

Notre équipe est composée de six membres, chacun ayant des responsabilités claires pour couvrir les trois composants du projet (Backend, Client Web, Client Mobile) :

* **Retys (Lead Backend Developer)**  
  * **Responsabilités :** Définition de l'architecture backend principale (Laravel), conception et validation des contrats d'API, supervision du développement des modules critiques du serveur applicatif, **coordination de l'équipe backend**, revue de code des contributions backend, garantie de la performance et de la sécurité du backend.  
* **Méryl (Backend Developer)**  
  * **Responsabilités :** Implémentation des fonctionnalités backend (API REST, intégration de services, gestion des hooks) , développement des interactions avec la base de données, rédaction de tests unitaires et d'intégration pour le backend, **participation aux revues de code au sein de l'équipe backend**.  
* **Asaph (Backend Developer)**  
  * **Responsabilités :** Implémentation des fonctionnalités backend (API REST, intégration de services, gestion des hooks), développement des interactions avec la base de données, rédaction de tests unitaires et d'intégration pour le backend, **participation aux revues de code au sein de l'équipe backend**.  
* **Florian (Lead Frontend Developer \- Web)**  
  * **Responsabilités :** Définition de l'architecture du client web (Nuxt.js), conception des composants UI/UX clés, supervision du développement frontend web, garantie de la communication fluide avec le backend, revue de code des contributions web frontend, assure la cohérence visuelle et l'accessibilité du client web.  
* **Prince (Frontend Developer \- Web)**  
  * **Responsabilités :** Implémentation des interfaces utilisateur web (Nuxt.js), intégration avec les APIs backend, développement des fonctionnalités spécifiques au client web (comme l'affichage des AREA), assure la réactivité et l'accessibilité des composants UI.  
* **Iyad (Mobile Developer \- Mobile Client)**  
  * **Responsabilités :** Développement complet de l'application mobile (Flutter) pour Android (et éventuellement Windows Mobile), intégration avec les APIs backend, gestion des spécificités mobiles (génération de l'APK, configuration de l'adresse du serveur), garantie de la performance et de l'accessibilité du client mobile.

### **3\. Processus de Collaboration et Workflow Git**

Notre collaboration s'articule autour d'outils et de méthodologies standards  
**Gestion des Sources avec Git et GitHub :**

* **Outil:** Dépôt centralisé sur GitHub.

**Stratégie de Branches (GitFlow)**

* **Branches Principales :**  
  1. `main` : Contient le code stable, toujours prêt pour le déploiement en production.  
  2. `dev` : Branche d'intégration où toutes les fonctionnalités terminées sont fusionnées.  
* **Branches de Support :**  
  1. `feature/<nom-de-la-fonctionnalite>` : Pour le développement de nouvelles fonctionnalités. Chaque développeur créera une branche `feature` à partir de `dev` et la fusionnera (via Pull Request) dans `dev` une fois terminée.  
  2. `bugfix/<description-du-bug>` : Pour les corrections de bugs non urgents. Créée à partir de `dev` et fusionnée dans `dev`.  
* **Processus de Développement :**  
  1. Chaque développeur travaille sur sa propre branche `feature` ou `bugfix`.  
  2. Les commits seront réguliers avec des noms clairs et explicites.  
  3. **Pull Requests:** Aucun code n'est fusionné dans `dev` ou `main` sans une Pull Request validée.  
     * Une Pull Request doit être approuvée par le lead correspondant (Retys pour le backend, Florian pour le frontend).  
     * Pour les merges dans `dev`, le **Lead** (Retys pour backend, Florian pour web frontend) doit donner son approbation finale.  
     * Pour les merges dans `main`, l'ensemble de l'équipe sera consulté, mais les Leads auront le dernier mot.  
  4. **Revue de Code :** La revue de code est obligatoire avant toute fusion. Elle vise à garantir la qualité, la performance et la sécurité du code.

### **4\. Gestion des Tâches**

Nous utiliserons **Trello** pour organiser et suivre l'avancement de nos tâches, offrant un visuelle de notre progression.
Notre lien: https://trello.com/b/58QaEVO4/area

* **Tableau de Bord :** Notre tableau Kanban sur Trello est structuré avec les colonnes suivantes:  
  1. **Ressources & Documentation :** Centralise les documents de référence du projet (ex: le fichier PDF du projet, les guides d'accessibilité W3C, les diagrammes d'architecture, etc.).  
  2. **Toutes les fonctionnalités :** Sert de backlog principal. C'est ici que sont listées toutes les grandes fonctionnalités à implémenter.  
  3. **À faire :** Regroupe les tâches priorisées et prêtes à être commencées pour le cycle de développement actuel (ex: la semaine en cours).  
  4. **En cours :** Contient les tâches sur lesquelles les développeurs travaillent actuellement.  
  5. **Terminé :** Toutes les tâches qui ont été développées, testées, revues et fusionnées dans la branche `develop` ou `main`.  
* **Fiches de Tâches (Cartes Trello) :** Chaque tâche sera représentée par une fiche avec :  
  1. Un titre clair et concis.  
  2. Une description détaillée des exigences et des critères.  
  3. Un ou plusieurs assignés.  
  4. Des labels pour identifier le composant (`backend`, `web-client`, `mobile-client`) et la priorité.  
  5. Une estimation de la charge de travail (si applicable).  
* **Workflow des Tâches :** Le processus de gestion des tâches est le suivant :  
  1. Les **Leads** alimentent la colonne **"Toutes les fonctionnalités"**.  
  2. Les tâches prioritaires sont déplacées de **"Toutes les fonctionnalités"** vers la colonne **"À faire"**.  
  3. Un développeur prend une tâche de **"À faire"**, se l'assigne, et la déplace vers **"En cours"**.  
  4. Une fois le développement d'une tâche terminé et une Pull Request (PR) ouverte sur GitHub  
  5. Après validation de la PR et fusion, la tâche est déplacée vers **Terminé**.

### **5\. Communication**

Une communication fluide et transparente est essentielle pour notre équipe.

* **Outil Principal : Microsoft Teams**  
  * **Justification :** Teams est notre plateforme centralisée pour **toutes les discussions et ressources relatives au projet**. Cet outil a été choisi pour son environnement professionnel, sa capacité à structurer les conversations par canaux, son intégration avec le partage de fichiers et ses fonctionnalités de visioconférence robustes.  
* **Outil Secondaire : WhatsApp**  
  * **Justification :** Le groupe WhatsApp est utilisé exclusivement pour la **communication informelle et les notifications urgentes**.  
  * **Cas d'usage :**  
    * Je suis en retard de 5 minutes pour la réunion.  
    * On a folow-up à quelle heure?  
  * **Règle :** Aucune décision technique importante ne doit être prise sur WhatsApp. Toute discussion technique doit être redirigée vers le canal approprié sur Microsoft Teams pour être documentée et accessible à tous.

* **Réunions Régulières (Communication) :**  
  * **Points de Synchronisation Bihebdomadaires**  
    * **Quand :** Lundi et Mercredi, de 14h00 à 14h30 (30 minutes).  
    * **Objectif :** Assurer l'alignement de l'équipe, identifier les blocages rapidement et maintenir la dynamique du projet. Ce n'est pas une réunion de résolution de problèmes, mais de partage d'informations.  
    * **Déroulement :** Chaque membre partagera succinctement :  
      1. Ce qui a été accompli depuis la dernière rencontre.  
      2. Ce qui est prévu pour la journée / les prochains jours.  
      3. Les éventuels obstacles ou blocages rencontrés nécessitant de l'aide.

* **Réunion de Planification et Revue Hebdomadaire (Vendredi \- 2 heures 30 minutes):**  
  * **Réunion de Planification et Revue Hebdomadaire**  
    * **Quand :** Vendredi, de 14h00 à 16h00 (2 heures).  
    * **Objectif :** C'est notre réunion stratégique la plus importante. Elle nous permet de faire le bilan de la semaine écoulée et de préparer la suivante.  
    * **Déroulement :**  
      1. **Revue de l'Avancement :** Présentation de ce qui a été réalisé durant la semaine, démonstration des fonctionnalités terminées (si possible).  
      2. **Analyse des Écarts :** Comparaison entre le réalisé et le planifié, identification des raisons des écarts.  
      3. **Planification des Tâches :** Définition des objectifs et répartition détaillée des tâches à accomplir avant la fin de la semaine suivante, en tenant compte des priorités et des capacités de l'équipe.  
      4. **Discussions Techniques Approfondies :** Temps dédié pour aborder les décisions architecturales complexes, les problèmes techniques majeurs ou les choix technologiques émergents.  
* **Communication Ad-hoc :**  
  * Les discussions spontanées et le pair programming sont encouragés via Microsoft Teams pour résoudre rapidement les problèmes urgents ou approfondir un sujet technique

### **6\. Gestion des Conflits et Désaccords Techniques**

Les désaccords techniques sont naturels dans tout projet de développement. Notre approche vise à les résoudre de manière efficace :

1. **Discussion Ouverte :** La première étape est toujours une discussion ouverte entre les parties concernées, en se basant sur des arguments techniques et les exigences du projet et non sur des préférences personnelles. Les discussions se tiendront dans les canaux Discord appropriés ou en présentiel à l’ école.  
2. **Implication des Leads :** Si un consensus n'est pas atteint au sein d'une sous-équipe (ex: backend), le Lead concerné (Retys pour le backend, Florian pour le frontend web)  a le dernier mot après avoir écouté toutes les parties. Sa décision est prise dans l'intérêt supérieur du projet.  
3. **Décisions Transversales :** Pour les désaccords majeurs affectant plusieurs composants de l'architecture, une discussion impliquant toute l'équipe sera organisée. L'objectif est d'atteindre un consensus ; si cela n'est pas possible, un vote pourra être envisagé, ou une décision sera prise collectivement par les Leads.  
4. **Documentation des Décisions :** Les décisions techniques importantes, en particulier celles résultant de désaccords, seront documentées dans un wiki du projet.  
5. **Focus sur les Objectifs du Projet :** Rappeler à tous que l'objectif principal est la réussite du projet et la satisfaction des exigences, et non la préférence personnelle pour une technologie ou une méthode.