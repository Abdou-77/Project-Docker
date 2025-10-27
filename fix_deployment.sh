#!/bin/bash
# Script de réparation du déploiement

set -e

echo "╔════════════════════════════════════════════════════════╗"
echo "║        RÉPARATION DU DÉPLOIEMENT SUR LE CLOUD         ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""

SSH_KEY="/Users/abdallahsofi/.ssh/abdellah_takima"
USER="admin"
HOST="abdellah.sofi1.takima.cloud"

echo "🔧 Étape 1: Arrêt et suppression des conteneurs existants"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
ssh -i "$SSH_KEY" "$USER@$HOST" << 'REMOTE_SSH'
# Arrêter tous les conteneurs
docker stop httpd backend database 2>/dev/null || true

# Supprimer les conteneurs
docker rm httpd backend database 2>/dev/null || true

# Supprimer le volume de la database pour repartir de zéro
docker volume rm db-data 2>/dev/null || true

echo "✅ Conteneurs et volumes nettoyés"
REMOTE_SSH

echo ""
echo "🚀 Étape 2: Redéploiement avec Ansible"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
cd /Users/abdallahsofi/Project-Docker/ansible
ansible-playbook -i inventories/setup.yml playbook.yml

echo ""
echo "⏳ Étape 3: Attente du démarrage des services (30 secondes)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
sleep 30

echo ""
echo "🔍 Étape 4: Vérification du déploiement"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
ssh -i "$SSH_KEY" "$USER@$HOST" << 'REMOTE_SSH'
echo ""
echo "📦 Conteneurs actifs:"
docker ps --format "  ✅ {{.Names}}: {{.Status}}"
echo ""
echo "🔍 Test Health Check:"
curl -s http://localhost:8080/actuator/health 2>&1
echo ""
echo ""
echo "📚 Test Departments:"
curl -s http://localhost:8080/departments 2>&1 | head -100
echo ""
REMOTE_SSH

echo ""
echo "🌐 Étape 5: Test via DNS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Test de http://abdellah.sofi1.takima.cloud/"
HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout 10 http://abdellah.sofi1.takima.cloud/)
echo "HTTP Status: $HTTP_STATUS"

if [ "$HTTP_STATUS" = "200" ]; then
    echo "✅ Application accessible via le DNS !"
else
    echo "⚠️  Status HTTP: $HTTP_STATUS"
fi

echo ""
echo "╔════════════════════════════════════════════════════════╗"
echo "║                ✅ RÉPARATION TERMINÉE !                ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""
echo "📍 Votre application est accessible via:"
echo "  🌐 http://abdellah.sofi1.takima.cloud/"
echo "  🔧 http://abdellah.sofi1.takima.cloud:8080/actuator/health"
echo "  📚 http://abdellah.sofi1.takima.cloud:8080/departments"
echo "  👨‍🎓 http://abdellah.sofi1.takima.cloud:8080/students"

