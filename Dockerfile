# Étape 1: Build Flutter Web
FROM dart:stable AS flutter-build

WORKDIR /app

# Installer Flutter
RUN apt-get update && apt-get install -y curl git unzip xz-utils zip libglu1-mesa
RUN git clone https://github.com/flutter/flutter.git -b stable /usr/local/flutter
ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"
RUN flutter doctor

# Copier les fichiers source
COPY . .

# Installer les dépendances
RUN flutter pub get

# Build pour le web
RUN flutter build web --web-renderer canvaskit --release

# Étape 2: Serveur Web
FROM nginx:alpine

# Copier le build Flutter dans nginx
COPY --from=flutter-build /app/build/web /usr/share/nginx/html

# Copier la configuration nginx
COPY nginx.conf /etc/nginx/nginx.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
