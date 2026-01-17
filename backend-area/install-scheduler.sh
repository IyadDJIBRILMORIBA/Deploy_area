#!/bin/bash

# Script d'installation du service scheduler AREA
# Usage: ./install-scheduler.sh

echo "🚀 Installation du service AREA Scheduler..."
echo ""

# Vérifier qu'on est dans le bon répertoire
if [ ! -f "artisan" ]; then
    echo "❌ Erreur: Ce script doit être exécuté depuis le dossier backend-area"
    exit 1
fi

# Obtenir le chemin absolu du projet
PROJECT_PATH=$(pwd)
USER_NAME=$(whoami)

echo "📁 Chemin du projet: $PROJECT_PATH"
echo "👤 Utilisateur: $USER_NAME"
echo ""

# Créer le fichier service avec les bons chemins
cat > area-scheduler.service << EOF
[Unit]
Description=AREA Scheduler Service
After=network.target

[Service]
Type=simple
User=$USER_NAME
WorkingDirectory=$PROJECT_PATH
ExecStart=/usr/bin/php $PROJECT_PATH/artisan schedule:work
Restart=always
RestartSec=5
StandardOutput=append:$PROJECT_PATH/storage/logs/scheduler.log
StandardError=append:$PROJECT_PATH/storage/logs/scheduler.log

[Install]
WantedBy=multi-user.target
EOF

echo "📝 Fichier service généré: area-scheduler.service"
echo ""

# Demander confirmation
read -p "⚠️  Voulez-vous installer le service maintenant ? (o/N) " -n 1 -r
echo ""

if [[ $REPLY =~ ^[OoYy]$ ]]; then
    echo "📦 Installation du service..."
    
    # Copier le fichier service
    sudo cp area-scheduler.service /etc/systemd/system/
    
    # Recharger systemd
    sudo systemctl daemon-reload
    
    # Activer le service au démarrage
    sudo systemctl enable area-scheduler
    
    # Démarrer le service
    sudo systemctl start area-scheduler
    
    echo ""
    echo "✅ Service installé et démarré avec succès!"
    echo ""
    echo "📊 Statut du service:"
    sudo systemctl status area-scheduler --no-pager -l
    
    echo ""
    echo "💡 Commandes utiles:"
    echo "  - Voir le statut:    sudo systemctl status area-scheduler"
    echo "  - Voir les logs:     sudo journalctl -u area-scheduler -f"
    echo "  - Redémarrer:        sudo systemctl restart area-scheduler"
    echo "  - Arrêter:           sudo systemctl stop area-scheduler"
    echo "  - Désactiver:        sudo systemctl disable area-scheduler"
else
    echo ""
    echo "ℹ️  Installation annulée. Le fichier area-scheduler.service a été créé."
    echo "   Pour installer manuellement, exécutez:"
    echo "   sudo cp area-scheduler.service /etc/systemd/system/"
    echo "   sudo systemctl daemon-reload"
    echo "   sudo systemctl enable area-scheduler"
    echo "   sudo systemctl start area-scheduler"
fi

echo ""
echo "✨ Terminé!"
