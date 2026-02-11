@echo off
title 🔧 Réparation Émulateur Android
color 0E

echo.
echo ╔══════════════════════════════════════════════════════════════╗
echo ║           🔧 RÉPARATION ÉMULATEUR ANDROID                     ║
echo ╚══════════════════════════════════════════════════════════════╝
echo.

echo [1/6] 📋 Arrêt des processus émulateur...
taskkill /f /im qemu-system-x86_64.exe 2>nul
taskkill /f /im qemu-system-i386.exe 2>nul
taskkill /f /im emulator.exe 2>nul
echo ✅ Processus arrêtés!

echo.
echo [2/6] 🧹 Nettoyage des fichiers temporaires...
if exist "%LOCALAPPDATA%\Android\Sdk\emulator" (
    del /q "%LOCALAPPDATA%\Android\Sdk\emulator\*.log" 2>nul
    del /q "%LOCALAPPDATA%\Android\Sdk\emulator\*.lock" 2>nul
)
echo ✅ Fichiers temporaires nettoyés!

echo.
echo [3/6] 🔍 Vérification des DLL manquantes...
set "ANDROID_SDK=%LOCALAPPDATA%\Android\Sdk"
set "EMULATOR_PATH=%ANDROID_SDK%\emulator"

if exist "%EMULATOR_PATH%\libandroid-emu-metrics.dll" (
    echo ✅ libandroid-emu-metrics.dll trouvé
) else (
    echo ❌ libandroid-emu-metrics.dll manquant
    echo 💡 Solution: Réinstaller Android Studio SDK Platform Tools
)

if exist "%EMULATOR_PATH%\liblibprotobuf.dll" (
    echo ✅ liblibprotobuf.dll trouvé
) else (
    echo ❌ liblibprotobuf.dll manquant
    echo 💡 Solution: Réinstaller Android Studio SDK Platform Tools
)

echo.
echo [4/6] 🔄 Recréation de l'émulateur...
echo 📋 Suppression de l'émulateur défectueux...
flutter emulators --delete Pixel_6_Pro 2>nul

echo 📋 Création d'un nouvel émulateur...
echo 💡 Cette étape peut prendre plusieurs minutes...

REM Commande pour créer un nouvel émulateur avec les bonnes configurations
echo 📱 Création d'un émulateur compatible...
cd /d "%ANDROID_SDK%\cmdline-tools\latest\bin"
avdmanager create avd -n "LibroFlow_Debug" -k "system-images;android-30;google_apis;x86_64" -d "pixel_6" --force

echo.
echo [5/6] 🚀 Lancement du nouvel émulateur...
cd /d "%ANDROID_SDK%\emulator"
emulator -avd "LibroFlow_Debug" -no-snapshot -wipe-data >nul 2>&1 &

echo.
echo [6/6] ⏳ Attente du démarrage de l'émulateur...
timeout /t 45 /nobreak

echo.
echo ╔══════════════════════════════════════════════════════════════╗
echo ║                    📋 VÉRIFICATION FINALE                   ║
echo ╚══════════════════════════════════════════════════════════════╝
echo.

echo 📱 Émulateurs disponibles:
flutter emulators

echo.
echo 📋 Appareils détectés:
timeout /t 10 /nobreak
flutter devices

echo.
echo ╔══════════════════════════════════════════════════════════════╗
echo ║                    🎯 INSTRUCTIONS FINALES                   ║
echo ╚══════════════════════════════════════════════════════════════╝
echo.
echo Si l'émulateur fonctionne:
echo   1. Lancez: flutter run -d <device_id> --debug
echo   2. Ou utilisez VS Code: F5 → Choisir l'émulateur
echo.
echo Si l'émulateur ne fonctionne pas:
echo   1. Réinstallez Android Studio complètement
echo   2. Ou utilisez un appareil physique Android
echo.
echo 📞 Alternative: Debug sur navigateur web
echo   flutter run -d chrome --debug
echo.

pause
