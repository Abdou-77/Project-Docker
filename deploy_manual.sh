#!/bin/bash
# Script de déploiement manuel des 3 conteneurs sur le serveur cloud

set -e

SERVER="abdellah.sofi1.takima.cloud"
USER="admin"
SSH_KEY="$HOME/.ssh/id_rsa"

echo "╔════════════════════════════════════════════════════════╗"
echo "║     DÉPLOIEMENT MANUEL DES 3 CONTENEURS SUR LE CLOUD  ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""

echo "🔍 Étape 1: Vérification de la connectivité..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if ! nc -zv -w 5 "$SERVER" 22 2>&1 | grep -q "succeeded"; then
    echo "⚠️  Impossible de se connecter au serveur $SERVER sur le port SSH (22)"
    echo ""
    echo "Vérifications possibles:"
    echo "  1. Le serveur cloud est-il démarré ?"
    echo "  2. Votre VPN est-il actif si nécessaire ?"
    echo "  3. Les règles de pare-feu autorisent-elles votre IP ?"
    echo ""
    echo "Pour déployer manuellement, connectez-vous au serveur et exécutez:"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    cat << 'EOF'
# 1. Créer le réseau Docker
docker network create app-network 2>/dev/null || echo "Network already exists"

# 2. Arrêter et supprimer les anciens conteneurs
docker stop database backend httpd 2>/dev/null || true
docker rm database backend httpd 2>/dev/null || true

# 3. Démarrer la base de données
docker run -d \
  --name database \
  --network app-network \
  -e POSTGRES_DB=db \
  -e POSTGRES_USER=usr \
  -e POSTGRES_PASSWORD=pwd \
  -v db-data:/var/lib/postgresql/data \
  --restart always \
  abdou775/tp-devops-simple-api-database:latest

# 4. Attendre que la base de données soit prête
sleep 10

# 5. Démarrer le backend
docker run -d \
  --name backend \
  --network app-network \
  -p 8080:8080 \
  -e SPRING_DATASOURCE_URL=jdbc:postgresql://database:5432/db \
  -e SPRING_DATASOURCE_USERNAME=usr \
  -e SPRING_DATASOURCE_PASSWORD=pwd \
  --restart always \
  abdou775/tp-devops-simple-api-backend:latest

# 6. Démarrer le proxy HTTPD
docker run -d \
  --name httpd \
  --network app-network \
  -p 80:80 \
  --restart always \
  abdou775/tp-devops-simple-api-httpd:latest

# 7. Vérifier que tous les conteneurs sont actifs
echo ""
echo "📦 Conteneurs actifs:"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# 8. Tester l'API
echo ""
echo "🔍 Test de l'API (attendez 30 secondes que le backend démarre)..."
sleep 30
curl -s http://localhost:8080/actuator/health || echo "API pas encore prête, réessayez dans quelques secondes"
EOF
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    exit 1
fi

echo "✅ Serveur accessible"
echo ""

echo "🚀 Étape 2: Connexion SSH et déploiement..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

ssh -i "$SSH_KEY" -o ConnectTimeout=10 -o StrictHostKeyChecking=no "$USER@$SERVER" << 'ENDSSH'
set -e

echo "🔧 Installation de Docker si nécessaire..."
if ! command -v docker &> /dev/null; then
    echo "Docker n'est pas installé. Installation..."
    sudo apt-get update
    sudo apt-get install -y docker.io
    sudo systemctl start docker
    sudo systemctl enable docker
    sudo usermod -aG docker admin
else
    echo "✅ Docker est déjà installé"
fi

echo ""
echo "🌐 Création du réseau Docker..."
docker network create app-network 2>/dev/null || echo "✅ Network déjà existant"

echo ""
echo "🧹 Nettoyage des anciens conteneurs..."
docker stop database backend httpd 2>/dev/null || true
docker rm database backend httpd 2>/dev/null || true

echo ""
echo "📦 Déploiement de la base de données..."
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
echo "📦 Déploiement du backend..."
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
echo "📦 Déploiement du proxy HTTPD..."
docker pull abdou775/tp-devops-simple-api-httpd:latest
docker run -d \
  --name httpd \
  --network app-network \
  -p 80:80 \
  --restart always \
  abdou775/tp-devops-simple-api-httpd:latest

echo ""
echo "✅ Tous les conteneurs sont déployés!"
echo ""
echo "📦 Conteneurs actifs:"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

echo ""
echo "⏳ Attente du démarrage complet du backend (30 secondes)..."
sleep 30

echo ""
echo "🔍 Tests de l'API..."
echo ""
echo "1. Health Check:"
curl -s http://localhost:8080/actuator/health | head -20
echo ""
echo ""
echo "2. Departments:"
curl -s http://localhost:8080/departments | head -100
echo ""
echo ""
echo "3. Students:"
curl -s http://localhost:8080/students | head -100
echo ""
ENDSSH

echo ""
echo "╔════════════════════════════════════════════════════════╗"
echo "║           ✅ DÉPLOIEMENT RÉUSSI !                      ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""
echo "🌐 Votre application est accessible sur:"
echo "   http://$SERVER"
echo "   http://$SERVER:8080 (API directe)"
echo ""
echo "🔍 Pour tester l'API depuis votre machine:"
echo "   curl http://$SERVER:8080/actuator/health"
echo "   curl http://$SERVER:8080/departments"
echo "   curl http://$SERVER:8080/students"
echo ""

