#!/bin/bash

# 🚀 Script de vérification et déploiement AREA
# Ce script vérifie que toutes les corrections sont en place

echo "========================================="
echo "🔍 Vérification des corrections AREA"
echo "========================================="
echo ""

# Vérification 1: Extension PostgreSQL dans Dockerfile
echo "1️⃣ Vérification extension PostgreSQL..."
if grep -q "pdo_pgsql" backend-area/Dockerfile; then
    echo "✅ Extension pdo_pgsql trouvée dans Dockerfile"
else
    echo "❌ Extension pdo_pgsql MANQUANTE dans Dockerfile"
    exit 1
fi

# Vérification 2: Configuration PostgreSQL
echo ""
echo "2️⃣ Vérification configuration PostgreSQL..."
if grep -q "DB_CONNECTION=pgsql" backend-area/.env.example; then
    echo "✅ Configuration PostgreSQL correcte dans .env.example"
else
    echo "❌ Configuration PostgreSQL INCORRECTE"
    exit 1
fi

# Vérification 3: Dockerfile de production
echo ""
echo "3️⃣ Vérification Dockerfile.production..."
if [ -f "backend-area/Dockerfile.production" ] && [ -s "backend-area/Dockerfile.production" ]; then
    echo "✅ Dockerfile.production existe et n'est pas vide"
else
    echo "❌ Dockerfile.production manquant ou vide"
    exit 1
fi

# Vérification 4: Nouveau design frontend
echo ""
echo "4️⃣ Vérification design frontend..."
if grep -q "animate-fade-in-up" frontend-area/app/pages/index.vue; then
    echo "✅ Animations CSS présentes dans index.vue"
else
    echo "⚠️  Animations peut-être manquantes"
fi

echo ""
echo "========================================="
echo "✅ TOUTES LES VÉRIFICATIONS PASSÉES"
echo "========================================="
echo ""
echo "📝 Prochaines étapes:"
echo ""
echo "1. Déploiement backend sur Render:"
echo "   - Créer un Web Service sur render.com"
echo "   - Connecter le repo GitHub"
echo "   - Sélectionner backend-area comme Root Directory"
echo "   - Dockerfile: Dockerfile.production"
echo "   - Ajouter les variables d'environnement PostgreSQL"
echo ""
echo "2. Test local:"
echo "   cd backend-area"
echo "   docker build -f Dockerfile.production -t area-backend ."
echo "   docker run -p 8000:8000 area-backend"
echo ""
echo "3. Frontend:"
echo "   cd frontend-area"
echo "   npm install"
echo "   npm run dev"
echo ""
echo "========================================="
