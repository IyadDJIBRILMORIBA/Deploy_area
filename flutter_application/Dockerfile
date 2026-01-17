# flutter_application/Dockerfile
FROM ghcr.io/cirruslabs/flutter:stable

WORKDIR /app

# Copie du projet
COPY . .

# On nettoie et on récupère les dépendances
RUN flutter clean
RUN flutter pub get

# On compile l'APK et on le copie dans le dossier de sortie (le volume)
# Le CMD est important : il construit puis copie le fichier
CMD flutter build apk --release && \
    mkdir -p /app/output && \
    cp build/app/outputs/flutter-apk/app-release.apk /app/output/client.apk && \
    echo "APK Generated and copied to shared volume!"