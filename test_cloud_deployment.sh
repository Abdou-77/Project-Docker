#!/bin/bash
# Script de test du déploiement cloud

echo "🔍 VÉRIFICATION DU DÉPLOIEMENT CLOUD"
echo "======================================"
echo ""

HOST="abdellah.sofi1.takima.cloud"
SSH_KEY="/Users/abdallahsofi/.ssh/abdellah_takima"
USER="admin"

echo "📋 1. Vérification des conteneurs Docker"
echo "----------------------------------------"
ssh -i $SSH_KEY $USER@$HOST "docker ps --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}'"
echo ""

echo "🌐 2. Vérification du réseau Docker"
echo "----------------------------------------"
ssh -i $SSH_KEY $USER@$HOST "docker network inspect app-network --format '{{range .Containers}}{{.Name}} {{end}}'" 2>/dev/null || echo "⚠️  Réseau app-network non trouvé"
echo ""

echo "🗃️  3. Test de la base de données"
echo "----------------------------------------"
ssh -i $SSH_KEY $USER@$HOST "docker exec database pg_isready -U usr -d db" 2>/dev/null || echo "❌ Base de données non accessible"
echo ""

echo "🔧 4. Test de l'API Backend (health check)"
echo "----------------------------------------"
ssh -i $SSH_KEY $USER@$HOST "curl -s http://localhost:8080/actuator/health" || echo "❌ Backend non accessible"
echo ""

echo "📊 5. Test de l'API Backend (departments)"
echo "----------------------------------------"
ssh -i $SSH_KEY $USER@$HOST "curl -s http://localhost:8080/departments" || echo "❌ Endpoint departments non accessible"
echo ""

echo "📊 6. Test de l'API Backend (students)"
echo "----------------------------------------"
ssh -i $SSH_KEY $USER@$HOST "curl -s http://localhost:8080/students" || echo "❌ Endpoint students non accessible"
echo ""

echo "🌍 7. Test du Proxy HTTPD"
echo "----------------------------------------"
ssh -i $SSH_KEY $USER@$HOST "curl -s -o /dev/null -w 'HTTP Status: %{http_code}\n' http://localhost/" || echo "❌ HTTPD non accessible"
echo ""

echo "📦 8. Vérification des volumes"
echo "----------------------------------------"
ssh -i $SSH_KEY $USER@$HOST "docker volume ls | grep db-data" || echo "⚠️  Volume db-data non trouvé"
echo ""

echo "======================================"
echo "✅ VÉRIFICATION TERMINÉE"
echo "======================================"

