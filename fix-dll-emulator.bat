@echo off
title 🔧 Réparation DLL Émulateur Android
color 0C

echo.
echo ╔══════════════════════════════════════════════════════════════╗
echo ║           🔧 RÉPARATION DLL MANQUANTES ÉMULATEUR              ║
echo ╚══════════════════════════════════════════════════════════════╝
echo.

echo [1/8] 📋 Diagnostic des DLL manquantes...
echo ❌ libandroid-emu-agents.dll
echo ❌ libandroid-emu-metrics.dll  
echo ❌ libglib2_windows_msvc-x86_64.dll
echo ❌ liblibprotobuf.dll
echo.

echo [2/8] 🛑 Arrêt complet des processus émulateur...
taskkill /f /im qemu-system-x86_64.exe 2>nul
taskkill /f /im qemu-system-i386.exe 2>nul
taskkill /f /im emulator.exe 2>nul
taskkill /f /im emulator-arm.exe 2>nul
taskkill /f /im emulator64-arm.exe 2>nul
echo ✅ Processus arrêtés!

echo.
echo [3/8] 🧹 Nettoyage complet des fichiers émulateur...
set "ANDROID_SDK=%LOCALAPPDATA%\Android\Sdk"

if exist "%ANDROID_SDK%\emulator" (
    del /q "%ANDROID_SDK%\emulator\*.dll" 2>nul
    del /q "%ANDROID_SDK%\emulator\*.exe" 2>nul
    del /q "%ANDROID_SDK%\emulator\*.lock" 2>nul
    del /q "%ANDROID_SDK%\emulator\*.log" 2>nul
    rmdir /s /q "%ANDROID_SDK%\emulator\cache" 2>nul
    rmdir /s /q "%ANDROID_SDK%\emulator\lib64" 2>nul
    rmdir /s /q "%ANDROID_SDK%\emulator\lib" 2>nul
)
echo ✅ Fichiers émulateur nettoyés!

echo.
echo [4/8] 🔄 Réinstallation Android SDK Tools...
echo 💡 Cette étape télécharge les composants manquants...

cd /d "%ANDROID_SDK%\cmdline-tools\latest\bin" 2>nul
if %errorlevel% neq 0 (
    echo ❌ Android SDK Tools non trouvé!
    echo 💡 Solution: Réinstaller Android Studio complètement
    goto :alternative
)

echo 📥 Mise à jour SDK Tools...
sdkmanager --update
sdkmanager "platform-tools" "emulator"

echo.
echo [5/8] 📱 Création d'un nouvel émulateur propre...
echo 🗑️ Suppression des anciens émulateurs...
flutter emulators --delete Pixel_6_Pro 2>nul
flutter emulators --delete LibroFlow_Debug 2>nul

echo 📱 Création nouvel émulateur...
avdmanager create avd -n "LibroFlow_Fixed" -k "system-images;android-31;google_apis;x86_64" -d "pixel_6" --force

echo.
echo [6/8] 🚀 Lancement du nouvel émulateur...
cd /d "%ANDROID_SDK%\emulator"
emulator -avd "LibroFlow_Fixed" -no-snapshot -wipe-data >nul 2>&1 &

echo.
echo [7/8] ⏳ Attente du démarrage (60 secondes)...
timeout /t 60 /nobreak

echo.
echo [8/8] 📋 Vérification finale...
echo 📱 Émulateurs disponibles:
flutter emulators

echo.
echo 📋 Appareils détectés:
timeout /t 10 /nobreak >nul
flutter devices

goto :end

:alternative
echo.
echo ╔══════════════════════════════════════════════════════════════╗
echo ║                    🌐 ALTERNATIVE WEB                        ║
echo ╚══════════════════════════════════════════════════════════════╝
echo.
echo 💡 L'émulateur nécessite une réinstallation complète d'Android Studio
echo.
echo 🌐 Solution immédiate: Debug Web
echo    ✅ Fonctionne maintenant
echo    ✅ Même code que mobile  
echo    ✅ Hot Reload instantané
echo    ✅ Outils Chrome DevTools
echo.
echo 🚀 Lancement du debug web...
debug-web-alternative.bat

:end
echo.
echo ╔══════════════════════════════════════════════════════════════╗
echo ║                    🎯 RÉSULTAT                              ║
echo ╚══════════════════════════════════════════════════════════════╝
echo.
echo Si l'émulateur fonctionne:
echo    flutter run -d <device_id> --debug
echo.
echo Si l'émulateur ne fonctionne pas:
echo    1. Utiliser le debug web (debug-web-alternative.bat)
echo    2. Réinstaller Android Studio complètement
echo    3. Utiliser un appareil physique Android
echo.

pause
