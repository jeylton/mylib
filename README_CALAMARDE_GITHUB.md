# 📚 LibroFlow - Instructions pour Calamarde

## 🎯 **Présentation du Projet**

**LibroFlow** est une application web moderne de gestion de bibliothèque développée avec **Flutter** (frontend) et **Node.js** (backend), permettant la gestion complète des emprunts de livres via une interface intuitive et professionnelle.

---

## 🚀 **Installation Rapide (5 minutes)**

### **Prérequis**
- ✅ **Docker Desktop** installé et lancé
- ✅ **Navigateur moderne** (Chrome/Firefox/Edge)
- ✅ **Windows 10/11** avec PowerShell

### **Étape 1 - Clonage du Repository**
```bash
git clone https://github.com/jeylton/libroflow.git
cd libroflow
```

### **Étape 2 - Lancement**
```bash
# Démarrer tous les services
docker-compose up -d
```

### **Étape 3 - Vérification**
```bash
# Vérifier que les conteneurs tournent
docker ps

# Tester l'API
curl http://localhost/api/test
```

### **Étape 4 - Lancement Application**
```bash
# Installer les dépendances Flutter
flutter pub get

# Lancer l'application web
flutter run -d chrome
```

### **Étape 5 - Connexion**
- **URL** : http://localhost
- **Admin** : `semporejeriel@gmail.com` / `Jeriel123`
- **Étudiant** : `firmin@gmail.com` / `Jeriel123`

---

## 🌟 **Fonctionnalités Principales**

### **👨‍🎓 Pour les Étudiants**
- ✅ **Catalogue complet** : Consultation de tous les livres disponibles
- ✅ **Emprunt intelligent** : Maximum 3 livres simultanés
- ✅ **Suivi des dates** : Notifications de retour
- ✅ **Historique personnel** : Tous les emprunts passés et présents
- ✅ **Dashboard statistique** : Livres lus, retards, balance
- ✅ **Profil utilisateur** : Gestion des informations personnelles

### **👨‍💼 Pour les Administrateurs**
- ✅ **Gestion du catalogue** : Ajouter, modifier, supprimer des livres
- ✅ **Surveillance active** : Vue en temps réel des emprunts
- ✅ **Statistiques globales** : Rapports détaillés de la bibliothèque
- ✅ **Gestion des utilisateurs** : Vue d'ensemble des comptes
- ✅ **Configuration système** : Paramètres et maintenance

---

## 🛡️ **Sécurité Implémentée**

- **🔐 Authentification JWT** : Tokens sécurisés avec expiration 7 jours
- **🛡️ Protection API** : CORS configuré + Rate Limiting
- **🔍 Validation Input** : Protection contre injections SQL/XSS
- **🗄️ Base de données** : Connexions SSL via Supabase
- **📡 Headers Security** : X-Frame-Options, CSP, XSS Protection

---

## 📋 **Guide de Démonstration**

### **Scénario 1 - Connexion Administrateur**
1. Ouvrir http://localhost
2. Utiliser `semporejeriel@gmail.com` / `Jeriel123`
3. Accéder au dashboard administrateur
4. Visualiser les statistiques globales
5. Gérer le catalogue des livres

### **Scénario 2 - Emprunt Étudiant**
1. Se connecter avec `firmin@gmail.com` / `Jeriel123`
2. Parcourir le catalogue des livres
3. Sélectionner un livre disponible
4. Confirmer l'emprunt
5. Voir la mise à jour automatique du dashboard

### **Scénario 3 - Retour de Livre**
1. Accéder à la section "Mes Livres"
2. Cliquer sur "Marquer comme lu"
3. Vérifier la mise à jour du stock
4. Consulter l'historique mis à jour

---

## 🏆 **Compétences Démontrées**

### **Frontend Development**
- ✅ **Flutter Framework** : Material Design 3, Provider Pattern
- ✅ **State Management** : Architecture reactive et optimisée
- ✅ **UI/UX Design** : Interfaces modernes et intuitives
- ✅ **Web Development** : Responsive design, performances

### **Backend Development**
- ✅ **Node.js/Express** : API RESTful, middleware sécurité
- ✅ **Database Design** : PostgreSQL, Sequelize ORM, indexation
- ✅ **Authentication** : JWT, validation, gestion sessions
- ✅ **API Architecture** : Routes, controllers, services

### **DevOps/Infrastructure**
- ✅ **Containerisation** : Docker multi-services, orchestration
- ✅ **Web Server** : Nginx, reverse proxy, load balancing
- ✅ **Cloud Services** : Supabase integration, backups automatiques
- ✅ **Deployment** : Configuration production, monitoring

---

## 🔧 **Dépannage**

### **Problèmes Communs**
- **Port 80 déjà utilisé** : Arrêter IIS ou autre service web
- **Docker ne démarre pas** : Vérifier Docker Desktop lancé
- **API inaccessible** : Vérifier `docker ps` et logs
- **Flutter ne compile pas** : `flutter clean` puis `flutter pub get`

### **Commandes Utiles**
```bash
# Vérifier les conteneurs
docker ps

# Voir les logs
docker logs [nom_conteneur]

# Redémarrer tout
docker-compose restart

# Nettoyer tout
docker-compose down && docker system prune -f
```

---

## 📞 **Support**

- **🌐 Repository** : https://github.com/jeylton/libroflow
- **📧 Documentation** : Voir README.md dans le repository
- **🐛 Issues** : https://github.com/jeylton/libroflow/issues

---

## 🎯 **Conclusion**

**LibroFlow** représente une solution **professionnelle, moderne et complète** pour la gestion de bibliothèque. 

### **Points Forts**
- 🏗️ **Architecture Full-Stack** moderne et scalabe
- 🛡️ **Sécurité robuste** à tous les niveaux
- 🚀 **Performance optimisée** pour une expérience utilisateur fluide
- 📚 **Fonctionnalités complètes** couvrant tous les besoins
- 🐳 **Déploiement industrialisé** avec Docker
- 📖 **Documentation exhaustive** pour maintenance facile

**Un projet prêt pour la production et démontrant une maîtrise technique complète !** 🚀

---

**Pour toute question technique ou problème d'installation, consulter la documentation complète sur GitHub.**
