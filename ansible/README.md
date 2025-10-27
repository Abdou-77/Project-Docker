# Ansible Deployment - Application Dockerisée

## 📁 Structure Créée

```
ansible/
├── playbook.yml                    # Playbook principal
├── group_vars/
│   └── all.yml                     # Variables globales
├── inventories/
│   └── setup.yml                   # Inventaire des serveurs
└── roles/
    ├── install_docker/             # Rôle 1: Installation Docker
    ├── create_network/             # Rôle 2: Réseau Docker
    ├── launch_database/            # Rôle 3: PostgreSQL
    ├── launch_app/                 # Rôle 4: Backend Spring Boot
    └── launch_proxy/               # Rôle 5: HTTPD Proxy
```

## 🎯 Les 5 Rôles Créés

### 1️⃣ **install_docker**
- Installe les dépendances système
- Ajoute le dépôt Docker officiel
- Installe Docker CE, CLI et containerd
- Crée un environnement virtuel Python avec Docker SDK
- Configure et démarre le service Docker

### 2️⃣ **create_network**
- Crée un réseau Docker bridge `app-network`
- Utilise `ansible_python_interpreter: /opt/docker_venv/bin/python`
- Permet la communication entre conteneurs

### 3️⃣ **launch_database**
- Lance PostgreSQL avec `docker_container`
- Configure les variables d'environnement:
  - `POSTGRES_DB`
  - `POSTGRES_USER`
  - `POSTGRES_PASSWORD`
- Monte un volume persistant pour les données
- Connecté au réseau `app-network`

### 4️⃣ **launch_app**
- Lance le backend Spring Boot avec `docker_container`
- Configure les variables d'environnement pour la connexion DB:
  - `SPRING_DATASOURCE_URL`
  - `SPRING_DATASOURCE_USERNAME`
  - `SPRING_DATASOURCE_PASSWORD`
- Expose le port 8080
- Connecté au réseau `app-network`

### 5️⃣ **launch_proxy**
- Lance HTTPD avec `docker_container` (comme demandé)
- Expose le port 80
- Connecté au réseau `app-network`

## ⚙️ Configuration Avant Déploiement

**Éditez `ansible/group_vars/all.yml`** et remplacez:
```yaml
dockerhub_username: your-dockerhub-username
```

Par votre nom d'utilisateur Docker Hub réel.

## 🚀 Déployer l'Application

```bash
cd ansible
ansible-playbook -i inventories/setup.yml playbook.yml
```

## ✅ Vérification Post-Déploiement

Connectez-vous au serveur et vérifiez:

```bash
# Vérifier les conteneurs
docker ps

# Tester l'API
curl http://localhost
curl http://localhost:8080/actuator/health

# Vérifier le réseau
docker network inspect app-network
```

## 📦 Conteneurs Déployés

| Nom | Image | Port | Réseau | Variables Env |
|-----|-------|------|--------|---------------|
| database | postgres:14-alpine | 5432 | app-network | POSTGRES_DB, POSTGRES_USER, POSTGRES_PASSWORD |
| backend | {username}/tp-devops-simple-api-backend:latest | 8080 | app-network | SPRING_DATASOURCE_* |
| httpd | {username}/tp-devops-simple-api-httpd:latest | 80 | app-network | - |

## 🔑 Points Clés Implémentés

✅ Module `docker_container` utilisé pour tous les conteneurs  
✅ Module `docker_network` pour créer le réseau  
✅ Variables d'environnement configurées (DB et App)  
✅ `ansible_python_interpreter` défini pour utiliser le venv  
✅ 5 rôles séparés comme demandé  
✅ Restart policy `always` pour tous les conteneurs  

Votre application est maintenant prête à être déployée ! 🎉

