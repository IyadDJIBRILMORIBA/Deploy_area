#!/bin/bash

# ============================================
# AREA Scheduler - Laravel Schedule:run
# ============================================
# 
# Ce script est appelé par le cron système
# et déclenche le Laravel Scheduler.
# 
# Le scheduler évalue et exécute toutes les
# tâches programmées (y compris areas:scheduled)
#

PROJECT_PATH="/home/the_flowww/G-DEV-500-COT-5-2-area-8/backend-area"

# Se positionner dans le répertoire du projet
cd "$PROJECT_PATH" || exit 1

# Exécuter le scheduler Laravel
# Cela évalue les tâches dans routes/console.php et les exécute si elles sont dues
php artisan schedule:run >> storage/logs/area-scheduler.log 2>&1

exit 0
