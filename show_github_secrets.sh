#!/bin/bash
# Script pour afficher la clé SSH privée à ajouter aux secrets GitHub

echo "╔════════════════════════════════════════════════════════╗"
echo "║     CONFIGURATION DES SECRETS GITHUB ACTIONS          ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""

echo "📋 Vous devez ajouter les secrets suivants dans votre dépôt GitHub :"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "1. SSH_PRIVATE_KEY"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "🔑 Contenu à copier pour SSH_PRIVATE_KEY :"
echo "-------------------------------------------"
if [ -f ~/.ssh/abdellah_takima ]; then
    cat ~/.ssh/abdellah_takima
    echo ""
    echo "✅ Clé privée abdellah_takima trouvée"
elif [ -f ~/.ssh/id_rsa ]; then
    cat ~/.ssh/id_rsa
    echo ""
    echo "✅ Clé privée id_rsa trouvée"
else
    echo "❌ Aucune clé SSH trouvée dans ~/.ssh/"
    echo ""
    echo "Créez une nouvelle clé avec :"
    echo "  ssh-keygen -t ed25519 -f ~/.ssh/abdellah_takima -N ''"
    exit 1
fi
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "2. SERVER_HOST"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Valeur : abdellah.sofi1.takima.cloud"
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "3. SERVER_USER"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Valeur : admin"
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📝 ÉTAPES POUR AJOUTER LES SECRETS :"
echo ""
echo "1. Allez sur GitHub : https://github.com/VOTRE_USERNAME/VOTRE_REPO/settings/secrets/actions"
echo ""
echo "2. Cliquez sur 'New repository secret'"
echo ""
echo "3. Ajoutez chaque secret :"
echo "   - Name: SSH_PRIVATE_KEY"
echo "     Value: [Copiez la clé privée ci-dessus, TOUTE LA CLÉ incluant BEGIN et END]"
echo ""
echo "   - Name: SERVER_HOST"
echo "     Value: abdellah.sofi1.takima.cloud"
echo ""
echo "   - Name: SERVER_USER"
echo "     Value: admin"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "⚠️  IMPORTANT : La clé publique doit être ajoutée au serveur !"
echo ""
echo "🔑 Clé publique à ajouter sur le serveur :"
echo "-------------------------------------------"
if [ -f ~/.ssh/abdellah_takima.pub ]; then
    cat ~/.ssh/abdellah_takima.pub
elif [ -f ~/.ssh/id_rsa.pub ]; then
    cat ~/.ssh/id_rsa.pub
fi
echo ""
echo ""
echo "Sur le serveur cloud, exécutez :"
echo "  mkdir -p ~/.ssh"
echo "  echo 'VOTRE_CLE_PUBLIQUE_CI_DESSUS' >> ~/.ssh/authorized_keys"
echo "  chmod 600 ~/.ssh/authorized_keys"
echo "  chmod 700 ~/.ssh"
echo ""
echo "╔════════════════════════════════════════════════════════╗"
echo "║           ✅ CONFIGURATION TERMINÉE !                  ║"
echo "╚════════════════════════════════════════════════════════╝"

