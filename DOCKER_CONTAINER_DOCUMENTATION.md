# Documentation des tâches docker_container

## Vue d'ensemble

Ce document décrit la configuration des tâches `docker_container` utilisées dans le projet pour déployer les 3 conteneurs (database, backend, httpd) sur le cloud avec Ansible.

---

## 📁 Architecture des fichiers

```
ansible/
├── playbook.yml                          # Playbook principal
├── inventories/
│   └── setup.yml                         # Configuration des hôtes
├── group_vars/
│   └── all.yml                           # Variables globales (images, noms, etc.)
└── roles/
    ├── install_docker/                   # Installation de Docker
    ├── create_network/                   # Création du réseau Docker
    ├── launch_database/
    │   └── tasks/
    │       └── main.yml                  # 🔹 Configuration du conteneur database
    ├── launch_app/
    │   └── tasks/
    │       └── main.yml                  # 🔹 Configuration du conteneur backend
    └── launch_proxy/
        └── tasks/
            └── main.yml                  # 🔹 Configuration du conteneur httpd
```

---

## 🗄️ 1. Configuration du conteneur DATABASE

**Fichier:** `ansible/roles/launch_database/tasks/main.yml`

```yaml
---
# Role: launch_database - Lance le conteneur PostgreSQL

- name: Run database container
  docker_container:
    name: "{{ database_container_name }}"           # Nom: "database"
    image: "{{ database_image }}"                   # Image: abdou775/tp-devops-simple-api-database:latest
    state: started                                  # État souhaité: démarré
    restart_policy: always                          # Redémarrage automatique en cas de crash
    networks:
      - name: "{{ docker_network_name }}"           # Réseau: "app-network"
    env:                                            # Variables d'environnement
      POSTGRES_DB: "{{ postgres_db }}"              # Nom de la base: "db"
      POSTGRES_USER: "{{ postgres_user }}"          # Utilisateur: "usr"
      POSTGRES_PASSWORD: "{{ postgres_password }}"  # Mot de passe: "pwd"
    volumes:
      - "{{ database_volume }}:/var/lib/postgresql/data"  # Volume persistant: "db-data"
  vars:
    ansible_python_interpreter: /opt/docker_venv/bin/python
```

**Variables utilisées (définies dans `group_vars/all.yml`):**
- `database_container_name`: "database"
- `database_image`: "abdou775/tp-devops-simple-api-database:latest"
- `database_volume`: "db-data"
- `postgres_db`: "db"
- `postgres_user`: "usr"
- `postgres_password`: "pwd"
- `docker_network_name`: "app-network"

**Fonctionnalités clés:**
- ✅ Volume persistant pour conserver les données entre les redémarrages
- ✅ Scripts d'initialisation SQL copiés dans l'image (01-CreateSchema.sql, 02-InsertData.sql)
- ✅ Connexion au réseau Docker pour communication avec le backend
- ✅ Politique de redémarrage automatique

---

## 🔧 2. Configuration du conteneur BACKEND

**Fichier:** `ansible/roles/launch_app/tasks/main.yml`

```yaml
---
# Role: launch_app - Lance le conteneur de l'application backend Spring Boot

- name: Run backend application container
  docker_container:
    name: "{{ app_container_name }}"                # Nom: "backend"
    image: "{{ app_image }}"                        # Image: abdou775/tp-devops-simple-api-backend:latest
    state: started                                  # État souhaité: démarré
    restart_policy: always                          # Redémarrage automatique
    networks:
      - name: "{{ docker_network_name }}"           # Réseau: "app-network"
    env:                                            # Variables d'environnement Spring Boot
      SPRING_DATASOURCE_URL: "jdbc:postgresql://{{ database_container_name }}:5432/{{ postgres_db }}"
      SPRING_DATASOURCE_USERNAME: "{{ postgres_user }}"
      SPRING_DATASOURCE_PASSWORD: "{{ postgres_password }}"
    ports:
      - "8080:8080"                                 # Exposition du port 8080
  vars:
    ansible_python_interpreter: /opt/docker_venv/bin/python
```

