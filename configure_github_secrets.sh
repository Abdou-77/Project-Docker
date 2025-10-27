#!/bin/bash
# Script pour préparer et afficher tous les secrets GitHub nécessaires

echo "╔════════════════════════════════════════════════════════╗"
echo "║     CONFIGURATION DES SECRETS GITHUB                  ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""

# Configuration
SSH_KEY="$HOME/.ssh/abdellah_takima"
SERVER_HOST="abdellah.sofi1.takima.cloud"
SERVER_USER="admin"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 SECRETS À CONFIGURER DANS GITHUB"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Allez sur GitHub : Settings → Secrets and variables → Actions → New repository secret"
echo ""

# 1. SSH_PRIVATE_KEY
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "1️⃣  SECRET: SSH_PRIVATE_KEY"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
if [ -f "$SSH_KEY" ]; then
    echo "✅ Clé privée trouvée : $SSH_KEY"
    echo ""
    echo "Copiez le contenu suivant (TOUT, y compris BEGIN et END) :"
    echo "────────────────────────────────────────────────────────"
    cat "$SSH_KEY"
    echo "────────────────────────────────────────────────────────"
    echo ""
    echo "📋 Copier dans le presse-papier ? (o/n)"
    read -r response
    if [[ "$response" =~ ^[oOyY]$ ]]; then
        cat "$SSH_KEY" | pbcopy 2>/dev/null && echo "✅ Copié dans le presse-papier !" || cat "$SSH_KEY"
    fi
else
    echo "❌ Clé privée non trouvée : $SSH_KEY"
    echo "Exécutez : ssh-keygen -t ed25519 -f $SSH_KEY"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "2️⃣  SECRET: SERVER_HOST"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Valeur : $SERVER_HOST"
echo "$SERVER_HOST" | pbcopy 2>/dev/null && echo "✅ Copié dans le presse-papier !" || true
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "3️⃣  SECRET: SERVER_USER"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Valeur : $SERVER_USER"
echo "$SERVER_USER" | pbcopy 2>/dev/null && echo "✅ Copié dans le presse-papier !" || true
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "4️⃣  SECRET: DOCKERHUB_USERNAME"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Votre nom d'utilisateur Docker Hub (sans @, juste le nom)"
echo "Exemple : abdou775"
echo ""
echo "Entrez votre Docker Hub username :"
read -r docker_user
echo "$docker_user" | pbcopy 2>/dev/null && echo "✅ Copié dans le presse-papier : $docker_user" || echo "Valeur : $docker_user"
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "5️⃣  SECRET: SECRET_TOKEN (ou SECRET_PASSWORD)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Votre Personal Access Token Docker Hub (PAT)"
echo "Créez-le sur : https://hub.docker.com/settings/security"
echo "→ New Access Token → Read, Write, Delete"
echo ""
echo "Entrez votre Docker Hub token :"
read -rs docker_token
echo "$docker_token" | pbcopy 2>/dev/null && echo "✅ Token copié dans le presse-papier" || echo "Token saisi"
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "6️⃣  SECRET: SONAR_TOKEN (optionnel)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Si vous utilisez SonarCloud, créez un token sur :"
echo "https://sonarcloud.io/account/security"
echo ""

echo ""
echo "╔════════════════════════════════════════════════════════╗"
echo "║     📝 RÉSUMÉ DES SECRETS À CONFIGURER               ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""
echo "Sur GitHub → Votre repo → Settings → Secrets and variables → Actions"
echo ""
echo "Créez ces 5 secrets (6 si SonarCloud) :"
echo "  1. SSH_PRIVATE_KEY      → Clé privée SSH complète"
echo "  2. SERVER_HOST          → $SERVER_HOST"
echo "  3. SERVER_USER          → $SERVER_USER"
echo "  4. DOCKERHUB_USERNAME   → Votre username Docker Hub"
echo "  5. SECRET_TOKEN         → Votre PAT Docker Hub"
echo "  6. SONAR_TOKEN          → (optionnel) Token SonarCloud"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "✅ Une fois configurés, chaque push sur main déclenchera :"
echo "   1. Tests backend + SonarCloud"
echo "   2. Build et push des 3 images Docker"
echo "   3. Déploiement automatique sur le serveur"
echo ""
echo "🚀 Prêt à tester ? Faites un commit et push sur main !"
echo ""

