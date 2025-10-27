#!/bin/bash
# Script de vérification du déploiement de l'application

echo "========================================="
echo "🔍 VÉRIFICATION DU DÉPLOIEMENT"
echo "========================================="
echo ""

echo "1️⃣ Conteneurs Docker en cours d'exécution :"
echo "-------------------------------------------"
docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}"
echo ""

echo "2️⃣ Réseau Docker :"
echo "-------------------------------------------"
docker network ls | grep app-network
echo ""

echo "3️⃣ Test de l'API via HTTPD (port 80) :"
echo "-------------------------------------------"
echo "GET http://localhost/"
curl -s -o /dev/null -w "Status Code: %{http_code}\n" http://localhost/ || echo "❌ ÉCHEC"
echo ""

echo "4️⃣ Test direct du Backend (port 8080) :"
echo "-------------------------------------------"
echo "GET http://localhost:8080/actuator/health"
curl -s http://localhost:8080/actuator/health || echo "❌ ÉCHEC"
echo ""
echo ""

echo "5️⃣ Test endpoints API :"
echo "-------------------------------------------"
echo "GET http://localhost:8080/departments"
curl -s http://localhost:8080/departments | head -5 || echo "❌ ÉCHEC"
echo ""
echo ""

echo "6️⃣ Inspection du réseau app-network :"
echo "-------------------------------------------"
docker network inspect app-network --format '{{range .Containers}}{{.Name}}: {{.IPv4Address}}{{"\n"}}{{end}}'
echo ""

echo "========================================="
echo "✅ VÉRIFICATION TERMINÉE"
echo "========================================="

