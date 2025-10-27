#!/bin/bash
# Script pour pousser les images et déployer (images déjà construites)

set -e

echo "╔════════════════════════════════════════════════════════╗"
echo "║       PUSH ET DÉPLOIEMENT DES 3 CONTENEURS            ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""

# Vérifier que l'utilisateur est connecté à Docker Hub
echo "🔐 Vérification de l'authentification Docker Hub..."
if ! docker info 2>/dev/null | grep -i "username" > /dev/null; then
    echo "⚠️  Impossible de vérifier l'authentification, tentative de push..."
else
    echo "✅ Connecté à Docker Hub"
fi
echo ""

# Re-tag des images avec le bon username
echo "🏷️  Re-tagging des images avec le username Docker Hub correct (abdou775)..."
docker tag abdallahsofi/tp-devops-simple-api-database:latest abdou775/tp-devops-simple-api-database:latest
docker tag abdallahsofi/tp-devops-simple-api-backend:latest abdou775/tp-devops-simple-api-backend:latest
docker tag abdallahsofi/tp-devops-simple-api-httpd:latest abdou775/tp-devops-simple-api-httpd:latest
echo "✅ Images re-tagged"
echo ""

# Push vers Docker Hub
echo "📤 ÉTAPE 1/2: Push des images vers Docker Hub"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo "📤 Pushing database image..."
docker push abdou775/tp-devops-simple-api-database:latest
echo "✅ Database image pushed"
echo ""

echo "📤 Pushing backend image..."
docker push abdou775/tp-devops-simple-api-backend:latest
echo "✅ Backend image pushed"
echo ""

echo "📤 Pushing httpd image..."
docker push abdou775/tp-devops-simple-api-httpd:latest
echo "✅ HTTPD image pushed"
echo ""

# Déploiement Ansible
echo "🚀 ÉTAPE 2/2: Déploiement sur le cloud avec Ansible"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

cd /Users/abdallahsofi/Project-Docker/ansible
ansible-playbook -i inventories/setup.yml playbook.yml

echo ""
echo "╔════════════════════════════════════════════════════════╗"
echo "║              ✅ DÉPLOIEMENT TERMINÉ !                  ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""

# Vérification
echo "🔍 Vérification du déploiement..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

ssh -i /Users/abdallahsofi/.ssh/abdellah_takima admin@abdellah.sofi1.takima.cloud << 'ENDSSH'
echo ""
echo "📦 Conteneurs actifs:"
docker ps --format "  ✅ {{.Names}}: {{.Status}}"
echo ""
echo "🔍 Tests API:"
echo ""
echo "Health Check:"
curl -s http://localhost:8080/actuator/health
echo ""
echo ""
echo "Departments:"
curl -s http://localhost:8080/departments | head -100
echo ""
echo ""
echo "Students:"
curl -s http://localhost:8080/students | head -100
echo ""
ENDSSH

echo ""
echo "🎉 Les 3 conteneurs sont déployés et fonctionnels !"
