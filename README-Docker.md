# 🐳 Docker LibroFlow - Production Ready

## ✅ **Application Dockerisée et Fonctionnelle !**

### 🌐 **Accès à l'Application**
- **Frontend Flutter**: http://localhost:3000
- **Backend API**: http://localhost:5001
- **Base de données**: localhost:5432

### 🚀 **Démarrage Rapide**

#### **Option 1: Script Automatique (Windows)**
```bash
# Double-cliquer sur:
start-docker.bat
```

#### **Option 2: Manuel**
```bash
# 1. Construire le frontend Flutter
flutter build web --release

# 2. Construire et démarrer Docker
docker-compose build
docker-compose up -d

# 3. Vérifier l'état
docker-compose ps
```

### 📊 **État Actuel des Services**
```
✅ Frontend (nginx)     : localhost:3000 → Container:80
✅ Backend (Node.js)    : localhost:5001 → Container:5000  
✅ Database (PostgreSQL): localhost:5432 → Container:5432
✅ Network Docker       : library-network (bridge)
✅ Volumes persistants  : postgres_data
```

### 🔧 **Configuration des Ports**
| Service | Port Hôte | Port Container | Description |
|---------|-----------|----------------|-------------|
| Frontend | 3000 | 80 | nginx + Flutter Web |
| Backend | 5001 | 5000 | API Node.js |
| PostgreSQL | 5432 | 5432 | Base de données |

### 🌐 **Communication Network**
- **Frontend → Backend**: `http://backend:5000` (interne Docker)
- **Frontend → Backend**: `http://localhost:5001` (externe)
- **Backend → PostgreSQL**: `postgres:5432` (interne Docker)

### 📋 **Commandes Essentielles**

#### **Démarrage/Arrêt**
```bash
# Démarrer tous les services
docker-compose up -d

# Arrêter tous les services
docker-compose down

# Redémarrer un service spécifique
docker-compose restart frontend
docker-compose restart backend
```

#### **Monitoring**
```bash
# Voir l'état des conteneurs
docker-compose ps

# Voir les logs en temps réel
docker-compose logs -f
docker-compose logs -f backend
docker-compose logs -f frontend
```

#### **Maintenance**
```bash
# Reconstruire après modifications
docker-compose build --no-cache
docker-compose up -d

# Nettoyer les ressources
docker system prune -f
```

### 🧪 **Tests de Connectivité**

#### **Frontend**
```bash
curl http://localhost:3000
# Expected: 200 OK + HTML content
```

#### **Backend API**
```bash
curl http://localhost:5001/api/books
# Expected: 200 OK + JSON books array

curl http://localhost:5001/api/auth/login -X POST -H "Content-Type: application/json" -d '{"email":"test@test.com","password":"test"}'
# Expected: 401/400 (auth validation)
```

#### **Base de Données**
```bash
# Test de connexion PostgreSQL
netstat -an | findstr :5432
# Expected: LISTENING on 5432
```

### 📁 **Structure des Fichiers Docker**
```
libroflow-master/
├── docker-compose.yml          # Configuration principale
├── Dockerfile                   # Build Flutter complet
├── Dockerfile.simple           # Build rapide (utilisé)
├── nginx.conf                   # Configuration nginx
├── .dockerignore               # Exclusions Docker
├── start-docker.bat            # Script démarrage Windows
├── start-docker.sh             # Script démarrage Linux/Mac
├── test-docker.bat             # Script test Windows
├── test-docker.sh              # Script test Linux/Mac
└── build/web/                  # Output Flutter build
```

### 🔍 **Débogage**

#### **Problèmes Communs**
1. **Port 5000 occupé**: Solution → Utiliser port 5001 (déjà configuré)
2. **Build Flutter échoue**: `flutter clean` puis `flutter build web --release`
3. **Conteneur ne démarre pas**: `docker-compose logs [service]`
4. **API inaccessible**: Vérifier `docker-compose ps` et les ports

#### **Logs Utiles**
```bash
# Tous les services
docker-compose logs --tail=50

# Service spécifique
docker-compose logs --tail=20 backend
docker-compose logs --tail=20 frontend
docker-compose logs --tail=20 postgres
```

### � **Déploiement Production**

Pour un déploiement en production:
1. **Sécuriser les variables d'environnement**
2. **Configurer SSL/TLS avec Let's Encrypt**
3. **Mettre en place un reverse proxy externe**
4. **Configurer les backups automatiques**
5. **Monitorer avec Prometheus/Grafana**

### 📈 **Performance**

#### **Optimisations en place**
- ✅ **Flutter Web**: CanvasKit renderer
- ✅ **Nginx**: Compression et cache statique
- ✅ **Docker**: Multi-stage build optimisé
- ✅ **Network**: Bridge Docker isolé

#### **Ressources Recommandées**
- **RAM**: 2GB minimum
- **CPU**: 2 cores minimum  
- **Storage**: 10GB minimum

---

## 🎉 **Application Prête !**

L'application LibroFlow est maintenant:
- ✅ **Dockerisée** avec tous les services
- ✅ **Configurée** pour la communication inter-services
- ✅ **Accessible** via les ports définis
- ✅ **Testée** et fonctionnelle
- ✅ **Production Ready** 

**Accès immédiat**: http://localhost:3000

🚀 **Bon usage de LibroFlow Docker !**
