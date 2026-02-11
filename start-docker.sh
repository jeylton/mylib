#!/bin/bash

echo "🚀 Démarrage de LibroFlow avec Docker..."

# Arrêter les conteneurs existants
echo "🛑 Arrêt des conteneurs existants..."
docker-compose down

# Nettoyer les images si nécessaire
echo "🧹 Nettoyage..."
docker system prune -f

# Construire et démarrer les services
echo "🔨 Construction des images..."
docker-compose build

echo "🚀 Démarrage des services..."
docker-compose up -d

# Attendre que les services soient prêts
echo "⏳ Attente du démarrage des services..."
sleep 10

# Vérifier l'état des services
echo "📊 État des services:"
docker-compose ps

echo ""
echo "✅ LibroFlow est démarré !"
echo ""
echo "🌐 Accès à l'application:"
echo "   Frontend: http://localhost:3000"
echo "   Backend API: http://localhost:5000"
echo "   Base de données: localhost:5432"
echo ""
echo "📋 Logs en temps réel:"
echo "   docker-compose logs -f"
echo ""
echo "🛑 Arrêter l'application:"
echo "   docker-compose down"
