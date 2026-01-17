#!/bin/bash

# Script de vérification de l'intégration des services
# Usage: ./check-services-integration.sh

echo "🔍 Vérification de l'intégration des services AREA..."
echo ""

# Couleurs
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Compteurs
TOTAL=0
PASSED=0
FAILED=0

# Fonction de test
check() {
    TOTAL=$((TOTAL + 1))
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✓${NC} $2"
        PASSED=$((PASSED + 1))
    else
        echo -e "${RED}✗${NC} $2"
        FAILED=$((FAILED + 1))
    fi
}

echo "📦 Vérification des fichiers de services..."
echo ""

# Vérifier les services backend
check $([ -f "app/Services/GoogleService.php" ] && echo 0 || echo 1) "GoogleService.php"
check $([ -f "app/Services/GitHubService.php" ] && echo 0 || echo 1) "GitHubService.php"
check $([ -f "app/Services/DiscordService.php" ] && echo 0 || echo 1) "DiscordService.php"
check $([ -f "app/Services/SlackService.php" ] && echo 0 || echo 1) "SlackService.php"
check $([ -f "app/Services/TwitchService.php" ] && echo 0 || echo 1) "TwitchService.php"
check $([ -f "app/Services/WeatherService.php" ] && echo 0 || echo 1) "WeatherService.php"
check $([ -f "app/Services/TrelloService.php" ] && echo 0 || echo 1) "TrelloService.php"
check $([ -f "app/Services/TimerService.php" ] && echo 0 || echo 1) "TimerService.php"

echo ""
echo "🔧 Vérification des commandes d'exécution..."
echo ""

# Vérifier la présence dans ExecuteAreas.php
check $(grep -q "TwitchService" app/Console/Commands/ExecuteAreas.php && echo 0 || echo 1) "TwitchService dans ExecuteAreas"
check $(grep -q "WeatherService" app/Console/Commands/ExecuteAreas.php && echo 0 || echo 1) "WeatherService dans ExecuteAreas"
check $(grep -q "TrelloService" app/Console/Commands/ExecuteAreas.php && echo 0 || echo 1) "TrelloService dans ExecuteAreas"

# Vérifier la présence dans ExecuteScheduledAreas.php
check $(grep -q "TwitchService" app/Console/Commands/ExecuteScheduledAreas.php && echo 0 || echo 1) "TwitchService dans ExecuteScheduledAreas"
check $(grep -q "WeatherService" app/Console/Commands/ExecuteScheduledAreas.php && echo 0 || echo 1) "WeatherService dans ExecuteScheduledAreas"
check $(grep -q "TrelloService" app/Console/Commands/ExecuteScheduledAreas.php && echo 0 || echo 1) "TrelloService dans ExecuteScheduledAreas"

echo ""
echo "📝 Vérification du seeder..."
echo ""

check $(grep -q "twitch" database/seeders/ServicesSeeder.php && echo 0 || echo 1) "Service Twitch dans seeder"
check $(grep -q "weather" database/seeders/ServicesSeeder.php && echo 0 || echo 1) "Service Weather dans seeder"
check $(grep -q "trello" database/seeders/ServicesSeeder.php && echo 0 || echo 1) "Service Trello dans seeder"

echo ""
echo "⚙️  Vérification de la configuration..."
echo ""

check $(grep -q "TWITCH_CLIENT_ID" .env.example && echo 0 || echo 1) "Variables Twitch dans .env.example"
check $(grep -q "OPENWEATHER_API_KEY" .env.example && echo 0 || echo 1) "Variables Weather dans .env.example"
check $(grep -q "TRELLO_API_KEY" .env.example && echo 0 || echo 1) "Variables Trello dans .env.example"

check $(grep -q "'twitch'" config/services.php && echo 0 || echo 1) "Configuration Twitch dans services.php"
check $(grep -q "'weather'" config/services.php && echo 0 || echo 1) "Configuration Weather dans services.php"
check $(grep -q "'trello'" config/services.php && echo 0 || echo 1) "Configuration Trello dans services.php"

echo ""
echo "🎨 Vérification du ServiceController..."
echo ""

check $(grep -q "twitch.*Twitch streaming" app/Http/Controllers/ServiceController.php && echo 0 || echo 1) "Description Twitch dans ServiceController"
check $(grep -q "weather.*Weather information" app/Http/Controllers/ServiceController.php && echo 0 || echo 1) "Description Weather dans ServiceController"
check $(grep -q "trello.*Trello board" app/Http/Controllers/ServiceController.php && echo 0 || echo 1) "Description Trello dans ServiceController"

echo ""
echo "📱 Vérification du frontend Flutter..."
echo ""

# Vérifier si on est dans le bon répertoire
if [ -d "../flutter_application" ]; then
    cd ../flutter_application
    
    check $(grep -q "twitch" lib/models/service_model.dart && echo 0 || echo 1) "Support Twitch dans service_model.dart"
    check $(grep -q "weather" lib/models/service_model.dart && echo 0 || echo 1) "Support Weather dans service_model.dart"
    check $(grep -q "trello" lib/models/service_model.dart && echo 0 || echo 1) "Support Trello dans service_model.dart"
    
    check $(grep -q "twitch" lib/services/create_area_data.dart && echo 0 || echo 1) "Support Twitch dans create_area_data.dart"
    check $(grep -q "weather" lib/services/create_area_data.dart && echo 0 || echo 1) "Support Weather dans create_area_data.dart"
    check $(grep -q "trello" lib/services/create_area_data.dart && echo 0 || echo 1) "Support Trello dans create_area_data.dart"
    
    cd - > /dev/null
else
    echo -e "${YELLOW}⚠${NC} Frontend Flutter non trouvé, vérification ignorée"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📊 Résultats de la vérification:"
echo ""
echo -e "Total de tests: ${TOTAL}"
echo -e "${GREEN}Réussis: ${PASSED}${NC}"
echo -e "${RED}Échoués: ${FAILED}${NC}"
echo ""

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}✅ Tous les tests sont passés ! L'intégration est complète.${NC}"
    exit 0
else
    echo -e "${RED}❌ Certains tests ont échoué. Vérifiez les fichiers ci-dessus.${NC}"
    exit 1
fi
