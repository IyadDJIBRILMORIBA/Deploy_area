FROM php:8.4-fpm

# Installation des dépendances système
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
    postgresql-client

# Installation des extensions PHP
RUN docker-php-ext-install pdo_mysql pdo_pgsql pgsql mbstring exif pcntl bcmath gd curl

# Installation de Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www

# Copie du projet
COPY . .

# Installation des dépendances Laravel
RUN composer install --no-interaction --optimize-autoloader

# Permissions
RUN chown -R www-data:www-data /var/www/storage /var/www/bootstrap/cache

# Copier le fichier .env.example si .env n'existe pas
RUN if [ ! -f .env ]; then cp .env.example .env; fi

# Générer la clé d'application Laravel
RUN php artisan key:generate

# Lancement du serveur sur le port 8000
CMD php artisan migrate --force && php artisan serve --host=0.0.0.0 --port=8000