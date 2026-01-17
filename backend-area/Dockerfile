FROM php:8.4-fpm

# Force rebuild - 2026-01-17-production
# Installation des dépendances système et PostgreSQL
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    libcurl4-openssl-dev \
    libpq-dev \
    postgresql-client \
    nginx \
    supervisor

# Installation des extensions PHP avec support PostgreSQL
RUN docker-php-ext-install pdo pdo_mysql pdo_pgsql pgsql mbstring exif pcntl bcmath gd curl && \
    php -m | grep -E '(pdo_pgsql|pgsql)' && \
    echo "✓ PostgreSQL extensions installed successfully"

# Installation de Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www

# Copie des fichiers composer
COPY composer.json composer.lock ./

# Installation des dépendances
RUN composer install --no-dev --no-scripts --no-autoloader --prefer-dist --optimize-autoloader

# Copie du projet
COPY . .

# Generate autoloader
RUN composer dump-autoload --optimize --no-dev --classmap-authoritative

# Create necessary directories
RUN mkdir -p storage/logs storage/framework/cache storage/framework/sessions storage/framework/views \
    bootstrap/cache

# Permissions
RUN chown -R www-data:www-data /var/www/storage /var/www/bootstrap/cache && \
    chmod -R 775 /var/www/storage /var/www/bootstrap/cache

# Copier le fichier .env.example si .env n'existe pas
RUN if [ ! -f .env ]; then cp .env.example .env; fi

# Générer la clé d'application Laravel
RUN php artisan key:generate

# Copy nginx configuration
COPY docker/nginx.conf /etc/nginx/nginx.conf

# Copy PHP-FPM configuration  
COPY docker/php-fpm.conf /usr/local/etc/php-fpm.d/www.conf

# Copy supervisor configuration
COPY docker/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Copy entrypoint script
COPY docker/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Expose port
EXPOSE 8000

# Use entrypoint for startup tasks
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

# Start supervisor
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]