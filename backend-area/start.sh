#!/bin/bash

# Script de démarrage pour Render.com
# Utilise le port fourni par la variable d'environnement PORT

echo "🚀 Starting AREA Backend..."

# Vider les caches
echo "📦 Clearing caches..."
php artisan config:clear
php artisan cache:clear

# Exécuter les migrations
echo "🗄️  Running migrations..."
php artisan migrate --force

# Optimisations Laravel
echo "⚡ Optimizing Laravel..."
php artisan config:cache
php artisan route:cache

# Démarrer le serveur sur le port fourni par Render
PORT=${PORT:-8000}
echo "🌐 Starting server on port $PORT..."
php artisan serve --host=0.0.0.0 --port=$PORT
