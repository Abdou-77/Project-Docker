# 🚀 Guide de Déploiement des 3 Conteneurs sur le Cloud

## ❌ Problème Actuel

La connexion SSH au serveur `abdellah.sofi1.takima.cloud` échoue avec "Permission denied (publickey)".

**Cause**: La clé SSH publique n'est pas autorisée sur le serveur cloud.

---

## ✅ Solution: Deux Options

### Option 1: Ajouter la Clé SSH via la Console Cloud (RECOMMANDÉ)

1. **Afficher votre clé publique**:
   ```bash
   cat ~/.ssh/abdellah_takima.pub
   ```
   
2. **Copier la clé publique dans le presse-papier**:
   ```bash
   cat ~/.ssh/abdellah_takima.pub | pbcopy
   ```

3. **Accéder à la console de votre fournisseur cloud** (AWS, Takima Cloud, etc.)

4. **Ajouter la clé publique aux clés SSH autorisées** pour votre serveur

5. **Redémarrer le serveur** si nécessaire

6. **Tester la connexion**:
   ```bash
   ssh -i ~/.ssh/abdellah_takima admin@abdellah.sofi1.takima.cloud "echo 'Connexion réussie!'"
   ```

---

### Option 2: Déploiement Manuel Direct sur le Serveur

Si vous avez accès à la console du serveur (interface web ou terminal direct), connectez-vous et exécutez ces commandes:

```bash
# 1. Créer le réseau Docker
docker network create app-network 2>/dev/null || echo "Network déjà existant"

# 2. Arrêter et supprimer les anciens conteneurs
docker stop database backend httpd 2>/dev/null || true
docker rm database backend httpd 2>/dev/null || true

# 3. Démarrer la base de données
docker run -d \
  --name database \
  --network app-network \
  -e POSTGRES_DB=db \
  -e POSTGRES_USER=usr \
  -e POSTGRES_PASSWORD=pwd \
  -v db-data:/var/lib/postgresql/data \
  --restart always \
  abdou775/tp-devops-simple-api-database:latest

# 4. Attendre que la base de données soit prête
echo "⏳ Attente de la base de données (10 secondes)..."
sleep 10

# 5. Démarrer le backend
docker run -d \
  --name backend \
  --network app-network \
  -p 8080:8080 \
  -e SPRING_DATASOURCE_URL=jdbc:postgresql://database:5432/db \
  -e SPRING_DATASOURCE_USERNAME=usr \
  -e SPRING_DATASOURCE_PASSWORD=pwd \
  --restart always \
  abdou775/tp-devops-simple-api-backend:latest

# 6. Démarrer le proxy HTTPD
docker run -d \
  --name httpd \
  --network app-network \
  -p 80:80 \
  --restart always \
  abdou775/tp-devops-simple-api-httpd:latest

# 7. Vérifier que tous les conteneurs sont actifs
echo ""
echo "📦 Conteneurs actifs:"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# 8. Attendre le démarrage du backend
echo ""
echo "⏳ Attente du démarrage du backend (30 secondes)..."
sleep 30

# 9. Tester l'API
echo ""
echo "🔍 Tests de l'API:"
echo ""
echo "Health Check:"
curl -s http://localhost:8080/actuator/health
echo -e "\n"

echo "Departments:"
curl -s http://localhost:8080/departments
echo -e "\n"

echo "Students:"
curl -s http://localhost:8080/students
echo -e "\n"
```

---

## 🧪 Tests Après Déploiement

Une fois les conteneurs déployés, testez l'API depuis votre machine locale:

```bash
# Health Check
curl http://abdellah.sofi1.takima.cloud:8080/actuator/health

# Liste des départements
curl http://abdellah.sofi1.takima.cloud:8080/departments

# Liste des étudiants
curl http://abdellah.sofi1.takima.cloud:8080/students

# Via le proxy HTTPD (port 80)
curl http://abdellah.sofi1.takima.cloud/
```

---

## 📋 État Actuel

✅ **Images Docker construites et poussées sur Docker Hub**:
- `abdou775/tp-devops-simple-api-database:latest`
- `abdou775/tp-devops-simple-api-backend:latest`
- `abdou775/tp-devops-simple-api-httpd:latest`

❌ **Connexion SSH au serveur**: Bloquée (clé SSH non autorisée)

---

## 🔧 Prochaines Étapes

1. **Résoudre le problème SSH** (Option 1 ci-dessus)
2. **Ou déployer manuellement** (Option 2 ci-dessus)
3. **Tester l'API** avec les commandes curl
4. **Configurer le déploiement continu** dans GitHub Actions

---

## 📞 Besoin d'Aide?

Si le problème persiste:
1. Vérifiez que le serveur cloud est bien démarré
2. Vérifiez les règles de pare-feu (ports 22, 80, 8080 doivent être ouverts)
3. Contactez votre administrateur cloud pour ajouter votre clé SSH

