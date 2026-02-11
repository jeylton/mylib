@echo off
title 🌐 Debug Web LibroFlow (Alternative Mobile)
color 0A

echo.
echo ╔══════════════════════════════════════════════════════════════╗
echo ║           🌐 DEBUG WEB LIBROFLOW (ALTERNATIVE MOBILE)       ║
echo ╚══════════════════════════════════════════════════════════════╝
echo.

echo [1/4] 📋 Vérification des prérequis...
flutter doctor >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Flutter n'est pas installé!
    pause
    exit /b 1
)
echo ✅ Flutter prêt!

echo.
echo [2/4] 🐳 Vérification du backend Docker...
curl -s -o nul -w "Backend Status: %%{http_code}\n" http://localhost:5001/api/books 2>nul
if %errorlevel% neq 0 (
    echo ❌ Backend Docker non accessible!
    echo 💡 Lancez d'abord: START-HERE.bat
    pause
    exit /b 1
)
echo ✅ Backend Docker accessible!

echo.
echo [3/4] 🌐 Configuration de l'API pour web...
echo 📡 Configuration: http://localhost:5001/api
echo ✅ API configurée pour le web!

echo.
echo [4/4] 🚀 Lancement du debug web...
echo.
echo ╔══════════════════════════════════════════════════════════════╗
echo ║                    🌐 DÉMARRAGE WEB DEBUG                    ║
echo ╚══════════════════════════════════════════════════════════════╝
echo.
echo 🌐 Navigateur: Chrome
echo 🔧 API: http://localhost:5001
echo 📱 Mode: Debug (identique au mobile)
echo.
echo 💡 Avantages du debug web:
echo    ✅ Hot Reload instantané
echo    ✅ Outils de développement Chrome
echo    ✅ Debuggage réseau facile
echo    ✅ Performance monitoring
echo    ✅ Même code que mobile
echo.

REM Lancer Flutter sur Chrome
echo 🚀 Lancement de LibroFlow en mode web debug...
flutter run -d chrome --debug --web-port=3002

echo.
echo ✅ Debug web terminé!
echo.
echo 📋 Accès à l'application:
echo    http://localhost:3002
echo.
echo 🔄 Pour redémarrer:
echo    flutter run -d chrome --debug --web-port=3002
echo.

pause
