#!/bin/bash
# Script de vérification complète du déploiement sur le cloud

set -e

echo "╔════════════════════════════════════════════════════════╗"
echo "║  VÉRIFICATION DU DÉPLOIEMENT DES 3 CONTENEURS CLOUD   ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""

HOST="abdellah.sofi1.takima.cloud"
SSH_KEY="/Users/abdallahsofi/.ssh/abdellah_takima"
USER="admin"

# Fonction pour exécuter une commande SSH
run_ssh() {
    ssh -o ConnectTimeout=10 -i "$SSH_KEY" "$USER@$HOST" "$1"
}

echo "🔌 Connexion au serveur: $HOST"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# 1. Vérifier les conteneurs
echo ""
echo "📦 1. CONTENEURS DOCKER ACTIFS:"
echo "───────────────────────────────────────────────────────"
run_ssh "docker ps --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}'"

# 2. Vérifier le réseau
echo ""
echo "🌐 2. RÉSEAU DOCKER (app-network):"
echo "───────────────────────────────────────────────────────"
run_ssh "docker network ls | grep app-network" && echo "✅ Réseau app-network existe" || echo "❌ Réseau app-network introuvable"

# 3. Test de la base de données
echo ""
echo "🗄️  3. TEST BASE DE DONNÉES (PostgreSQL):"
echo "───────────────────────────────────────────────────────"
run_ssh "docker exec database pg_isready -U usr -d db" && echo "✅ Base de données opérationnelle" || echo "❌ Base de données non accessible"

# 4. Vérifier les données dans la BDD
echo ""
echo "📊 4. DONNÉES DANS LA BASE (departments):"
echo "───────────────────────────────────────────────────────"
run_ssh "docker exec database psql -U usr -d db -c 'SELECT * FROM departments;'" || echo "❌ Impossible de lire les departments"

echo ""
echo "📊 5. DONNÉES DANS LA BASE (students):"
echo "───────────────────────────────────────────────────────"
run_ssh "docker exec database psql -U usr -d db -c 'SELECT * FROM students LIMIT 5;'" || echo "❌ Impossible de lire les students"

# 5. Test de l'API Backend - Health
echo ""
echo "🔧 6. TEST API BACKEND - HEALTH CHECK:"
echo "───────────────────────────────────────────────────────"
HEALTH=$(run_ssh "curl -s http://localhost:8080/actuator/health")
echo "$HEALTH"
if echo "$HEALTH" | grep -q "UP"; then
    echo "✅ Backend est UP"
else
    echo "❌ Backend n'est pas UP"
fi

# 6. Test de l'API Backend - Departments
echo ""
echo "📚 7. TEST API BACKEND - GET /departments:"
echo "───────────────────────────────────────────────────────"
DEPARTMENTS=$(run_ssh "curl -s http://localhost:8080/departments")
echo "$DEPARTMENTS" | head -50
if [ -n "$DEPARTMENTS" ] && [ "$DEPARTMENTS" != "[]" ]; then
    echo "✅ Endpoint /departments fonctionne"
else
    echo "⚠️  Endpoint /departments retourne des données vides"
fi

# 7. Test de l'API Backend - Students
echo ""
echo "👨‍🎓 8. TEST API BACKEND - GET /students:"
echo "───────────────────────────────────────────────────────"
STUDENTS=$(run_ssh "curl -s http://localhost:8080/students")
echo "$STUDENTS" | head -50
if [ -n "$STUDENTS" ] && [ "$STUDENTS" != "[]" ]; then
    echo "✅ Endpoint /students fonctionne"
else
    echo "⚠️  Endpoint /students retourne des données vides"
fi

# 8. Test du Proxy HTTPD
echo ""
echo "🌍 9. TEST PROXY HTTPD - GET /:"
echo "───────────────────────────────────────────────────────"
HTTPD_STATUS=$(run_ssh "curl -s -o /dev/null -w '%{http_code}' http://localhost/")
echo "HTTP Status Code: $HTTPD_STATUS"
if [ "$HTTPD_STATUS" = "200" ]; then
    echo "✅ HTTPD fonctionne (HTTP 200)"
    run_ssh "curl -s http://localhost/ | head -20"
else
    echo "❌ HTTPD ne répond pas correctement"
fi

# 9. Test de la configuration du proxy reverse
echo ""
echo "🔄 10. TEST PROXY REVERSE - /api/departments via HTTPD:"
echo "───────────────────────────────────────────────────────"
PROXY_API=$(run_ssh "curl -s http://localhost/api/departments 2>&1")
echo "$PROXY_API" | head -50
if echo "$PROXY_API" | grep -q "id\|departmentId"; then
    echo "✅ Proxy reverse fonctionne vers le backend"
else
    echo "⚠️  Proxy reverse ne semble pas configuré ou ne fonctionne pas"
fi

# 10. Vérifier les volumes
echo ""
echo "💾 11. VOLUMES DOCKER:"
echo "───────────────────────────────────────────────────────"
run_ssh "docker volume ls | grep db-data" && echo "✅ Volume db-data existe" || echo "❌ Volume db-data introuvable"

# 11. Vérifier les logs des conteneurs (dernières lignes)
echo ""
echo "📋 12. LOGS DES CONTENEURS (dernières 5 lignes):"
echo "───────────────────────────────────────────────────────"
echo "--- Database logs ---"
run_ssh "docker logs database --tail 5 2>&1" || echo "Pas de logs database"
echo ""
echo "--- Backend logs ---"
run_ssh "docker logs backend --tail 5 2>&1" || echo "Pas de logs backend"
echo ""
echo "--- HTTPD logs ---"
run_ssh "docker logs httpd --tail 5 2>&1" || echo "Pas de logs httpd"

# Résumé final
echo ""
echo "╔════════════════════════════════════════════════════════╗"
echo "║                 RÉSUMÉ DU DÉPLOIEMENT                  ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""
run_ssh "docker ps --format 'Conteneur: {{.Names}} | Image: {{.Image}} | Status: {{.Status}}'"
echo ""
echo "🌐 URLs accessibles:"
echo "  - API Backend: http://$HOST:8080"
echo "  - API Health:  http://$HOST:8080/actuator/health"
echo "  - Departments: http://$HOST:8080/departments"
echo "  - Students:    http://$HOST:8080/students"
echo "  - HTTPD:       http://$HOST"
echo ""
echo "✅ Vérification terminée!"

