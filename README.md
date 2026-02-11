# 📚 LibroFlow - Library Borrowing System

<div align="center">

![LibroFlow Logo](https://img.shields.io/badge/LibroFlow-📚-blue?style=for-the-badge)
![Flutter](https://img.shields.io/badge/Flutter-3.6.1-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Node.js](https://img.shields.io/badge/Node.js-18+-339933?style=for-the-badge&logo=node.js&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-4169E1?style=for-the-badge&logo=postgresql&logoColor=white)

*Application web moderne de gestion de bibliothèque*

[📖 Documentation](#documentation) • [🚀 Installation](#installation) • [🌟 Fonctionnalités](#fonctionnalités) • [🛡️ Sécurité](#sécurité)

</div>

---

## 🎯 **Présentation**

**LibroFlow** est une solution moderne et professionnelle pour la gestion de bibliothèque, développée avec **Flutter** (frontend) et **Node.js** (backend), permettant une gestion complète des emprunts de livres via une interface intuitive et sécurisée.

### ✨ **Points Forts**
- 🏗️ **Architecture Full-Stack** moderne et scalabe
- 🛡️ **Sécurité robuste** à tous les niveaux
- 🚀 **Performance optimisée** pour une expérience fluide
- 🐳 **Déploiement Dockerisé** simple et reproductible
- 📱 **Responsive Design** adapté à tous les écrans

---

## 🚀 **Installation Rapide**

### **Prérequis**
- ✅ **Docker Desktop** installé et lancé
- ✅ **Navigateur moderne** (Chrome/Firefox/Edge)
- ✅ **Git** pour cloner le repository

### **Étape 1 - Clonage**
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
# Vérifier les conteneurs
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

## 🏗️ **Architecture Technique**

```
🌐 Navigateur Web
    ↓
🐳 Nginx (Port 80)
    ↓
📱 Flutter Web + ⚙️ Node.js API
    ↓
🗄️ Supabase PostgreSQL
```

### **Technologies**
- **Frontend** : Flutter 3.6.1 + Material Design 3
- **Backend** : Node.js + Express.js + Sequelize ORM
- **Database** : PostgreSQL via Supabase (cloud)
- **Infrastructure** : Docker + Nginx (reverse proxy)
- **Authentification** : JWT tokens sécurisés

---

## 🌟 **Fonctionnalités**

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

## 🛡️ **Sécurité**

- **🔐 Authentification JWT** : Tokens sécurisés avec expiration 7 jours
- **🛡️ Protection API** : CORS configuré + Rate Limiting
- **🔍 Validation Input** : Protection contre injections SQL/XSS
- **🗄️ Base de données** : Connexions SSL via Supabase
- **📡 Headers Security** : X-Frame-Options, CSP, XSS Protection

---

## 📊 **Modèles de Données**

### **📚 Livre**
```json
{
  "id": "uuid",
  "title": "Titre du livre",
  "author": "Auteur",
  "isbn": "ISBN",
  "genre": "Genre",
  "quantity": 5,
  "borrowedCount": 2,
  "status": "available"
}
```

### **👤 Utilisateur**
```json
{
  "id": "uuid",
  "name": "Nom complet",
  "email": "email@example.com",
  "role": "student|admin",
  "balance": 2500.00,
  "emailVerified": true
}
```

### **📋 Emprunt**
```json
{
  "id": "uuid",
  "userId": "uuid",
  "bookId": "uuid",
  "borrowDate": "2026-02-10",
  "dueDate": "2026-02-24",
  "returnDate": null,
  "status": "active|returned|overdue",
  "isRead": false
}
```

---

## 📁 **Structure du Projet**

```
libroflow/
├── 📖 DOCUMENTATION_PROJET.md     # Documentation technique complète
├── 📋 README.md                   # Ce fichier
├── 🐳 docker-compose.yml           # Configuration conteneurs
├── 🎨 lib/                       # Code Flutter frontend
│   ├── screens/                   # Écrans application
│   ├── widgets/                   # Composants réutilisables
│   ├── services/                  # Services API
│   ├── providers/                  # Gestion état
│   └── models/                    # Modèles données
├── ⚙️ backend/                    # Code Node.js backend
│   ├── controllers/               # Logique métier
│   ├── models/                    # Modèles Sequelize
│   ├── routes/                    # Routes API
│   └── services/                  # Services externes
└── 📄 nginx.conf                  # Configuration reverse proxy
```

---

## 📋 **API Endpoints**

```
POST   /api/auth/login          # Connexion utilisateur
POST   /api/auth/register       # Inscription
GET    /api/books              # Catalogue livres
POST   /api/borrowings/borrow   # Emprunter livre
POST   /api/borrowings/return   # Retourner livre
GET    /api/dashboard/student   # Dashboard étudiant
GET    /api/dashboard/admin     # Dashboard administrateur
```

---

## 🧪 **Tests**

### **Tests Unitaires**
```bash
# Tests Flutter
flutter test

# Tests Backend
cd backend && npm test
```

### **Tests d'Intégration**
```bash
# Tests API
curl -X POST http://localhost/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password"}'
```

---

## 🚀 **Déploiement**

### **Production**
```bash
# Configuration production
docker-compose -f docker-compose.prod.yml up -d
```

### **Monitoring**
```bash
# Logs des conteneurs
docker-compose logs -f

# Statistiques
docker stats
```

---

## 📈 **Performance**

- **⚡ Chargement optimisé** : Lazy loading et cache intelligent
- **📱 Responsive Design** : Adaptation tous écrans
- **🔄 Synchronisation temps réel** : Mise à jour automatique
- **📊 Monitoring** : Logs et métriques intégrées

---

## 🛠️ **Dépannage**

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

## 🤝 **Contributions**

Les contributions sont les bienvenues ! Veuillez suivre ces étapes :

1. **Fork** le repository
2. **Créer** une branche (`git checkout -b feature/amazing-feature`)
3. **Commit** vos changements (`git commit -m 'Add amazing feature'`)
4. **Push** vers la branche (`git push origin feature/amazing-feature`)
5. **Ouvrir** une Pull Request

---

## 📄 **Licence**

Ce projet est sous licence **MIT** - voir le fichier [LICENSE](LICENSE) pour plus de détails.

---

## 📞 **Contact**

- **👤 Auteur** : Jeylton
- **📧 Email** : [Votre Email]
- **🌐 Repository** : https://github.com/jeylton/libroflow
- **🐛 Issues** : https://github.com/jeylton/libroflow/issues

---

## 🏆 **Remerciements**

Merci à tous les contributeurs et à la communauté open source pour les outils et technologies utilisés dans ce projet.

---

<div align="center">

**⭐ Si ce projet vous plaît, n'hésitez pas à laisser une étoile ! ⭐**

Made with ❤️ by Jeylton

</div>
#   l i b r a r y  
 