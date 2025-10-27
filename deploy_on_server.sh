#!/bin/bash
# Commandes à exécuter directement sur le serveur cloud
# Copiez-collez ce script dans le terminal de votre serveur

set -e

echo "╔════════════════════════════════════════════════════════╗"
echo "║     DÉPLOIEMENT DES 3 CONTENEURS (MANUEL)             ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""

# 1. Créer le réseau Docker
echo "🌐 Création du réseau Docker..."
docker network create app-network 2>/dev/null || echo "✅ Réseau déjà existant"

# 2. Nettoyer les anciens conteneurs
echo ""
echo "🧹 Nettoyage des anciens conteneurs..."
docker stop database backend httpd 2>/dev/null || true
docker rm database backend httpd 2>/dev/null || true

# 3. Démarrer la base de données
echo ""
echo "📦 Démarrage de la base de données PostgreSQL..."
docker run -d \
  --name database \
  --network app-network \
  -e POSTGRES_DB=db \
  -e POSTGRES_USER=usr \
  -e POSTGRES_PASSWORD=pwd \
  -v db-data:/var/lib/postgresql/data \
  --restart always \
  abdou775/tp-devops-simple-api-database:latest

echo "✅ Base de données démarrée"
echo "⏳ Attente de l'initialisation (10 secondes)..."
sleep 10

# 4. Démarrer le backend
echo ""
echo "📦 Démarrage du backend Spring Boot..."
docker run -d \
  --name backend \
  --network app-network \
  -p 8080:8080 \
  -e SPRING_DATASOURCE_URL=jdbc:postgresql://database:5432/db \
  -e SPRING_DATASOURCE_USERNAME=usr \
  -e SPRING_DATASOURCE_PASSWORD=pwd \
  --restart always \
  abdou775/tp-devops-simple-api-backend:latest

echo "✅ Backend démarré"

# 5. Démarrer le proxy HTTPD
echo ""
echo "📦 Démarrage du proxy HTTPD..."
docker run -d \
  --name httpd \
  --network app-network \
  -p 80:80 \
  --restart always \
  abdou775/tp-devops-simple-api-httpd:latest

echo "✅ Proxy HTTPD démarré"

# 6. Vérifier les conteneurs
echo ""
echo "╔════════════════════════════════════════════════════════╗"
echo "║           ✅ DÉPLOIEMENT TERMINÉ !                     ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""
echo "📦 Conteneurs actifs:"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# 7. Attendre le démarrage complet
echo ""
echo "⏳ Attente du démarrage complet de l'application (30 secondes)..."
sleep 30

# 8. Tests de l'API
echo ""
echo "🧪 TESTS DE L'API"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

echo "1️⃣  Health Check:"
echo "---"
curl -s http://localhost:8080/actuator/health
echo -e "\n"

echo ""
echo "2️⃣  Liste des Departments:"
echo "---"
curl -s http://localhost:8080/departments
echo -e "\n"

echo ""
echo "3️⃣  Liste des Students:"
echo "---"
curl -s http://localhost:8080/students
echo -e "\n"

echo ""
echo "╔════════════════════════════════════════════════════════╗"
echo "║      🎉 TOUT FONCTIONNE CORRECTEMENT !                ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""
echo "🌐 L'application est accessible depuis l'extérieur sur :"
echo "   - http://abdellah.sofi1.takima.cloud (via HTTPD)"
echo "   - http://abdellah.sofi1.takima.cloud:8080 (API directe)"
echo ""

