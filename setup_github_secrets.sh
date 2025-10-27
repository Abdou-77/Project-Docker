#!/bin/bash
# Script pour préparer les secrets GitHub

echo "╔════════════════════════════════════════════════════════╗"
echo "║  PRÉPARATION DES SECRETS GITHUB ACTIONS               ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""

# Trouver la clé SSH privée
if [ -f ~/.ssh/abdellah_takima ]; then
    PRIVATE_KEY_FILE="$HOME/.ssh/abdellah_takima"
    PUBLIC_KEY_FILE="$HOME/.ssh/abdellah_takima.pub"
    echo "✅ Clé trouvée : abdellah_takima"
elif [ -f ~/.ssh/id_rsa ]; then
    PRIVATE_KEY_FILE="$HOME/.ssh/id_rsa"
    PUBLIC_KEY_FILE="$HOME/.ssh/id_rsa.pub"
    echo "✅ Clé trouvée : id_rsa"
else
    echo "❌ Aucune clé SSH trouvée !"
    echo ""
    echo "Créez une nouvelle clé avec :"
    echo "  ssh-keygen -t ed25519 -f ~/.ssh/abdellah_takima -N ''"
    echo ""
    exit 1
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "ÉTAPE 1 : Copier la clé privée dans le presse-papier"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📋 La clé privée a été copiée dans votre presse-papier !"
cat "$PRIVATE_KEY_FILE" | pbcopy
echo ""
echo "➡️  Collez-la dans GitHub comme secret SSH_PRIVATE_KEY"
echo ""
read -p "Appuyez sur ENTRÉE une fois que vous avez collé la clé dans GitHub..."

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "ÉTAPE 2 : Copier les autres secrets"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📋 Copiez ces valeurs dans GitHub Secrets :"
echo ""
echo "   SERVER_HOST: abdellah.sofi1.takima.cloud"
echo "   SERVER_USER: admin"
echo ""
echo "abdellah.sofi1.takima.cloud" | pbcopy
echo "➡️  SERVER_HOST copié dans le presse-papier"
read -p "Appuyez sur ENTRÉE une fois ajouté..."
echo "admin" | pbcopy
echo "➡️  SERVER_USER copié dans le presse-papier"
read -p "Appuyez sur ENTRÉE une fois ajouté..."

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "ÉTAPE 3 : Ajouter la clé publique au serveur"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📋 Clé publique copiée dans le presse-papier !"
cat "$PUBLIC_KEY_FILE" | pbcopy
echo ""
echo "➡️  Connectez-vous à votre serveur cloud et exécutez :"
echo ""
echo "    mkdir -p ~/.ssh && chmod 700 ~/.ssh"
echo "    nano ~/.ssh/authorized_keys"
echo "    # Collez la clé publique (Cmd+V)"
echo "    # Sauvegardez (Ctrl+O, Entrée, Ctrl+X)"
echo "    chmod 600 ~/.ssh/authorized_keys"
echo ""
read -p "Appuyez sur ENTRÉE une fois la clé ajoutée au serveur..."

echo ""
echo "╔════════════════════════════════════════════════════════╗"
echo "║      ✅ CONFIGURATION TERMINÉE !                       ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""
echo "🚀 Vous pouvez maintenant pousser sur GitHub et le déploiement"
echo "   se fera automatiquement !"
echo ""
echo "Test local de connexion SSH :"
ssh -i "$PRIVATE_KEY_FILE" -o ConnectTimeout=5 admin@abdellah.sofi1.takima.cloud "echo '✅ Connexion SSH réussie !'" 2>&1 || echo "⚠️  Connexion SSH échouée - vérifiez que la clé publique est sur le serveur"

