#!/bin/bash

# Configuration
RENDER_SERVICE_NAME="area-backend"
REGION="frankfurt"

echo "🚀 AREA Backend - Render Deployment Setup"
echo "=========================================="
echo ""

# Check if .env exists
if [ ! -f .env ]; then
    echo "⚠️  .env file not found. Creating from .env.example..."
    cp .env.example .env
    echo "✅ .env file created"
    echo "⚠️  Please configure your .env file before deployment"
else
    echo "✅ .env file found"
fi

# Generate APP_KEY if not set
if ! grep -q "APP_KEY=base64:" .env; then
    echo "🔑 Generating APP_KEY..."
    php artisan key:generate
    echo "✅ APP_KEY generated"
else
    echo "✅ APP_KEY already set"
fi

# Show current APP_KEY
echo ""
echo "📋 Your APP_KEY (add this to Render environment variables):"
grep "APP_KEY=" .env
echo ""

# Instructions
echo "📝 Next Steps:"
echo ""
echo "1. Create a database on Render or external service (MySQL/PostgreSQL)"
echo "   - For PostgreSQL: Use Render's built-in database (free tier available)"
echo "   - For MySQL: Use PlanetScale, Railway.io, or another provider"
echo ""
echo "2. Push your code to GitHub:"
echo "   git add ."
echo "   git commit -m 'Add Render deployment configuration'"
echo "   git push origin masters"
echo ""
echo "3. Go to https://dashboard.render.com"
echo "   - Click 'New +' → 'Web Service'"
echo "   - Connect your GitHub repository"
echo "   - Configure:"
echo "     * Name: $RENDER_SERVICE_NAME"
echo "     * Region: $REGION"
echo "     * Root Directory: backend-area"
echo "     * Environment: Docker"
echo "     * Dockerfile Path: Dockerfile.production"
echo ""
echo "4. Add environment variables in Render (copy from .env):"
echo "   - APP_NAME, APP_ENV, APP_DEBUG, APP_URL"
echo "   - APP_KEY (shown above)"
echo "   - DB_* (database configuration)"
echo "   - All OAuth credentials (GOOGLE_*, MICROSOFT_*, SPOTIFY_*, etc.)"
echo ""
echo "5. Deploy!"
echo ""
echo "📚 For detailed instructions, see: RENDER_DEPLOYMENT.md"
echo ""
echo "✨ Good luck with your deployment!"
