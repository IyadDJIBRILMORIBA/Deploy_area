#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "🔍 AREA Backend - Pre-Deployment Validation"
echo "============================================"
echo ""

errors=0
warnings=0

# Check if required files exist
echo "📁 Checking required files..."
required_files=(
    "Dockerfile.production"
    "render.yaml"
    "composer.json"
    "artisan"
    "docker/nginx.conf"
    "docker/php-fpm.conf"
    "docker/supervisord.conf"
    "docker/entrypoint.sh"
)

for file in "${required_files[@]}"; do
    if [ -f "$file" ]; then
        echo -e "${GREEN}✓${NC} $file"
    else
        echo -e "${RED}✗${NC} $file (missing)"
        ((errors++))
    fi
done

echo ""

# Check .env configuration
echo "⚙️  Checking environment configuration..."
if [ -f .env ]; then
    echo -e "${GREEN}✓${NC} .env file exists"
    
    # Check for critical env vars
    if grep -q "APP_KEY=base64:" .env; then
        echo -e "${GREEN}✓${NC} APP_KEY is set"
    else
        echo -e "${RED}✗${NC} APP_KEY is not set - run: php artisan key:generate"
        ((errors++))
    fi
    
    if grep -q "DB_HOST=" .env; then
        echo -e "${GREEN}✓${NC} DB_HOST is configured"
    else
        echo -e "${YELLOW}⚠${NC} DB_HOST not set (will need to configure in Render)"
        ((warnings++))
    fi
else
    echo -e "${YELLOW}⚠${NC} .env file not found (will be configured in Render)"
    ((warnings++))
fi

echo ""

# Check Docker files are executable
echo "🔐 Checking file permissions..."
executable_files=(
    "docker/entrypoint.sh"
    "docker/deploy.sh"
    "setup-render.sh"
)

for file in "${executable_files[@]}"; do
    if [ -f "$file" ]; then
        if [ -x "$file" ]; then
            echo -e "${GREEN}✓${NC} $file is executable"
        else
            echo -e "${YELLOW}⚠${NC} $file is not executable - fixing..."
            chmod +x "$file"
            ((warnings++))
        fi
    fi
done

echo ""

# Check composer.json
echo "📦 Checking dependencies..."
if [ -f "composer.json" ]; then
    if grep -q '"laravel/framework"' composer.json; then
        echo -e "${GREEN}✓${NC} Laravel framework dependency found"
    else
        echo -e "${RED}✗${NC} Laravel framework not found in composer.json"
        ((errors++))
    fi
    
    if grep -q '"laravel/sanctum"' composer.json; then
        echo -e "${GREEN}✓${NC} Laravel Sanctum found"
    else
        echo -e "${YELLOW}⚠${NC} Laravel Sanctum not found (may be needed for API auth)"
        ((warnings++))
    fi
fi

echo ""

# Check database migrations
echo "🗄️  Checking database migrations..."
if [ -d "database/migrations" ]; then
    migration_count=$(find database/migrations -name "*.php" | wc -l)
    echo -e "${GREEN}✓${NC} Found $migration_count migration files"
else
    echo -e "${RED}✗${NC} database/migrations directory not found"
    ((errors++))
fi

echo ""

# Check routes
echo "🛣️  Checking routes..."
if [ -f "routes/api.php" ]; then
    echo -e "${GREEN}✓${NC} API routes file exists"
else
    echo -e "${RED}✗${NC} routes/api.php not found"
    ((errors++))
fi

echo ""

# Check storage directories
echo "💾 Checking storage directories..."
storage_dirs=(
    "storage/app"
    "storage/framework/cache"
    "storage/framework/sessions"
    "storage/framework/views"
    "storage/logs"
    "bootstrap/cache"
)

for dir in "${storage_dirs[@]}"; do
    if [ -d "$dir" ]; then
        echo -e "${GREEN}✓${NC} $dir"
    else
        echo -e "${YELLOW}⚠${NC} $dir (will be created during build)"
        ((warnings++))
    fi
done

echo ""

# Summary
echo "============================================"
echo "📊 Validation Summary"
echo "============================================"

if [ $errors -eq 0 ] && [ $warnings -eq 0 ]; then
    echo -e "${GREEN}✅ All checks passed! Ready for deployment.${NC}"
    echo ""
    echo "Next steps:"
    echo "1. git add ."
    echo "2. git commit -m 'Add Render deployment configuration'"
    echo "3. git push origin masters"
    echo "4. Deploy on Render Dashboard"
    exit 0
elif [ $errors -eq 0 ]; then
    echo -e "${YELLOW}⚠️  $warnings warning(s) found.${NC}"
    echo -e "${GREEN}You can proceed with deployment, but review the warnings.${NC}"
    echo ""
    echo "Next steps:"
    echo "1. Review warnings above"
    echo "2. git add ."
    echo "3. git commit -m 'Add Render deployment configuration'"
    echo "4. git push origin masters"
    echo "5. Deploy on Render Dashboard"
    exit 0
else
    echo -e "${RED}❌ $errors error(s) and $warnings warning(s) found.${NC}"
    echo -e "${RED}Please fix the errors before deployment.${NC}"
    exit 1
fi
