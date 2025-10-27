#!/bin/bash
# Script de test rapide du déploiement

echo "Test de connexion au serveur cloud..."
ssh -o ConnectTimeout=10 -i /Users/abdallahsofi/.ssh/abdellah_takima admin@abdellah.sofi1.takima.cloud << 'EOF'
echo "=== CONTENEURS ACTIFS ==="
docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}"
echo ""
echo "=== TEST API HEALTH ==="
curl -s http://localhost:8080/actuator/health 2>&1 || echo "API non accessible"
echo ""
echo "=== TEST API DEPARTMENTS ==="
curl -s http://localhost:8080/departments 2>&1 | head -100 || echo "Departments non accessible"
echo ""
echo "=== TEST API STUDENTS ==="
curl -s http://localhost:8080/students 2>&1 | head -100 || echo "Students non accessible"
echo ""
echo "=== TEST HTTPD ==="
curl -s http://localhost/ 2>&1 | head -20 || echo "HTTPD non accessible"
EOF

