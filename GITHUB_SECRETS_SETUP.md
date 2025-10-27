# Configuration des Secrets GitHub pour le Déploiement Continu

## 📋 Secrets requis

Pour que le déploiement automatique fonctionne, vous devez configurer les secrets suivants dans votre repository GitHub.

---

## 🔐 1. Configuration des secrets dans GitHub

### Étapes :

1. Allez sur votre repository GitHub
2. Cliquez sur **Settings** (en haut à droite)
3. Dans le menu de gauche : **Secrets and variables** → **Actions**
4. Cliquez sur **New repository secret**
5. Ajoutez chaque secret ci-dessous

---

## 📝 2. Liste des secrets à configurer

### A. Secrets Docker Hub (déjà configurés)

```bash
DOCKERHUB_USERNAME=abdou775
SECRET_TOKEN=<votre_token_docker_hub>
```

✅ Ces secrets sont déjà configurés dans votre projet.

---

### B. Secrets SSH pour le déploiement (À AJOUTER)

#### **SSH_PRIVATE_KEY**

Votre clé SSH privée pour se connecter au serveur cloud.

**Comment obtenir la valeur :**
```bash
# Sur votre Mac, afficher le contenu de votre clé SSH
cat ~/.ssh/abdellah_takima
```

**Copiez tout le contenu** (de `-----BEGIN OPENSSH PRIVATE KEY-----` jusqu'à `-----END OPENSSH PRIVATE KEY-----` inclus)

**Nom du secret dans GitHub :** `SSH_PRIVATE_KEY`  
**Valeur :** Le contenu complet de votre clé privée

⚠️ **ATTENTION** : Ne partagez JAMAIS cette clé publiquement !

---

#### **SERVER_HOST**

L'adresse de votre serveur cloud.

**Nom du secret :** `SERVER_HOST`  
**Valeur :** `abdellah.sofi1.takima.cloud`

---

#### **SERVER_USER**

Le nom d'utilisateur pour se connecter au serveur.

**Nom du secret :** `SERVER_USER`  
**Valeur :** `admin`

---

## 🚀 3. Test de configuration

Une fois tous les secrets configurés, vous pouvez tester le déploiement automatique :

```bash
# 1. Faire un commit et push sur la branche main
git add .
git commit -m "test: déploiement automatique"
git push origin main

# 2. Aller sur GitHub → Actions
# 3. Vérifier que le workflow s'exécute
# 4. Vérifier que le job "deploy-to-production" s'exécute
```

---

## 📊 4. Vérification des secrets

Pour vérifier que vos secrets sont bien configurés :

1. Allez sur **Settings** → **Secrets and variables** → **Actions**
2. Vous devriez voir :
   - ✅ `DOCKERHUB_USERNAME`
   - ✅ `SECRET_TOKEN` (ou `SECRET_PASSWORD`)
   - ✅ `SSH_PRIVATE_KEY` ← **NOUVEAU**
   - ✅ `SERVER_HOST` ← **NOUVEAU**
   - ✅ `SERVER_USER` ← **NOUVEAU**
   - ✅ `SONAR_TOKEN` (pour SonarCloud)
   - ✅ `GITHUB_TOKEN` (automatique)

---

## 🔒 5. Sécurité des secrets

### ✅ Bonnes pratiques :

1. **Ne jamais commit les secrets** dans le code
2. **Rotation régulière** : Changer les clés tous les 3-6 mois
3. **Clé SSH dédiée** : Utiliser une clé spécifique pour le déploiement (pas votre clé personnelle)
4. **Permissions minimales** : La clé SSH doit avoir le minimum de permissions nécessaires
5. **Audit** : Vérifier régulièrement qui a accès aux secrets

### 🔄 Comment créer une clé SSH dédiée au déploiement :

```bash
# Créer une nouvelle clé SSH spécifique pour le déploiement
ssh-keygen -t ed25519 -C "github-actions-deploy" -f ~/.ssh/github_deploy_key

# Copier la clé publique sur le serveur
ssh-copy-id -i ~/.ssh/github_deploy_key.pub admin@abdellah.sofi1.takima.cloud

# Utiliser cette nouvelle clé dans le secret SSH_PRIVATE_KEY
cat ~/.ssh/github_deploy_key
```

---

## 🎯 6. Résumé : Configuration complète

| Secret | Valeur | Statut |
|--------|--------|--------|
| `DOCKERHUB_USERNAME` | `abdou775` | ✅ Configuré |
| `SECRET_TOKEN` | Token Docker Hub | ✅ Configuré |
| `SSH_PRIVATE_KEY` | Contenu clé privée SSH | ⚠️ À ajouter |
| `SERVER_HOST` | `abdellah.sofi1.takima.cloud` | ⚠️ À ajouter |
| `SERVER_USER` | `admin` | ⚠️ À ajouter |
| `SONAR_TOKEN` | Token SonarCloud | ✅ Configuré |

---

## 🛠️ 7. Commande rapide pour ajouter les secrets

Pour ajouter rapidement le secret SSH_PRIVATE_KEY, vous pouvez utiliser cette commande :

```bash
# Copier la clé SSH dans le presse-papier (Mac)
cat ~/.ssh/abdellah_takima | pbcopy
echo "✅ Clé SSH copiée dans le presse-papier"
echo "Allez sur GitHub → Settings → Secrets → New secret"
echo "Nom: SSH_PRIVATE_KEY"
echo "Valeur: Collez avec Cmd+V"
```

---

## 🐛 8. Dépannage

### Erreur : "Permission denied (publickey)"

**Cause :** La clé SSH n'est pas correctement configurée

**Solution :**
1. Vérifier que le secret `SSH_PRIVATE_KEY` contient bien toute la clé (y compris les lignes BEGIN et END)
2. Vérifier que la clé publique est bien sur le serveur dans `~/.ssh/authorized_keys`
3. Tester manuellement : `ssh -i ~/.ssh/abdellah_takima admin@abdellah.sofi1.takima.cloud`

---

### Erreur : "Host key verification failed"

**Cause :** Le serveur n'est pas dans les hosts connus

**Solution :** Le workflow gère cela automatiquement avec `ssh-keyscan`, mais vous pouvez tester :
```bash
ssh-keyscan -H abdellah.sofi1.takima.cloud >> ~/.ssh/known_hosts
```

---

### Erreur : "Secret not found"

**Cause :** Le nom du secret ne correspond pas

**Solution :** Vérifier que le nom du secret dans GitHub correspond exactement au nom utilisé dans le workflow (sensible à la casse)

---

## 📞 Support

Si vous rencontrez des problèmes, vérifiez :
1. Les logs GitHub Actions (onglet Actions de votre repo)
2. Que tous les secrets sont bien configurés
3. Que la clé SSH fonctionne en local : `ssh -i ~/.ssh/abdellah_takima admin@abdellah.sofi1.takima.cloud`

---

**Date :** 27 octobre 2025  
**Version :** 1.0

