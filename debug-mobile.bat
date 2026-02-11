@echo off
title 📱 LibroFlow Mobile Debug
color 0B

echo.
echo ╔══════════════════════════════════════════════════════════════╗
echo ║           📱 LIBROFLOW - DEBUG MODE MOBILE                   ║
echo ╚══════════════════════════════════════════════════════════════╝
echo.

REM Vérifier les prérequis
echo [1/5] 📋 Vérification des prérequis...
flutter doctor --verbose >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Flutter n'est pas correctement configuré!
    pause
    exit /b 1
)

REM Lancer l'émulateur
echo.
echo [2/5] 📱 Démarrage de l'émulateur Android...
echo 📋 Émulateur disponible: Pixel 6 Pro
flutter emulators --launch Pixel_6_Pro
echo ✅ Émulateur en cours de démarrage...

REM Attendre que l'émulateur soit prêt
echo.
echo [3/5] ⏳ Attente du démarrage de l'émulateur...
timeout /t 30 /nobreak

REM Vérifier les appareils connectés
echo.
echo [4/5] 📱 Vérification des appareils...
flutter devices

REM Configuration API pour mobile
echo.
echo [5/5] 🔧 Configuration de l'API pour mobile...
echo 📡 Configuration: Utilisation de l'API Docker sur localhost:5001

REM Lancer le debug
echo.
echo ╔══════════════════════════════════════════════════════════════╗
echo ║                    🚀 DÉMARRAGE DU DEBUG                      ║
echo ╚══════════════════════════════════════════════════════════════╝
echo.
echo 📱 Appareil cible: Émulateur Pixel 6 Pro
echo 🔧 API Backend: http://localhost:5001
echo 🌐 Mode: Debug Mobile
echo.

REM Vérifier que Docker tourne
echo 🐳 Vérification du backend Docker...
curl -s -o nul -w "Backend Status: %%{http_code}\n" http://localhost:5001/api/books 2>nul

REM Lancer Flutter sur l'émulateur
echo.
echo 🚀 Lancement de LibroFlow en mode debug mobile...
echo 💡 Utilisez les commandes suivantes dans VS Code:
echo    - F5: Démarrer le debug
echo    - Ctrl+Shift+P: Flutter: Hot Reload
echo    - Ctrl+F5: Hot Restart
echo.

REM Lancer le debug
flutter run -d Pixel_6_Pro --debug

echo.
echo ✅ Debug mobile terminé!
pause
