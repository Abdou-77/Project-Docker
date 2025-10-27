#!/bin/bash
# Script de test et déploiement simplifié

set -e

SERVER="abdellah.sofi1.takima.cloud"
USER="admin"

echo "╔════════════════════════════════════════════════════════╗"
echo "║        TEST DE CONNEXION ET DÉPLOIEMENT               ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""

# Test 1: Vérifier la résolution DNS
echo "🔍 Test 1: Résolution DNS..."
if host $SERVER > /dev/null 2>&1; then
    IP=$(host $SERVER | grep "has address" | awk '{print $4}')
    echo "✅ DNS OK: $SERVER -> $IP"
else
    echo "❌ Échec de la résolution DNS"
    exit 1
fi
echo ""

# Test 2: Tester avec la clé abdellah_takima
echo "🔍 Test 2: Connexion SSH avec clé abdellah_takima..."
if timeout 5 ssh -o BatchMode=yes -o ConnectTimeout=5 -i ~/.ssh/abdellah_takima $USER@$SERVER "echo 'SSH OK'" 2>/dev/null; then
    echo "✅ Connexion SSH réussie avec abdellah_takima"
    SSH_KEY="~/.ssh/abdellah_takima"
    SSH_SUCCESS=true
else
    echo "⚠️  Échec avec abdellah_takima"
    SSH_SUCCESS=false
fi
echo ""

# Test 3: Tester avec la clé id_rsa si le premier test a échoué
if [ "$SSH_SUCCESS" = false ]; then
    echo "🔍 Test 3: Connexion SSH avec clé id_rsa..."
    if timeout 5 ssh -o BatchMode=yes -o ConnectTimeout=5 -i ~/.ssh/id_rsa $USER@$SERVER "echo 'SSH OK'" 2>/dev/null; then
        echo "✅ Connexion SSH réussie avec id_rsa"
        SSH_KEY="~/.ssh/id_rsa"
        SSH_SUCCESS=true
    else
        echo "⚠️  Échec avec id_rsa"
    fi
    echo ""
fi

# Test 4: Tester sans spécifier de clé (utilisation de l'agent SSH)
if [ "$SSH_SUCCESS" = false ]; then
    echo "🔍 Test 4: Connexion SSH avec clés par défaut..."
    if timeout 5 ssh -o BatchMode=yes -o ConnectTimeout=5 $USER@$SERVER "echo 'SSH OK'" 2>/dev/null; then
        echo "✅ Connexion SSH réussie avec les clés par défaut"
        SSH_KEY=""
        SSH_SUCCESS=true
    else
        echo "❌ Échec avec les clés par défaut"
    fi
    echo ""
fi

# Si aucune connexion SSH ne fonctionne
if [ "$SSH_SUCCESS" = false ]; then
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "❌ IMPOSSIBLE DE SE CONNECTER AU SERVEUR"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "Le serveur $SERVER est résolvable mais la connexion SSH échoue."
    echo ""
    echo "Solutions possibles:"
    echo "1. Vérifiez que le serveur est démarré dans votre console cloud"
    echo "2. Vérifiez que votre clé SSH publique est autorisée sur le serveur"
    echo "3. Connectez-vous directement via la console cloud et exécutez:"
    echo ""
    echo "   # Déploiement manuel des 3 conteneurs"
    echo "   docker network create app-network 2>/dev/null || true"
    echo "   docker stop database backend httpd 2>/dev/null || true"
    echo "   docker rm database backend httpd 2>/dev/null || true"
    echo ""
    echo "   docker run -d --name database --network app-network \\"
    echo "     -e POSTGRES_DB=db -e POSTGRES_USER=usr -e POSTGRES_PASSWORD=pwd \\"
    echo "     -v db-data:/var/lib/postgresql/data --restart always \\"
    echo "     abdou775/tp-devops-simple-api-database:latest"
    echo ""
    echo "   sleep 10"
    echo ""
    echo "   docker run -d --name backend --network app-network -p 8080:8080 \\"
    echo "     -e SPRING_DATASOURCE_URL=jdbc:postgresql://database:5432/db \\"
    echo "     -e SPRING_DATASOURCE_USERNAME=usr -e SPRING_DATASOURCE_PASSWORD=pwd \\"
    echo "     --restart always abdou775/tp-devops-simple-api-backend:latest"
    echo ""
    echo "   docker run -d --name httpd --network app-network -p 80:80 \\"
    echo "     --restart always abdou775/tp-devops-simple-api-httpd:latest"
    echo ""
    exit 1
