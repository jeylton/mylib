# 🔧 Dépannage Debug Mobile LibroFlow

## ❌ **Problèmes Courants et Solutions**

### **📱 Émulateur**

#### **"Aucun appareil détecté"**
```bash
# Solution 1: Lancer manuellement
flutter emulators --launch Pixel_6_Pro
# Attendre 30-60 secondes
flutter devices

# Solution 2: Via Android Studio
# Ouvrir Android Studio → Tools → AVD Manager → Démarrer l'émulateur
```

#### **"Émulateur ne démarre pas"**
```bash
# Vérifier la RAM disponible
# Minimum 4GB RAM recommandée pour l'émulateur

# Redémarrer Android Studio
# Tools → AVD Manager → Wipe Data → Cold Boot
```

#### **"Émulateur lent"**
```bash
# Dans AVD Manager:
# - Éditer l'émulateur
# - Advanced Settings → Graphics: Hardware
# - RAM: 4096MB minimum
# - Storage: 6GB minimum
```

---

### **🔧 Build Flutter**

#### **"Gradle build échoue"**
```bash
# Nettoyer complètement
flutter clean
cd android
./gradlew clean
cd ..
flutter pub get
flutter run -d emulator-5554 --debug
```

#### **"Build trop lent"**
```bash
# Augmenter la mémoire Gradle
# Dans android/gradle.properties:
org.gradle.jvmargs=-Xmx4096m -XX:MaxPermSize=512m

# Activer le daemon Gradle
org.gradle.daemon=true
org.gradle.parallel=true
```

#### **"Out of memory"**
```bash
# Fermer d'autres applications
# Augmenter la mémoire virtuelle Windows
# Redémarrer l'ordinateur
```

---

### **🌐 API et Réseau**

#### **"API inaccessible depuis mobile"**
```bash
# Vérifier que Docker tourne
docker-compose ps

# Tester l'API localement
curl http://localhost:5001/api/books

# Vérifier la configuration
# Dans lib/config/api_config_selector.dart
# baseUrl doit être "http://10.0.2.2:5001/api"
```

#### **"Connection refused"**
```bash
# Vérifier les ports
netstat -an | findstr :5001

# Redémarrer Docker
docker-compose down
docker-compose up -d
```

#### **"CORS error"**
```bash
# Le backend Docker doit avoir:
# Access-Control-Allow-Origin: *
# Access-Control-Allow-Methods: GET,POST,PUT,DELETE
# Access-Control-Allow-Headers: Content-Type,Authorization
```

---

### **🔍 Debug et Logs**

#### **"Pas de logs dans la console"**
```bash
# Vérifier que le mode debug est actif
flutter run -d emulator-5554 --debug

# Logs séparés
flutter logs -d emulator-5554

# Logs avec filtre
flutter logs | grep "ERROR"
```

#### **"Hot Reload ne fonctionne pas"**
```bash
# Arrêter et relancer
q (dans le terminal Flutter)
flutter run -d emulator-5554 --debug

# Vérifier les erreurs de syntaxe
flutter analyze
```

#### **"Breakpoints ne fonctionnent pas"**
```bash
# Dans VS Code:
# 1. F5 pour démarrer le debug
# 2. Placer les breakpoints
# 3. Utiliser "Debug View" pour voir les variables

# Vérifier launch.json
# "type": "dart" doit être correct
```

---

### **💻 VS Code**

#### **"Extensions Flutter manquantes"**
```bash
# Installer les extensions:
# - Flutter
# - Dart
# - Flutter Widget Snippets
# - Flutter Tree
```

#### **"Device non détecté dans VS Code"**
```bash
# Vérifier dans terminal:
flutter devices

# Dans VS Code:
# Ctrl+Shift+P → "Flutter: Select Device"
# Choisir "emulator-5554"
```

---

## 🛠️ **Solutions Avancées**

### **1. Réinitialisation Complète**
```bash
# Arrêter tout
docker-compose down
flutter emulators --shutdown

# Nettoyer
flutter clean
cd android
./gradlew clean
cd ..

# Redémarrer
docker-compose up -d
flutter emulators --launch Pixel_6_Pro
# Attendre 60 secondes
flutter run -d emulator-5554 --debug
```

### **2. Configuration Alternative**
```bash
# Utiliser un autre émulateur
flutter emulators --create --name "Test Device"
flutter emulators --launch "Test Device"
flutter run -d "Test Device" --debug
```

### **3. Appareil Physique**
```bash
# Activer "Developer Options" sur Android
# Activer "USB Debugging"
# Connecter le téléphone
flutter devices
flutter run -d <device_id> --debug
```

---

## 📊 **Monitoring**

### **Performance**
```bash
# Mode profile
flutter run --profile

# Outils dans VS Code:
# - Flutter Performance
# - Memory View
# - CPU Profiler
```

### **Réseau**
```bash
# Installer des logs réseau
# Dans le code:
print('🌐 Request: $method $url');
print('📦 Response: ${response.statusCode}');
```

---

## 🎯 **Checklist de Dépannage**

### **Avant de commencer:**
- [ ] Docker Desktop démarré
- [ ] Backend API accessible (curl localhost:5001)
- [ ] Émulateur lancé et visible dans `flutter devices`
- [ ] VS Code avec extensions Flutter

### **Si problème persiste:**
- [ ] Redémarrer l'ordinateur
- [ ] Nettoyer Flutter (`flutter clean`)
- [ ] Recréer l'émulateur
- [ ] Réinstaller les extensions VS Code

---

## 🆘 **Aide Rapide**

### **Commandes de secours:**
```bash
# Tout arrêter
docker-compose down
flutter emulators --shutdown

# Tout redémarrer
docker-compose up -d
flutter emulators --launch Pixel_6_Pro
sleep 60
flutter run -d emulator-5554 --debug
```

### **Logs utiles:**
```bash
# Logs Flutter
flutter logs --verbose

# Logs Docker
docker-compose logs --tail=50

# Logs système Android
adb logcat
```

---

**Si aucun de ces solutions ne fonctionne, contactez le support technique avec les logs complets.** 🛠️
