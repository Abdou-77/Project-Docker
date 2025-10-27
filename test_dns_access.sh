#!/bin/bash
# Test d'accès via le DNS abdellah.sofi1.takima.cloud

echo "╔════════════════════════════════════════════════════════╗"
echo "║     TEST D'ACCÈS VIA DNS: abdellah.sofi1.takima.cloud ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""

DNS="abdellah.sofi1.takima.cloud"

echo "🌐 Test 1: Résolution DNS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
host $DNS || nslookup $DNS
echo ""

echo "🌍 Test 2: HTTPD (port 80) - Page d'accueil"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout 10 http://$DNS/)
echo "HTTP Status: $HTTP_STATUS"
if [ "$HTTP_STATUS" = "200" ]; then
    echo "✅ HTTPD accessible"
    curl -s http://$DNS/ | head -30
else
    echo "❌ HTTPD non accessible (HTTP $HTTP_STATUS)"
fi
echo ""

echo "🔧 Test 3: Backend API - Health Check (port 8080)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
HEALTH=$(curl -s --connect-timeout 10 http://$DNS:8080/actuator/health 2>&1)
if echo "$HEALTH" | grep -q "UP"; then
    echo "✅ Backend API UP"
    echo "$HEALTH"
else
    echo "⚠️  Backend non accessible sur le port 8080"
    echo "$HEALTH"
fi
echo ""

echo "📚 Test 4: API Endpoint - /departments (port 8080)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
DEPARTMENTS=$(curl -s --connect-timeout 10 http://$DNS:8080/departments 2>&1)
if [ -n "$DEPARTMENTS" ] && [ "$DEPARTMENTS" != "[]" ]; then
    echo "✅ Endpoint /departments fonctionne"
    echo "$DEPARTMENTS" | head -100
else
    echo "⚠️  Endpoint /departments retourne des données vides ou erreur"
    echo "$DEPARTMENTS"
fi
echo ""

echo "👨‍🎓 Test 5: API Endpoint - /students (port 8080)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
STUDENTS=$(curl -s --connect-timeout 10 http://$DNS:8080/students 2>&1)
if [ -n "$STUDENTS" ] && [ "$STUDENTS" != "[]" ]; then
    echo "✅ Endpoint /students fonctionne"
    echo "$STUDENTS" | head -100
else
    echo "⚠️  Endpoint /students retourne des données vides ou erreur"
    echo "$STUDENTS"
fi
echo ""

echo "🔄 Test 6: Proxy Reverse - /api/departments (via HTTPD)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
PROXY_DEPT=$(curl -s --connect-timeout 10 http://$DNS/api/departments 2>&1)
if echo "$PROXY_DEPT" | grep -q "id\|departmentId"; then
    echo "✅ Proxy reverse fonctionne vers /api/departments"
    echo "$PROXY_DEPT" | head -100
else
    echo "⚠️  Proxy reverse ne fonctionne pas ou n'est pas configuré"
    echo "$PROXY_DEPT"
fi
echo ""

echo "╔════════════════════════════════════════════════════════╗"
echo "║                    RÉSUMÉ DES URLs                     ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""
echo "📍 URLs disponibles:"
echo "  🌐 Page d'accueil:     http://$DNS/"
echo "  🔧 Health check:       http://$DNS:8080/actuator/health"
echo "  📚 Departments:        http://$DNS:8080/departments"
echo "  👨‍🎓 Students:           http://$DNS:8080/students"
echo "  🔄 Proxy departments:  http://$DNS/api/departments"
echo "  🔄 Proxy students:     http://$DNS/api/students"
echo ""
echo "✅ Tests terminés!"

