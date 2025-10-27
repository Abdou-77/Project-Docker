#!/bin/bash
# Script de déploiement complet des 3 couches

set -e  # Arrête en cas d'erreur

echo "🚀 DÉPLOIEMENT COMPLET DES 3 COUCHES"
echo "====================================="
echo ""

# Étape 1: Construire les images Docker
echo "📦 ÉTAPE 1: Construction des images Docker"
echo "-------------------------------------------"
cd /Users/abdallahsofi/Project-Docker

echo "Building backend..."
docker build -t abdallahsofi/tp-devops-simple-api-backend:latest ./backend

echo "Building database..."
docker build -t abdallahsofi/tp-devops-simple-api-database:latest ./initdb

echo "Building httpd..."
docker build -t abdallahsofi/tp-devops-simple-api-httpd:latest ./httpd

echo "✅ Images construites"
echo ""

# Étape 2: Pousser les images vers Docker Hub
echo "📤 ÉTAPE 2: Push vers Docker Hub"
echo "-------------------------------------------"
docker push abdallahsofi/tp-devops-simple-api-backend:latest
docker push abdallahsofi/tp-devops-simple-api-database:latest
docker push abdallahsofi/tp-devops-simple-api-httpd:latest

echo "✅ Images poussées sur Docker Hub"
echo ""

# Étape 3: Déployer avec Ansible
echo "🎯 ÉTAPE 3: Déploiement Ansible"
echo "-------------------------------------------"
cd /Users/abdallahsofi/Project-Docker/ansible
ansible-playbook -i inventories/setup.yml playbook.yml

echo ""
echo "✅ Déploiement terminé"
echo ""

# Étape 4: Vérifier le déploiement
echo "🔍 ÉTAPE 4: Vérification"
echo "-------------------------------------------"
ssh -i /Users/abdallahsofi/.ssh/abdellah_takima admin@abdellah.sofi1.takima.cloud << 'ENDSSH'
echo "Conteneurs en cours d'exécution:"
docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}"
echo ""
echo "Test de l'API backend:"
curl -s http://localhost:8080/actuator/health || echo "❌ Backend non accessible"
echo ""
echo "Test du proxy HTTPD:"
curl -s -o /dev/null -w "HTTP Status: %{http_code}\n" http://localhost/ || echo "❌ HTTPD non accessible"
ENDSSH

echo ""
echo "====================================="
echo "🎉 DÉPLOIEMENT DES 3 COUCHES TERMINÉ"
echo "====================================="

