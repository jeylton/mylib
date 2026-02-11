@echo off
title 🚀 LibroFlow Docker - Démarrage Complet
color 0A

echo.
echo ╔══════════════════════════════════════════════════════════════╗
echo ║           🐳 LIBROFLOW DOCKER - DÉMARRAGE AUTOMATIQUE           ║
echo ╚══════════════════════════════════════════════════════════════╝
echo.

REM Étape 1: Vérifier Docker
echo [1/6] 📋 Vérification de Docker...
docker --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Docker n'est pas installé ou démarré!
    echo 💡 Veuillez installer Docker Desktop depuis https://www.docker.com
    pause
    exit /b 1
)
echo ✅ Docker est installé et prêt!

REM Étape 2: Vérifier Flutter
echo.
echo [2/6] 📋 Vérification de Flutter...
flutter --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Flutter n'est pas installé!
    echo 💡 Veuillez installer Flutter depuis https://flutter.dev/docs/get-started/install
    pause
    exit /b 1
)
echo ✅ Flutter est installé et prêt!

REM Étape 3: Arrêter les anciens conteneurs
echo.
echo [3/6] 🛑 Arrêt des anciens conteneurs...
docker-compose down >nul 2>&1
echo ✅ Anciens conteneurs arrêtés!

REM Étape 4: Build Flutter
echo.
echo [4/6] 🔨 Construction du frontend Flutter...
flutter build web --release
if %errorlevel% neq 0 (
    echo ❌ Erreur lors du build Flutter!
    pause
    exit /b 1
)
echo ✅ Frontend Flutter construit!

REM Étape 5: Build Docker
echo.
echo [5/6] 🐳 Construction des images Docker...
docker-compose build
if %errorlevel% neq 0 (
    echo ❌ Erreur lors du build Docker!
    pause
    exit /b 1
)
echo ✅ Images Docker construites!

REM Étape 6: Démarrage des services
echo.
echo [6/6] 🚀 Démarrage des services Docker...
docker-compose up -d
if %errorlevel% neq 0 (
    echo ❌ Erreur lors du démarrage des services!
    pause
    exit /b 1
)
echo ✅ Services Docker démarrés!

REM Étape 7: Vérification finale
echo.
echo ⏳ Attente du démarrage complet des services...
timeout /t 15 /nobreak >nul

echo.
echo ╔══════════════════════════════════════════════════════════════╗
echo ║                     📊 ÉTAT DES SERVICES                      ║
echo ╚══════════════════════════════════════════════════════════════╝
echo.
docker-compose ps

echo.
echo ╔══════════════════════════════════════════════════════════════╗
echo ║                    🌐 ACCÈS À L'APPLICATION                    ║
echo ╚══════════════════════════════════════════════════════════════╝
echo.
echo 🌐 Frontend Flutter: http://localhost:3000
echo 🔧 Backend API:      http://localhost:5001
echo 🗄️ Base de données:  localhost:5432
echo.

REM Test de connectivité
echo 🧪 Test de connectivité...
curl -s -o nul -w "Frontend: %%{http_code}\n" http://localhost:3000 2>nul
curl -s -o nul -w "Backend:  %%{http_code}\n" http://localhost:5001/api/books 2>nul

echo.
echo ╔══════════════════════════════════════════════════════════════╗
echo ║                   ✅ LIBROFLOW EST PRÊT !                       ║
echo ╚══════════════════════════════════════════════════════════════╝
echo.
echo 🚀 Ouvrez votre navigateur et accédez à: http://localhost:3000
echo.
echo 👤 Connexions disponibles:
echo    Admin:  semporejeriel@gmail.com / Jeriel123
echo    Étudiant: firmin@gmail.com / Jeriel123
echo.
echo 📋 Commandes utiles:
echo    Voir les logs: docker-compose logs -f
echo    Arrêter:      docker-compose down
echo    Redémarrer:    docker-compose restart
echo.

echo 🌐 Lancement du navigateur...
start http://localhost:3000

echo.
echo Appuyez sur une touche pour quitter...
pause >nul
