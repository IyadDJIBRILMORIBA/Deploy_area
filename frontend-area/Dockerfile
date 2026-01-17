FROM node:22

WORKDIR /app

# Install dependencies for better-sqlite3
RUN apt-get update && apt-get install -y \
    python3 \
    make \
    g++ \
    && rm -rf /var/lib/apt/lists/*

# Copie des fichiers de dépendances
COPY package*.json ./

# Installation des dépendances
RUN npm install

# Copie du reste du projet
COPY . .

# Build de l'application
RUN npm run build

# Exposition du port
EXPOSE 3000

# Lancement
CMD ["node", ".output/server/index.mjs"]