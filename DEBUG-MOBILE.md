# 📱 Debug Mobile LibroFlow - Guide Complet

## 🚀 **Démarrage Rapide du Debug Mobile**

### **📋 Prérequis**
- ✅ Docker Desktop démarré avec le backend
- ✅ Flutter installé et configuré
- ✅ Android Studio avec émulateur
- ✅ VS Code avec extensions Flutter

---

## 🔧 **Méthode 1: Script Automatique (Recommandé)**

### **1. Démarrer le Backend Docker**
```bash
# Double-cliquer sur:
START-HERE.bat
# Ou manuellement:
docker-compose up -d
```

### **2. Lancer le Debug Mobile**
```bash
# Double-cliquer sur:
debug-mobile.bat
```

**Le script fait tout automatiquement:**
- ✅ Lance l'émulateur Pixel 6 Pro
- ✅ Attend le démarrage complet
- ✅ Configure l'API pour mobile
- ✅ Lance Flutter en mode debug

---

## 🔧 **Méthode 2: Manuel Complet**

### **1. Vérifier les prérequis**
```bash
flutter doctor
flutter devices
flutter emulators
```

### **2. Démarrer l'émulateur**
```bash
# Lancer l'émulateur Pixel 6 Pro
flutter emulators --launch Pixel_6_Pro

# Attendre 30 secondes que l'émulateur soit prêt
```

### **3. Vérifier les appareils**
```bash
flutter devices
# Doit afficher: Pixel 6 Pro • android-arm64
```

### **4. Lancer le debug**
```bash
# Lancer sur l'émulateur spécifique
flutter run -d Pixel_6_Pro --debug

# Ou lancer sur le premier appareil mobile disponible
flutter run -d android --debug
```

---

## 🌐 **Configuration API Mobile**

### **Automatique avec ApiConfigSelector**
L'application utilise automatiquement:
- **Mobile Debug**: `http://10.0.2.2:5001/api` (émulateur Android)
- **Web**: `http://localhost:5001/api`

### **10.0.2.2 = localhost depuis émulateur Android**
Cette adresse spéciale permet à l'émulateur d'accéder à votre machine locale.

---

## 📱 **Commandes Debug Essentielles**

### **Dans VS Code**
- **F5**: Démarrer le debug
- **Ctrl+Shift+P**: Flutter: Hot Reload
- **Ctrl+F5**: Hot Restart
- **Shift+F5**: Stop Debug

### **Dans Terminal**
```bash
# Hot Reload (r)
r

# Hot Restart (R)
R

# Quitter (q)
q

# Afficher la grille de performance
p

# Activer le debug painting
w
```

---

## 🔍 **Outils de Debug**

### **1. Flutter Inspector**
- Ouvrir VS Code
- F5 pour démarrer le debug
- Onglet "Flutter Inspector"
- Visualiser l'arborescence des widgets

### **2. Console Debug**
```bash
# Afficher les logs de l'application
flutter logs

# Logs spécifiques à l'appareil
flutter logs -d Pixel_6_Pro
```

### **3. Performance**
```bash
# Analyser la performance
flutter run --profile

# Tracer la performance
flutter run --trace-startup
```

---

## 🛠️ **Résolution des Problèmes**

### **❌ "Aucun appareil détecté"**
```bash
# Solution:
flutter emulators --launch Pixel_6_Pro
# Attendre 30-60 secondes
flutter devices
```

### **❌ "Émulateur ne démarre pas"**
```bash
# Solution:
# 1. Ouvrir Android Studio
# 2. Tools → AVD Manager
# 3. Démarrer manuellement l'émulateur
# 4. Relancer flutter devices
```

### **❌ "API inaccessible depuis mobile"**
```bash
# Vérifier que Docker tourne:
docker-compose ps

# Tester l'API:
curl http://localhost:5001/api/books

# Vérifier la configuration dans ApiConfigSelector
```

### **❌ "Hot Reload ne fonctionne pas"**
```bash
# Solution:
# 1. Arrêter le debug (q)
# 2. Relancer flutter run
# 3. Vérifier que le mode debug est actif
```

### **❌ "Build échoue"**
```bash
# Nettoyer et recommencer:
flutter clean
flutter pub get
flutter run -d Pixel_6_Pro --debug
```

---

## 📊 **Monitoring en Temps Réel**

### **1. Logs Application**
```bash
# Tous les logs
flutter logs

# Logs avec filtre
flutter logs | grep "ERROR"
flutter logs | grep "API"
```

### **2. Réseau**
```bash
# Surveiller les requêtes API
# Dans le code, ajouter des logs:
print('🌐 API Request: $url');
print('📦 Response: $response');
```

### **3. Performance**
```bash
# Mode profile pour analyse
flutter run --profile

# Outils de performance dans VS Code:
# - Flutter Performance
# - Flutter Inspector
# - Memory View
```

---

## 🎯 **Workflow de Debug Optimal**

### **1. Préparation**
```bash
# 1. Démarrer Docker
START-HERE.bat

# 2. Lancer le debug mobile
debug-mobile.bat
```

### **2. Développement**
- **Modifier le code** dans VS Code
- **Hot Reload** automatique (Ctrl+S)
- **Console** pour les erreurs
- **Inspector** pour le UI

### **3. Tests**
- **Tester les fonctionnalités** sur l'émulateur
- **Vérifier les appels API** dans les logs
- **Surveiller la performance** avec les outils Flutter

---

## 🔧 **Configuration Avancée**

### **1. Appareil Physique**
```bash
# Activer le debug USB sur le téléphone
# Connecter le téléphone
flutter devices
flutter run -d <device_id>
```

### **2. Multiple Émulateurs**
```bash
# Lister tous les émulateurs
flutter emulators

# Lancer un émulateur spécifique
flutter emulators --launch <emulator_id>

# Lancer sur un émulateur spécifique
flutter run -d <emulator_id>
```

### **3. Variables d'Environnement**
```bash
# Pour le debug mobile
export FLUTTER_API_URL=http://10.0.2.2:5001/api

# Pour le web
export FLUTTER_API_URL=http://localhost:5001/api
```

---

## 🎉 **Checklist de Debug Mobile**

- [ ] **Docker Desktop** démarré
- [ ] **Backend API** accessible (curl localhost:5001)
- [ ] **Émulateur Android** lancé
- [ ] **Flutter devices** montre l'émulateur
- [ ] **VS Code** avec extensions Flutter
- [ ] **ApiConfigSelector** configure automatiquement
- [ ] **Hot Reload** fonctionne
- [ ] **Logs** visibles dans la console

---

## 🚀 **Lancement Rapide**

**En 3 commandes:**
```bash
# 1. Backend Docker
START-HERE.bat

# 2. Debug Mobile
debug-mobile.bat

# 3. Développer !
# Modifier le code → Hot Reload automatique
```

**L'application mobile est maintenant prête pour le debug !** 📱✨
