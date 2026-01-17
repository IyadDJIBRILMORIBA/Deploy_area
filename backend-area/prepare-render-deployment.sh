#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

clear

echo -e "${BLUE}"
cat << "EOF"
   ___  ____  _________
  / _ |/ __ \/ __/ _ |
 / __ / /_/ / _// __ |
/_/ |_\____/___/_/ |_|

Backend Deployment Setup for Render
EOF
echo -e "${NC}"

echo ""
echo "This script will help you prepare your AREA backend for Render deployment."
echo ""

# Step 1: Generate APP_KEY if needed
echo -e "${BLUE}Step 1/4: Checking APP_KEY...${NC}"
if [ ! -f .env ]; then
    echo -e "${YELLOW}No .env file found. Creating from .env.example...${NC}"
    cp .env.example .env
    echo -e "${GREEN}✓ .env created${NC}"
fi

if ! grep -q "APP_KEY=base64:" .env; then
    echo -e "${YELLOW}Generating new APP_KEY...${NC}"
    php artisan key:generate
    echo -e "${GREEN}✓ APP_KEY generated${NC}"
else
    echo -e "${GREEN}✓ APP_KEY already set${NC}"
fi

APP_KEY=$(grep "APP_KEY=" .env | cut -d '=' -f2)
echo -e "${BLUE}Your APP_KEY: ${YELLOW}$APP_KEY${NC}"
echo ""

# Step 2: Validate dependencies
echo -e "${BLUE}Step 2/4: Validating dependencies...${NC}"
if [ -f composer.lock ]; then
    echo -e "${GREEN}✓ composer.lock found${NC}"
else
    echo -e "${YELLOW}composer.lock not found. Generating...${NC}"
    composer install
    echo -e "${GREEN}✓ Dependencies installed${NC}"
fi

# Step 3: Run validation
echo ""
echo -e "${BLUE}Step 3/4: Running deployment validation...${NC}"
./validate-deployment.sh
VALIDATION_RESULT=$?

# Step 4: Summary and next steps
echo ""
echo -e "${BLUE}Step 4/4: Deployment Information${NC}"
echo "================================"
echo ""
echo -e "${GREEN}✓ Backend ready for deployment!${NC}"
echo ""
echo -e "${YELLOW}📋 Important Information:${NC}"
echo ""
echo -e "1. ${BLUE}APP_KEY${NC} (add this to Render environment variables):"
echo -e "   ${GREEN}$APP_KEY${NC}"
echo ""
echo -e "2. ${BLUE}Database Options:${NC}"
echo "   - PostgreSQL (Render native, free): https://dashboard.render.com/new/database"
echo "   - MySQL (external): PlanetScale, Railway.io"
echo ""
echo -e "3. ${BLUE}Required Environment Variables:${NC}"
echo "   - APP_NAME, APP_ENV, APP_DEBUG, APP_URL"
echo "   - APP_KEY (from above)"
echo "   - DB_CONNECTION, DB_HOST, DB_PORT, DB_DATABASE, DB_USERNAME, DB_PASSWORD"
echo "   - OAuth credentials (GOOGLE_*, MICROSOFT_*, SPOTIFY_*, GITHUB_*, DISCORD_*)"
echo ""
echo -e "${YELLOW}📚 Documentation:${NC}"
echo "   - Quick Start: QUICKSTART_RENDER.md"
echo "   - Full Guide: RENDER_DEPLOYMENT.md"
echo "   - Env Example: .env.render.example"
echo ""
echo -e "${YELLOW}🚀 Next Steps:${NC}"
echo ""
echo "1. Commit your changes:"
echo -e "   ${BLUE}git add .${NC}"
echo -e "   ${BLUE}git commit -m 'Add Render deployment configuration'${NC}"
echo -e "   ${BLUE}git push origin masters${NC}"
echo ""
echo "2. Create database on Render:"
echo -e "   ${BLUE}https://dashboard.render.com/new/database${NC}"
echo ""
echo "3. Deploy backend:"
echo -e "   ${BLUE}https://dashboard.render.com/new/web${NC}"
echo "   - Environment: Docker"
echo "   - Dockerfile: Dockerfile.production"
echo "   - Root Directory: backend-area"
echo ""
echo "4. Configure environment variables in Render dashboard"
echo ""
echo "5. Deploy and test:"
echo -e "   ${BLUE}curl https://your-service.onrender.com/api/health${NC}"
echo ""
echo -e "${GREEN}Good luck with your deployment! 🎉${NC}"
echo ""

if [ $VALIDATION_RESULT -eq 0 ]; then
    exit 0
else
    echo -e "${RED}⚠️  Some validation checks failed. Please review and fix before deploying.${NC}"
    exit 1
fi
