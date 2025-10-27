#!/bin/bash
# Script de nettoyage du projet - Supprime tous les fichiers obsolètes

echo "🧹 Nettoyage du projet en cours..."
echo ""

cd "$(dirname "$0")"

# Scripts de déploiement obsolètes
echo "Suppression des scripts obsolètes..."
rm -f deploy_all.sh deploy_complete.sh deploy_manual.sh deploy_on_server.sh \
      push_and_deploy.sh test_and_deploy.sh fix_deployment.sh \
      quick_test.sh simple_test.sh test_cloud_deployment.sh \
      test_dns_access.sh verify_deployment.sh \
      prepare_github_secrets.sh setup_github_secrets.sh show_github_secrets.sh

# Documentation redondante
echo "Suppression de la documentation redondante..."
rm -f CONTINUOUS_DEPLOYMENT_SECURITY.md DOCKER_CONTAINER_DOCUMENTATION.md \
      GITHUB_SECRETS_SETUP.md GUIDE_DEPLOIEMENT.md

# Fichiers système macOS
echo "Suppression des fichiers système..."
find . -name ".DS_Store" -type f -delete 2>/dev/null

echo ""
echo "✅ Nettoyage terminé !"
echo ""
echo "📁 Fichiers restants :"
ls -1

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Fichiers essentiels conservés :"
echo "   • auto_deploy.sh - déploiement local manuel"
echo "   • configure_github_secrets.sh - configuration des secrets"
echo "   • GITHUB_SECRETS_CONFIGURATION.md - guide complet"
echo "   • README.md - documentation principale"
echo "   • docker-compose.yml - configuration Docker"
echo "   • .github/workflows/main.yml - CI/CD"
echo "   • ansible/ - playbooks de déploiement"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

