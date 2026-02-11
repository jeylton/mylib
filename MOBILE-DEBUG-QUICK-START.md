# 📱 Debug Mobile LibroFlow - Quick Start

## 🚀 **Démarrage en 3 Étapes**

### **1️⃣ Démarrer le Backend Docker**
```bash
START-HERE.bat
```

### **2️⃣ Lancer le Debug Mobile**
```bash
debug-mobile.bat
```

### **3️⃣ Développer !**
- Ouvrir VS Code
- F5 pour démarrer le debug
- Modifier le code → Hot Reload automatique

---

## 📱 **Accès Rapide**

### **Émulateur Disponible**
- **Nom**: Pixel 6 Pro
- **ID**: emulator-5554
- **OS**: Android 16 (API 36)

### **Configuration API**
- **Mobile**: `http://10.0.2.2:5001/api`
- **Web**: `http://localhost:5001/api`

---

## 🔧 **VS Code Debug Configurations**

Appuyez sur **F5** et choisissez:

- **📱 LibroFlow Mobile Debug** - Debug sur émulateur
- **🌐 LibroFlow Web Debug** - Debug sur navigateur
- **💻 LibroFlow Windows Debug** - Debug sur Windows

---

## 🎯 **Commandes Essentielles**

### **Dans l'application (terminal Flutter)**
- **r** - Hot Reload
- **R** - Hot Restart  
- **p** - Performance overlay
- **w** - Debug painting
- **q** - Quitter

### **Dans VS Code**
- **F5** - Démarrer/Continuer le debug
- **Shift+F5** - Arrêter le debug
- **Ctrl+Shift+P** → "Flutter: Hot Reload"

---

## 🔍 **Vérification**

### **Backend Docker**
```bash
docker-compose ps
# 3 services doivent être "Up"
```

### **API Access**
```bash
curl http://localhost:5001/api/books
# Doit retourner du JSON
```

### **Émulateur**
```bash
flutter devices
# Doit montrer "emulator-5554"
```

---

## ⚡ **Workflow Optimal**

1. **PC allumé** → `START-HERE.bat`
2. **Debug mobile** → `debug-mobile.bat`  
3. **VS Code** → F5
4. **Coder** → Hot Reload automatique

---

## 🎉 **Ready to Debug!**

**L'application mobile est maintenant configurée pour le debug complet avec:**
- ✅ Hot Reload
- ✅ Debug Inspector
- ✅ Performance monitoring
- ✅ API Docker connectée
- ✅ VS Code integration

**Commencez à développer !** 🚀
