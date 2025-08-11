#!/bin/bash

echo "🧪 Test du système complet..."
echo ""

# Couleurs pour les résultats
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Fonction de test
test_service() {
    local service_name=$1
    local url=$2
    
    echo -n "Testing $service_name... "
    
    if curl -s -f "$url" > /dev/null 2>&1; then
        echo -e "${GREEN}✓ OK${NC}"
        return 0
    else
        echo -e "${RED}✗ FAILED${NC}"
        return 1
    fi
}

# Test des services
echo "📊 Test des services :"
test_service "Event Service" "http://localhost:8080/api/events"
test_service "Reservation Service" "http://localhost:3000/health"
test_service "Payment Service" "http://localhost:5000/health"
test_service "Analytics Service" "http://localhost:8081/api/analytics"
test_service "Event Store Service" "http://localhost:3001/health"
test_service "Saga Orchestrator" "http://localhost:3002/health"
test_service "Notification Service" "http://localhost:5001/health"

echo ""
echo "📡 Test des bases de données :"
test_service "PostgreSQL Events" "http://localhost:5432"
test_service "MongoDB Reservations" "http://localhost:27017"
test_service "Redis Cache" "http://localhost:6379"
test_service "Elasticsearch" "http://localhost:9200"
test_service "RabbitMQ Management" "http://localhost:15672"

echo ""
echo "✅ Tests terminés"
