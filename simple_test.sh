#!/bin/bash
# Test rapide et simple

ssh -i /Users/abdallahsofi/.ssh/abdellah_takima admin@abdellah.sofi1.takima.cloud << 'EOF'
echo "=== CONTENEURS ==="
docker ps --format "{{.Names}}: {{.Status}}"
echo ""
echo "=== HEALTH CHECK ==="
curl -s http://localhost:8080/actuator/health
echo ""
echo "=== DEPARTMENTS ==="
curl -s http://localhost:8080/departments | head -200
echo ""
echo "=== STUDENTS ==="
curl -s http://localhost:8080/students | head -200
echo ""
echo "=== HTTPD ==="
curl -s -I http://localhost/ | head -5
EOF

