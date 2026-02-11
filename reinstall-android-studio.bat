@echo off
title 🔄 Réinstallation Complète Android Studio
color 0E

echo.
echo ╔══════════════════════════════════════════════════════════════╗
echo ║           🔄 RÉINSTALLATION COMPLÈTE ANDROID STUDIO         ║
echo ╚══════════════════════════════════════════════════════════════╝
echo.

echo [1/6] 🛑 Arrêt complet de tous les processus Android...
taskkill /f /im "studio64.exe" 2>nul
taskkill /f /im "studio.exe" 2>nul
taskkill /f /im qemu-system-x86_64.exe 2>nul
taskkill /f /im emulator.exe 2>nul
echo ✅ Processus arrêtés!

echo.
echo [2/6] 🧹 Suppression complète des dossiers Android...
set "LOCAL_ANDROID=%LOCALAPPDATA%\Android"
set "PROGRAM_ANDROID=%PROGRAMFILES%\Android"
set "APPDATA_ANDROID=%APPDATA%\Android"

echo 🗑️ Suppression: %LOCAL_ANDROID%
if exist "%LOCAL_ANDROID%" (
    rmdir /s /q "%LOCAL_ANDROID%" 2>nul
    echo ✅ %LOCAL_ANDROID% supprimé
) else (
    echo ℹ️ %LOCAL_ANDROID% n'existe pas
)

echo 🗑️ Suppression: %PROGRAM_ANDROID%
if exist "%PROGRAM_ANDROID%" (
    rmdir /s /q "%PROGRAM_ANDROID%" 2>nul
    echo ✅ %PROGRAM_ANDROID% supprimé
) else (
    echo ℹ️ %PROGRAM_ANDROID% n'existe pas
)

echo 🗑️ Suppression: %APPDATA_ANDROID%
if exist "%APPDATA_ANDROID%" (
    rmdir /s /q "%APPDATA_ANDROID%" 2>nul
    echo ✅ %APPDATA_ANDROID% supprimé
) else (
    echo ℹ️ %APPDATA_ANDROID% n'existe pas
)

echo.
echo [3/6] 🧹 Nettoyage du registre Windows...
echo 💡 Suppression des clés Android Studio du registre...
reg delete "HKCU\SOFTWARE\AndroidStudio" /f 2>nul
reg delete "HKLM\SOFTWARE\AndroidStudio" /f 2>nul
echo ✅ Registre nettoyé!

echo.
echo [4/6] 📥 Téléchargement Android Studio...
echo 🌐 Ouverture du site officiel...
start https://developer.android.com/studio

echo.
echo ╔══════════════════════════════════════════════════════════════╗
echo ║                    📋 INSTRUCTIONS MANUELLES               ║
echo ╚══════════════════════════════════════════════════════════════╝
echo.
echo 1. 📥 Téléchargez Android Studio depuis la page qui s'est ouverte
echo 2. 💾 Exécutez l'installateur en tant qu'administrateur
echo 3. ✅ Cochez "Android Virtual Device" pendant l'installation
echo 4. 🚀 Lancez Android Studio après l'installation
echo 5. 📱 Dans le setup initial, installez:
echo    - Android SDK
echo    - Android SDK Platform-Tools  
echo    - Android SDK Build-Tools
echo    - Android 12 (API 31) ou plus récent
echo 6. 📱 Créez un nouvel émulateur:
echo    - Tools → AVD Manager → Create Virtual Device
echo    - Choisissez: Pixel 6
echo    - System Image: Android 12 (API 31) with Google APIs
echo    - Finish
echo.

echo [5/6] ⏳ Attente de l'installation manuelle...
echo 💡 Une fois Android Studio installé, appuyez sur une touche pour continuer...
pause

echo.
echo [6/6] 📋 Vérification de l'installation...
echo 📱 Vérification des émulateurs...
flutter emulators

echo.
echo 📋 Vérification des appareils...
timeout /t 10 /nobreak >nul
flutter devices

echo.
echo ╔══════════════════════════════════════════════════════════════╗
echo ║                    🎯 INSTRUCTIONS FINALES                   ║
echo ╚══════════════════════════════════════════════════════════════╝
echo.
echo Si l'émulateur fonctionne maintenant:
echo    flutter run -d <device_id> --debug
echo.
echo Si l'émulateur ne fonctionne toujours pas:
echo    🌐 Utilisez le debug web: debug-web-alternative.bat
echo    📱 Ou utilisez un appareil physique Android
echo.

echo 🚀 Test de l'émulateur...
echo 💡 Si vous avez un émulateur, testez-le maintenant:
echo    emulator -list-avds
echo    emulator -avd <nom_emulateur>

pause
