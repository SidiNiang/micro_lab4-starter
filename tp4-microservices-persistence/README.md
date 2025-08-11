
# 🏗️ TP4 - PERSISTANCE DANS LES MICROSERVICES

## 🎯 Vue d'ensemble

Cette architecture implémente une plateforme complète de gestion d'événements avec **7 microservices** utilisant **5 technologies de bases de données différentes**, démontrant les patterns essentiels de persistance distribuée.

## 🏛️ Architecture Polyglotte

### Services et leurs bases de données

| Service | Technologie | Base de Données | Port | Rôle |
|---------|-------------|-----------------|------|------|
| **Event Service** | Java/Spring Boot | PostgreSQL | 8080 | Gestion des événements (ACID) |
| **Reservation Service** | Node.js/Express | MongoDB | 3000 | Réservations flexibles (NoSQL) |
| **Payment Service** | Python/Flask | PostgreSQL + Redis | 5000 | Transactions + Cache |
| **Analytics Service** | Java/Spring Boot | Elasticsearch | 8081 | Recherche et analytics |
| **Event Store** | Node.js/Express | MongoDB | 3001 | Event Sourcing |
| **Saga Orchestrator** | Node.js/Express | In-Memory | 3002 | Transactions distribuées |
| **Notification Service** | Python/Flask | MongoDB | 5001 | Gestion des notifications |

## 🚀 Démarrage rapide

### 1. Démarrer l'infrastructure

```bash
cd scripts
./start-dev.sh

### 2. Compléter les TODOs

Le code contient **15 exercices pratiques** répartis par pattern :

#### Database per Service (4 TODOs)
- **TODO-DB1**: Validation métier de réservation
- **TODO-DB2**: Réservation atomique avec optimistic locking  
- **TODO-DB3**: Statistiques avec agrégation MongoDB
- **TODO-DB4**: Middleware timeline automatique

#### Polyglot Persistence (5 TODOs)
- **TODO-POLY1**: Gestionnaire cache Redis
- **TODO-POLY2**: Cache des données de paiement
- **TODO-POLY3**: Pattern Cache-Aside
- **TODO-POLY4**: Calcul de métriques Elasticsearch
- **TODO-POLY5**: Mise à jour temps réel

#### Saga Pattern (4 TODOs)
- **TODO-SAGA1**: Initialisation et orchestration du Saga
- **TODO-SAGA2**: Étape de réservation distribuée
- **TODO-SAGA3**: Étape de paiement distribuée
- **TODO-SAGA4**: Compensations automatiques

#### Event Sourcing (3 TODOs)
- **TODO-ES1**: Reconstruction d'historique d'agrégat
- **TODO-ES2**: Requêtes par type d'événement
- **TODO-ES3**: Validation de cohérence de version

#### API REST (1 TODO)
- **TODO-REST1**: Endpoint de réservation RESTful

### 3. Construire et démarrer les services

```bash
docker-compose up -d
```

### 4. Tester le système

```bash
cd scripts
./test-system.sh
```

## 📊 Patterns implémentés

### 1. Database per Service
Chaque microservice possède sa propre base de données, garantissant :
- Isolation complète des données
- Évolution indépendante des schémas
- Scaling individuel
- Pas de couplage par la base de données

### 2. Polyglot Persistence
Utilisation de la technologie de BD optimale pour chaque cas :
- **PostgreSQL** : Transactions ACID (événements, paiements)
- **MongoDB** : Documents flexibles (réservations, notifications)
- **Redis** : Cache haute performance
- **Elasticsearch** : Recherche full-text et analytics

### 3. Saga Pattern
Gestion des transactions distribuées sans 2PC :
- Orchestration centralisée
- Compensations automatiques en cas d'échec
- Traçabilité complète des étapes
- Idempotence des opérations

### 4. Event Sourcing & CQRS
Capture de tous les changements comme événements :
- Audit trail complet
- Reconstruction d'état à tout moment
- Séparation lecture/écriture
- Time travel queries

## 🧪 Scénarios de test

### Scénario 1 : Réservation complète réussie
```bash
# 1. Créer un événement
curl -X POST http://localhost:8080/api/events \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Concert Jazz",
    "eventDate": "2025-12-25T20:00:00",
    "location": "Dakar Arena",
    "totalCapacity": 100,
    "ticketPrice": 50
  }'

# 2. Démarrer le processus de réservation via Saga
curl -X POST http://localhost:3002/api/saga/booking \
  -H "Content-Type: application/json" \
  -d '{
    "eventId": 1,
    "userId": "user123",
    "userName": "John Doe",
    "userEmail": "john@example.com",
    "seats": 2,
    "ticketPrice": 50,
    "paymentMethod": "card"
  }'
```

### Scénario 2 : Recherche et analytics
```bash
# Rechercher des événements
curl http://localhost:8081/api/analytics/search?location=Dakar

# Voir les événements à forte occupation
curl http://localhost:8081/api/analytics/high-occupancy?minRate=80
```

### Scénario 3 : Event Sourcing
```bash
# Voir l'historique d'un agrégat
curl http://localhost:3001/api/aggregates/RESERVATION-123/history

# Reconstruire l'état à un moment donné
curl http://localhost:3001/api/aggregates/RESERVATION-123/reconstruct?toVersion=5
```

## 📈 Monitoring et administration

### Interfaces d'administration
- **RabbitMQ Management**: http://localhost:15672 (guest/guest)
- **Elasticsearch**: http://localhost:9200
- **MongoDB**: `docker exec -it mongo-reservations mongosh`
- **PostgreSQL**: `docker exec -it postgres-events psql -U events_user -d events_db`
- **Redis**: `docker exec -it redis-cache redis-cli`

### Logs des services
```bash
# Voir les logs d'un service spécifique
docker-compose logs -f event-service

# Voir tous les logs
docker-compose logs -f
```

## 🔧 Développement

### Structure du projet
```
tp4-microservices-persistence/
├── event-service/          # Java/Spring Boot
├── reservation-service/    # Node.js/Express
├── payment-service/        # Python/Flask
├── analytics-service/      # Java/Spring Boot
├── event-store-service/    # Node.js/Express
├── saga-orchestrator/      # Node.js/Express
├── notification-service/   # Python/Flask
├── scripts/               # Scripts utilitaires
├── docker-compose.yml     # Orchestration
└── README.md             # Ce fichier
```

### Lancer un service en mode développement
```bash
# Service Java
cd event-service
./gradlew bootRun

# Service Node.js
cd reservation-service
npm install
npm run dev

# Service Python
cd payment-service
pip install -r requirements.txt
python app.py
```

## 🐛 Dépannage

### Problème de connexion aux bases de données
```bash
# Vérifier que les conteneurs sont bien démarrés
docker ps

# Redémarrer un service spécifique
docker-compose restart postgres-events
```

### Nettoyer l'environnement
```bash
# Arrêter tous les services
docker-compose down

# Nettoyer complètement (y compris les volumes)
./scripts/cleanup.sh --volumes
```

## 📚 Ressources

- [Database per Service Pattern](https://microservices.io/patterns/data/database-per-service.html)
- [Saga Pattern](https://microservices.io/patterns/data/saga.html)
- [Event Sourcing](https://martinfowler.com/eaaDev/EventSourcing.html)
- [CQRS](https://martinfowler.com/bliki/CQRS.html)

## 🎓 Contexte académique

**TP4 - Architectures Logicielles Modernes**  
Dr. El Hadji Bassirou TOURE  
Département de Mathématiques et Informatique  
Faculté des Sciences et Techniques  
Université Cheikh Anta Diop

---

🚀 **Bon apprentissage de la persistance distribuée !**
