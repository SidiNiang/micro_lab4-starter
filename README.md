# 🏗️ TP4 - PERSISTANCE DANS LES MICROSERVICES

## 🎯 À propos de ce TP

Ce TP vous permet d'implémenter une **architecture de persistance polyglotte complète** avec tous les patterns essentiels des microservices modernes. Vous allez construire un système distribué avec 7 microservices et 5 technologies de bases de données différentes.

## 🚀 Démarrage Rapide

### 1. Exécuter le script de génération

```bash
# Rendre le script exécutable
chmod +x script.sh

# Générer l'architecture complète
./script.sh
```

### 2. Se déplacer dans le projet généré

```bash
cd tp4-microservices-persistence
```

### 3. Démarrer l'infrastructure

```bash
# Démarrer les bases de données
./scripts/start-dev.sh
```

### 4. Compléter les TODOs

Complétez les exercices dans le code (voir section TODOs ci-dessous)

### 5. Démarrer tous les services

```bash
# Construire et démarrer tous les microservices
docker-compose up -d
```

### 6. Tester le système

```bash
# Lancer les tests automatisés
./scripts/test-system.sh
```

## 🏛️ Architecture Générée

Le script va créer une architecture polyglotte complète avec :

### 📦 **7 Microservices**

| Service               | Technologie      | Base de Données    | Port |
| --------------------- | ---------------- | ------------------ | ---- |
| **Événements**        | Java/Spring Boot | PostgreSQL         | 8080 |
| **Réservations**      | Node.js/Express  | MongoDB            | 3000 |
| **Paiements**         | Python/Flask     | PostgreSQL + Redis | 5000 |
| **Analytics**         | Java/Spring Boot | Elasticsearch      | 8081 |
| **Event Store**       | Node.js/Express  | MongoDB            | 3001 |
| **Saga Orchestrator** | Node.js/Express  | In-Memory          | 3002 |
| **Notifications**     | Python/Flask     | MongoDB            | 5001 |

### 💾 **5 Technologies de Bases de Données**

- **PostgreSQL** : Données relationnelles (événements, paiements)
- **MongoDB** : Documents flexibles (réservations, event store, notifications)
- **Redis** : Cache haute performance (paiements)
- **Elasticsearch** : Recherche et analytics
- **RabbitMQ** : Messaging asynchrone

### 🎯 **Patterns Implémentés**

- ✅ **Database per Service** - Isolation complète des données
- ✅ **Polyglot Persistence** - Technologies adaptées aux besoins
- ✅ **Saga Pattern** - Transactions distribuées avec compensation
- ✅ **CQRS + Event Sourcing** - Séparation lecture/écriture + audit trail
- ✅ **Cohérence éventuelle** - Réplication et synchronisation

## 📝 TODOs à Compléter

Le script génère **15 exercices pratiques** répartis par pattern :

### 🗄️ Database per Service (4 TODOs)

- **TODO-DB1** : Validation métier de réservation (Java)
- **TODO-DB2** : Réservation atomique avec optimistic locking (Java)
- **TODO-DB3** : Statistiques avec agrégation MongoDB (Node.js)
- **TODO-DB4** : Middleware timeline automatique (Node.js)

### 🔄 Polyglot Persistence (5 TODOs)

- **TODO-POLY1** : Gestionnaire cache Redis (Python)
- **TODO-POLY2** : Cache des données de paiement (Python)
- **TODO-POLY3** : Pattern Cache-Aside (Python)
- **TODO-POLY4** : Calcul de métriques Elasticsearch (Java)
- **TODO-POLY5** : Mise à jour temps réel (Java)

### 🎭 Saga Pattern (4 TODOs)

- **TODO-SAGA1** : Initialisation et orchestration du Saga (Node.js)
- **TODO-SAGA2** : Étape de réservation distribuée (Node.js)
- **TODO-SAGA3** : Étape de paiement distribuée (Node.js)
- **TODO-SAGA4** : Compensations automatiques (Node.js)

### 📚 Event Sourcing (3 TODOs)

- **TODO-ES1** : Reconstruction d'historique d'agrégat (Node.js)
- **TODO-ES2** : Requêtes par type d'événement (Node.js)
- **TODO-ES3** : Validation de cohérence de version (Node.js)

### 🌐 API REST (1 TODO)

- **TODO-REST1** : Endpoint de réservation RESTful (Java)

## 🧪 Tests et Validation

Une fois les TODOs complétés, vous pouvez valider votre travail :

### Tests Automatisés

```bash
./scripts/test-system.sh
```

### Tests Manuels

```bash
# Tester chaque service individuellement
curl http://localhost:8080/api/events      # Service Événements
curl http://localhost:3000/api/reservations # Service Réservations
curl http://localhost:5000/api/payments    # Service Paiements
curl http://localhost:8081/api/analytics   # Service Analytics
curl http://localhost:3001/api/events      # Event Store
curl http://localhost:3002/api/saga        # Saga Orchestrator
```

### Interfaces d'Administration

- **RabbitMQ Management** : http://localhost:15672 (guest/guest)
- **Elasticsearch** : http://localhost:9200
- **MongoDB** : `docker exec -it mongo-reservations mongosh`
- **PostgreSQL** : `docker exec -it postgres-events psql -U events_user -d events_db`
- **Redis** : `docker exec -it redis-cache redis-cli`

## 📚 Structure Générée

Après exécution du script, vous obtiendrez :

```
tp4-microservices-persistence/
├── event-service/          # Java/Spring Boot + PostgreSQL
├── reservation-service/    # Node.js + MongoDB
├── payment-service/        # Python/Flask + PostgreSQL + Redis
├── analytics-service/      # Java/Spring Boot + Elasticsearch
├── event-store-service/    # Node.js + MongoDB (Event Sourcing)
├── saga-orchestrator/      # Node.js (Transactions distribuées)
├── notification-service/   # Python/Flask + MongoDB
├── scripts/               # Scripts utilitaires
├── docker-compose.yml     # Orchestration complète
└── README.md             # Documentation détaillée
```

## 🏆 Objectifs Pédagogiques

À la fin de ce TP, vous maîtriserez :

✅ **L'isolation des données** avec Database per Service  
✅ **Le choix technologique** avec Polyglot Persistence  
✅ **Les transactions distribuées** avec le pattern Saga  
✅ **L'audit trail complet** avec Event Sourcing  
✅ **La performance optimisée** avec cache et recherche spécialisée  
✅ **La cohérence dans la distribution** avec compensation automatique

## 🔧 Prérequis

Avant d'exécuter le script, assurez-vous d'avoir :

- **Docker** et **Docker Compose**
- **Node.js 18+**
- **Python 3.9+**
- **Java 17+**
- **Git**

## 📖 Documentation

Une fois le projet généré, consultez le `README.md` détaillé dans le dossier `tp4-microservices-persistence/` pour :

- Instructions détaillées de chaque TODO
- Exemples de solutions
- Guide de dépannage complet
- Ressources d'approfondissement

## 🆘 Support

En cas de problème :

1. **Vérifiez les prérequis** listés ci-dessus
2. **Consultez les logs** : `docker-compose logs [service-name]`
3. **Redémarrez proprement** : `./scripts/cleanup.sh` puis recommencez

## 🎓 Contexte Académique

**TP4 - Architectures Logicielles Modernes**  
Dr. El Hadji Bassirou TOURE  
Département de Mathématiques et Informatique  
Faculté des Sciences et Techniques  
Université Cheikh Anta Diop

---

🚀 **Prêt à découvrir la persistance distribuée ? Exécutez `./script.sh` !**
