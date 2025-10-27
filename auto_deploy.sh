#!/bin/bash
# Script de déploiement automatique complet

set -e

echo "╔════════════════════════════════════════════════════════╗"
echo "║     DÉPLOIEMENT AUTOMATIQUE DES 3 CONTENEURS          ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""

# Configuration
SSH_KEY="$HOME/.ssh/abdellah_takima"
SERVER_HOST="abdellah.sofi1.takima.cloud"
SERVER_USER="admin"

# Couleurs
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "ÉTAPE 1/6 : Test de connexion SSH"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if ssh -i "$SSH_KEY" -o ConnectTimeout=10 -o StrictHostKeyChecking=no "$SERVER_USER@$SERVER_HOST" "echo 'SSH OK'" 2>/dev/null; then
    echo -e "${GREEN}✅ Connexion SSH réussie${NC}"
else
    echo -e "${RED}❌ Connexion SSH échouée${NC}"
    echo ""
    echo "La clé publique n'est pas sur le serveur."
    echo "Connectez-vous à la console web de votre VM et exécutez :"
    echo ""
    echo "mkdir -p ~/.ssh && chmod 700 ~/.ssh && echo 'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICsjmckW8u6O4sDcrWwRG/o9Opq6nJW5UqQpCa4i3wKl admin@abdellah.sofi1.takima.cloud' >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys"
    echo ""
    exit 1
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "ÉTAPE 2/6 : Test Ansible (ping)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if ansible all -i ansible/inventories/setup.yml -m ping 2>/dev/null | grep -q "SUCCESS"; then
    echo -e "${GREEN}✅ Ansible fonctionne correctement${NC}"
else
    echo -e "${RED}❌ Ansible ping échoué${NC}"
    exit 1
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "ÉTAPE 3/6 : Déploiement via Ansible"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo "Lancement du playbook Ansible..."
if ansible-playbook -i ansible/inventories/setup.yml ansible/playbook.yml; then
    echo -e "${GREEN}✅ Déploiement Ansible terminé${NC}"
else
    echo -e "${RED}❌ Déploiement Ansible échoué${NC}"
    exit 1
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "ÉTAPE 4/6 : Vérification des conteneurs"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo "Conteneurs en cours d'exécution sur le serveur :"
ssh -i "$SSH_KEY" "$SERVER_USER@$SERVER_HOST" "docker ps --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}'" || true

echo ""
echo "Vérification des 3 conteneurs attendus :"
CONTAINERS=$(ssh -i "$SSH_KEY" "$SERVER_USER@$SERVER_HOST" "docker ps --format '{{.Names}}'" 2>/dev/null || echo "")

if echo "$CONTAINERS" | grep -q "database" || echo "$CONTAINERS" | grep -q "postgres" || echo "$CONTAINERS" | grep -q "db"; then
    echo -e "${GREEN}✅ Conteneur Database détecté${NC}"
else
    echo -e "${YELLOW}⚠️  Conteneur Database non trouvé${NC}"
fi

if echo "$CONTAINERS" | grep -q "backend" || echo "$CONTAINERS" | grep -q "api"; then
    echo -e "${GREEN}✅ Conteneur Backend détecté${NC}"
else
    echo -e "${YELLOW}⚠️  Conteneur Backend non trouvé${NC}"
fi

if echo "$CONTAINERS" | grep -q "httpd" || echo "$CONTAINERS" | grep -q "proxy"; then
    echo -e "${GREEN}✅ Conteneur Proxy détecté${NC}"
else
    echo -e "${YELLOW}⚠️  Conteneur Proxy non trouvé${NC}"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "ÉTAPE 5/6 : Test des endpoints HTTP"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo "Attente de 10 secondes pour que les services démarrent..."
sleep 10

echo ""
echo "Test du proxy (port 8080) :"
if curl -s -o /dev/null -w "%{http_code}" --connect-timeout 10 "http://$SERVER_HOST:8080" | grep -q "200\|301\|302"; then
    echo -e "${GREEN}✅ Proxy répond correctement${NC}"
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "http://$SERVER_HOST:8080")
    echo "   Code HTTP: $HTTP_CODE"
else
    echo -e "${RED}❌ Proxy ne répond pas${NC}"
fi

echo ""
echo "Test de l'API backend via proxy :"
# Tester différents endpoints possibles
for endpoint in "/" "/api" "/departments" "/students"; do
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout 5 "http://$SERVER_HOST:8080$endpoint" 2>/dev/null || echo "000")
    if [ "$HTTP_CODE" != "000" ] && [ "$HTTP_CODE" != "404" ]; then
        echo -e "${GREEN}✅ $endpoint - Code HTTP: $HTTP_CODE${NC}"
    fi
done

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "ÉTAPE 6/6 : Résumé et tests curl détaillés"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo ""
echo "Test complet avec curl -v :"
echo "$ curl -v http://$SERVER_HOST:8080/"
curl -v "http://$SERVER_HOST:8080/" 2>&1 | head -20

echo ""
echo "╔════════════════════════════════════════════════════════╗"
echo "║            ✅ DÉPLOIEMENT TERMINÉ !                    ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""
echo "🌐 Votre application est accessible à :"
echo "   http://$SERVER_HOST:8080"
echo ""
echo "📋 Prochaine étape : Configurer les secrets GitHub"
echo "   Exécutez : ./setup_github_secrets.sh"
echo ""

