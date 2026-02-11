# 🚀 Démarrage Rapide LibroFlow Docker

## 📋 **PC Fraîchement Allumé ? Suivez ces étapes :**

### **1️⃣ Installation des Prérequis**
```bash
# Installer Docker Desktop
# 📥 Télécharger: https://www.docker.com/products/docker-desktop
# 💡 Lancer l'installation et démarrer Docker Desktop

# Installer Flutter
# 📥 Télécharger: https://flutter.dev/docs/get-started/install/windows
# 💡 Ajouter Flutter au PATH pendant l'installation
```

### **2️⃣ Démarrage Automatique (Recommandé)**
```bash
# 1. Ouvrir l'explorateur de fichiers
# 2. Naviguer vers: C:\Users\USER\Downloads\libroflow-master\libroflow-master
# 3. Double-cliquer sur: START-HERE.bat
# 4. Attendre la fin du processus
# 5. Le navigateur s'ouvre automatiquement sur http://localhost:3000
```

### **3️⃣ Démarrage Manuel (Alternative)**
```bash
# Ouvrir CMD/PowerShell en tant qu'administrateur
cd C:\Users\USER\Downloads\libroflow-master\libroflow-master

# Lancer le script de démarrage
START-HERE.bat

# Ou manuellement:
flutter build web --release
docker-compose build
docker-compose up -d
start http://localhost:3000
```

---

## 🔍 **Vérification du Bon Fonctionnement**

### **Étape 1: Vérifier les services**
```bash
docker-compose ps
# Doit afficher 3 services "Up" (frontend, backend, postgres)
```

### **Étape 2: Tester l'accès**
- 🌐 **Frontend**: http://localhost:3000 (doit afficher l'application)
- 🔧 **Backend**: http://localhost:5001/api/books (doit afficher du JSON)

### **Étape 3: Se connecter**
- **Admin**: `semporejeriel@gmail.com` / `Jeriel123`
- **Étudiant**: `firmin@gmail.com` / `Jeriel123`

---

## 🛠️ **Commandes Essentielles**

### **Démarrage/Arrêt**
```bash
# Démarrer
docker-compose up -d

# Arrêter
docker-compose down

# Redémarrer
docker-compose restart
```

### **Monitoring**
```bash
# Voir l'état
docker-compose ps

# Voir les logs
docker-compose logs -f

# Logs d'un service spécifique
docker-compose logs -f backend
```

### **Maintenance**
```bash
# Reconstruire après modification
docker-compose build --no-cache
docker-compose up -d

# Nettoyer Docker
docker system prune -f
```

---

## ⚠️ **Problèmes Courants et Solutions**

### **❌ "Docker n'est pas installé"**
```bash
# Solution: Installer Docker Desktop depuis https://www.docker.com
# Redémarrer l'ordinateur après l'installation
```

### **❌ "Flutter n'est pas installé"**
```bash
# Solution: Installer Flutter depuis https://flutter.dev/docs/get-started/install/windows
# Ajouter flutter au PATH Windows
```

### **❌ "Port déjà utilisé"**
```bash
# Solution: Le port 5001 est déjà configuré pour éviter les conflits
# Si problème persiste, changer le port dans docker-compose.yml
```

### **❌ "Build échoue"**
```bash
# Solution: Nettoyer et recommencer
flutter clean
flutter build web --release
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

### **❌ "Services ne démarrent pas"**
```bash
# Solution: Vérifier les logs
docker-compose logs --tail=20

# Redémarrer Docker Desktop
# Relancer START-HERE.bat
```

---

## 🎯 **Résumé en 3 Étapes**

1. **Installer Docker Desktop + Flutter**
2. **Double-cliquer sur `START-HERE.bat`**
3. **Naviguer vers http://localhost:3000**

C'est tout ! 🎉

---

## 📞 **Aide**

Si vous rencontrez des problèmes:
1. Vérifiez que Docker Desktop est bien démarré
2. Vérifiez que Flutter est dans le PATH
3. Lancez `START-HERE.bat` en tant qu'administrateur
4. Consultez les logs avec `docker-compose logs -f`

**L'application sera accessible immédiatement après le démarrage !** 🚀
