<?php

namespace App\Interfaces;

interface ServiceInterface
{
    /**
     * Vérifie si une Action (Trigger) s'est produite.
     * @param array $params Les paramètres stockés dans l'AREA (ex: l'heure du timer, l'ID du calendrier)
     * @param object|null $userToken L'objet UserService contenant le token de l'utilisateur
     * @return bool|array Retourne false si rien, ou des données si l'action a eu lieu
     */
    public function checkTrigger(string $actionName, array $params, $userToken);

    /**
     * Exécute une Réaction.
     * @param array $params Les paramètres de la réaction (ex: contenu du mail, destinataire)
     * @param object|null $userToken L'objet UserService contenant le token de l'utilisateur
     * @param array $triggerData Les données récupérées par le Trigger (ex: le sujet du mail reçu)
     */
    public function executeReaction(string $reactionName, array $params, $userToken, array $triggerData);
}
