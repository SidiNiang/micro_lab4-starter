#!/bin/bash

echo "🧹 Nettoyage de l'environnement..."

# Arrêter tous les conteneurs
docker-compose down -v

# Supprimer les volumes si demandé
if [ "$1" == "--volumes" ]; then
    echo "🗑️  Suppression des volumes de données..."
    docker volume rm tp4-microservices-persistence_postgres-events-data 2>/dev/null
    docker volume rm tp4-microservices-persistence_postgres-payments-data 2>/dev/null
    docker volume rm tp4-microservices-persistence_mongo-reservations-data 2>/dev/null
    docker volume rm tp4-microservices-persistence_mongo-event-store-data 2>/dev/null
    docker volume rm tp4-microservices-persistence_mongo-notifications-data 2>/dev/null
    docker volume rm tp4-microservices-persistence_redis-data 2>/dev/null
    docker volume rm tp4-microservices-persistence_elasticsearch-data 2>/dev/null
    docker volume rm tp4-microservices-persistence_rabbitmq-data 2>/dev/null
fi

echo "✅ Nettoyage terminé"
