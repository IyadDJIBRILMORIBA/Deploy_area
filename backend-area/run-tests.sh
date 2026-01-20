#!/bin/bash

# Script pour exécuter les tests avec différentes options

set -e

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}╔═══════════════════════════════════════╗${NC}"
echo -e "${GREEN}║     AREA - Test Runner Script        ║${NC}"
echo -e "${GREEN}╔═══════════════════════════════════════╝${NC}"
echo ""

# Vérifier si nous sommes dans le bon répertoire
if [ ! -f "artisan" ]; then
    echo -e "${RED}❌ Erreur: Ce script doit être exécuté depuis backend-area/${NC}"
    exit 1
fi

# Fonction d'aide
show_help() {
    echo "Usage: ./run-tests.sh [option]"
    echo ""
    echo "Options:"
    echo "  all        - Exécuter tous les tests (défaut)"
    echo "  unit       - Exécuter uniquement les tests unitaires"
    echo "  feature    - Exécuter uniquement les tests fonctionnels"
    echo "  coverage   - Générer un rapport de couverture HTML"
    echo "  watch      - Mode watch (re-exécute les tests à chaque modification)"
    echo "  fast       - Tests rapides sans couverture"
    echo "  ci         - Mode CI (avec couverture XML)"
    echo "  help       - Afficher cette aide"
    echo ""
    echo "Exemples:"
    echo "  ./run-tests.sh unit"
    echo "  ./run-tests.sh coverage"
}

# Fonction pour exécuter les tests
run_tests() {
    local suite=$1
    local extra_args=$2
    
    echo -e "${YELLOW}🧪 Exécution des tests${NC}: $suite"
    echo ""
    
    if [ -z "$suite" ]; then
        php artisan test $extra_args
    else
        php artisan test --testsuite=$suite $extra_args
    fi
}

# Parser les arguments
case "${1:-all}" in
    all)
        echo -e "${GREEN}📋 Exécution de tous les tests${NC}"
        run_tests "" ""
        ;;
    
    unit)
        echo -e "${GREEN}🔧 Exécution des tests unitaires${NC}"
        run_tests "Unit" ""
        ;;
    
    feature)
        echo -e "${GREEN}🌐 Exécution des tests fonctionnels${NC}"
        run_tests "Feature" ""
        ;;
    
    coverage)
        echo -e "${GREEN}📊 Génération du rapport de couverture${NC}"
        vendor/bin/phpunit --coverage-html coverage/
        echo ""
        echo -e "${GREEN}✅ Rapport généré dans: coverage/index.html${NC}"
        
        # Ouvrir automatiquement dans le navigateur (Linux)
        if command -v xdg-open > /dev/null; then
            xdg-open coverage/index.html
        fi
        ;;
    
    watch)
        echo -e "${GREEN}👀 Mode watch activé${NC}"
        echo -e "${YELLOW}Les tests se relanceront à chaque modification${NC}"
        echo -e "${YELLOW}Appuyez sur Ctrl+C pour arrêter${NC}"
        echo ""
        
        if ! command -v inotifywait > /dev/null; then
            echo -e "${RED}❌ inotify-tools n'est pas installé${NC}"
            echo "Installez avec: sudo apt install inotify-tools"
            exit 1
        fi
        
        while true; do
            php artisan test --compact
            inotifywait -r -e modify app/ tests/ || break
            clear
        done
        ;;
    
    fast)
        echo -e "${GREEN}⚡ Tests rapides (sans couverture)${NC}"
        run_tests "" "--parallel"
        ;;
    
    ci)
        echo -e "${GREEN}🤖 Mode CI${NC}"
        vendor/bin/phpunit --coverage-clover=coverage.xml
        echo ""
        echo -e "${GREEN}✅ Rapport XML généré: coverage.xml${NC}"
        ;;
    
    help)
        show_help
        ;;
    
    *)
        echo -e "${RED}❌ Option invalide: $1${NC}"
        echo ""
        show_help
        exit 1
        ;;
esac

# Si les tests ont réussi
if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}✅ Tests terminés avec succès!${NC}"
    exit 0
else
    echo ""
    echo -e "${RED}❌ Certains tests ont échoué${NC}"
    exit 1
fi
