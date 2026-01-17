#!/bin/bash
set -e

echo "🚀 Starting AREA Backend..."

# Wait for database to be ready
echo "⏳ Waiting for database connection..."
max_attempts=30
attempt=0

while [ $attempt -lt $max_attempts ]; do
    if php artisan migrate:status > /dev/null 2>&1; then
        echo "✅ Database connection successful"
        break
    fi
    attempt=$((attempt + 1))
    echo "⏳ Attempt $attempt/$max_attempts - Database not ready yet..."
    sleep 2
done

if [ $attempt -eq $max_attempts ]; then
    echo "⚠️  Warning: Could not connect to database after $max_attempts attempts"
    echo "⚠️  Continuing anyway - please check database configuration"
fi

# Run migrations
echo "📊 Running database migrations..."
if php artisan migrate --force --no-interaction; then
    echo "✅ Migrations completed successfully"
else
    echo "⚠️  Warning: Migrations failed - check database configuration"
fi

# Run seeders
echo "🌱 Seeding database..."
if php artisan db:seed --force --no-interaction; then
    echo "✅ Database seeding completed successfully"
else
    echo "⚠️  Warning: Seeding failed - check seeder configuration"
fi

# Cache configuration
echo "⚡ Optimizing application..."
php artisan config:cache || echo "⚠️  Config cache failed"
php artisan route:cache || echo "⚠️  Route cache failed"
php artisan view:cache || echo "⚠️  View cache failed"

# Create storage link
if [ ! -L public/storage ]; then
    echo "🔗 Creating storage link..."
    php artisan storage:link || echo "⚠️  Storage link failed"
fi

echo "✅ Application ready!"
echo "🌐 Starting web server..."

# Execute the main command
exec "$@"
