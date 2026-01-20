#!/bin/bash

# 🎨 Script de test du nouveau design frontend

echo "🎨 Lancement du frontend AREA avec nouveau design..."
echo ""

# Vérifier si Node.js est installé
if ! command -v node &> /dev/null; then
    echo "❌ Node.js n'est pas installé"
    echo "📦 Installez Node.js: https://nodejs.org/"
    exit 1
fi

# Vérifier si npm est installé
if ! command -v npm &> /dev/null; then
    echo "❌ npm n'est pas installé"
    exit 1
fi

echo "✅ Node.js version: $(node --version)"
echo "✅ npm version: $(npm --version)"
echo ""

# Aller dans le dossier frontend
cd frontend-area

# Vérifier si node_modules existe
if [ ! -d "node_modules" ]; then
    echo "📦 Installation des dépendances..."
    npm install
    echo ""
fi

echo "🚀 Démarrage du serveur de développement..."
echo ""
echo "📱 Le nouveau design sera visible sur:"
echo "   http://localhost:3000"
echo ""
echo "✨ Fonctionnalités à tester:"
echo "   - Animations au chargement de la page"
echo "   - Effet ping sur le badge 'En ligne'"
echo "   - Hover sur les boutons (scale + ombres)"
echo "   - Cartes flottantes dans le Hero"
echo "   - Effet 3D sur les cartes Features"
echo "   - Transitions sur tous les liens"
echo ""
echo "Press Ctrl+C pour arrêter le serveur"
echo "=========================================="
echo ""

npm run dev