fi

# Déploiement si la connexion SSH fonctionne
echo "╔════════════════════════════════════════════════════════╗"
echo "║            🚀 DÉPLOIEMENT EN COURS...                  ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""

SSH_CMD="ssh -o BatchMode=yes -o ConnectTimeout=10 -o StrictHostKeyChecking=no"
if [ -n "$SSH_KEY" ]; then
    SSH_CMD="$SSH_CMD -i $SSH_KEY"
fi

$SSH_CMD $USER@$SERVER bash << 'ENDSSH'
set -e

echo "🌐 Création du réseau Docker..."
docker network create app-network 2>/dev/null || echo "✅ Réseau déjà existant"

echo ""
echo "🧹 Nettoyage des anciens conteneurs..."
docker stop database backend httpd 2>/dev/null || true
docker rm database backend httpd 2>/dev/null || true

echo ""
echo "📦 Démarrage de la base de données..."
docker pull abdou775/tp-devops-simple-api-database:latest
docker run -d \
  --name database \
  --network app-network \
  -e POSTGRES_DB=db \
  -e POSTGRES_USER=usr \
  -e POSTGRES_PASSWORD=pwd \
  -v db-data:/var/lib/postgresql/data \
  --restart always \
  abdou775/tp-devops-simple-api-database:latest

echo "⏳ Attente du démarrage de la base de données (10 secondes)..."
sleep 10

echo ""
echo "📦 Démarrage du backend..."
docker pull abdou775/tp-devops-simple-api-backend:latest
docker run -d \
  --name backend \
  --network app-network \
  -p 8080:8080 \
  -e SPRING_DATASOURCE_URL=jdbc:postgresql://database:5432/db \
  -e SPRING_DATASOURCE_USERNAME=usr \
  -e SPRING_DATASOURCE_PASSWORD=pwd \
  --restart always \
  abdou775/tp-devops-simple-api-backend:latest

echo ""
echo "📦 Démarrage du proxy HTTPD..."
docker pull abdou775/tp-devops-simple-api-httpd:latest
docker run -d \
  --name httpd \
  --network app-network \
  -p 80:80 \
  --restart always \
  abdou775/tp-devops-simple-api-httpd:latest

echo ""
echo "✅ DÉPLOIEMENT TERMINÉ !"
echo ""
echo "📦 Conteneurs actifs:"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

echo ""
echo "⏳ Attente du démarrage du backend (30 secondes)..."
sleep 30

echo ""
echo "🔍 Tests de l'API:"
echo ""
echo "=== Health Check ==="
curl -s http://localhost:8080/actuator/health | head -20 || echo "API pas encore prête"

echo ""
echo ""
echo "=== Departments ==="
curl -s http://localhost:8080/departments | head -100 || echo "Departments non accessible"

echo ""
echo ""
echo "=== Students ==="
curl -s http://localhost:8080/students | head -100 || echo "Students non accessible"
echo ""
ENDSSH

echo ""
echo "╔════════════════════════════════════════════════════════╗"
echo "║              ✅ DÉPLOIEMENT RÉUSSI !                   ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""
echo "🌐 Testez l'API depuis votre machine:"
echo ""
echo "   curl http://$SERVER:8080/actuator/health"
echo "   curl http://$SERVER:8080/departments"
echo "   curl http://$SERVER:8080/students"
echo "   curl http://$SERVER/"
echo ""

