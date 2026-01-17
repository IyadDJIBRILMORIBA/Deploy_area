#!/bin/bash

# Exit on error
set -e

echo "Starting deployment process..."

# Wait for database to be ready
echo "Waiting for database connection..."
php artisan migrate:status || sleep 5

# Run migrations
echo "Running database migrations..."
php artisan migrate --force --no-interaction

# Clear and cache configuration
echo "Optimizing application..."
php artisan config:cache
php artisan route:cache
php artisan view:cache

# Create storage link if not exists
if [ ! -L public/storage ]; then
    echo "Creating storage link..."
    php artisan storage:link
fi

echo "Deployment process completed!"
