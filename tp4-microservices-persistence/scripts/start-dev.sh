#!/bin/bash

echo "🚀 Démarrage de l'infrastructure de développement..."

# Démarrer uniquement les bases de données et l'infrastructure
docker-compose up -d \
  postgres-events \
  postgres-payments \
  mongo-reservations \
  mongo-event-store \
  mongo-notifications \
  redis-cache \
  elasticsearch \
  rabbitmq

echo "⏳ Attente du démarrage des services (30s)..."
sleep 30

echo "✅ Infrastructure prête !"
echo ""
echo "📊 Services disponibles :"
echo "   - PostgreSQL Events: localhost:5432"
echo "   - PostgreSQL Payments: localhost:5433"
echo "   - MongoDB Reservations: localhost:27017"
echo "   - MongoDB Event Store: localhost:27018"
echo "   - MongoDB Notifications: localhost:27019"
echo "   - Redis Cache: localhost:6379"
echo "   - Elasticsearch: localhost:9200"
echo "   - RabbitMQ: localhost:5672 (Management: localhost:15672)"
