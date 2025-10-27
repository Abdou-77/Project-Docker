# 🔐 Configuration des Secrets GitHub - Guide Complet

## ✅ Problème Résolu

Le workflow GitHub Actions était configuré pour créer la clé SSH dans `~/.ssh/deploy_key` mais Ansible cherchait `~/.ssh/id_rsa`. 

**Solution appliquée** : Le fichier `.github/workflows/main.yml` a été corrigé pour utiliser `id_rsa` partout.

---

## 📋 Secrets à Configurer dans GitHub

Allez sur votre dépôt GitHub → **Settings** → **Secrets and variables** → **Actions** → **New repository secret**

### 1️⃣ SSH_PRIVATE_KEY

**Nom du secret** : `SSH_PRIVATE_KEY`

**Valeur** : Copiez le contenu COMPLET de votre clé privée

```bash
# Sur votre Mac, exécutez :
cat ~/.ssh/abdellah_takima
```

**Important** : 
- Copiez TOUT le contenu, y compris les lignes `-----BEGIN OPENSSH PRIVATE KEY-----` et `-----END OPENSSH PRIVATE KEY-----`
- Ne modifiez aucun caractère, ne supprimez aucun retour à la ligne

---

### 2️⃣ SERVER_HOST

**Nom du secret** : `SERVER_HOST`

**Valeur** : 
```
abdellah.sofi1.takima.cloud
```

---

### 3️⃣ SERVER_USER

**Nom du secret** : `SERVER_USER`

**Valeur** : 
```
admin
```

---

### 4️⃣ DOCKERHUB_USERNAME

**Nom du secret** : `DOCKERHUB_USERNAME`

**Valeur** : Votre nom d'utilisateur Docker Hub (exemple : `abdou775`)

**⚠️ Important** : 
- Utilisez UNIQUEMENT le nom d'utilisateur, PAS l'email
- Pas de `@` ni de domaine
- C'est le nom qui apparaît dans vos images : `abdou775/tp-devops-simple-api-backend`

---

### 5️⃣ SECRET_TOKEN

**Nom du secret** : `SECRET_TOKEN`

**Valeur** : Votre Personal Access Token Docker Hub

**Comment créer le token** :
1. Allez sur https://hub.docker.com/settings/security
2. Cliquez sur **New Access Token**
3. Nom : `GitHub Actions CI/CD`
4. Permissions : **Read, Write, Delete**
5. Copiez le token généré (vous ne pourrez plus le voir après)

---

### 6️⃣ SONAR_TOKEN (Optionnel)

**Nom du secret** : `SONAR_TOKEN`

**Valeur** : Token SonarCloud (si vous utilisez SonarCloud)

**Comment créer le token** :
1. Allez sur https://sonarcloud.io/account/security
2. Générez un nouveau token
3. Copiez-le dans GitHub

**Note** : Si vous n'utilisez pas SonarCloud, vous pouvez supprimer ou commenter le job `Analyze with SonarCloud` dans le workflow.

---

## 🚀 Vérification de la Configuration

### Étape 1 : Vérifier que tous les secrets sont configurés

Dans GitHub → Settings → Secrets and variables → Actions, vous devez voir :
- ✅ SSH_PRIVATE_KEY
- ✅ SERVER_HOST
- ✅ SERVER_USER
- ✅ DOCKERHUB_USERNAME
- ✅ SECRET_TOKEN
- ✅ SONAR_TOKEN (optionnel)

### Étape 2 : Tester le workflow

1. Faites un changement dans votre code (par exemple, modifiez le README)
2. Committez et pushez sur la branche `main` :
   ```bash
   git add .
   git commit -m "test: CI/CD deployment"
   git push origin main
   ```
3. Allez dans l'onglet **Actions** de votre repo GitHub
4. Suivez l'exécution du workflow

### Étape 3 : Vérifier le déploiement

