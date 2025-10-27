#!/bin/bash
# Rapport de diagnostic complet du déploiement Ansible

echo "=========================================="
echo "📊 RAPPORT DE DIAGNOSTIC COMPLET"
echo "=========================================="
echo ""

echo "1️⃣ STRUCTURE ANSIBLE"
echo "----------------------------------------"
echo "Playbook principal :"
cat /Users/abdallahsofi/Project-Docker/ansible/playbook.yml
echo ""

echo "2️⃣ RÔLES DÉFINIS"
echo "----------------------------------------"
ls -la /Users/abdallahsofi/Project-Docker/ansible/roles/
echo ""

echo "3️⃣ VARIABLES GLOBALES"
echo "----------------------------------------"
cat /Users/abdallahsofi/Project-Docker/ansible/group_vars/all.yml
echo ""

echo "4️⃣ VÉRIFICATION DES FICHIERS DE RÔLES"
echo "----------------------------------------"
for role in install_docker create_network launch_database launch_app launch_proxy; do
    echo "--- Rôle: $role ---"
    if [ -f "/Users/abdallahsofi/Project-Docker/ansible/roles/$role/tasks/main.yml" ]; then
        echo "✅ tasks/main.yml existe"
        head -3 "/Users/abdallahsofi/Project-Docker/ansible/roles/$role/tasks/main.yml"
    else
        echo "❌ tasks/main.yml MANQUANT"
    fi
    echo ""
done

echo "5️⃣ IMAGES DOCKER SUR DOCKER HUB"
echo "----------------------------------------"
echo "Vérification des images poussées..."
docker images | grep abdallahsofi
echo ""

echo "6️⃣ SYNTAXE DU PLAYBOOK"
echo "----------------------------------------"
cd /Users/abdallahsofi/Project-Docker/ansible
ansible-playbook -i inventories/setup.yml playbook.yml --syntax-check
echo ""

echo "=========================================="
echo "✅ DIAGNOSTIC TERMINÉ"
echo "=========================================="

