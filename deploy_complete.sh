#!/bin/bash
# Script de déploiement complet - Build, Push, Deploy

set -e

echo "╔════════════════════════════════════════════════════════╗"
echo "║    DÉPLOIEMENT COMPLET DES 3 CONTENEURS SUR LE CLOUD  ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""

cd /Users/abdallahsofi/Project-Docker

# Étape 1: Build des 3 images
echo "📦 ÉTAPE 1/3: Construction des images Docker"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo "🗄️  Building database image..."
docker build -t abdallahsofi/tp-devops-simple-api-database:latest ./initdb
echo "✅ Database image built"
echo ""

echo "🔧 Building backend image..."
docker build -t abdallahsofi/tp-devops-simple-api-backend:latest ./backend
echo "✅ Backend image built"
echo ""

echo "🌐 Building httpd image..."
docker build -t abdallahsofi/tp-devops-simple-api-httpd:latest ./httpd
echo "✅ HTTPD image built"
echo ""

# Étape 2: Push vers Docker Hub
echo "📤 ÉTAPE 2/3: Push des images vers Docker Hub"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo "📤 Pushing database image..."
docker push abdallahsofi/tp-devops-simple-api-database:latest
echo "✅ Database image pushed"
echo ""

echo "📤 Pushing backend image..."
docker push abdallahsofi/tp-devops-simple-api-backend:latest
echo "✅ Backend image pushed"
echo ""

echo "📤 Pushing httpd image..."
docker push abdallahsofi/tp-devops-simple-api-httpd:latest
echo "✅ HTTPD image pushed"
echo ""

# Étape 3: Déploiement Ansible
echo "🚀 ÉTAPE 3/3: Déploiement sur le cloud avec Ansible"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

cd /Users/abdallahsofi/Project-Docker/ansible
ansible-playbook -i inventories/setup.yml playbook.yml

echo ""
echo "╔════════════════════════════════════════════════════════╗"
echo "║              ✅ DÉPLOIEMENT TERMINÉ !                  ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""

# Étape 4: Vérification
echo "🔍 Vérification du déploiement..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

ssh -i /Users/abdallahsofi/.ssh/abdellah_takima admin@abdellah.sofi1.takima.cloud << 'ENDSSH'
echo ""
echo "📦 Conteneurs actifs:"
docker ps --format "  - {{.Names}}: {{.Status}}"
echo ""
echo "🔍 Test rapide de l'API:"
echo "  Health: $(curl -s http://localhost:8080/actuator/health | head -50)"
echo ""
echo "✅ Les 3 conteneurs sont déployés sur abdellah.sofi1.takima.cloud"
ENDSSH

echo ""
echo "🎉 Déploiement réussi !"