Le workflow va :
1. ✅ Tester le backend avec Maven
2. ✅ Analyser le code avec SonarCloud
3. ✅ Builder et pusher les 3 images Docker
4. ✅ Déployer automatiquement sur le serveur via Ansible
5. ✅ Vérifier que les conteneurs tournent

---

## 🔍 Résolution de Problèmes

### Erreur : "Permission denied (publickey)"

**Cause** : La clé privée n'est pas correctement configurée dans `SSH_PRIVATE_KEY`

**Solution** :
1. Vérifiez que vous avez copié TOUTE la clé (y compris BEGIN et END)
2. Vérifiez qu'il n'y a pas d'espaces supplémentaires
3. Régénérez le secret dans GitHub

### Erreur : "Failed to connect to the host via ssh"

**Cause** : Le serveur n'est pas accessible ou le nom d'hôte est incorrect

**Solution** :
1. Vérifiez que `SERVER_HOST` = `abdellah.sofi1.takima.cloud`
2. Vérifiez que le serveur est accessible publiquement
3. Testez manuellement : `ssh -i ~/.ssh/abdellah_takima admin@abdellah.sofi1.takima.cloud`

### Erreur : "unauthorized: authentication required"

**Cause** : Les credentials Docker Hub sont incorrects

**Solution** :
1. Vérifiez `DOCKERHUB_USERNAME` (sans @)
2. Régénérez un nouveau token Docker Hub
3. Mettez à jour `SECRET_TOKEN`

### Le déploiement Ansible échoue

**Cause** : Ansible ne peut pas se connecter au serveur

**Solution** :
1. Vérifiez que la clé publique est sur le serveur :
   ```bash
   ssh admin@abdellah.sofi1.takima.cloud "cat ~/.ssh/authorized_keys"
   ```
2. Elle doit contenir : `ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICsjmckW8u6O4sDcrWwRG/o9Opq6nJW5UqQpCa4i3wKl`

---

## 📝 Commandes Utiles

### Copier la clé privée dans le presse-papier (macOS)
```bash
cat ~/.ssh/abdellah_takima | pbcopy
```

### Vérifier que SSH fonctionne localement
```bash
ssh -i ~/.ssh/abdellah_takima admin@abdellah.sofi1.takima.cloud "docker ps"
```

### Tester le déploiement Ansible localement
```bash
cd ansible
ansible-playbook -i inventories/setup.yml playbook.yml
```

### Vérifier les conteneurs sur le serveur
```bash
ssh -i ~/.ssh/abdellah_takima admin@abdellah.sofi1.takima.cloud "docker ps --format 'table {{.Names}}\t{{.Status}}'"
```

---

## ✅ Checklist Finale

Avant de pusher sur `main` :

- [ ] Tous les secrets sont configurés dans GitHub
- [ ] La clé publique SSH est sur le serveur
- [ ] Docker Hub username est correct (sans @)
- [ ] Le token Docker Hub est valide
- [ ] Ansible fonctionne localement
- [ ] Le serveur est accessible via SSH

---

## 🎯 Workflow CI/CD Complet

Voici ce qui se passe automatiquement à chaque push sur `main` :

```
Push sur main
    ↓
1. Test Backend (JUnit, Maven)
    ↓
2. Analyse SonarCloud
    ↓
3. Build Docker Images
    ├── Backend (Spring Boot API)
    ├── Database (PostgreSQL)
    └── Proxy (HTTPD)
    ↓
4. Push vers Docker Hub
    ↓
5. Déploiement Ansible
    ├── Installer Docker (si absent)
    ├── Créer le réseau
    ├── Lancer Database
    ├── Lancer Backend
    └── Lancer Proxy
    ↓
6. Vérification
    ├── docker ps sur le serveur
    └── Test HTTP du proxy
    ↓
✅ Application déployée !
```

---

## 🌐 Accès à l'Application

Une fois déployée, l'application est accessible à :

- **URL** : http://abdellah.sofi1.takima.cloud
- **Port** : 80 (proxy HTTPD)

Le proxy redirige les requêtes vers le backend sur le port 8080 interne.

---

**Bonne chance ! 🚀**

