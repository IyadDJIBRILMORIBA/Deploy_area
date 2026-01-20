#!/bin/sh

# Script de démarrage pour Render.com
# Utilise le port fourni par la variable d'environnement PORT

echo "🚀 Starting AREA Backend..."

# Vider les caches (IMPORTANT pour utiliser les vraies variables d'env)
echo "📦 Clearing all caches..."
php artisan config:clear
php artisan cache:clear
php artisan route:clear
php artisan view:clear

# Exécuter les migrations
echo "🗄️  Running migrations..."
php artisan migrate --force

# NE PAS mettre en cache la config sur Render
# Car les variables d'environnement doivent être lues dynamiquement
echo "⚡ Optimizing routes and views only..."
php artisan route:cache
php artisan view:cache

# Démarrer le serveur sur le port fourni par Render
PORT=${PORT:-8000}
echo "🌐 Starting server on port $PORT..."
php artisan serve --host=0.0.0.0 --port=$PORT