**Variables utilisées:**
- `app_container_name`: "backend"
- `app_image`: "abdou775/tp-devops-simple-api-backend:latest"
- `database_container_name`: "database" (utilisé dans l'URL JDBC)
- `postgres_db`: "db"
- `postgres_user`: "usr"
- `postgres_password`: "pwd"
- `docker_network_name`: "app-network"

**Fonctionnalités clés:**
- ✅ Connexion à la base de données via le nom DNS Docker ("database:5432")
- ✅ Port 8080 exposé pour accès à l'API REST
- ✅ Variables d'environnement Spring Boot pour la configuration de la datasource
- ✅ Connexion au réseau Docker pour communication avec database et httpd

**Endpoints API disponibles:**
- `GET /actuator/health` - Health check
- `GET /departments` - Liste des départements
- `GET /students` - Liste des étudiants

---

## 🌐 3. Configuration du conteneur HTTPD (Proxy)

**Fichier:** `ansible/roles/launch_proxy/tasks/main.yml`

```yaml
---
# Role: launch_proxy - Lance le conteneur Apache HTTPD (reverse proxy)

- name: Run HTTPD
  docker_container:
    name: "{{ proxy_container_name }}"              # Nom: "httpd"
    image: "{{ proxy_image }}"                      # Image: abdou775/tp-devops-simple-api-httpd:latest
    state: started                                  # État souhaité: démarré
    restart_policy: always                          # Redémarrage automatique
    networks:
      - name: "{{ docker_network_name }}"           # Réseau: "app-network"
    ports:
      - "80:80"                                     # Exposition du port 80 (HTTP)
  vars:
    ansible_python_interpreter: /opt/docker_venv/bin/python
```

**Variables utilisées:**
- `proxy_container_name`: "httpd"
- `proxy_image`: "abdou775/tp-devops-simple-api-httpd:latest"
- `docker_network_name`: "app-network"

**Fonctionnalités clés:**
- ✅ Port 80 exposé pour accès HTTP public
- ✅ Configuration de proxy reverse vers le backend (via httpd.conf dans l'image)
- ✅ Sert la page d'accueil statique (index.html)
- ✅ Redirection des requêtes `/api/*` vers le backend

**Configuration du proxy reverse (dans httpd.conf):**
```apache
ProxyPass /api http://backend:8080
ProxyPassReverse /api http://backend:8080
```

---

## 📋 4. Variables globales

**Fichier:** `ansible/group_vars/all.yml`

```yaml
---
# Variables globales pour le déploiement

# Docker Hub username
dockerhub_username: abdou775

# Configuration réseau
docker_network_name: app-network

# Configuration database
database_container_name: database
database_image: "{{ dockerhub_username }}/tp-devops-simple-api-database:latest"
database_volume: db-data
postgres_db: db
postgres_user: usr
postgres_password: pwd

# Configuration backend
app_container_name: backend
app_image: "{{ dockerhub_username }}/tp-devops-simple-api-backend:latest"

# Configuration proxy
proxy_container_name: httpd
proxy_image: "{{ dockerhub_username }}/tp-devops-simple-api-httpd:latest"
```

---

## 🔄 5. Ordre de déploiement

Le playbook principal (`playbook.yml`) définit l'ordre d'exécution des rôles :

```yaml
---
- hosts: all
  gather_facts: true
  become: true
  
  roles:
    - install_docker      # 1. Installation de Docker
    - create_network      # 2. Création du réseau "app-network"
    - launch_database     # 3. Démarrage du conteneur database
    - launch_app          # 4. Démarrage du conteneur backend
    - launch_proxy        # 5. Démarrage du conteneur httpd
```

**Pourquoi cet ordre ?**
1. Docker doit être installé avant tout
2. Le réseau doit exister pour connecter les conteneurs
3. La database doit démarrer avant le backend (dépendance)
4. Le backend doit démarrer avant le proxy (dépendance)

---

## 🌐 6. Configuration réseau Docker

**Fichier:** `ansible/roles/create_network/tasks/main.yml`

```yaml
---
# Role: create_network - Crée le réseau Docker pour connecter les conteneurs

- name: Create Docker network
  docker_network:
    name: "{{ docker_network_name }}"    # Nom: "app-network"
    state: present
  vars:
    ansible_python_interpreter: /opt/docker_venv/bin/python
```

**Avantages du réseau Docker:**
- ✅ Les conteneurs peuvent communiquer via leurs noms (ex: `backend`, `database`)
- ✅ Isolation des conteneurs du reste du système
- ✅ Résolution DNS automatique entre conteneurs
- ✅ Pas besoin de gérer les adresses IP manuellement

**Exemple de communication:**
```
httpd --> http://backend:8080 --> jdbc:postgresql://database:5432/db
```

---

## 🎯 7. Points importants à retenir

### ✅ Bonnes pratiques appliquées

1. **Utilisation des noms DNS** au lieu des IP
   - `jdbc:postgresql://database:5432/db` ✅
   - `jdbc:postgresql://172.18.0.2:5432/db` ❌

2. **Variables centralisées** dans `group_vars/all.yml`
   - Facilite la modification des configurations
   - Réutilisable pour différents environnements

3. **Politique de redémarrage automatique**
   - `restart_policy: always` pour tous les conteneurs
   - Garantit la disponibilité après un crash ou redémarrage du serveur

4. **Images multi-architecture**
   - Images construites avec `--platform linux/amd64`
   - Compatible avec les serveurs cloud x86_64

5. **Volumes persistants**
   - `db-data` pour la base de données
   - Les données survivent aux redémarrages

### ⚠️ Points d'attention

1. **Ordre de démarrage:** Database → Backend → HTTPD
2. **Temps de démarrage:** Attendre 30 secondes après le déploiement pour que tous les services soient prêts
3. **Credentials:** Les mots de passe sont en clair dans les variables (à améliorer avec Ansible Vault)
4. **Port 8080:** Doit être ouvert dans le firewall pour accès externe

---

## 🧪 8. Vérification du déploiement

Après le déploiement, vérifier que tout fonctionne :

```bash
# Vérifier les conteneurs actifs
docker ps

# Tester le health check
curl http://localhost:8080/actuator/health

# Tester l'API
curl http://localhost:8080/departments
curl http://localhost:8080/students

# Tester le proxy
curl http://localhost/
curl http://localhost/api/departments
```

---

## 🌍 9. Accès via DNS

L'application est accessible via le DNS : **abdellah.sofi1.takima.cloud**

**URLs disponibles:**
- 🌐 Page d'accueil: http://abdellah.sofi1.takima.cloud/
- 🔧 Health check: http://abdellah.sofi1.takima.cloud:8080/actuator/health
- 📚 Departments: http://abdellah.sofi1.takima.cloud:8080/departments
- 👨‍🎓 Students: http://abdellah.sofi1.takima.cloud:8080/students
- 🔄 Via proxy: http://abdellah.sofi1.takima.cloud/api/departments

---

## 🛠️ 10. Commandes utiles

### Déploiement complet
```bash
cd /Users/abdallahsofi/Project-Docker/ansible
ansible-playbook -i inventories/setup.yml playbook.yml
```

### Déploiement avec verbose (debug)
```bash
ansible-playbook -i inventories/setup.yml playbook.yml -v
```

### Réparation (nettoyage + redéploiement)
```bash
/Users/abdallahsofi/Project-Docker/fix_deployment.sh
```

### Test des conteneurs sur le serveur
```bash
ssh -i ~/.ssh/abdellah_takima admin@abdellah.sofi1.takima.cloud "docker ps"
ssh -i ~/.ssh/abdellah_takima admin@abdellah.sofi1.takima.cloud "docker logs backend"
ssh -i ~/.ssh/abdellah_takima admin@abdellah.sofi1.takima.cloud "docker logs database"
```

---

## 📚 Références

- [Documentation Ansible docker_container](https://docs.ansible.com/ansible/latest/collections/community/docker/docker_container_module.html)
- [Documentation Docker Networks](https://docs.docker.com/network/)
- [Documentation Spring Boot Docker](https://spring.io/guides/gs/spring-boot-docker/)
- [Documentation PostgreSQL Docker](https://hub.docker.com/_/postgres)

---

**Date de création:** 27 octobre 2025  
**Version:** 1.0  
**Auteur:** Documentation générée pour le projet tp-devops

