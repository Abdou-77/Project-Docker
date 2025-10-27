#!/bin/bash
# Script de test final du déploiement

echo "🧪 TEST FINAL DU DÉPLOIEMENT ANSIBLE"
echo "===================================="
echo ""

# Test 1: Vérifier la structure locale
echo "✅ TEST 1: Structure Ansible locale"
echo "------------------------------------"
if [ -f "playbook.yml" ]; then
    echo "✅ playbook.yml existe"
    ROLES_COUNT=$(grep -c "^    -" playbook.yml)
    echo "   Nombre de rôles: $ROLES_COUNT/5"
else
    echo "❌ playbook.yml manquant"
fi
echo ""

# Test 2: Vérifier les rôles
echo "✅ TEST 2: Rôles Ansible"
echo "------------------------------------"
for role in install_docker create_network launch_database launch_app launch_proxy; do
    if [ -f "roles/$role/tasks/main.yml" ]; then
        echo "✅ $role"
    else
        echo "❌ $role (MANQUANT)"
    fi
done
echo ""

# Test 3: Vérifier les images Docker locales
echo "✅ TEST 3: Images Docker locales"
echo "------------------------------------"
docker images abdallahsofi/* --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"
echo ""

# Test 4: Tester la syntaxe du playbook
echo "✅ TEST 4: Syntaxe du playbook"
echo "------------------------------------"
ansible-playbook -i inventories/setup.yml playbook.yml --syntax-check
if [ $? -eq 0 ]; then
    echo "✅ Syntaxe valide"
else
    echo "❌ Erreur de syntaxe"
fi
echo ""

# Test 5: Test de connexion au serveur
echo "✅ TEST 5: Connexion au serveur"
echo "------------------------------------"
ansible all -i inventories/setup.yml -m ping
echo ""

echo "===================================="
echo "📊 RÉSUMÉ DES TESTS"
echo "===================================="
echo ""
echo "Pour tester manuellement sur le serveur:"
echo "  ssh -i ~/.ssh/abdellah_takima admin@abdellah.sofi1.takima.cloud"
echo ""
echo "Puis exécutez:"
echo "  docker ps"
echo "  curl http://localhost:8080/actuator/health"
echo "  curl http://localhost/"
echo ""

