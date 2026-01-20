#!/bin/sh

# Script de démarrage pour Render.com
# Utilise le port fourni par la variable d'environnement PORT

echo "🚀 Starting AREA Backend..."

# S'assurer qu'il n'y a pas de fichier .env
rm -f /var/www/.env

# Vérifier que les variables d'environnement sont présentes
echo "🔍 Checking environment variables..."
echo "📊 DB_CONNECTION: $DB_CONNECTION"
echo "📊 DB_HOST: $DB_HOST"
echo "📊 DB_DATABASE: $DB_DATABASE"
echo "📊 DB_USERNAME: $DB_USERNAME"
echo "📊 APP_ENV: $APP_ENV"

# Régénérer la clé si APP_KEY est vide
if [ -z "$APP_KEY" ]; then
  echo "🔑 Generating APP_KEY..."
  php artisan key:generate --force --show
fi

# Vider TOUS les caches
echo "📦 Clearing all caches..."
php artisan config:clear
php artisan cache:clear
php artisan route:clear
php artisan view:clear

# Exécuter les migrations
echo "🗄️  Running migrations..."
php artisan migrate --force

# Optimiser uniquement routes et views (PAS config)
echo "⚡ Optimizing..."
php artisan route:cache
php artisan view:cache

# Démarrer le serveur
PORT=${PORT:-8000}
echo "🌐 Starting server on port $PORT..."
php artisan serve --host=0.0.0.0 --port=$PORT
