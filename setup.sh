#!/bin/bash

# =============================================================================
# TP4 - PERSISTANCE DANS LES MICROSERVICES - SCRIPT COMPLET CORRIGÉ
# Script de création d'une architecture polyglotte complète
# 
# Patterns implémentés :
# ✅ Database per Service (isolation des données)
# ✅ Polyglot Persistence (PostgreSQL, MongoDB, Redis, Elasticsearch)  
# ✅ Saga Pattern (transactions distribuées)
# ✅ CQRS + Event Sourcing (séparation lecture/écriture)
# ✅ Cohérence éventuelle (réplication de données)
# 
# Total TODOs : 31 exercices pratiques
# 
# Auteur: Dr. El Hadji Bassirou TOURE
# Université: DMI/FST/UCAD
# =============================================================================

set -e  # Arrête le script en cas d'erreur

echo ""
echo "🏗️  TP4 - PERSISTANCE DANS LES MICROSERVICES"
echo "============================================="
echo ""
echo "🎯 Ce TP vous fera implémenter une architecture polyglotte complète avec :"
echo "   📊 Database per Service (chaque service a sa BD)"
echo "   🔄 Polyglot Persistence (5 technologies de BD différentes)"
echo "   🔗 Saga Pattern (transactions distribuées robustes)"
echo "   📝 CQRS + Event Sourcing (audit trail complet)"
echo "   🔄 Cohérence éventuelle (réplication intelligente)"
echo ""
echo "📚 31 exercices pratiques (TODOs) à compléter"
echo ""

# =============================================================================
# VÉRIFICATION DES PRÉREQUIS
# =============================================================================

check_dependencies() {
    echo "🔍 Vérification des prérequis..."
    
    local missing_deps=()
    
    if ! command -v docker &> /dev/null; then
        missing_deps+=("docker")
    fi
    
    if ! command -v docker-compose &> /dev/null; then
        missing_deps+=("docker-compose")
    fi
    
    if ! command -v node &> /dev/null; then
        missing_deps+=("node (Node.js 18+)")
    fi
    
    if ! command -v npm &> /dev/null; then
        missing_deps+=("npm")
    fi
    
    if ! command -v python3 &> /dev/null; then
        missing_deps+=("python3 (Python 3.9+)")
    fi
    
    if ! command -v java &> /dev/null; then
        missing_deps+=("java (JDK 17+)")
    fi
    
    if [ ${#missing_deps[@]} -ne 0 ]; then
        echo "❌ Dépendances manquantes :"
        for dep in "${missing_deps[@]}"; do
            echo "   - $dep"
        done
        echo ""
        echo "📋 Installez les dépendances manquantes et relancez le script."
        exit 1
    fi
    
    echo "✅ Tous les prérequis sont installés"
    echo ""
}

# =============================================================================
# CRÉATION DE LA STRUCTURE DU PROJET
# =============================================================================

create_project_structure() {
    echo "📁 Création de la structure du projet..."
    
    # Structure principale simplifiée
    mkdir -p tp4-microservices-persistence/{event-service,reservation-service,payment-service,analytics-service,event-store-service,saga-orchestrator,notification-service,scripts}
    
    echo "✅ Structure du projet créée"
}

# =============================================================================
# SERVICE ÉVÉNEMENTS (Java/Spring Boot + PostgreSQL)
# Database per Service avec validation métier
# =============================================================================

create_event_service() {
    echo "📦 Service Événements (Java/Spring Boot + PostgreSQL)..."
    
    cd tp4-microservices-persistence/event-service
    
    # Créer les répertoires nécessaires
    mkdir -p src/main/{java/com/fst/dmi/eventservice/{controller,service,model,repository,config},resources}
    
    # build.gradle
    cat > build.gradle << 'EOF'
plugins {
    id 'org.springframework.boot' version '3.2.0'
    id 'io.spring.dependency-management' version '1.1.4'
    id 'java'
}

group = 'com.fst.dmi'
version = '0.0.1-SNAPSHOT'
sourceCompatibility = '17'

repositories {
    mavenCentral()
}

dependencies {
    implementation 'org.springframework.boot:spring-boot-starter-data-jpa'
    implementation 'org.springframework.boot:spring-boot-starter-web'
    implementation 'org.springframework.boot:spring-boot-starter-validation'
    implementation 'org.springframework.boot:spring-boot-starter-amqp'
    runtimeOnly 'org.postgresql:postgresql'
    testImplementation 'org.springframework.boot:spring-boot-starter-test'
}

test {
    useJUnitPlatform()
}
EOF

    # settings.gradle
    echo "rootProject.name = 'event-service'" > settings.gradle

    # gradle.properties
    cat > gradle.properties << 'EOF'
org.gradle.daemon=false
org.gradle.parallel=true
org.gradle.caching=true
EOF

    # Configuration
    cat > src/main/resources/application.yml << 'EOF'
spring:
  datasource:
    url: jdbc:postgresql://${POSTGRES_HOST:localhost}:${POSTGRES_PORT:5432}/${POSTGRES_DB:events_db}
    username: ${POSTGRES_USER:events_user}
    password: ${POSTGRES_PASSWORD:events_password}
    driver-class-name: org.postgresql.Driver
  
  jpa:
    hibernate:
      ddl-auto: update
    show-sql: true
    properties:
      hibernate:
        dialect: org.hibernate.dialect.PostgreSQLDialect
        format_sql: true
        
  rabbitmq:
    host: ${RABBITMQ_HOST:localhost}
    port: ${RABBITMQ_PORT:5672}
    username: ${RABBITMQ_USER:guest}
    password: ${RABBITMQ_PASSWORD:guest}

server:
  port: 8080

logging:
  level:
    com.fst.dmi.eventservice: DEBUG
EOF

    # Application principale
    cat > src/main/java/com/fst/dmi/eventservice/EventServiceApplication.java << 'EOF'
package com.fst.dmi.eventservice;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class EventServiceApplication {
    public static void main(String[] args) {
        SpringApplication.run(EventServiceApplication.class, args);
    }
}
EOF

    # Modèle Event avec TODOs
    cat > src/main/java/com/fst/dmi/eventservice/model/Event.java << 'EOF'
package com.fst.dmi.eventservice.model;

import jakarta.persistence.*;
import jakarta.validation.constraints.*;
import java.time.LocalDateTime;
import java.math.BigDecimal;

/**
 * Entité Event - Démontre le pattern Database per Service
 * 
 * Cette classe illustre :
 * - L'isolation des données (seul ce service accède à cette table)
 * - Les contraintes d'intégrité relationnelle 
 * - La validation métier au niveau du domaine
 * - L'optimistic locking avec @Version
 */
@Entity
@Table(name = "events", indexes = {
    @Index(name = "idx_event_date", columnList = "event_date"),
    @Index(name = "idx_event_location", columnList = "location")
})
public class Event {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, length = 255)
    @NotBlank(message = "Event name is required")
    private String name;
    
    @Column(columnDefinition = "TEXT")
    private String description;
    
    @Column(name = "event_date", nullable = false)
    @NotNull(message = "Event date is required")
    @Future(message = "Event date must be in the future")
    private LocalDateTime eventDate;
    
    @Column(nullable = false)
    @NotBlank(message = "Location is required")
    private String location;
    
    @Column(name = "total_capacity", nullable = false)
    @Min(value = 1, message = "Total capacity must be at least 1")
    private Integer totalCapacity;
    
    @Column(name = "booked_seats", nullable = false)
    @Min(value = 0, message = "Booked seats cannot be negative")
    private Integer bookedSeats = 0;
    
    @Column(name = "ticket_price", precision = 10, scale = 2)
    private BigDecimal ticketPrice;
    
    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt;
    
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
    
    @Version
    private Long version;

    // =========================================================================
    // TODO-DB1: Implémentez la méthode de validation métier pour la réservation
    // =========================================================================
    /**
     * Cette méthode doit vérifier si le nombre de places demandées est disponible
     * et respecter les règles métier (ex: pas de sur-réservation, marge de sécurité).
     * 
     * Règles à implémenter :
     * 1. Vérifier que requestedSeats > 0
     * 2. Calculer les places disponibles avec une marge de sécurité de 5%
     * 3. Vérifier qu'il y a suffisamment de places
     * 
     * @param requestedSeats nombre de places demandées
     * @return true si la réservation est possible, false sinon
     */
    public boolean canBookSeats(int requestedSeats) {
        // ⚠️  TODO: À implémenter par les étudiants
        
        // Exemple de solution :
        // if (requestedSeats <= 0) return false;
        // int safetyMargin = (int) Math.ceil(totalCapacity * 0.05);
        // int availableSeats = totalCapacity - bookedSeats - safetyMargin;
        // return availableSeats >= requestedSeats;
        
        return false; // Placeholder - à remplacer
    }

    // =========================================================================
    // TODO-DB2: Implémentez la méthode de réservation atomique
    // =========================================================================
    /**
     * Cette méthode doit réserver les places de façon thread-safe
     * et retourner true si la réservation a réussi.
     * 
     * Utilise l'optimistic locking (@Version) pour la concurrence.
     * 
     * @param seats nombre de places à réserver
     * @return true si la réservation a réussi, false sinon
     */
    public boolean bookSeats(int seats) {
        // ⚠️  TODO: À implémenter par les étudiants
        
        // Exemple de solution :
        // if (!canBookSeats(seats)) return false;
        // this.bookedSeats += seats;
        // return true;
        
        return false; // Placeholder - à remplacer
    }

    // Getters et setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    
    public LocalDateTime getEventDate() { return eventDate; }
    public void setEventDate(LocalDateTime eventDate) { this.eventDate = eventDate; }
    
    public String getLocation() { return location; }
    public void setLocation(String location) { this.location = location; }
    
    public Integer getTotalCapacity() { return totalCapacity; }
    public void setTotalCapacity(Integer totalCapacity) { this.totalCapacity = totalCapacity; }
    
    public Integer getBookedSeats() { return bookedSeats; }
    public void setBookedSeats(Integer bookedSeats) { this.bookedSeats = bookedSeats; }
    
    public BigDecimal getTicketPrice() { return ticketPrice; }
    public void setTicketPrice(BigDecimal ticketPrice) { this.ticketPrice = ticketPrice; }
    
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
    
    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }
    
    public Long getVersion() { return version; }
    public void setVersion(Long version) { this.version = version; }
    
    // Méthodes utilitaires
    public int getAvailableSeats() {
        return totalCapacity - bookedSeats;
    }
    
    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
    }
    
    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }
}
EOF

    # Repository
    cat > src/main/java/com/fst/dmi/eventservice/repository/EventRepository.java << 'EOF'
package com.fst.dmi.eventservice.repository;

import com.fst.dmi.eventservice.model.Event;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;
import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface EventRepository extends JpaRepository<Event, Long> {
    
    List<Event> findByEventDateAfter(LocalDateTime date);
    
    List<Event> findByLocationContainingIgnoreCase(String location);
    
    @Query("SELECT e FROM Event e WHERE e.eventDate > :now AND e.totalCapacity > e.bookedSeats")
    List<Event> findAvailableEvents(LocalDateTime now);
    
    @Query("SELECT e FROM Event e WHERE e.eventDate BETWEEN :start AND :end")
    List<Event> findEventsBetween(LocalDateTime start, LocalDateTime end);
}
EOF

    # Service
    cat > src/main/java/com/fst/dmi/eventservice/service/EventService.java << 'EOF'
package com.fst.dmi.eventservice.service;

import com.fst.dmi.eventservice.model.Event;
import com.fst.dmi.eventservice.repository.EventRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Service
@Transactional
public class EventService {

    private final EventRepository eventRepository;

    @Autowired
    public EventService(EventRepository eventRepository) {
        this.eventRepository = eventRepository;
    }

    public List<Event> getAllEvents() {
        return eventRepository.findAll();
    }

    public Optional<Event> getEventById(Long id) {
        return eventRepository.findById(id);
    }

    public Event createEvent(Event event) {
        return eventRepository.save(event);
    }

    public Event updateEvent(Long id, Event eventDetails) {
        return eventRepository.findById(id)
            .map(event -> {
                event.setName(eventDetails.getName());
                event.setDescription(eventDetails.getDescription());
                event.setEventDate(eventDetails.getEventDate());
                event.setLocation(eventDetails.getLocation());
                event.setTotalCapacity(eventDetails.getTotalCapacity());
                event.setTicketPrice(eventDetails.getTicketPrice());
                return eventRepository.save(event);
            })
            .orElseThrow(() -> new RuntimeException("Event not found with id: " + id));
    }

    public void deleteEvent(Long id) {
        eventRepository.deleteById(id);
    }

    public List<Event> getAvailableEvents() {
        return eventRepository.findAvailableEvents(LocalDateTime.now());
    }

    public boolean bookEventSeats(Long eventId, int seats) {
        return eventRepository.findById(eventId)
            .map(event -> {
                if (event.bookSeats(seats)) {
                    eventRepository.save(event);
                    return true;
                }
                return false;
            })
            .orElse(false);
    }

    public boolean releaseSeats(Long eventId, int seats) {
        return eventRepository.findById(eventId)
            .map(event -> {
                int newBookedSeats = Math.max(0, event.getBookedSeats() - seats);
                event.setBookedSeats(newBookedSeats);
                eventRepository.save(event);
                return true;
            })
            .orElse(false);
    }
}
EOF

    # Controller avec TODO
    cat > src/main/java/com/fst/dmi/eventservice/controller/EventController.java << 'EOF'
package com.fst.dmi.eventservice.controller;

import com.fst.dmi.eventservice.model.Event;
import com.fst.dmi.eventservice.service.EventService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/events")
@CrossOrigin(origins = "*")
public class EventController {

    private final EventService eventService;

    @Autowired
    public EventController(EventService eventService) {
        this.eventService = eventService;
    }

    @GetMapping
    public List<Event> getAllEvents() {
        return eventService.getAllEvents();
    }

    @GetMapping("/{id}")
    public ResponseEntity<Event> getEventById(@PathVariable Long id) {
        return eventService.getEventById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    public Event createEvent(@RequestBody Event event) {
        return eventService.createEvent(event);
    }

    @PutMapping("/{id}")
    public ResponseEntity<Event> updateEvent(@PathVariable Long id, @RequestBody Event eventDetails) {
        try {
            Event updatedEvent = eventService.updateEvent(id, eventDetails);
            return ResponseEntity.ok(updatedEvent);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteEvent(@PathVariable Long id) {
        eventService.deleteEvent(id);
        return ResponseEntity.ok().build();
    }

    @GetMapping("/available")
    public List<Event> getAvailableEvents() {
        return eventService.getAvailableEvents();
    }

    // =========================================================================
    // TODO-REST1: Implémentez l'endpoint pour la réservation de places
    // =========================================================================
    /**
     * Cet endpoint doit recevoir une requête POST avec le nombre de places à réserver.
     * Il doit appeler eventService.bookEventSeats et retourner une réponse appropriée.
     * 
     * Format attendu: {"seats": 5}
     * Réponse succès: {"success": true, "message": "...", "eventId": 1, "seatsBooked": 5}
     * Réponse échec: {"error": "...", "reason": "..."}
     */
    @PostMapping("/{id}/book")
    public ResponseEntity<?> bookEventSeats(@PathVariable Long id, @RequestBody Map<String, Integer> bookingRequest) {
        // ⚠️  TODO: À implémenter par les étudiants
        
        // Exemple de solution :
        // Integer seats = bookingRequest.get("seats");
        // if (seats == null || seats <= 0) {
        //     return ResponseEntity.badRequest()
        //             .body(Map.of("error", "Invalid number of seats"));
        // }
        // 
        // boolean booked = eventService.bookEventSeats(id, seats);
        // if (booked) {
        //     return ResponseEntity.ok(Map.of(
        //             "success", true,
        //             "message", "Successfully booked " + seats + " seats",
        //             "eventId", id,
        //             "seatsBooked", seats
        //     ));
        // } else {
        //     return ResponseEntity.badRequest()
        //             .body(Map.of("error", "Could not book seats. Not enough availability."));
        // }
        
        return ResponseEntity.badRequest().body(Map.of("error", "Not implemented yet"));
    }

    @PostMapping("/{id}/release")
    public ResponseEntity<?> releaseEventSeats(@PathVariable Long id, @RequestBody Map<String, Integer> releaseRequest) {
        Integer seats = releaseRequest.get("seats");
        if (seats == null || seats <= 0) {
            return ResponseEntity.badRequest()
                    .body(Map.of("error", "Invalid number of seats to release"));
        }

        boolean released = eventService.releaseSeats(id, seats);
        if (released) {
            return ResponseEntity.ok(Map.of(
                    "message", "Successfully released " + seats + " seats",
                    "eventId", id,
                    "seatsReleased", seats
            ));
        } else {
            return ResponseEntity.badRequest()
                    .body(Map.of("error", "Could not release seats. Event might not exist."));
        }
    }
}
EOF

    # Dockerfile
    cat > Dockerfile << 'EOF'
FROM openjdk:17-jdk-slim

# Installer Gradle
RUN apt-get update && apt-get install -y wget unzip && \
    wget https://services.gradle.org/distributions/gradle-8.4-bin.zip && \
    unzip gradle-8.4-bin.zip && \
    mv gradle-8.4 /opt/gradle && \
    ln -s /opt/gradle/bin/gradle /usr/bin/gradle && \
    rm gradle-8.4-bin.zip && \
    apt-get clean

WORKDIR /app

# Copier les fichiers de build
COPY build.gradle .
COPY settings.gradle .
COPY gradle.properties .

# Télécharger les dépendances
RUN gradle build -x test --no-daemon || return 0

# Copier le code source
COPY src src

# Construire l'application
RUN gradle clean build -x test --no-daemon

EXPOSE 8080

CMD ["java", "-jar", "build/libs/event-service-0.0.1-SNAPSHOT.jar"]
EOF

    cd ../..
    echo "✅ Service Événements créé (PostgreSQL + Database per Service)"
}

# =============================================================================
# SERVICE RÉSERVATIONS (Node.js + MongoDB)
# Polyglot Persistence avec documents flexibles
# =============================================================================

create_reservation_service() {
    echo "📦 Service Réservations (Node.js + MongoDB)..."
    
    cd tp4-microservices-persistence/reservation-service
    
    # Créer les répertoires nécessaires
    mkdir -p src/{controllers,services,models,config,utils,handlers,compensations}
    mkdir -p test
    
    # package.json
    cat > package.json << 'EOF'
{
  "name": "reservation-service",
  "version": "1.0.0",
  "description": "Service de réservations avec MongoDB - Polyglot Persistence",
  "main": "src/app.js",
  "scripts": {
    "start": "node src/app.js",
    "dev": "nodemon src/app.js",
    "test": "jest"
  },
  "dependencies": {
    "express": "^4.18.2",
    "mongoose": "^8.0.3",
    "cors": "^2.8.5",
    "helmet": "^7.1.0",
    "morgan": "^1.10.0",
    "dotenv": "^16.3.1",
    "axios": "^1.6.2",
    "amqplib": "^0.10.3",
    "uuid": "^9.0.1",
    "joi": "^17.11.0"
  },
  "devDependencies": {
    "nodemon": "^3.0.2",
    "jest": "^29.7.0"
  }
}
EOF

    # Configuration base
    cat > src/config/database.js << 'EOF'
const mongoose = require('mongoose');

const MONGODB_URI = process.env.MONGODB_URI || 
  'mongodb://localhost:27017/reservations_db';

const connectDB = async () => {
  try {
    const conn = await mongoose.connect(MONGODB_URI, {
      useNewUrlParser: true,
      useUnifiedTopology: true,
      maxPoolSize: 10,
      serverSelectionTimeoutMS: 5000,
      socketTimeoutMS: 45000,
    });

    console.log(`✅ MongoDB Connected: ${conn.connection.host}`);
    
    mongoose.connection.on('error', (err) => {
      console.error('❌ MongoDB connection error:', err);
    });

    mongoose.connection.on('disconnected', () => {
      console.log('⚠️  MongoDB disconnected');
    });

  } catch (error) {
    console.error('❌ Error connecting to MongoDB:', error);
    process.exit(1);
  }
};

module.exports = connectDB;
EOF

    # Modèle de réservation avec TODOs
    cat > src/models/reservation.model.js << 'EOF'
const mongoose = require('mongoose');

/**
 * Modèle de Réservation - Démontre Polyglot Persistence avec MongoDB
 * 
 * Ce modèle illustre :
 * - La flexibilité du schéma NoSQL (documents imbriqués)
 * - Les index composés pour optimiser les requêtes
 * - Les validations au niveau du schéma
 * - L'agrégation de données avec MongoDB
 */

const reservationSchema = new mongoose.Schema({
  eventId: {
    type: Number,
    required: true,
    index: true
  },
  userId: {
    type: String,
    required: true,
    index: true
  },
  userDetails: {
    name: { type: String, required: true },
    email: { type: String, required: true },
    phone: { type: String },
    preferences: {
      seatType: { type: String, enum: ['standard', 'premium', 'vip'] },
      accessibilityNeeds: { type: Boolean, default: false },
      dietaryRestrictions: [String]
    }
  },
  bookingDetails: {
    seats: { type: Number, required: true, min: 1 },
    seatNumbers: [String], // Peut être vide si places non assignées
    totalAmount: { type: Number, required: true },
    currency: { type: String, default: 'XOF' }
  },
  status: {
    type: String,
    enum: ['pending', 'confirmed', 'cancelled', 'refunded'],
    default: 'pending',
    index: true
  },
  timeline: [{
    status: String,
    timestamp: { type: Date, default: Date.now },
    reason: String,
    updatedBy: String
  }],
  metadata: {
    source: { type: String, default: 'web' }, // web, mobile, api
    channel: String,
    promotionCode: String,
    referralId: String
  }
}, {
  timestamps: true,
  versionKey: '__v'
});

// Index composé pour optimiser les requêtes fréquentes
reservationSchema.index({ eventId: 1, status: 1 });
reservationSchema.index({ userId: 1, createdAt: -1 });

// =========================================================================
// TODO-DB3: Implémentez la méthode statique pour calculer les statistiques de réservation
// =========================================================================
/**
 * Cette méthode doit agréger les données par événement et retourner un résumé
 * utilisant le pipeline d'agrégation MongoDB.
 * 
 * Doit retourner :
 * - totalReservations: nombre total de réservations
 * - totalSeats: nombre total de places réservées
 * - confirmedSeats: places confirmées
 * - pendingSeats: places en attente
 * - revenue: revenus des réservations confirmées
 * 
 * @param {Number} eventId - ID de l'événement
 * @returns {Object} Statistiques de réservation
 */
reservationSchema.statics.getEventReservationStats = async function(eventId) {
  // ⚠️  TODO: À implémenter par les étudiants
  
  // Exemple de solution avec aggregation pipeline :
  // const stats = await this.aggregate([
  //   { $match: { eventId: parseInt(eventId) } },
  //   {
  //     $group: {
  //       _id: '$status',
  //       count: { $sum: 1 },
  //       totalSeats: { $sum: '$bookingDetails.seats' },
  //       totalRevenue: { $sum: '$bookingDetails.totalAmount' }
  //     }
  //   }
  // ]);
  //
  // // Consolider les résultats...
  
  return {
    totalReservations: 0,
    totalSeats: 0,
    confirmedSeats: 0,
    pendingSeats: 0,
    revenue: 0
  }; // Placeholder - à remplacer
};

// =========================================================================
// TODO-DB4: Implémentez le middleware pre-save pour mettre à jour la timeline
// =========================================================================
/**
 * Ce middleware doit automatiquement ajouter une entrée timeline quand le status change.
 * 
 * Logique :
 * 1. Vérifier si le status a été modifié (this.isModified('status'))
 * 2. Si oui, ajouter une entrée dans timeline avec le nouveau status
 * 3. Inclure timestamp, reason et updatedBy
 */
reservationSchema.pre('save', function(next) {
  // ⚠️  TODO: À implémenter par les étudiants
  
  // Exemple de solution :
  // if (this.isModified('status')) {
  //   this.timeline.push({
  //     status: this.status,
  //     timestamp: new Date(),
  //     reason: `Status changed to ${this.status}`,
  //     updatedBy: 'system'
  //   });
  // }
  
  next();
});

module.exports = mongoose.model('Reservation', reservationSchema);
EOF

    # Service principal
    cat > src/services/reservation.service.js << 'EOF'
const Reservation = require('../models/reservation.model');
const eventService = require('./event.service');

class ReservationService {
  
  async createReservation(reservationData) {
    try {
      console.log('📝 Creating new reservation:', reservationData);
      
      // Vérifier la disponibilité de l'événement
      const event = await eventService.getEventById(reservationData.eventId);
      console.log('🎭 Event found:', event.name);
      
      // Tenter de réserver les places via le service événements
      const bookingResponse = await eventService.bookEventSeats(
        reservationData.eventId, 
        reservationData.seats
      );
      console.log('🎫 Booking response:', bookingResponse);
      
      // Créer la réservation
      const reservation = new Reservation({
        eventId: reservationData.eventId,
        userId: reservationData.userId,
        userDetails: {
          name: reservationData.userName,
          email: reservationData.userEmail,
          phone: reservationData.userPhone,
          preferences: reservationData.preferences || {}
        },
        bookingDetails: {
          seats: reservationData.seats,
          totalAmount: reservationData.totalAmount || (reservationData.seats * (event.ticketPrice || 50)),
          currency: reservationData.currency || 'XOF'
        },
        metadata: {
          source: reservationData.source || 'api',
          channel: reservationData.channel
        }
      });
      
      await reservation.save();
      console.log('✅ Reservation created:', reservation._id);
      
      return {
        success: true,
        reservation,
        message: 'Reservation created successfully'
      };
      
    } catch (error) {
      console.error('❌ Error creating reservation:', error);
      throw new Error(error.message || 'Failed to create reservation');
    }
  }

  async getReservationById(id) {
    try {
      const reservation = await Reservation.findById(id);
      if (!reservation) {
        throw new Error('Reservation not found');
      }
      return reservation;
    } catch (error) {
      throw new Error(error.message);
    }
  }

  async getUserReservations(userId) {
    try {
      return await Reservation.find({ userId })
        .sort({ createdAt: -1 });
    } catch (error) {
      throw new Error('Failed to fetch user reservations');
    }
  }

  async getEventReservations(eventId) {
    try {
      return await Reservation.find({ eventId })
        .sort({ createdAt: -1 });
    } catch (error) {
      throw new Error('Failed to fetch event reservations');
    }
  }

  async updateReservationStatus(id, status, reason = '') {
    try {
      const reservation = await Reservation.findById(id);
      if (!reservation) {
        throw new Error('Reservation not found');
      }
      
      reservation.status = status;
      await reservation.save(); // Le middleware pre-save s'occupe de la timeline
      
      return reservation;
    } catch (error) {
      throw new Error(error.message);
    }
  }

  async cancelReservation(id, reason = 'Cancelled by user') {
    try {
      const reservation = await Reservation.findById(id);
      if (!reservation) {
        throw new Error('Reservation not found');
      }
      
      if (reservation.status === 'cancelled') {
        throw new Error('Reservation already cancelled');
      }
      
      // Libérer les places dans le service événements
      await eventService.releaseSeats(reservation.eventId, reservation.bookingDetails.seats);
      
      // Mettre à jour le statut
      reservation.status = 'cancelled';
      await reservation.save();
      
      return reservation;
    } catch (error) {
      throw new Error(error.message);
    }
  }

  async getReservationStats(eventId) {
    try {
      return await Reservation.getEventReservationStats(eventId);
    } catch (error) {
      throw new Error('Failed to get reservation statistics');
    }
  }
}

module.exports = new ReservationService();
EOF

    # Service communication avec événements
    cat > src/services/event.service.js << 'EOF'
const axios = require('axios');

const EVENT_SERVICE_URL = process.env.EVENT_SERVICE_URL || 'http://localhost:8080/api/events';

class EventService {
  
  constructor() {
    this.apiClient = axios.create({
      timeout: 5000,
      headers: {
        'Content-Type': 'application/json'
      }
    });
  }

  async getEventById(eventId) {
    try {
      console.log(`🔍 Fetching event ${eventId} from ${EVENT_SERVICE_URL}/${eventId}`);
      const response = await this.apiClient.get(`${EVENT_SERVICE_URL}/${eventId}`);
      return response.data;
    } catch (error) {
      console.error(`❌ Error fetching event with ID ${eventId}:`, error.message);
      if (error.response && error.response.status === 404) {
        throw new Error(`Event with ID ${eventId} not found`);
      }
      throw new Error('Failed to fetch event');
    }
  }

  async bookEventSeats(eventId, seats) {
    try {
      console.log(`🎫 Booking ${seats} seats for event ${eventId}`);
      const response = await this.apiClient.post(`${EVENT_SERVICE_URL}/${eventId}/book`, {
        seats: seats
      });
      
      return response.data;
    } catch (error) {
      console.error(`❌ Error booking seats for event ${eventId}:`, error.message);
      if (error.response) {
        throw new Error(error.response.data.error || 'Failed to book seats');
      }
      throw new Error('Failed to book seats');
    }
  }

  async releaseSeats(eventId, seats) {
    try {
      console.log(`🔄 Releasing ${seats} seats for event ${eventId}`);
      const response = await this.apiClient.post(`${EVENT_SERVICE_URL}/${eventId}/release`, {
        seats: seats
      });
      
      return response.data;
    } catch (error) {
      console.error(`❌ Error releasing seats for event ${eventId}:`, error.message);
      if (error.response) {
        throw new Error(error.response.data.error || 'Failed to release seats');
      }
      throw new Error('Failed to release seats');
    }
  }
}

module.exports = new EventService();
EOF

    # Service de compensation (TODO-SAGA5 et TODO-SAGA6)
    cat > src/compensations/reservation.compensation.js << 'EOF'
const Reservation = require('../models/reservation.model');
const eventService = require('../services/event.service');

class ReservationCompensationService {
  
  // =========================================================================
  // TODO-SAGA5: Implémentez la compensation de réservation
  // =========================================================================
  /**
   * Cette méthode doit annuler une réservation et libérer les places
   * 
   * Actions à effectuer :
   * 1. Trouver la réservation par ID
   * 2. Vérifier qu'elle peut être annulée (status != 'cancelled')
   * 3. Libérer les places dans le service événements
   * 4. Marquer la réservation comme annulée
   * 5. Enregistrer la raison de l'annulation dans la timeline
   * 
   * @param {String} reservationId - ID de la réservation à compenser
   * @param {String} reason - Raison de la compensation
   */
  async compensateReservation(reservationId, reason = 'Saga compensation') {
    try {
      // ⚠️  TODO: À implémenter par les étudiants
      
      // Exemple de solution :
      // const reservation = await Reservation.findById(reservationId);
      // if (!reservation) {
      //   throw new Error(`Reservation ${reservationId} not found`);
      // }
      // 
      // if (reservation.status === 'cancelled') {
      //   console.log(`Reservation ${reservationId} already cancelled`);
      //   return;
      // }
      // 
      // // Libérer les places
      // await this.releaseEventSeats(
      //   reservation.eventId, 
      //   reservation.bookingDetails.seats
      // );
      // 
      // // Marquer comme annulée
      // reservation.status = 'cancelled';
      // reservation.timeline.push({
      //   status: 'cancelled',
      //   timestamp: new Date(),
      //   reason: reason,
      //   updatedBy: 'saga-compensator'
      // });
      // 
      // await reservation.save();
      // console.log(`✅ Reservation ${reservationId} compensated`);
      
    } catch (error) {
      console.error(`Failed to compensate reservation ${reservationId}:`, error);
      throw error;
    }
  }

  // =========================================================================
  // TODO-SAGA6: Implémentez la vérification de l'état de compensation
  // =========================================================================
  /**
   * Cette méthode doit vérifier si une réservation peut être compensée
   * 
   * Critères :
   * 1. La réservation existe
   * 2. Le statut n'est pas déjà 'cancelled' ou 'refunded'
   * 3. La réservation n'est pas trop ancienne (ex: moins de 24h)
   * 
   * @param {String} reservationId - ID de la réservation
   * @returns {Boolean} true si la compensation est possible
   */
  async canCompensateReservation(reservationId) {
    // ⚠️  TODO: À implémenter par les étudiants
    
    // Exemple de solution :
    // try {
    //   const reservation = await Reservation.findById(reservationId);
    //   if (!reservation) return false;
    //   
    //   if (['cancelled', 'refunded'].includes(reservation.status)) {
    //     return false;
    //   }
    //   
    //   // Vérifier si pas trop ancienne (24h)
    //   const hoursSinceCreation = (Date.now() - reservation.createdAt) / (1000 * 60 * 60);
    //   if (hoursSinceCreation > 24) {
    //     return false;
    //   }
    //   
    //   return true;
    // } catch (error) {
    //   console.error(`Error checking compensation eligibility:`, error);
    //   return false;
    // }
    
    return false; // Placeholder - à remplacer
  }

  // Méthode pour libérer les places dans le service événements
  async releaseEventSeats(eventId, seats) {
    try {
      const response = await eventService.releaseSeats(eventId, seats);
      return response;
    } catch (error) {
      console.error(`Failed to release ${seats} seats for event ${eventId}:`, error);
      throw error;
    }
  }
}

module.exports = new ReservationCompensationService();
EOF

    # Contrôleur principal
    cat > src/controllers/reservation.controller.js << 'EOF'
const reservationService = require('../services/reservation.service');
const compensationService = require('../compensations/reservation.compensation');
const Joi = require('joi');

// Validation schema
const createReservationSchema = Joi.object({
  eventId: Joi.number().required(),
  userId: Joi.string().required(),
  userName: Joi.string().required(),
  userEmail: Joi.string().email().required(),
  userPhone: Joi.string().optional(),
  seats: Joi.number().min(1).required(),
  totalAmount: Joi.number().optional(),
  currency: Joi.string().optional(),
  preferences: Joi.object().optional(),
  source: Joi.string().optional(),
  channel: Joi.string().optional()
});

class ReservationController {
  
  async createReservation(req, res) {
    try {
      const { error, value } = createReservationSchema.validate(req.body);
      if (error) {
        return res.status(400).json({ 
          error: 'Validation error', 
          details: error.details 
        });
      }
      
      const result = await reservationService.createReservation(value);
      res.status(201).json(result);
      
    } catch (error) {
      console.error('❌ Error creating reservation:', error);
      res.status(500).json({ 
        error: 'Failed to create reservation', 
        message: error.message 
      });
    }
  }

  async getReservationById(req, res) {
    try {
      const reservation = await reservationService.getReservationById(req.params.id);
      res.json(reservation);
    } catch (error) {
      console.error('❌ Error getting reservation:', error);
      res.status(404).json({ 
        error: 'Reservation not found', 
        message: error.message 
      });
    }
  }

  async getUserReservations(req, res) {
    try {
      const reservations = await reservationService.getUserReservations(req.params.userId);
      res.json(reservations);
    } catch (error) {
      console.error('❌ Error getting user reservations:', error);
      res.status(500).json({ 
        error: 'Failed to fetch reservations', 
        message: error.message 
      });
    }
  }

  async getEventReservations(req, res) {
    try {
      const reservations = await reservationService.getEventReservations(req.params.eventId);
      res.json(reservations);
    } catch (error) {
      console.error('❌ Error getting event reservations:', error);
      res.status(500).json({ 
        error: 'Failed to fetch reservations', 
        message: error.message 
      });
    }
  }

  async getReservationStats(req, res) {
    try {
      const stats = await reservationService.getReservationStats(req.params.eventId);
      res.json(stats);
    } catch (error) {
      console.error('❌ Error getting reservation stats:', error);
      res.status(500).json({ 
        error: 'Failed to get statistics', 
        message: error.message 
      });
    }
  }

  async updateReservationStatus(req, res) {
    try {
      const { status, reason } = req.body;
      const reservation = await reservationService.updateReservationStatus(
        req.params.id, 
        status, 
        reason
      );
      res.json(reservation);
    } catch (error) {
      console.error('❌ Error updating reservation status:', error);
      res.status(500).json({ 
        error: 'Failed to update reservation', 
        message: error.message 
      });
    }
  }

  async cancelReservation(req, res) {
    try {
      const { reason } = req.body;
      const reservation = await reservationService.cancelReservation(
        req.params.id, 
        reason
      );
      res.json(reservation);
    } catch (error) {
      console.error('❌ Error cancelling reservation:', error);
      res.status(500).json({ 
        error: 'Failed to cancel reservation', 
        message: error.message 
      });
    }
  }

  async compensateReservation(req, res) {
    try {
      const { reason } = req.body;
      await compensationService.compensateReservation(
        req.params.id, 
        reason || 'Saga compensation'
      );
      res.json({ message: 'Reservation compensated successfully' });
    } catch (error) {
      console.error('❌ Error compensating reservation:', error);
      res.status(500).json({ 
        error: 'Failed to compensate reservation', 
        message: error.message 
      });
    }
  }
}

module.exports = new ReservationController();
EOF

    # Command Handler pour CQRS (TODO-ES4, TODO-ES5, TODO-ES6)
    cat > src/handlers/reservation.command.handler.js << 'EOF'
const DomainEvent = require('../../event-store-service/src/models/domain.event');
const { v4: uuidv4 } = require('uuid');

class ReservationCommandHandler {
  constructor(eventStore, reservationRepository) {
    this.eventStore = eventStore;
    this.reservationRepository = reservationRepository;
  }

  // =========================================================================
  // TODO-ES4: Implémentez le traitement de la commande CreateReservation
  // =========================================================================
  /**
   * Cette méthode doit valider la commande et générer un événement ReservationCreated
   * 
   * Étapes :
   * 1. Valider la commande (champs requis, valeurs valides)
   * 2. Vérifier les règles métier (places disponibles, etc.)
   * 3. Générer l'événement ReservationCreated avec les données
   * 4. Sauvegarder dans l'Event Store
   * 5. Déclencher la mise à jour des vues de lecture
   * 
   * @param {Object} command - Commande CreateReservation
   * @returns {Object} Résultat avec reservationId et event
   */
  async handleCreateReservation(command) {
    try {
      // ⚠️  TODO: À implémenter par les étudiants
      
      // Exemple de solution :
      // // 1. Valider la commande
      // this.validateCreateReservationCommand(command);
      // 
      // // 2. Générer un ID unique pour la réservation
      // const reservationId = uuidv4();
      // 
      // // 3. Obtenir la prochaine version
      // const version = await this.getNextVersion(reservationId);
      // 
      // // 4. Créer les données de l'événement
      // const eventData = {
      //   reservationId,
      //   eventId: command.eventId,
      //   userId: command.userId,
      //   userName: command.userName,
      //   userEmail: command.userEmail,
      //   seats: command.seats,
      //   totalAmount: command.totalAmount,
      //   currency: command.currency || 'XOF',
      //   status: 'pending'
      // };
      // 
      // // 5. Sauvegarder l'événement
      // const event = await this.saveEvent(
      //   reservationId,
      //   'Reservation',
      //   'ReservationCreated',
      //   eventData,
      //   version,
      //   command.metadata
      // );
      // 
      // console.log(`Reservation created: ${reservationId}`);
      // return { reservationId, event };
      
    } catch (error) {
      console.error('Error handling CreateReservation command:', error);
      throw error;
    }
  }

  // =========================================================================
  // TODO-ES5: Implémentez le traitement de la commande ConfirmReservation
  // =========================================================================
  /**
   * Cette méthode doit changer le statut de la réservation et générer l'événement approprié
   * 
   * Étapes :
   * 1. Récupérer l'historique de la réservation depuis l'Event Store
   * 2. Reconstruire l'état actuel en rejouant les événements
   * 3. Valider que la confirmation est possible (statut actuel = 'pending')
   * 4. Générer l'événement ReservationConfirmed
   * 5. Sauvegarder et déclencher les mises à jour
   * 
   * @param {Object} command - Commande ConfirmReservation avec reservationId
   */
  async handleConfirmReservation(command) {
    try {
      // ⚠️  TODO: À implémenter par les étudiants
      
      // Exemple de solution :
      // const { reservationId } = command;
      // 
      // // 1. Récupérer l'historique
      // const history = await this.eventStore.getAggregateHistory(reservationId);
      // if (history.length === 0) {
      //   throw new Error(`Reservation ${reservationId} not found`);
      // }
      // 
      // // 2. Reconstruire l'état actuel
      // const currentState = await this.reconstructReservationState(reservationId);
      // 
      // // 3. Valider la transition
      // if (currentState.status !== 'pending') {
      //   throw new Error(`Cannot confirm reservation in status ${currentState.status}`);
      // }
      // 
      // // 4. Générer l'événement
      // const version = await this.getNextVersion(reservationId);
      // const eventData = {
      //   reservationId,
      //   previousStatus: currentState.status,
      //   newStatus: 'confirmed',
      //   confirmedAt: new Date()
      // };
      // 
      // // 5. Sauvegarder
      // const event = await this.saveEvent(
      //   reservationId,
      //   'Reservation',
      //   'ReservationConfirmed',
      //   eventData,
      //   version,
      //   command.metadata
      // );
      // 
      // return { reservationId, event };
      
    } catch (error) {
      console.error('Error handling ConfirmReservation command:', error);
      throw error;
    }
  }

  // =========================================================================
  // TODO-ES6: Implémentez la reconstruction de l'état d'une réservation
  // =========================================================================
  /**
   * Cette méthode doit rejouer tous les événements pour reconstituer l'état actuel
   * 
   * Principe de l'Event Sourcing :
   * 1. Récupérer tous les événements de l'agrégat
   * 2. Partir d'un état initial vide
   * 3. Appliquer chaque événement dans l'ordre pour modifier l'état
   * 4. Retourner l'état final reconstitué
   * 
   * @param {String} reservationId - ID de la réservation
   * @returns {Object} État actuel de la réservation
   */
  async reconstructReservationState(reservationId) {
    // ⚠️  TODO: À implémenter par les étudiants
    
    // Exemple de solution :
    // const events = await this.eventStore.getAggregateHistory(reservationId);
    // 
    // // État initial
    // let state = {
    //   reservationId,
    //   status: null,
    //   version: 0
    // };
    // 
    // // Rejouer chaque événement
    // for (const event of events) {
    //   switch (event.eventType) {
    //     case 'ReservationCreated':
    //       state = {
    //         ...state,
    //         ...event.eventData,
    //         status: event.eventData.status || 'pending',
    //         version: event.version
    //       };
    //       break;
    //       
    //     case 'ReservationConfirmed':
    //       state.status = 'confirmed';
    //       state.confirmedAt = event.eventData.confirmedAt;
    //       state.version = event.version;
    //       break;
    //       
    //     case 'ReservationCancelled':
    //       state.status = 'cancelled';
    //       state.cancelledAt = event.eventData.cancelledAt;
    //       state.version = event.version;
    //       break;
    //   }
    // }
    // 
    // return state;
    
    return {}; // Placeholder - à remplacer
  }

  // Méthodes utilitaires
  async saveEvent(aggregateId, aggregateType, eventType, eventData, version, metadata = {}) {
    const domainEvent = new DomainEvent({
      eventId: uuidv4(),
      aggregateId,
      aggregateType,
      eventType,
      eventData,
      version,
      metadata: {
        ...metadata,
        correlationId: metadata.correlationId || uuidv4()
      },
      timestamp: new Date()
    });

    await domainEvent.save();
    
    // Publier l'événement pour mise à jour des vues de lecture
    await this.publishEvent(domainEvent);
    
    return domainEvent;
  }

  async publishEvent(domainEvent) {
    // Publier l'événement via messaging pour mise à jour des projections
    // Intégration avec RabbitMQ du TP précédent
    console.log(`Event published: ${domainEvent.eventType} for ${domainEvent.aggregateId}`);
  }

  validateCreateReservationCommand(command) {
    if (!command.eventId || !command.userId || !command.seats) {
      throw new Error('Invalid CreateReservation command: missing required fields');
    }
    if (command.seats <= 0) {
      throw new Error('Invalid CreateReservation command: seats must be positive');
    }
  }

  async getNextVersion(aggregateId) {
    const lastEvent = await DomainEvent.findOne({ aggregateId })
      .sort({ version: -1 })
      .select('version');
    
    return lastEvent ? lastEvent.version + 1 : 1;
  }
}

module.exports = ReservationCommandHandler;
EOF

    # Projection pour vues de lecture (TODO-ES7, TODO-ES8, TODO-ES9)
    cat > src/handlers/reservation.projection.js << 'EOF'
const mongoose = require('mongoose');

// Schéma de vue de lecture optimisée (dénormalisée)
const reservationViewSchema = new mongoose.Schema({
  reservationId: { type: String, required: true, unique: true, index: true },
  eventId: { type: Number, required: true, index: true },
  eventName: String,
  eventDate: Date,
  eventLocation: String,
  userId: { type: String, required: true, index: true },
  userName: String,
  userEmail: String,
  seats: { type: Number, required: true },
  totalAmount: Number,
  currency: String,
  status: { type: String, required: true, index: true },
  paymentStatus: String,
  paymentId: String,
  createdAt: { type: Date, required: true },
  confirmedAt: Date,
  cancelledAt: Date,
  lastUpdated: { type: Date, default: Date.now }
}, {
  collection: 'reservation_views'
});

const ReservationView = mongoose.model('ReservationView', reservationViewSchema);

class ReservationProjectionHandler {
  
  // =========================================================================
  // TODO-ES7: Implémentez la gestion de l'événement ReservationCreated
  // =========================================================================
  /**
   * Cette méthode doit créer une nouvelle vue de lecture lors de la création
   * 
   * Actions :
   * 1. Extraire les données de l'événement
   * 2. Enrichir avec des données du service Event si nécessaire
   * 3. Créer la vue de lecture dénormalisée
   * 4. Sauvegarder dans la collection reservation_views
   * 
   * @param {Object} event - Événement ReservationCreated
   */
  async handleReservationCreated(event) {
    try {
      // ⚠️  TODO: À implémenter par les étudiants
      
      // Exemple de solution :
      // const { eventData } = event;
      // 
      // // Enrichir avec les données de l'événement
      // const eventDetails = await this.enrichWithEventData(eventData.eventId);
      // 
      // // Créer la vue de lecture
      // const view = new ReservationView({
      //   reservationId: eventData.reservationId,
      //   eventId: eventData.eventId,
      //   eventName: eventDetails?.name || 'Unknown Event',
      //   eventDate: eventDetails?.eventDate,
      //   eventLocation: eventDetails?.location,
      //   userId: eventData.userId,
      //   userName: eventData.userName,
      //   userEmail: eventData.userEmail,
      //   seats: eventData.seats,
      //   totalAmount: eventData.totalAmount,
      //   currency: eventData.currency,
      //   status: eventData.status,
      //   createdAt: event.timestamp
      // });
      // 
      // await view.save();
      // console.log(`✅ Reservation view created for ${eventData.reservationId}`);
      
    } catch (error) {
      console.error('Error handling ReservationCreated projection:', error);
      throw error;
    }
  }

  // =========================================================================
  // TODO-ES8: Implémentez la gestion de l'événement ReservationConfirmed
  // =========================================================================
  /**
   * Cette méthode doit mettre à jour la vue existante lors de la confirmation
   * 
   * Actions :
   * 1. Trouver la vue existante par reservationId
   * 2. Mettre à jour le statut à 'confirmed'
   * 3. Ajouter confirmedAt avec le timestamp
   * 4. Sauvegarder les modifications
   * 
   * @param {Object} event - Événement ReservationConfirmed
   */
  async handleReservationConfirmed(event) {
    try {
      // ⚠️  TODO: À implémenter par les étudiants
      
      // Exemple de solution :
      // const { eventData } = event;
      // 
      // const view = await ReservationView.findOne({ 
      //   reservationId: eventData.reservationId 
      // });
      // 
      // if (!view) {
      //   throw new Error(`View not found for reservation ${eventData.reservationId}`);
      // }
      // 
      // view.status = 'confirmed';
      // view.confirmedAt = eventData.confirmedAt || event.timestamp;
      // view.lastUpdated = new Date();
      // 
      // await view.save();
      // console.log(`✅ Reservation view updated to confirmed for ${eventData.reservationId}`);
      
    } catch (error) {
      console.error('Error handling ReservationConfirmed projection:', error);
      throw error;
    }
  }

  // =========================================================================
  // TODO-ES9: Implémentez une requête optimisée pour les réservations par utilisateur
  // =========================================================================
  /**
   * Cette méthode doit utiliser la vue dénormalisée pour des performances optimales
   * 
   * Fonctionnalités :
   * 1. Filtrer par userId
   * 2. Appliquer les filtres optionnels (status, dates)
   * 3. Trier par date de création décroissante
   * 4. Paginer les résultats
   * 
   * @param {String} userId - ID de l'utilisateur
   * @param {Object} options - Options de filtrage et pagination
   * @returns {Array} Liste des réservations de l'utilisateur
   */
  async getUserReservations(userId, options = {}) {
    // ⚠️  TODO: À implémenter par les étudiants
    
    // Exemple de solution :
    // try {
    //   const { 
    //     status, 
    //     fromDate, 
    //     toDate, 
    //     limit = 20, 
    //     offset = 0 
    //   } = options;
    //   
    //   // Construire la requête
    //   const query = { userId };
    //   
    //   if (status) {
    //     query.status = status;
    //   }
    //   
    //   if (fromDate || toDate) {
    //     query.createdAt = {};
    //     if (fromDate) query.createdAt.$gte = new Date(fromDate);
    //     if (toDate) query.createdAt.$lte = new Date(toDate);
    //   }
    //   
    //   // Exécuter la requête optimisée
    //   const reservations = await ReservationView
    //     .find(query)
    //     .sort({ createdAt: -1 })
    //     .skip(offset)
    //     .limit(limit)
    //     .lean();
    //   
    //   return reservations;
    //   
    // } catch (error) {
    //   console.error('Error getting user reservations:', error);
    //   throw error;
    // }
    
    return []; // Placeholder - à remplacer
  }

  // Méthode utilitaire pour enrichir les données
  async enrichWithEventData(eventId) {
    try {
      // Appel au service Event pour récupérer les détails
      // En production, pourrait utiliser un cache Redis
      const response = await fetch(`http://localhost:8080/api/events/${eventId}`);
      if (response.ok) {
        return await response.json();
      }
      return null;
    } catch (error) {
      console.warn(`Could not enrich with event data for eventId ${eventId}:`, error);
      return null;
    }
  }
}

module.exports = { ReservationView, ReservationProjectionHandler };
EOF

    # Application principale
    cat > src/app.js << 'EOF'
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
require('dotenv').config();

const connectDB = require('./config/database');
const reservationController = require('./controllers/reservation.controller');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(helmet());
app.use(cors());
app.use(morgan('combined'));
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));

// Connexion à MongoDB
connectDB();

// Routes principales
app.get('/', (req, res) => {
  res.json({
    message: '📝 Reservation Service API - MongoDB + Polyglot Persistence',
    version: '1.0.0',
    database: 'MongoDB',
    patterns: ['Database per Service', 'Polyglot Persistence', 'CQRS', 'Saga Compensation'],
    endpoints: {
      reservations: '/api/reservations',
      compensations: '/api/reservations/:id/compensate',
      health: '/health'
    }
  });
});

app.get('/health', (req, res) => {
  res.json({ 
    status: 'OK', 
    timestamp: new Date().toISOString(),
    service: 'reservation-service',
    database: 'MongoDB'
  });
});

// Routes des réservations
app.post('/api/reservations', reservationController.createReservation);
app.get('/api/reservations/:id', reservationController.getReservationById);
app.get('/api/reservations/user/:userId', reservationController.getUserReservations);
app.get('/api/reservations/event/:eventId', reservationController.getEventReservations);
app.put('/api/reservations/:id/status', reservationController.updateReservationStatus);
app.post('/api/reservations/:id/cancel', reservationController.cancelReservation);
app.post('/api/reservations/:id/compensate', reservationController.compensateReservation);
app.get('/api/reservations/stats/:eventId', reservationController.getReservationStats);

// Gestionnaire d'erreurs global
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({
    error: 'Internal Server Error',
    message: process.env.NODE_ENV === 'development' ? err.message : 'Something went wrong'
  });
});

// 404 handler
app.use('*', (req, res) => {
  res.status(404).json({
    error: 'Not Found',
    message: `Route ${req.originalUrl} not found`
  });
});

app.listen(PORT, () => {
  console.log(`🚀 Reservation Service running on port ${PORT}`);
  console.log(`📊 Database: MongoDB (Polyglot Persistence)`);
});

module.exports = app;
EOF

    # Dockerfile CORRIGÉ - utilise npm install au lieu de npm ci
    cat > Dockerfile << 'EOF'
FROM node:18-alpine

WORKDIR /app

# Copier package.json uniquement
COPY package.json ./

# Installer les dépendances et générer package-lock.json
RUN npm install --production

# Copier le code source
COPY src ./src

EXPOSE 3000

CMD ["npm", "start"]
EOF

    cd ../..
    echo "✅ Service Réservations créé avec TODOs SAGA et CQRS"
}

# =============================================================================
# SERVICE PAIEMENTS (Python/Flask + PostgreSQL + Redis)
# Polyglot Persistence avec cache haute performance
# =============================================================================

create_payment_service() {
    echo "📦 Service Paiements (Python/Flask + PostgreSQL + Redis)..."
    
    cd tp4-microservices-persistence/payment-service
    
    # Créer les répertoires nécessaires
    mkdir -p {models,services,controllers,config,utils,migrations,compensations}
    
    # requirements.txt
    cat > requirements.txt << 'EOF'
Flask==3.0.0
SQLAlchemy==2.0.23
psycopg2-binary==2.9.9
redis==5.0.1
flask-sqlalchemy==3.1.1
flask-cors==4.0.0
requests==2.31.0
python-dotenv==1.0.0
marshmallow==3.20.1
gunicorn==21.2.0
pika==1.3.2
celery==5.3.4
EOF

    # Configuration avec TODOs
    cat > config.py << 'EOF'
"""
Configuration du Service Paiements - Polyglot Persistence
Démontre l'utilisation combinée de PostgreSQL + Redis

PostgreSQL: Pour les transactions ACID critiques (paiements)
Redis: Pour le cache haute performance et les sessions
"""

import os
import redis
from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker

# Configuration PostgreSQL pour les transactions
POSTGRES_URL = os.getenv(
    'POSTGRES_URL',
    'postgresql://payments_user:payments_password@localhost:5432/payments_db'
)

# Configuration Redis pour le cache
REDIS_URL = os.getenv('REDIS_URL', 'redis://localhost:6379/0')

# SQLAlchemy setup
engine = create_engine(
    POSTGRES_URL,
    pool_size=20,
    max_overflow=30,
    pool_pre_ping=True,
    echo=True if os.getenv('DEBUG') == 'true' else False
)

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

# Redis setup
redis_client = redis.Redis.from_url(
    REDIS_URL,
    decode_responses=True,
    socket_connect_timeout=5,
    socket_timeout=5,
    retry_on_timeout=True
)

# =========================================================================
# TODO-POLY1: Implémentez la classe CacheManager pour gérer le cache Redis
# =========================================================================
class CacheManager:
    """
    Gestionnaire de cache Redis pour optimiser les performances.
    
    Cette classe doit fournir des méthodes pour :
    - get(key): Récupérer une valeur du cache
    - set(key, value, ttl): Stocker une valeur avec TTL optionnel  
    - delete(key): Supprimer une clé du cache
    - exists(key): Vérifier l'existence d'une clé
    
    Gestion d'erreurs : Les erreurs Redis ne doivent pas faire planter l'application
    """
    
    def __init__(self, redis_client):
        self.redis = redis_client
    
    def get(self, key):
        """Récupère une valeur du cache Redis"""
        # ⚠️  TODO: À implémenter par les étudiants
        
        # Exemple de solution :
        # try:
        #     return self.redis.get(key)
        # except redis.RedisError as e:
        #     print(f"Redis get error: {e}")
        #     return None
        
        pass  # Placeholder - à remplacer
    
    def set(self, key, value, ttl=None):
        """Stocke une valeur dans Redis avec TTL optionnel"""
        # ⚠️  TODO: À implémenter par les étudiants
        
        # Exemple de solution :
        # try:
        #     if ttl:
        #         return self.redis.setex(key, ttl, value)
        #     else:
        #         return self.redis.set(key, value)
        # except redis.RedisError as e:
        #     print(f"Redis set error: {e}")
        #     return False
        
        pass  # Placeholder - à remplacer
    
    def delete(self, key):
        """Supprime une clé du cache"""
        # ⚠️  TODO: À implémenter par les étudiants
        pass  # Placeholder - à remplacer
    
    def exists(self, key):
        """Vérifie si une clé existe dans le cache"""
        # ⚠️  TODO: À implémenter par les étudiants
        pass  # Placeholder - à remplacer

cache_manager = CacheManager(redis_client)
EOF

    # Modèle de paiement avec TODOs
    cat > models/payment.py << 'EOF'
"""
Modèle Payment - Démontre Polyglot Persistence avec PostgreSQL + Redis

PostgreSQL: Stockage persistant des transactions (ACID)
Redis: Cache des données fréquemment accédées (performance)
"""

from sqlalchemy import Column, Integer, String, DateTime, Decimal, Boolean, Text
from sqlalchemy.sql import func
from config import Base, CacheManager, redis_client, cache_manager
import json
from datetime import datetime, timedelta

class Payment(Base):
    """
    Modèle de paiement combinant PostgreSQL (persistance) et Redis (cache)
    
    Démontre :
    - Transactions ACID critiques en PostgreSQL
    - Cache des données chaudes en Redis
    - Stratégie cache-aside pattern
    """
    
    __tablename__ = 'payments'

    id = Column(Integer, primary_key=True, index=True)
    reservation_id = Column(String(50), nullable=False, index=True)
    user_id = Column(String(50), nullable=False, index=True)
    amount = Column(Decimal(10, 2), nullable=False)
    currency = Column(String(3), default='XOF')
    payment_method = Column(String(50), nullable=False)  # card, mobile_money, bank_transfer
    status = Column(String(20), default='pending')  # pending, processing, completed, failed, refunded
    transaction_id = Column(String(100), unique=True)
    provider_reference = Column(String(100))
    metadata = Column(Text)  # JSON string for flexible data
    created_at = Column(DateTime, server_default=func.now())
    updated_at = Column(DateTime, server_default=func.now(), onupdate=func.now())
    completed_at = Column(DateTime)

    # =========================================================================
    # TODO-POLY2: Implémentez la méthode pour mettre en cache les données de paiement
    # =========================================================================
    def cache_payment_data(self, ttl_seconds=3600):
        """
        Cette méthode doit sérialiser l'objet Payment et le stocker dans Redis avec TTL.
        
        Logique :
        1. Créer une clé cache (ex: "payment:{id}")
        2. Sérialiser les données avec self.to_dict()
        3. Stocker en JSON dans Redis avec TTL
        4. Gérer les erreurs gracieusement
        """
        # ⚠️  TODO: À implémenter par les étudiants
        
        # Exemple de solution :
        # cache_key = f"payment:{self.id}"
        # payment_data = json.dumps(self.to_dict(), default=str)
        # 
        # try:
        #     cache_manager.set(cache_key, payment_data, ttl_seconds)
        #     print(f"Payment {self.id} cached with TTL {ttl_seconds}s")
        # except Exception as e:
        #     print(f"Failed to cache payment {self.id}: {e}")
        
        pass  # Placeholder - à remplacer

    # =========================================================================
    # TODO-POLY3: Implémentez la méthode statique pour récupérer depuis le cache
    # =========================================================================
    @classmethod
    def get_payment_with_cache(cls, payment_id, session):
        """
        Cette méthode doit essayer le cache Redis d'abord, puis la base PostgreSQL.
        
        Pattern Cache-Aside :
        1. Vérifier le cache Redis avec la clé "payment:{id}"
        2. Si trouvé, désérialiser et retourner
        3. Si pas trouvé, requêter PostgreSQL
        4. Mettre à jour le cache avec le résultat
        5. Retourner le résultat
        """
        # ⚠️  TODO: À implémenter par les étudiants
        
        # Exemple de solution :
        # cache_key = f"payment:{payment_id}"
        # 
        # # Essayer le cache d'abord
        # cached_data = cache_manager.get(cache_key)
        # if cached_data:
        #     try:
        #         return json.loads(cached_data)
        #     except json.JSONDecodeError:
        #         pass
        # 
        # # Si pas en cache, requêter la base
        # payment = session.query(cls).filter(cls.id == payment_id).first()
        # if payment:
        #     # Mettre à jour le cache
        #     payment.cache_payment_data()
        #     return payment.to_dict()
        # 
        # return None
        
        return None  # Placeholder - à remplacer

    def to_dict(self):
        """Sérialise l'objet Payment en dictionnaire"""
        return {
            'id': self.id,
            'reservation_id': self.reservation_id,
            'user_id': self.user_id,
            'amount': float(self.amount),
            'currency': self.currency,
            'payment_method': self.payment_method,
            'status': self.status,
            'transaction_id': self.transaction_id,
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'updated_at': self.updated_at.isoformat() if self.updated_at else None,
            'completed_at': self.completed_at.isoformat() if self.completed_at else None
        }
EOF

    # Service de paiement
    cat > services/payment_service.py << 'EOF'
from sqlalchemy.orm import Session
from models.payment import Payment
from config import SessionLocal, cache_manager
import uuid
import logging
from datetime import datetime
import json

class PaymentService:
    """
    Service de gestion des paiements avec cache Redis
    Démontre l'architecture Polyglot Persistence
    """
    
    def __init__(self):
        self.logger = logging.getLogger(__name__)
    
    def create_payment(self, payment_data):
        """Crée un nouveau paiement avec mise en cache automatique"""
        db: Session = SessionLocal()
        try:
            payment = Payment(
                reservation_id=payment_data['reservation_id'],
                user_id=payment_data['user_id'],
                amount=payment_data['amount'],
                currency=payment_data.get('currency', 'XOF'),
                payment_method=payment_data['payment_method'],
                transaction_id=str(uuid.uuid4()),
                metadata=json.dumps(payment_data.get('metadata', {}))
            )
            
            db.add(payment)
            db.commit()
            db.refresh(payment)
            
            # Mettre en cache automatiquement
            payment.cache_payment_data()
            
            self.logger.info(f"✅ Payment created: {payment.id}")
            return payment
            
        except Exception as e:
            db.rollback()
            self.logger.error(f"❌ Failed to create payment: {e}")
            raise e
        finally:
            db.close()
    
    def get_payment_by_id(self, payment_id: int):
        """Récupère un paiement avec cache-aside pattern"""
        db: Session = SessionLocal()
        try:
            # Utiliser la méthode avec cache
            cached_payment = Payment.get_payment_with_cache(payment_id, db)
            if cached_payment:
                self.logger.info(f"🎯 Payment {payment_id} found (cache hit)")
                return cached_payment
                
            # Fallback direct si le cache échoue
            payment = db.query(Payment).filter(Payment.id == payment_id).first()
            if payment:
                payment.cache_payment_data()
                self.logger.info(f"💾 Payment {payment_id} found (database)")
                return payment.to_dict()
            
            self.logger.warning(f"❌ Payment {payment_id} not found")
            return None
            
        except Exception as e:
            self.logger.error(f"❌ Failed to get payment {payment_id}: {e}")
            raise e
        finally:
            db.close()
    
    def update_payment_status(self, payment_id: int, status: str, metadata: dict = None):
        """Met à jour le statut d'un paiement et invalide le cache"""
        db: Session = SessionLocal()
        try:
            payment = db.query(Payment).filter(Payment.id == payment_id).first()
            if not payment:
                raise ValueError(f"Payment {payment_id} not found")
            
            payment.status = status
            if metadata:
                existing_metadata = json.loads(payment.metadata) if payment.metadata else {}
                existing_metadata.update(metadata)
                payment.metadata = json.dumps(existing_metadata)
            
            if status == 'completed':
                payment.completed_at = datetime.now()
            
            db.commit()
            db.refresh(payment)
            
            # Mettre à jour le cache
            payment.cache_payment_data()
            
            self.logger.info(f"✅ Payment {payment_id} status updated to {status}")
            return payment
            
        except Exception as e:
            db.rollback()
            self.logger.error(f"❌ Failed to update payment {payment_id}: {e}")
            raise e
        finally:
            db.close()

payment_service = PaymentService()
EOF

    # Service de compensation (TODO-SAGA7 et TODO-SAGA8)
    cat > compensations/payment_compensation.py << 'EOF'
from sqlalchemy.orm import Session
from models.payment import Payment
from config import SessionLocal
import logging

class PaymentCompensationService:
    
    def __init__(self):
        self.logger = logging.getLogger(__name__)
    
    # =========================================================================
    # TODO-SAGA7: Implémentez la compensation de paiement (remboursement)
    # =========================================================================
    """
    Cette méthode doit initier un remboursement et mettre à jour le statut
    
    Actions :
    1. Trouver le paiement par ID
    2. Vérifier qu'il est dans un état remboursable (completed)
    3. Initier le processus de remboursement
    4. Mettre à jour le statut à 'refunding' puis 'refunded'
    5. Enregistrer la raison du remboursement dans les métadonnées
    
    @param payment_id: ID du paiement à rembourser
    @param reason: Raison du remboursement
    """
    def compensate_payment(self, payment_id: int, reason: str = "Saga compensation"):
        db: Session = SessionLocal()
        try:
            # ⚠️  TODO: À implémenter par les étudiants
            
            # Exemple de solution :
            # payment = db.query(Payment).filter(Payment.id == payment_id).first()
            # if not payment:
            #     raise ValueError(f"Payment {payment_id} not found")
            # 
            # if payment.status == 'refunded':
            #     self.logger.info(f"Payment {payment_id} already refunded")
            #     return
            # 
            # if payment.status != 'completed':
            #     raise ValueError(f"Cannot refund payment in status {payment.status}")
            # 
            # # Mettre à jour le statut
            # payment.status = 'refunding'
            # db.commit()
            # 
            # # Simuler le processus de remboursement
            # if self.process_refund(payment, reason):
            #     payment.status = 'refunded'
            # else:
            #     payment.status = 'refund_failed'
            # 
            # # Enregistrer la raison
            # metadata = json.loads(payment.metadata) if payment.metadata else {}
            # metadata['refund_reason'] = reason
            # metadata['refunded_at'] = datetime.now().isoformat()
            # payment.metadata = json.dumps(metadata)
            # 
            # db.commit()
            # self.logger.info(f"✅ Payment {payment_id} compensated")
            
            pass  # Placeholder - à remplacer
            
        except Exception as e:
            self.logger.error(f"Failed to compensate payment {payment_id}: {e}")
            db.rollback()
            raise e
        finally:
            db.close()
    
    # =========================================================================
    # TODO-SAGA8: Implémentez la vérification de l'état de compensation
    # =========================================================================
    """
    Cette méthode doit vérifier si un paiement peut être remboursé
    
    Critères :
    1. Le paiement existe
    2. Le statut est 'completed' (pas déjà remboursé)
    3. Le paiement n'est pas trop ancien (ex: moins de 30 jours)
    4. Le montant est supérieur à 0
    
    @param payment_id: ID du paiement
    @returns: True si le remboursement est possible
    """
    def can_compensate_payment(self, payment_id: int) -> bool:
        # ⚠️  TODO: À implémenter par les étudiants
        
        # Exemple de solution :
        # db: Session = SessionLocal()
        # try:
        #     payment = db.query(Payment).filter(Payment.id == payment_id).first()
        #     if not payment:
        #         return False
        #     
        #     if payment.status != 'completed':
        #         return False
        #     
        #     # Vérifier l'âge du paiement (30 jours max)
        #     if payment.completed_at:
        #         days_since_payment = (datetime.now() - payment.completed_at).days
        #         if days_since_payment > 30:
        #             return False
        #     
        #     # Vérifier le montant
        #     if float(payment.amount) <= 0:
        #         return False
        #     
        #     return True
        #     
        # except Exception as e:
        #     self.logger.error(f"Error checking compensation eligibility: {e}")
        #     return False
        # finally:
        #     db.close()
        
        return False  # Placeholder - à remplacer
    
    def process_refund(self, payment: Payment, reason: str):
        """Simulate refund processing with external payment provider"""
        try:
            # En production, ici on appellerait l'API du provider de paiement
            # Pour la simulation, on marque comme remboursé
            
            payment.status = 'refunded'
            payment.metadata = f"Refunded: {reason}"
            
            self.logger.info(f"Refund processed for payment {payment.id}")
            return True
            
        except Exception as e:
            self.logger.error(f"Refund processing failed for payment {payment.id}: {e}")
            return False

compensation_service = PaymentCompensationService()
EOF

    # API Flask
    cat > app.py << 'EOF'
from flask import Flask, request, jsonify
from flask_cors import CORS
import os
import logging
from datetime import datetime
from config import engine, Base
from services.payment_service import payment_service
from compensations.payment_compensation import compensation_service

app = Flask(__name__)
CORS(app)

# Configuration du logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Créer les tables
Base.metadata.create_all(bind=engine)

@app.route('/', methods=['GET'])
def health_check():
    return jsonify({
        'message': '💳 Payment Service API - PostgreSQL + Redis Cache',
        'version': '1.0.0',
        'status': 'healthy',
        'database': 'PostgreSQL (transactions) + Redis (cache)',
        'patterns': ['Polyglot Persistence', 'Cache-Aside', 'Saga Compensation'],
        'endpoints': {
            'payments': '/api/payments',
            'compensations': '/api/payments/:id/compensate',
            'health': '/health'
        }
    })

@app.route('/health', methods=['GET'])
def health():
    return jsonify({
        'status': 'OK',
        'service': 'payment-service',
        'timestamp': datetime.now().isoformat(),
        'database': 'PostgreSQL + Redis'
    })

@app.route('/api/payments', methods=['POST'])
def create_payment():
    try:
        data = request.get_json()
        logger.info(f"💳 Creating payment: {data}")
        
        # Validation basique
        required_fields = ['reservation_id', 'user_id', 'amount', 'payment_method']
        for field in required_fields:
            if field not in data:
                return jsonify({'error': f'Missing required field: {field}'}), 400
        
        payment = payment_service.create_payment(data)
        
        return jsonify({
            'success': True,
            'payment': payment.to_dict(),
            'message': 'Payment created successfully'
        }), 201
        
    except Exception as e:
        logger.error(f"❌ Error creating payment: {e}")
        return jsonify({
            'error': 'Failed to create payment',
            'message': str(e)
        }), 500

@app.route('/api/payments/<int:payment_id>', methods=['GET'])
def get_payment(payment_id):
    try:
        logger.info(f"🔍 Getting payment {payment_id}")
        payment = payment_service.get_payment_by_id(payment_id)
        if not payment:
            return jsonify({'error': 'Payment not found'}), 404
        
        return jsonify(payment)
        
    except Exception as e:
        logger.error(f"❌ Error getting payment {payment_id}: {e}")
        return jsonify({
            'error': 'Failed to get payment',
            'message': str(e)
        }), 500

@app.route('/api/payments/<int:payment_id>/status', methods=['PUT'])
def update_payment_status(payment_id):
    try:
        data = request.get_json()
        status = data.get('status')
        metadata = data.get('metadata', {})
        
        if not status:
            return jsonify({'error': 'Status is required'}), 400
        
        payment = payment_service.update_payment_status(payment_id, status, metadata)
        
        return jsonify({
            'success': True,
            'payment': payment.to_dict(),
            'message': 'Payment status updated successfully'
        })
        
    except ValueError as e:
        return jsonify({'error': str(e)}), 404
    except Exception as e:
        logger.error(f"❌ Error updating payment status {payment_id}: {e}")
        return jsonify({
            'error': 'Failed to update payment status',
            'message': str(e)
        }), 500

@app.route('/api/payments/<int:payment_id>/compensate', methods=['POST'])
def compensate_payment(payment_id):
    try:
        data = request.get_json()
        reason = data.get('reason', 'Saga compensation')
        
        # Vérifier l'éligibilité
        if not compensation_service.can_compensate_payment(payment_id):
            return jsonify({
                'error': 'Payment cannot be compensated',
                'message': 'Payment is not eligible for refund'
            }), 400
        
        compensation_service.compensate_payment(payment_id, reason)
        
        return jsonify({
            'success': True,
            'message': f'Payment {payment_id} compensated successfully'
        })
        
    except Exception as e:
        logger.error(f"❌ Error compensating payment {payment_id}: {e}")
        return jsonify({
            'error': 'Failed to compensate payment',
            'message': str(e)
        }), 500

@app.errorhandler(404)
def not_found(error):
    return jsonify({'error': 'Not found'}), 404

@app.errorhandler(500)
def internal_error(error):
    return jsonify({'error': 'Internal server error'}), 500

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 5000))
    debug = os.environ.get('DEBUG', 'false').lower() == 'true'
    logger.info(f"🚀 Starting Payment Service on port {port}")
    logger.info(f"💾 Using PostgreSQL + Redis (Polyglot Persistence)")
    app.run(host='0.0.0.0', port=port, debug=debug)
EOF

    # Dockerfile
    cat > Dockerfile << 'EOF'
FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 5000

CMD ["gunicorn", "--bind", "0.0.0.0:5000", "--workers", "4", "app:app"]
EOF

    cd ../..
    echo "✅ Service Paiements créé avec TODOs Polyglot et Saga"
}

# =============================================================================
# SERVICE ANALYTICS (Java/Spring Boot + Elasticsearch)
# Polyglot Persistence pour recherche et agrégations
# =============================================================================

create_analytics_service() {
    echo "📦 Service Analytics (Java/Spring Boot + Elasticsearch)..."
    
    cd tp4-microservices-persistence/analytics-service
    
    # Créer les répertoires nécessaires
    mkdir -p src/main/{java/com/fst/dmi/analyticsservice/{controller,service,model,repository,config},resources}
    
    # build.gradle
    cat > build.gradle << 'EOF'
plugins {
    id 'org.springframework.boot' version '3.2.0'
    id 'io.spring.dependency-management' version '1.1.4'
    id 'java'
}

group = 'com.fst.dmi'
version = '0.0.1-SNAPSHOT'
sourceCompatibility = '17'

repositories {
    mavenCentral()
}

dependencies {
    implementation 'org.springframework.boot:spring-boot-starter-web'
    implementation 'org.springframework.boot:spring-boot-starter-data-elasticsearch'
    implementation 'org.springframework.boot:spring-boot-starter-amqp'
    implementation 'org.springframework.boot:spring-boot-starter-validation'
    implementation 'com.fasterxml.jackson.core:jackson-databind'
    testImplementation 'org.springframework.boot:spring-boot-starter-test'
}

test {
    useJUnitPlatform()
}
EOF

    # settings.gradle
    echo "rootProject.name = 'analytics-service'" > settings.gradle

    # gradle.properties
    cat > gradle.properties << 'EOF'
org.gradle.daemon=false
org.gradle.parallel=true
org.gradle.caching=true
EOF

    # Configuration
    cat > src/main/resources/application.yml << 'EOF'
spring:
  elasticsearch:
    uris: http://${ELASTICSEARCH_HOST:localhost}:${ELASTICSEARCH_PORT:9200}
    
  rabbitmq:
    host: ${RABBITMQ_HOST:localhost}
    port: ${RABBITMQ_PORT:5672}
    username: ${RABBITMQ_USER:guest}
    password: ${RABBITMQ_PASSWORD:guest}

server:
  port: 8080

logging:
  level:
    com.fst.dmi.analyticsservice: DEBUG
    org.springframework.data.elasticsearch: DEBUG
EOF

    # Application principale
    cat > src/main/java/com/fst/dmi/analyticsservice/AnalyticsServiceApplication.java << 'EOF'
package com.fst.dmi.analyticsservice;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class AnalyticsServiceApplication {
    public static void main(String[] args) {
        SpringApplication.run(AnalyticsServiceApplication.class, args);
    }
}
EOF

    # Modèle Elasticsearch avec TODOs
    cat > src/main/java/com/fst/dmi/analyticsservice/model/EventAnalytics.java << 'EOF'
package com.fst.dmi.analyticsservice.model;

import org.springframework.data.annotation.Id;
import org.springframework.data.elasticsearch.annotations.Document;
import org.springframework.data.elasticsearch.annotations.Field;
import org.springframework.data.elasticsearch.annotations.FieldType;
import java.time.LocalDateTime;
import java.math.BigDecimal;

/**
 * Document Elasticsearch pour les données d'analyse
 * 
 * Démontre Polyglot Persistence avec Elasticsearch pour :
 * - Recherche full-text performante
 * - Agrégations complexes en temps réel
 * - Analytics et métriques business
 * - Indexation optimisée pour les requêtes analytiques
 */
@Document(indexName = "event_analytics")
public class EventAnalytics {

    @Id
    private String id;

    @Field(type = FieldType.Long)
    private Long eventId;

    @Field(type = FieldType.Text, analyzer = "standard")
    private String eventName;

    @Field(type = FieldType.Keyword)
    private String eventCategory;

    @Field(type = FieldType.Text)
    private String location;

    @Field(type = FieldType.Date)
    private LocalDateTime eventDate;

    @Field(type = FieldType.Integer)
    private Integer totalCapacity;

    @Field(type = FieldType.Integer)
    private Integer bookedSeats;

    @Field(type = FieldType.Double)
    private Double occupancyRate;

    @Field(type = FieldType.Double)
    private BigDecimal totalRevenue;

    @Field(type = FieldType.Integer)
    private Integer totalReservations;

    @Field(type = FieldType.Date)
    private LocalDateTime lastUpdated;

    // =========================================================================
    // TODO-POLY4: Implémentez la méthode pour calculer le taux d'occupation
    // =========================================================================
    /**
     * Cette méthode doit calculer le pourcentage de places occupées.
     * 
     * Logique :
     * 1. Vérifier que totalCapacity > 0 pour éviter division par zéro
     * 2. Calculer le pourcentage : (bookedSeats / totalCapacity) * 100
     * 3. Arrondir le résultat à 2 décimales
     * 4. Gérer les cas edge (valeurs nulles, négatives)
     */
    public void calculateOccupancyRate() {
        // ⚠️  TODO: À implémenter par les étudiants
        
        // Exemple de solution :
        // if (totalCapacity != null && totalCapacity > 0 && bookedSeats != null) {
        //     this.occupancyRate = Math.round((bookedSeats.doubleValue() / totalCapacity.doubleValue()) * 100.0 * 100.0) / 100.0;
        // } else {
        //     this.occupancyRate = 0.0;
        // }
    }

    // =========================================================================
    // TODO-POLY5: Implémentez la méthode pour mettre à jour les métriques
    // =========================================================================
    /**
     * Cette méthode doit être appelée quand les données de réservation changent.
     * 
     * Actions :
     * 1. Mettre à jour bookedSeats, totalRevenue, totalReservations
     * 2. Recalculer automatiquement le taux d'occupation
     * 3. Mettre à jour lastUpdated avec l'horodatage actuel
     * 4. S'assurer que toutes les valeurs sont cohérentes
     */
    public void updateMetrics(Integer newBookedSeats, BigDecimal newRevenue, Integer newReservations) {
        // ⚠️  TODO: À implémenter par les étudiants
        
        // Exemple de solution :
        // this.bookedSeats = newBookedSeats;
        // this.totalRevenue = newRevenue;
        // this.totalReservations = newReservations;
        // this.lastUpdated = LocalDateTime.now();
        // 
        // // Recalculer le taux d'occupation
        // calculateOccupancyRate();
    }

    // Constructeurs
    public EventAnalytics() {}

    public EventAnalytics(Long eventId, String eventName) {
        this.eventId = eventId;
        this.eventName = eventName;
        this.lastUpdated = LocalDateTime.now();
        this.occupancyRate = 0.0;
        this.totalRevenue = BigDecimal.ZERO;
        this.totalReservations = 0;
        this.bookedSeats = 0;
    }

    // Getters et setters
    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public Long getEventId() { return eventId; }
    public void setEventId(Long eventId) { this.eventId = eventId; }

    public String getEventName() { return eventName; }
    public void setEventName(String eventName) { this.eventName = eventName; }

    public String getEventCategory() { return eventCategory; }
    public void setEventCategory(String eventCategory) { this.eventCategory = eventCategory; }

    public String getLocation() { return location; }
    public void setLocation(String location) { this.location = location; }

    public LocalDateTime getEventDate() { return eventDate; }
    public void setEventDate(LocalDateTime eventDate) { this.eventDate = eventDate; }

    public Integer getTotalCapacity() { return totalCapacity; }
    public void setTotalCapacity(Integer totalCapacity) { this.totalCapacity = totalCapacity; }

    public Integer getBookedSeats() { return bookedSeats; }
    public void setBookedSeats(Integer bookedSeats) { this.bookedSeats = bookedSeats; }

    public Double getOccupancyRate() { return occupancyRate; }
    public void setOccupancyRate(Double occupancyRate) { this.occupancyRate = occupancyRate; }

    public BigDecimal getTotalRevenue() { return totalRevenue; }
    public void setTotalRevenue(BigDecimal totalRevenue) { this.totalRevenue = totalRevenue; }

    public Integer getTotalReservations() { return totalReservations; }
    public void setTotalReservations(Integer totalReservations) { this.totalReservations = totalReservations; }

    public LocalDateTime getLastUpdated() { return lastUpdated; }
    public void setLastUpdated(LocalDateTime lastUpdated) { this.lastUpdated = lastUpdated; }
}
EOF

    # Repository
    cat > src/main/java/com/fst/dmi/analyticsservice/repository/EventAnalyticsRepository.java << 'EOF'
package com.fst.dmi.analyticsservice.repository;

import com.fst.dmi.analyticsservice.model.EventAnalytics;
import org.springframework.data.elasticsearch.repository.ElasticsearchRepository;
import org.springframework.stereotype.Repository;
import java.util.Optional;
import java.util.List;
import java.time.LocalDateTime;

@Repository
public interface EventAnalyticsRepository extends ElasticsearchRepository<EventAnalytics, String> {
    
    Optional<EventAnalytics> findByEventId(Long eventId);
    
    List<EventAnalytics> findByEventNameContaining(String eventName);
    
    List<EventAnalytics> findByLocationContaining(String location);
    
    List<EventAnalytics> findByEventDateBetween(LocalDateTime start, LocalDateTime end);
    
    List<EventAnalytics> findByOccupancyRateGreaterThan(Double rate);
    
    List<EventAnalytics> findByEventCategoryOrderByOccupancyRateDesc(String category);
}
EOF

    # Service
    cat > src/main/java/com/fst/dmi/analyticsservice/service/AnalyticsService.java << 'EOF'
package com.fst.dmi.analyticsservice.service;

import com.fst.dmi.analyticsservice.model.EventAnalytics;
import com.fst.dmi.analyticsservice.repository.EventAnalyticsRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.time.LocalDateTime;
import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;

@Service
public class AnalyticsService {

    private final EventAnalyticsRepository repository;

    @Autowired
    public AnalyticsService(EventAnalyticsRepository repository) {
        this.repository = repository;
    }

    public EventAnalytics createOrUpdateEventAnalytics(Long eventId, String eventName, 
                                                      Integer totalCapacity, LocalDateTime eventDate,
                                                      String location, String category) {
        Optional<EventAnalytics> existing = repository.findByEventId(eventId);
        
        EventAnalytics analytics;
        if (existing.isPresent()) {
            analytics = existing.get();
            System.out.println("📊 Updating existing analytics for event " + eventId);
        } else {
            analytics = new EventAnalytics(eventId, eventName);
            analytics.setTotalCapacity(totalCapacity);
            analytics.setEventDate(eventDate);
            analytics.setLocation(location);
            analytics.setEventCategory(category);
            System.out.println("📊 Creating new analytics for event " + eventId);
        }
        
        analytics.calculateOccupancyRate();
        analytics.setLastUpdated(LocalDateTime.now());
        
        return repository.save(analytics);
    }

    public EventAnalytics updateEventMetrics(Long eventId, Integer bookedSeats, 
                                           BigDecimal revenue, Integer reservations) {
        return repository.findByEventId(eventId)
                .map(analytics -> {
                    System.out.println("📈 Updating metrics for event " + eventId + 
                                     ": " + bookedSeats + " seats, " + revenue + " revenue");
                    analytics.updateMetrics(bookedSeats, revenue, reservations);
                    return repository.save(analytics);
                })
                .orElseThrow(() -> new RuntimeException("Event analytics not found: " + eventId));
    }

    public List<EventAnalytics> searchEventsByName(String name) {
        System.out.println("🔍 Searching events by name: " + name);
        return repository.findByEventNameContaining(name);
    }

    public List<EventAnalytics> searchEventsByLocation(String location) {
        System.out.println("🔍 Searching events by location: " + location);
        return repository.findByLocationContaining(location);
    }

    public List<EventAnalytics> getEventsBetweenDates(LocalDateTime start, LocalDateTime end) {
        System.out.println("📅 Getting events between " + start + " and " + end);
        return repository.findByEventDateBetween(start, end);
    }

    public List<EventAnalytics> getHighOccupancyEvents(Double minOccupancyRate) {
        System.out.println("📊 Getting events with occupancy > " + minOccupancyRate + "%");
        return repository.findByOccupancyRateGreaterThan(minOccupancyRate);
    }

    public List<EventAnalytics> getEventsByCategory(String category) {
        System.out.println("🎭 Getting events by category: " + category);
        return repository.findByEventCategoryOrderByOccupancyRateDesc(category);
    }

    public List<EventAnalytics> getAllEventAnalytics() {
        return (List<EventAnalytics>) repository.findAll();
    }

    public Optional<EventAnalytics> getEventAnalytics(Long eventId) {
        return repository.findByEventId(eventId);
    }
}
EOF

    # Controller
    cat > src/main/java/com/fst/dmi/analyticsservice/controller/AnalyticsController.java << 'EOF'
package com.fst.dmi.analyticsservice.controller;

import com.fst.dmi.analyticsservice.model.EventAnalytics;
import com.fst.dmi.analyticsservice.service.AnalyticsService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/analytics")
@CrossOrigin(origins = "*")
public class AnalyticsController {

    private final AnalyticsService analyticsService;

    @Autowired
    public AnalyticsController(AnalyticsService analyticsService) {
        this.analyticsService = analyticsService;
    }

    @GetMapping
    public ResponseEntity<Map<String, Object>> getSystemInfo() {
        List<EventAnalytics> analytics = analyticsService.getAllEventAnalytics();
        
        return ResponseEntity.ok(Map.of(
            "message", "📊 Analytics Service - Elasticsearch + Polyglot Persistence",
            "database", "Elasticsearch",
            "patterns", List.of("Polyglot Persistence", "Full-text Search", "Real-time Analytics"),
            "totalEvents", analytics.size(),
            "analytics", analytics,
            "endpoints", Map.of(
                "search", "/api/analytics/search",
                "highOccupancy", "/api/analytics/high-occupancy",
                "events", "/api/analytics/events/{eventId}"
            )
        ));
    }

    @GetMapping("/events/{eventId}")
    public ResponseEntity<EventAnalytics> getEventAnalytics(@PathVariable Long eventId) {
        return analyticsService.getEventAnalytics(eventId)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @GetMapping("/search")
    public List<EventAnalytics> searchEvents(@RequestParam(required = false) String name,
                                           @RequestParam(required = false) String location,
                                           @RequestParam(required = false) String category) {
        if (name != null) {
            return analyticsService.searchEventsByName(name);
        } else if (location != null) {
            return analyticsService.searchEventsByLocation(location);
        } else if (category != null) {
            return analyticsService.getEventsByCategory(category);
        }
        return analyticsService.getAllEventAnalytics();
    }

    @GetMapping("/high-occupancy")
    public List<EventAnalytics> getHighOccupancyEvents(@RequestParam(defaultValue = "80.0") Double minRate) {
        return analyticsService.getHighOccupancyEvents(minRate);
    }

    @PostMapping("/events/{eventId}/update")
    public ResponseEntity<EventAnalytics> updateEventMetrics(@PathVariable Long eventId,
                                                            @RequestBody UpdateMetricsRequest request) {
        try {
            EventAnalytics updated = analyticsService.updateEventMetrics(
                    eventId, 
                    request.getBookedSeats(), 
                    request.getRevenue(), 
                    request.getReservations()
            );
            return ResponseEntity.ok(updated);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @PostMapping("/events")
    public ResponseEntity<EventAnalytics> createEventAnalytics(@RequestBody CreateAnalyticsRequest request) {
        EventAnalytics analytics = analyticsService.createOrUpdateEventAnalytics(
                request.getEventId(),
                request.getEventName(),
                request.getTotalCapacity(),
                request.getEventDate(),
                request.getLocation(),
                request.getCategory()
        );
        return ResponseEntity.ok(analytics);
    }

    // Classes internes pour les requêtes
    public static class UpdateMetricsRequest {
        private Integer bookedSeats;
        private java.math.BigDecimal revenue;
        private Integer reservations;

        // Getters et setters
        public Integer getBookedSeats() { return bookedSeats; }
        public void setBookedSeats(Integer bookedSeats) { this.bookedSeats = bookedSeats; }

        public java.math.BigDecimal getRevenue() { return revenue; }
        public void setRevenue(java.math.BigDecimal revenue) { this.revenue = revenue; }

        public Integer getReservations() { return reservations; }
        public void setReservations(Integer reservations) { this.reservations = reservations; }
    }

    public static class CreateAnalyticsRequest {
        private Long eventId;
        private String eventName;
        private Integer totalCapacity;
        private LocalDateTime eventDate;
        private String location;
        private String category;

        // Getters et setters
        public Long getEventId() { return eventId; }
        public void setEventId(Long eventId) { this.eventId = eventId; }

        public String getEventName() { return eventName; }
        public void setEventName(String eventName) { this.eventName = eventName; }

        public Integer getTotalCapacity() { return totalCapacity; }
        public void setTotalCapacity(Integer totalCapacity) { this.totalCapacity = totalCapacity; }

        public LocalDateTime getEventDate() { return eventDate; }
        public void setEventDate(LocalDateTime eventDate) { this.eventDate = eventDate; }

        public String getLocation() { return location; }
        public void setLocation(String location) { this.location = location; }

        public String getCategory() { return category; }
        public void setCategory(String category) { this.category = category; }
    }
}
EOF

    # Dockerfile corrigé
    cat > Dockerfile << 'EOF'
FROM openjdk:17-jdk-slim

# Installer Gradle
RUN apt-get update && apt-get install -y wget unzip && \
    wget https://services.gradle.org/distributions/gradle-8.4-bin.zip && \
    unzip gradle-8.4-bin.zip && \
    mv gradle-8.4 /opt/gradle && \
    ln -s /opt/gradle/bin/gradle /usr/bin/gradle && \
    rm gradle-8.4-bin.zip && \
    apt-get clean

WORKDIR /app

# Copier les fichiers de build
COPY build.gradle .
COPY settings.gradle .
COPY gradle.properties .

# Télécharger les dépendances
RUN gradle build -x test --no-daemon || return 0

# Copier le code source
COPY src src

# Construire l'application
RUN gradle clean build -x test --no-daemon

EXPOSE 8080

CMD ["java", "-jar", "build/libs/analytics-service-0.0.1-SNAPSHOT.jar"]
EOF

    cd ../..
    echo "✅ Service Analytics créé (Elasticsearch + Polyglot Persistence)"
}

# =============================================================================
# SERVICE EVENT STORE (Node.js + MongoDB)
# Event Sourcing et CQRS
# =============================================================================

create_event_store_service() {
    echo "📦 Service Event Store (Node.js + MongoDB)..."
    
    cd tp4-microservices-persistence/event-store-service
    
    # Créer les répertoires nécessaires
    mkdir -p src/{controllers,services,models,config,utils,sync}
    
    # package.json
    cat > package.json << 'EOF'
{
  "name": "event-store-service",
  "version": "1.0.0",
  "description": "Service Event Store pour Event Sourcing et CQRS",
  "main": "src/app.js",
  "scripts": {
    "start": "node src/app.js",
    "dev": "nodemon src/app.js",
    "test": "jest"
  },
  "dependencies": {
    "express": "^4.18.2",
    "mongoose": "^8.0.3",
    "cors": "^2.8.5",
    "helmet": "^7.1.0",
    "morgan": "^1.10.0",
    "dotenv": "^16.3.1",
    "uuid": "^9.0.1",
    "joi": "^17.11.0",
    "amqplib": "^0.10.3",
    "axios": "^1.6.2"
  },
  "devDependencies": {
    "nodemon": "^3.0.2",
    "jest": "^29.7.0"
  }
}
EOF

    # Configuration base
    cat > src/config/database.js << 'EOF'
const mongoose = require('mongoose');

const MONGODB_URI = process.env.MONGODB_URI || 
  'mongodb://localhost:27017/event_store_db';

const connectDB = async () => {
  try {
    const conn = await mongoose.connect(MONGODB_URI, {
      useNewUrlParser: true,
      useUnifiedTopology: true,
      maxPoolSize: 10,
      serverSelectionTimeoutMS: 5000,
      socketTimeoutMS: 45000,
    });

    console.log(`✅ Event Store MongoDB Connected: ${conn.connection.host}`);
    
    mongoose.connection.on('error', (err) => {
      console.error('❌ Event Store MongoDB connection error:', err);
    });

    mongoose.connection.on('disconnected', () => {
      console.log('⚠️  Event Store MongoDB disconnected');
    });

  } catch (error) {
    console.error('❌ Error connecting to Event Store MongoDB:', error);
    process.exit(1);
  }
};

module.exports = connectDB;
EOF

    # Modèle d'événement de domaine avec TODOs
    cat > src/models/domain.event.js << 'EOF'
const mongoose = require('mongoose');

/**
 * Modèle d'Événement de Domaine pour Event Sourcing
 * 
 * Ce modèle capture tous les changements d'état du système comme
 * une séquence d'événements immuables, permettant :
 * - Reconstruction complète de l'état à tout moment
 * - Audit trail exhaustif de toutes les opérations
 * - Traçabilité des changements et causation
 * - Support pour CQRS (Command Query Responsibility Segregation)
 */

const domainEventSchema = new mongoose.Schema({
  eventId: {
    type: String,
    required: true,
    unique: true,
    index: true
  },
  aggregateId: {
    type: String,
    required: true,
    index: true
  },
  aggregateType: {
    type: String,
    required: true,
    enum: ['Event', 'Reservation', 'Payment', 'User'],
    index: true
  },
  eventType: {
    type: String,
    required: true,
    index: true
  },
  eventData: {
    type: mongoose.Schema.Types.Mixed,
    required: true
  },
  metadata: {
    userId: String,
    userEmail: String,
    ipAddress: String,
    userAgent: String,
    correlationId: String,
    causationId: String
  },
  version: {
    type: Number,
    required: true,
    min: 1
  },
  timestamp: {
    type: Date,
    default: Date.now,
    index: true
  }
}, {
  timestamps: false, // On gère timestamp manuellement
  versionKey: false
});

// Index composé pour optimiser les requêtes de reconstruction d'agrégat
domainEventSchema.index({ aggregateId: 1, version: 1 });
domainEventSchema.index({ aggregateType: 1, timestamp: -1 });
domainEventSchema.index({ eventType: 1, timestamp: -1 });

// =========================================================================
// TODO-ES1: Implémentez la méthode statique pour récupérer l'historique d'un agrégat
// =========================================================================
/**
 * Cette méthode doit retourner tous les événements d'un agrégat dans l'ordre chronologique.
 * 
 * Paramètres :
 * - aggregateId: ID de l'agrégat (ex: réservation, paiement)
 * - fromVersion: Version de départ (pour reconstruction incrémentale)
 * 
 * Logique :
 * 1. Filtrer par aggregateId et version > fromVersion
 * 2. Trier par version croissante (ordre de création)
 * 3. Retourner la liste d'événements
 * 4. Gérer les erreurs gracieusement
 */
domainEventSchema.statics.getAggregateHistory = async function(aggregateId, fromVersion = 0) {
  // ⚠️  TODO: À implémenter par les étudiants
  
  // Exemple de solution :
  // try {
  //   const events = await this.find({
  //     aggregateId: aggregateId,
  //     version: { $gt: fromVersion }
  //   })
  //   .sort({ version: 1 })
  //   .lean();
  //   
  //   return events;
  // } catch (error) {
  //   console.error(`Error retrieving aggregate history for ${aggregateId}:`, error);
  //   throw error;
  // }
  
  return []; // Placeholder - à remplacer
};

// =========================================================================
// TODO-ES2: Implémentez la méthode statique pour récupérer les événements par type
// =========================================================================
/**
 * Cette méthode doit permettre de filtrer par type d'événement et période.
 * 
 * Paramètres :
 * - eventType: Type d'événement (ex: "ReservationCreated", "PaymentCompleted")
 * - fromDate: Date de début (optionnel)
 * - toDate: Date de fin (optionnel)
 * - limit: Nombre maximum de résultats
 * 
 * Logique :
 * 1. Construire la requête avec eventType
 * 2. Ajouter les filtres de date si fournis
 * 3. Limiter le nombre de résultats
 * 4. Trier par timestamp décroissant (plus récents en premier)
 */
domainEventSchema.statics.getEventsByType = async function(eventType, fromDate, toDate, limit = 100) {
  // ⚠️  TODO: À implémenter par les étudiants
  
  // Exemple de solution :
  // try {
  //   const query = { eventType };
  //   
  //   if (fromDate || toDate) {
  //     query.timestamp = {};
  //     if (fromDate) query.timestamp.$gte = new Date(fromDate);
  //     if (toDate) query.timestamp.$lte = new Date(toDate);
  //   }
  //   
  //   const events = await this.find(query)
  //     .sort({ timestamp: -1 })
  //     .limit(limit)
  //     .lean();
  //   
  //   return events;
  // } catch (error) {
  //   console.error(`Error retrieving events by type ${eventType}:`, error);
  //   throw error;
  // }
  
  return []; // Placeholder - à remplacer
};

// =========================================================================
// TODO-ES3: Implémentez la méthode pour valider la cohérence de version
// =========================================================================
/**
 * Cette méthode doit vérifier qu'il n'y a pas de conflit de version.
 * 
 * L'Event Sourcing requiert que les versions soient séquentielles pour
 * chaque agrégat (1, 2, 3, ...) sans trous ni doublons.
 * 
 * Paramètres :
 * - aggregateId: ID de l'agrégat
 * - expectedVersion: Version attendue (dernière version + 1)
 * 
 * Logique :
 * 1. Trouver la dernière version pour cet agrégat
 * 2. Vérifier que expectedVersion = dernière version + 1
 * 3. Lever une erreur explicite en cas de conflit
 */
domainEventSchema.statics.validateEventVersion = async function(aggregateId, expectedVersion) {
  // ⚠️  TODO: À implémenter par les étudiants
  
  // Exemple de solution :
  // try {
  //   const lastEvent = await this.findOne({ aggregateId })
  //     .sort({ version: -1 })
  //     .select('version');
  //   
  //   const currentVersion = lastEvent ? lastEvent.version : 0;
  //   
  //   if (expectedVersion !== currentVersion + 1) {
  //     throw new Error(
  //       `Version conflict for aggregate ${aggregateId}. ` +
  //       `Expected version ${expectedVersion}, but current version is ${currentVersion}`
  //     );
  //   }
  //   
  //   return true;
  // } catch (error) {
  //   console.error(`Version validation error for ${aggregateId}:`, error);
  //   throw error;
  // }
  
  return true; // Placeholder - à remplacer
};

module.exports = mongoose.model('DomainEvent', domainEventSchema);
EOF

    # Service principal de l'Event Store
    cat > src/services/event.store.service.js << 'EOF'
const DomainEvent = require('../models/domain.event');
const { v4: uuidv4 } = require('uuid');

/**
 * Service Event Store - Implémentation de l'Event Sourcing
 * 
 * Ce service gère :
 * - L'ajout d'événements immuables
 * - La reconstruction d'état depuis les événements
 * - La validation de cohérence des versions
 * - Les requêtes sur les flux d'événements
 */
class EventStoreService {
  
  async appendEvent(aggregateId, aggregateType, eventType, eventData, metadata = {}) {
    try {
      console.log(`📝 Appending event: ${eventType} for ${aggregateType}:${aggregateId}`);
      
      // Obtenir la prochaine version
      const nextVersion = await this.getNextVersion(aggregateId);
      
      // Valider la version pour éviter les conflits
      await DomainEvent.validateEventVersion(aggregateId, nextVersion);
      
      const domainEvent = new DomainEvent({
        eventId: uuidv4(),
        aggregateId,
        aggregateType,
        eventType,
        eventData,
        version: nextVersion,
        metadata: {
          ...metadata,
          correlationId: metadata.correlationId || uuidv4()
        },
        timestamp: new Date()
      });

      await domainEvent.save();
      
      console.log(`✅ Event appended: ${eventType} for ${aggregateType}:${aggregateId} v${nextVersion}`);
      
      return domainEvent;
      
    } catch (error) {
      console.error('❌ Error appending event:', error);
      throw error;
    }
  }

  async getAggregateHistory(aggregateId, fromVersion = 0) {
    try {
      console.log(`📚 Getting aggregate history for ${aggregateId} from version ${fromVersion}`);
      return await DomainEvent.getAggregateHistory(aggregateId, fromVersion);
    } catch (error) {
      console.error(`❌ Error getting aggregate history for ${aggregateId}:`, error);
      throw error;
    }
  }

  async getEventsByType(eventType, options = {}) {
    try {
      const { fromDate, toDate, limit = 100 } = options;
      console.log(`🔍 Getting events by type: ${eventType} (limit: ${limit})`);
      return await DomainEvent.getEventsByType(eventType, fromDate, toDate, limit);
    } catch (error) {
      console.error(`❌ Error getting events by type ${eventType}:`, error);
      throw error;
    }
  }

  async getAllEvents(options = {}) {
    try {
      const { limit = 100, offset = 0, aggregateType, eventType } = options;
      
      let query = {};
      if (aggregateType) query.aggregateType = aggregateType;
      if (eventType) query.eventType = eventType;
      
      console.log(`📋 Getting all events (limit: ${limit}, offset: ${offset})`);
      
      return await DomainEvent.find(query)
        .sort({ timestamp: -1 })
        .limit(limit)
        .skip(offset);
        
    } catch (error) {
      console.error('❌ Error getting all events:', error);
      throw error;
    }
  }

  async getNextVersion(aggregateId) {
    try {
      const lastEvent = await DomainEvent.findOne({ aggregateId })
        .sort({ version: -1 })
        .select('version');
      
      const nextVersion = lastEvent ? lastEvent.version + 1 : 1;
      console.log(`🔢 Next version for ${aggregateId}: ${nextVersion}`);
      return nextVersion;
    } catch (error) {
      console.error(`❌ Error getting next version for ${aggregateId}:`, error);
      throw error;
    }
  }

  async getEventStreamMetrics() {
    try {
      console.log('📊 Getting event stream metrics...');
      
      const [totalEvents, aggregateTypes, eventTypes] = await Promise.all([
        DomainEvent.countDocuments(),
        DomainEvent.distinct('aggregateType'),
        DomainEvent.distinct('eventType')
      ]);
      
      return {
        totalEvents,
        aggregateTypes: aggregateTypes.length,
        eventTypes: eventTypes.length,
        aggregateTypesList: aggregateTypes,
        eventTypesList: eventTypes,
        timestamp: new Date().toISOString()
      };
    } catch (error) {
      console.error('❌ Error getting event stream metrics:', error);
      throw error;
    }
  }

  async reconstructAggregateState(aggregateId, toVersion = null) {
    try {
      console.log(`🔄 Reconstructing state for aggregate ${aggregateId}`);
      
      const events = await this.getAggregateHistory(aggregateId);
      
      if (events.length === 0) {
        return null;
      }
      
      // Filtrer jusqu'à la version demandée si spécifiée
      const filteredEvents = toVersion ? 
        events.filter(event => event.version <= toVersion) : 
        events;
      
      // Reconstruction basique - peut être étendue selon les besoins
      const state = {
        aggregateId,
        aggregateType: events[0].aggregateType,
        version: filteredEvents[filteredEvents.length - 1].version,
        events: filteredEvents,
        reconstructedAt: new Date().toISOString()
      };
      
      console.log(`✅ State reconstructed for ${aggregateId} with ${filteredEvents.length} events`);
      return state;
      
    } catch (error) {
      console.error(`❌ Error reconstructing state for ${aggregateId}:`, error);
      throw error;
    }
  }
}

module.exports = new EventStoreService();
EOF

    # Service de synchronisation (TODO-SYNC1, TODO-SYNC2, TODO-SYNC3)
    cat > src/sync/data.sync.service.js << 'EOF'
const EventEmitter = require('events');
const mongoose = require('mongoose');
const axios = require('axios');

// Schéma pour les données d'événements répliquées
const replicatedEventSchema = new mongoose.Schema({
  originalEventId: { type: Number, required: true, unique: true },
  name: { type: String, required: true },
  description: String,
  eventDate: Date,
  location: String,
  totalCapacity: Number,
  currentBookedSeats: { type: Number, default: 0 },
  ticketPrice: Number,
  category: String,
  status: { type: String, default: 'active' },
  lastSyncedAt: { type: Date, default: Date.now },
  version: { type: Number, default: 1 }
}, {
  collection: 'replicated_events'
});

const ReplicatedEvent = mongoose.model('ReplicatedEvent', replicatedEventSchema);

class DataSyncService extends EventEmitter {
  constructor() {
    super();
    this.syncInProgress = new Set();
  }

  // =========================================================================
  // TODO-SYNC1: Implémentez la synchronisation initiale des événements
  // =========================================================================
  /**
   * Cette méthode doit récupérer tous les événements et les répliquer localement
   * 
   * Étapes :
   * 1. Récupérer tous les événements du service Events via API
   * 2. Pour chaque événement, créer ou mettre à jour la réplique locale
   * 3. Marquer la date de synchronisation
   * 4. Émettre un événement de synchronisation complète
   * 5. Gérer les erreurs individuelles sans arrêter le processus
   */
  async performInitialSync() {
    try {
      console.log('Starting initial data synchronization...');
      
      // ⚠️  TODO: À implémenter par les étudiants
      
      // Exemple de solution :
      // // 1. Récupérer tous les événements
      // const events = await this.fetchEventsFromService();
      // 
      // let syncedCount = 0;
      // let errorCount = 0;
      // 
      // // 2. Traiter chaque événement
      // for (const event of events) {
      //   try {
      //     await this.createOrUpdateReplica(event);
      //     syncedCount++;
      //   } catch (error) {
      //     console.error(`Failed to sync event ${event.id}:`, error);
      //     errorCount++;
      //   }
      // }
      // 
      // // 3. Émettre l'événement de synchronisation complète
      // this.emit('initialSyncCompleted', {
      //   totalEvents: events.length,
      //   syncedCount,
      //   errorCount,
      //   completedAt: new Date()
      // });
      // 
      // console.log(`Initial sync completed: ${syncedCount} events synced, ${errorCount} errors`);
      // 
      // return {
      //   success: true,
      //   syncedCount,
      //   errorCount
      // };
      
    } catch (error) {
      console.error('Initial sync failed:', error);
      this.emit('syncError', error);
      throw error;
    }
  }

  // =========================================================================
  // TODO-SYNC2: Implémentez la synchronisation incrémentale
  // =========================================================================
  /**
   * Cette méthode doit synchroniser seulement les événements modifiés
   * 
   * Étapes :
   * 1. Déterminer la date de dernière synchronisation
   * 2. Récupérer les événements modifiés depuis cette date
   * 3. Mettre à jour les répliques concernées
   * 4. Gérer les conflits de version si nécessaire
   * 5. Mettre à jour lastSyncedAt pour chaque réplique
   */
  async performIncrementalSync() {
    try {
      // ⚠️  TODO: À implémenter par les étudiants
      
      // Exemple de solution :
      // // 1. Déterminer la date de dernière synchronisation
      // const lastSyncDate = await this.getLastSyncDate();
      // 
      // if (!lastSyncDate) {
      //   console.log('No previous sync found, performing initial sync');
      //   return this.performInitialSync();
      // }
      // 
      // console.log(`Starting incremental sync from ${lastSyncDate.toISOString()}`);
      // 
      // // 2. Récupérer les événements modifiés
      // const modifiedEvents = await this.fetchEventsFromService(lastSyncDate);
      // 
      // let updatedCount = 0;
      // let conflictCount = 0;
      // 
      // // 3. Traiter chaque événement modifié
      // for (const event of modifiedEvents) {
      //   try {
      //     const existingReplica = await ReplicatedEvent.findOne({ 
      //       originalEventId: event.id 
      //     });
      //     
      //     // Vérifier la version pour éviter les régressions
      //     if (existingReplica && event.version < existingReplica.version) {
      //       console.warn(`Skipping event ${event.id}: remote version ${event.version} < local version ${existingReplica.version}`);
      //       conflictCount++;
      //       continue;
      //     }
      //     
      //     await this.createOrUpdateReplica(event);
      //     updatedCount++;
      //     
      //   } catch (error) {
      //     console.error(`Failed to sync modified event ${event.id}:`, error);
      //   }
      // }
      // 
      // this.emit('incrementalSyncCompleted', {
      //   modifiedEvents: modifiedEvents.length,
      //   updatedCount,
      //   conflictCount,
      //   lastSyncDate
      // });
      // 
      // return {
      //   success: true,
      //   updatedCount,
      //   conflictCount
      // };
      
    } catch (error) {
      console.error('Incremental sync failed:', error);
      throw error;
    }
  }

  // =========================================================================
  // TODO-SYNC3: Implémentez la gestion des événements de mise à jour en temps réel
  // =========================================================================
  /**
   * Cette méthode doit écouter les événements et mettre à jour les répliques
   * 
   * Étapes :
   * 1. Parser le message d'événement reçu
   * 2. Trouver la réplique correspondante
   * 3. Appliquer la mise à jour si la version est plus récente
   * 4. Résoudre les conflits selon une stratégie définie
   * 5. Émettre un événement de mise à jour réussie/échouée
   */
  async handleEventUpdated(eventUpdateMessage) {
    try {
      // ⚠️  TODO: À implémenter par les étudiants
      
      // Exemple de solution :
      // // 1. Parser le message
      // const { eventId, eventData, version, timestamp } = eventUpdateMessage;
      // 
      // console.log(`📡 Received update for event ${eventId} v${version}`);
      // 
      // // 2. Trouver la réplique
      // const replica = await ReplicatedEvent.findOne({ 
      //   originalEventId: eventId 
      // });
      // 
      // if (!replica) {
      //   console.log(`Creating new replica for event ${eventId}`);
      //   await this.createOrUpdateReplica(eventData);
      //   return;
      // }
      // 
      // // 3. Vérifier la version
      // if (version <= replica.version) {
      //   console.log(`Skipping update: version ${version} <= current ${replica.version}`);
      //   return;
      // }
      // 
      // // 4. Appliquer la mise à jour
      // await this.createOrUpdateReplica(eventData);
      // 
      // this.emit('realtimeUpdateCompleted', {
      //   eventId,
      //   version,
      //   timestamp
      // });
      
    } catch (error) {
      console.error('Real-time event update failed:', error);
      this.emit('realtimeUpdateFailed', { error: error.message });
      throw error;
    }
  }

  // Méthodes utilitaires
  async fetchEventsFromService(lastSyncDate = null) {
    const eventsServiceUrl = process.env.EVENTS_SERVICE_URL || 'http://localhost:8080';
    const url = lastSyncDate 
      ? `${eventsServiceUrl}/api/events?modifiedSince=${lastSyncDate.toISOString()}`
      : `${eventsServiceUrl}/api/events`;
    
    const response = await axios.get(url);
    return response.data;
  }

  async getLastSyncDate() {
    const lastSynced = await ReplicatedEvent.findOne()
      .sort({ lastSyncedAt: -1 })
      .select('lastSyncedAt');
    
    return lastSynced ? lastSynced.lastSyncedAt : null;
  }

  async createOrUpdateReplica(eventData) {
    const replica = await ReplicatedEvent.findOneAndUpdate(
      { originalEventId: eventData.id },
      {
        name: eventData.name,
        description: eventData.description,
        eventDate: new Date(eventData.eventDate),
        location: eventData.location,
        totalCapacity: eventData.totalCapacity,
        currentBookedSeats: eventData.bookedSeats || 0,
        ticketPrice: eventData.ticketPrice,
        category: eventData.category?.name,
        status: eventData.status || 'active',
        lastSyncedAt: new Date(),
        version: eventData.version || 1
      },
      { 
        upsert: true, 
        new: true, 
        setDefaultsOnInsert: true 
      }
    );

    return replica;
  }
}

module.exports = { DataSyncService, ReplicatedEvent };
EOF

    # Service de résolution de conflits (TODO-CONFLICT1, TODO-CONFLICT2, TODO-CONFLICT3)
    cat > src/sync/conflict.resolution.js << 'EOF'
class ConflictResolutionService {
  
  // =========================================================================
  // TODO-CONFLICT1: Implémentez la détection de conflits de version
  // =========================================================================
  /**
   * Cette méthode doit détecter les conflits entre versions locales et distantes
   * 
   * Critères de détection :
   * 1. Comparer les numéros de version
   * 2. Comparer les timestamps de modification
   * 3. Identifier le type de conflit :
   *    - CONCURRENT_UPDATE: modifications simultanées
   *    - STALE_UPDATE: mise à jour sur une version obsolète
   *    - VERSION_MISMATCH: incohérence de version
   * 4. Retourner un objet décrivant le conflit
   * 
   * @param {Object} localData - Données locales
   * @param {Object} remoteData - Données distantes
   * @returns {Object} Information sur le conflit détecté
   */
  detectVersionConflict(localData, remoteData) {
    // ⚠️  TODO: À implémenter par les étudiants
    
    // Exemple de solution :
    // if (!localData || !remoteData) {
    //   return { hasConflict: false };
    // }
    // 
    // const conflict = {
    //   hasConflict: false,
    //   type: null,
    //   details: {}
    // };
    // 
    // // Comparer les versions
    // if (localData.version === remoteData.version && 
    //     localData.lastModified !== remoteData.lastModified) {
    //   conflict.hasConflict = true;
    //   conflict.type = 'CONCURRENT_UPDATE';
    //   conflict.details = {
    //     localVersion: localData.version,
    //     remoteVersion: remoteData.version,
    //     localModified: localData.lastModified,
    //     remoteModified: remoteData.lastModified
    //   };
    // } else if (remoteData.version < localData.version) {
    //   conflict.hasConflict = true;
    //   conflict.type = 'STALE_UPDATE';
    //   conflict.details = {
    //     message: 'Remote update is based on older version'
    //   };
    // }
    // 
    // return conflict;
    
    return { hasConflict: false }; // Placeholder - à remplacer
  }

  // =========================================================================
  // TODO-CONFLICT2: Implémentez la stratégie "Last Writer Wins"
  // =========================================================================
  /**
   * Cette stratégie résout les conflits en favorisant la dernière écriture
   * 
   * Logique :
   * 1. Comparer les timestamps de dernière modification
   * 2. Sélectionner les données avec le timestamp le plus récent
   * 3. Préserver certains champs critiques si nécessaire
   * 4. Retourner les données fusionnées
   * 
   * @param {Object} localData - Données locales
   * @param {Object} remoteData - Données distantes
   * @returns {Object} Données résolues selon Last Writer Wins
   */
  resolveConflictLastWriterWins(localData, remoteData) {
    // ⚠️  TODO: À implémenter par les étudiants
    
    // Exemple de solution :
    // if (!localData) return remoteData;
    // if (!remoteData) return localData;
    // 
    // const localTime = new Date(localData.lastModified || 0).getTime();
    // const remoteTime = new Date(remoteData.lastModified || 0).getTime();
    // 
    // // Sélectionner les données les plus récentes
    // const winner = localTime > remoteTime ? localData : remoteData;
    // 
    // // Optionnel : préserver certains champs critiques
    // const resolved = {
    //   ...winner,
    //   _conflictResolution: {
    //     strategy: 'LAST_WRITER_WINS',
    //     resolvedAt: new Date(),
    //     localTimestamp: localTime,
    //     remoteTimestamp: remoteTime,
    //     winner: localTime > remoteTime ? 'local' : 'remote'
    //   }
    // };
    // 
    // return resolved;
    
    return localData; // Placeholder - à remplacer
  }

  // =========================================================================
  // TODO-CONFLICT3: Implémentez la stratégie de merge intelligent
  // =========================================================================
  /**
   * Cette stratégie tente de fusionner les modifications non conflictuelles
   * 
   * Logique :
   * 1. Identifier les champs modifiés dans chaque version
   * 2. Pour les champs modifiés dans une seule version, prendre cette valeur
   * 3. Pour les champs modifiés dans les deux versions :
   *    - Si valeurs identiques, pas de conflit
   *    - Si valeurs différentes, appliquer une règle (ex: max, concat, etc.)
   * 4. Construire l'objet fusionné
   * 5. Marquer les champs en conflit pour revue manuelle si nécessaire
   * 
   * @param {Object} localData - Données locales
   * @param {Object} remoteData - Données distantes
   * @returns {Object} Données fusionnées intelligemment
   */
  resolveConflictIntelligentMerge(localData, remoteData) {
    // ⚠️  TODO: À implémenter par les étudiants
    
    // Exemple de solution :
    // if (!localData) return remoteData;
    // if (!remoteData) return localData;
    // 
    // const merged = {};
    // const conflicts = [];
    // 
    // // Obtenir tous les champs uniques
    // const allFields = new Set([
    //   ...Object.keys(localData),
    //   ...Object.keys(remoteData)
    // ]);
    // 
    // for (const field of allFields) {
    //   const localValue = localData[field];
    //   const remoteValue = remoteData[field];
    //   
    //   if (localValue === remoteValue) {
    //     // Pas de conflit
    //     merged[field] = localValue;
    //   } else if (localValue === undefined) {
    //     // Nouveau champ dans remote
    //     merged[field] = remoteValue;
    //   } else if (remoteValue === undefined) {
    //     // Champ supprimé dans remote
    //     merged[field] = localValue;
    //   } else {
    //     // Conflit réel - appliquer une stratégie
    //     if (field === 'bookedSeats' || field === 'totalRevenue') {
    //       // Pour les compteurs, prendre le maximum
    //       merged[field] = Math.max(localValue, remoteValue);
    //     } else if (field === 'lastModified') {
    //       // Pour les timestamps, prendre le plus récent
    //       merged[field] = new Date(localValue) > new Date(remoteValue) ? localValue : remoteValue;
    //     } else {
    //       // Pour les autres, marquer le conflit
    //       conflicts.push({
    //         field,
    //         localValue,
    //         remoteValue
    //       });
    //       merged[field] = remoteValue; // Favoriser remote par défaut
    //     }
    //   }
    // }
    // 
    // if (conflicts.length > 0) {
    //   merged._conflicts = conflicts;
    // }
    // 
    // merged._conflictResolution = {
    //   strategy: 'INTELLIGENT_MERGE',
    //   resolvedAt: new Date(),
    //   conflictCount: conflicts.length
    // };
    // 
    // return merged;
    
    return localData; // Placeholder - à remplacer
  }

  // Stratégies de résolution disponibles
  getResolutionStrategies() {
    return {
      LAST_WRITER_WINS: this.resolveConflictLastWriterWins.bind(this),
      INTELLIGENT_MERGE: this.resolveConflictIntelligentMerge.bind(this),
      MANUAL_RESOLUTION: this.flagForManualResolution.bind(this)
    };
  }

  flagForManualResolution(localData, remoteData) {
    // Marquer pour résolution manuelle
    return {
      requiresManualResolution: true,
      localData,
      remoteData,
      timestamp: new Date()
    };
  }
}

module.exports = ConflictResolutionService;
EOF

    # Contrôleur principal
    cat > src/controllers/event.store.controller.js << 'EOF'
const eventStoreService = require('../services/event.store.service');
const { DataSyncService } = require('../sync/data.sync.service');
const ConflictResolutionService = require('../sync/conflict.resolution');
const Joi = require('joi');

const dataSyncService = new DataSyncService();
const conflictResolver = new ConflictResolutionService();

const appendEventSchema = Joi.object({
  aggregateId: Joi.string().required(),
  aggregateType: Joi.string().valid('Event', 'Reservation', 'Payment', 'User').required(),
  eventType: Joi.string().required(),
  eventData: Joi.object().required(),
  metadata: Joi.object().optional()
});

class EventStoreController {
  
  async appendEvent(req, res) {
    try {
      const { error, value } = appendEventSchema.validate(req.body);
      if (error) {
        return res.status(400).json({ 
          error: 'Validation error', 
          details: error.details 
        });
      }
      
      const { aggregateId, aggregateType, eventType, eventData, metadata } = value;
      
      const domainEvent = await eventStoreService.appendEvent(
        aggregateId, 
        aggregateType, 
        eventType, 
        eventData, 
        metadata
      );
      
      res.status(201).json({
        success: true,
        event: domainEvent,
        message: 'Event appended successfully to event store'
      });
      
    } catch (error) {
      console.error('❌ Error appending event:', error);
      if (error.message.includes('Version conflict')) {
        res.status(409).json({ 
          error: 'Version conflict', 
          message: error.message 
        });
      } else {
        res.status(500).json({ 
          error: 'Failed to append event', 
          message: error.message 
        });
      }
    }
  }

  async getAggregateHistory(req, res) {
    try {
      const { aggregateId } = req.params;
      const { fromVersion = 0 } = req.query;
      
      const events = await eventStoreService.getAggregateHistory(
        aggregateId, 
        parseInt(fromVersion)
      );
      
      res.json({
        aggregateId,
        events,
        count: events.length,
        fromVersion: parseInt(fromVersion)
      });
      
    } catch (error) {
      console.error('❌ Error getting aggregate history:', error);
      res.status(500).json({ 
        error: 'Failed to get aggregate history', 
        message: error.message 
      });
    }
  }

  async getEventsByType(req, res) {
    try {
      const { eventType } = req.params;
      const { fromDate, toDate, limit = 100 } = req.query;
      
      const events = await eventStoreService.getEventsByType(eventType, {
        fromDate: fromDate ? new Date(fromDate) : undefined,
        toDate: toDate ? new Date(toDate) : undefined,
        limit: parseInt(limit)
      });
      
      res.json({
        eventType,
        events,
        count: events.length,
        filters: { fromDate, toDate, limit: parseInt(limit) }
      });
      
    } catch (error) {
      console.error('❌ Error getting events by type:', error);
      res.status(500).json({ 
        error: 'Failed to get events by type', 
        message: error.message 
      });
    }
  }

  async getAllEvents(req, res) {
    try {
      const { 
        limit = 100, 
        offset = 0, 
        aggregateType, 
        eventType 
      } = req.query;
      
      const events = await eventStoreService.getAllEvents({
        limit: parseInt(limit),
        offset: parseInt(offset),
        aggregateType,
        eventType
      });
      
      res.json({
        events,
        count: events.length,
        pagination: {
          limit: parseInt(limit),
          offset: parseInt(offset)
        },
        filters: { aggregateType, eventType }
      });
      
    } catch (error) {
      console.error('❌ Error getting all events:', error);
      res.status(500).json({ 
        error: 'Failed to get events', 
        message: error.message 
      });
    }
  }

  async reconstructAggregateState(req, res) {
    try {
      const { aggregateId } = req.params;
      const { toVersion } = req.query;
      
      const state = await eventStoreService.reconstructAggregateState(
        aggregateId, 
        toVersion ? parseInt(toVersion) : null
      );
      
      if (!state) {
        return res.status(404).json({
          error: 'Aggregate not found',
          aggregateId
        });
      }
      
      res.json({
        reconstructedState: state,
        aggregateId,
        toVersion: toVersion ? parseInt(toVersion) : 'latest'
      });
      
    } catch (error) {
      console.error('❌ Error reconstructing aggregate state:', error);
      res.status(500).json({ 
        error: 'Failed to reconstruct aggregate state', 
        message: error.message 
      });
    }
  }

  async getMetrics(req, res) {
    try {
      const metrics = await eventStoreService.getEventStreamMetrics();
      res.json({
        message: '📊 Event Store Metrics',
        metrics
      });
    } catch (error) {
      console.error('❌ Error getting metrics:', error);
      res.status(500).json({ 
        error: 'Failed to get metrics', 
        message: error.message 
      });
    }
  }

  // Endpoints de synchronisation
  async performSync(req, res) {
    try {
      const { type = 'incremental' } = req.body;
      
      let result;
      if (type === 'initial') {
        result = await dataSyncService.performInitialSync();
      } else {
        result = await dataSyncService.performIncrementalSync();
      }
      
      res.json({
        success: true,
        syncType: type,
        result
      });
      
    } catch (error) {
      console.error('❌ Error performing sync:', error);
      res.status(500).json({ 
        error: 'Failed to perform sync', 
        message: error.message 
      });
    }
  }

  async handleRealtimeUpdate(req, res) {
    try {
      const updateMessage = req.body;
      await dataSyncService.handleEventUpdated(updateMessage);
      
      res.json({
        success: true,
        message: 'Realtime update processed'
      });
      
    } catch (error) {
      console.error('❌ Error handling realtime update:', error);
      res.status(500).json({ 
        error: 'Failed to process realtime update', 
        message: error.message 
      });
    }
  }

  async resolveConflict(req, res) {
    try {
      const { localData, remoteData, strategy = 'LAST_WRITER_WINS' } = req.body;
      
      // Détecter le conflit
      const conflict = conflictResolver.detectVersionConflict(localData, remoteData);
      
      if (!conflict.hasConflict) {
        return res.json({
          hasConflict: false,
          message: 'No conflict detected'
        });
      }
      
      // Résoudre selon la stratégie
      const strategies = conflictResolver.getResolutionStrategies();
      const resolveFunction = strategies[strategy];
      
      if (!resolveFunction) {
        return res.status(400).json({
          error: 'Invalid resolution strategy',
          availableStrategies: Object.keys(strategies)
        });
      }
      
      const resolved = resolveFunction(localData, remoteData);
      
      res.json({
        hasConflict: true,
        conflictType: conflict.type,
        conflictDetails: conflict.details,
        resolution: {
          strategy,
          resolvedData: resolved
        }
      });
      
    } catch (error) {
      console.error('❌ Error resolving conflict:', error);
      res.status(500).json({ 
        error: 'Failed to resolve conflict', 
        message: error.message 
      });
    }
  }
}

module.exports = new EventStoreController();
EOF

    # Application principale
    cat > src/app.js << 'EOF'
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
require('dotenv').config();

const connectDB = require('./config/database');
const eventStoreController = require('./controllers/event.store.controller');

const app = express();
const PORT = process.env.PORT || 3001;

// Middleware
app.use(helmet());
app.use(cors());
app.use(morgan('combined'));
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));

// Connexion à MongoDB
connectDB();

// Routes principales
app.get('/', (req, res) => {
  res.json({
    message: '📚 Event Store Service API - Event Sourcing + CQRS',
    version: '1.0.0',
    database: 'MongoDB',
    patterns: ['Event Sourcing', 'CQRS', 'Immutable Event Log', 'Data Synchronization', 'Conflict Resolution'],
    capabilities: [
      'Immutable event storage',
      'Aggregate reconstruction',
      'Time travel queries',
      'Complete audit trail',
      'Data synchronization',
      'Conflict resolution'
    ],
    endpoints: {
      events: '/api/events',
      aggregates: '/api/aggregates',
      sync: '/api/sync',
      conflicts: '/api/conflicts',
      metrics: '/api/metrics',
      health: '/health'
    }
  });
});

app.get('/health', (req, res) => {
  res.json({ 
    status: 'OK', 
    timestamp: new Date().toISOString(),
    service: 'event-store-service',
    database: 'MongoDB (Event Sourcing)'
  });
});

// Routes de l'Event Store
app.post('/api/events', eventStoreController.appendEvent);
app.get('/api/events', eventStoreController.getAllEvents);
app.get('/api/events/type/:eventType', eventStoreController.getEventsByType);
app.get('/api/aggregates/:aggregateId/history', eventStoreController.getAggregateHistory);
app.get('/api/aggregates/:aggregateId/reconstruct', eventStoreController.reconstructAggregateState);
app.get('/api/metrics', eventStoreController.getMetrics);

// Routes de synchronisation
app.post('/api/sync', eventStoreController.performSync);
app.post('/api/sync/realtime', eventStoreController.handleRealtimeUpdate);

// Routes de résolution de conflits
app.post('/api/conflicts/resolve', eventStoreController.resolveConflict);

// Gestionnaire d'erreurs global
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({
    error: 'Internal Server Error',
    message: process.env.NODE_ENV === 'development' ? err.message : 'Something went wrong'
  });
});

// 404 handler
app.use('*', (req, res) => {
  res.status(404).json({
    error: 'Not Found',
    message: `Route ${req.originalUrl} not found`
  });
});

app.listen(PORT, () => {
  console.log(`🚀 Event Store Service running on port ${PORT}`);
  console.log(`📚 Providing Event Sourcing, CQRS, Sync and Conflict Resolution capabilities`);
});

module.exports = app;
EOF

    # Dockerfile CORRIGÉ - utilise npm install au lieu de npm ci
    cat > Dockerfile << 'EOF'
FROM node:18-alpine

WORKDIR /app

# Copier package.json uniquement
COPY package.json ./

# Installer les dépendances et générer package-lock.json
RUN npm install --production

# Copier le code source
COPY src ./src

EXPOSE 3001

CMD ["npm", "start"]
EOF

    cd ../..
    echo "✅ Service Event Store créé avec tous les TODOs"
}

# =============================================================================
# SAGA ORCHESTRATOR (Node.js)
# Gestion des transactions distribuées
# =============================================================================

create_saga_orchestrator() {
    echo "📦 Saga Orchestrator (Node.js)..."
    
    cd tp4-microservices-persistence/saga-orchestrator
    
    # Créer les répertoires nécessaires
    mkdir -p src/{orchestrators,services,models,config,utils,controllers}
    
    # package.json
    cat > package.json << 'EOF'
{
  "name": "saga-orchestrator",
  "version": "1.0.0",
  "description": "Orchestrateur Saga pour transactions distribuées",
  "main": "src/app.js",
  "scripts": {
    "start": "node src/app.js",
    "dev": "nodemon src/app.js",
    "test": "jest"
  },
  "dependencies": {
    "express": "^4.18.2",
    "cors": "^2.8.5",
    "helmet": "^7.1.0",
    "morgan": "^1.10.0",
    "dotenv": "^16.3.1",
    "axios": "^1.6.2",
    "uuid": "^9.0.1",
    "joi": "^17.11.0"
  },
  "devDependencies": {
    "nodemon": "^3.0.2",
    "jest": "^29.7.0"
  }
}
EOF

    # Orchestrateur Saga principal avec TODOs
    cat > src/orchestrators/saga.orchestrator.js << 'EOF'
const EventEmitter = require('events');
const axios = require('axios');

/**
 * Orchestrateur Saga - Gestion des transactions distribuées
 * 
 * Implémente le pattern Saga avec orchestration centralisée pour :
 * - Coordonner les transactions entre microservices
 * - Gérer les compensations en cas d'échec
 * - Maintenir la cohérence sans verrouillage distribué
 * - Tracer toutes les étapes pour l'audit
 */
class SagaOrchestrator extends EventEmitter {
  constructor() {
    super();
    this.activeSagas = new Map();
    this.serviceEndpoints = {
      events: process.env.EVENTS_SERVICE_URL || 'http://localhost:8080',
      reservations: process.env.RESERVATIONS_SERVICE_URL || 'http://localhost:3000',
      payments: process.env.PAYMENTS_SERVICE_URL || 'http://localhost:5000',
      notifications: process.env.NOTIFICATIONS_SERVICE_URL || 'http://localhost:5001'
    };
    
    console.log('🎭 Saga Orchestrator initialized with endpoints:', this.serviceEndpoints);
  }

  // =========================================================================
  // TODO-SAGA1: Implémentez la méthode pour démarrer un nouveau Saga
  // =========================================================================
  /**
   * Cette méthode doit initialiser le state du Saga et exécuter la première étape.
   * 
   * Flux complet : Réservation → Paiement → Confirmation → Notification
   * 
   * Logique :
   * 1. Générer un ID unique pour le Saga
   * 2. Initialiser la structure de données du Saga
   * 3. Exécuter la première étape (réservation)
   * 4. Si succès, passer à l'étape suivante
   * 5. Si échec, déclencher la compensation
   * 6. Retourner l'ID du Saga pour le suivi
   */
  async startBookingProcessSaga(sagaData) {
    const sagaId = this.generateSagaId();
    const saga = {
      id: sagaId,
      type: 'BOOKING_PROCESS',
      status: 'STARTED',
      data: sagaData,
      steps: [],
      currentStep: 0,
      createdAt: new Date(),
      updatedAt: new Date()
    };

    this.activeSagas.set(sagaId, saga);
    
    try {
      console.log(`🚀 Starting Saga ${sagaId} for booking process`);
      
      // ⚠️  TODO: À implémenter par les étudiants
      
      // Exemple de solution :
      // // Étape 1: Réservation
      // await this.executeReservationStep(sagaId);
      // 
      // // Si réservation réussie, passer au paiement
      // saga.currentStep = 1;
      // await this.executePaymentStep(sagaId);
      // 
      // // Si tout réussit, marquer comme complété
      // saga.status = 'COMPLETED';
      // await this.recordSagaStep(sagaId, 'SAGA_COMPLETED', {}, 'COMPLETED');
      
      return sagaId; // Placeholder - à améliorer
      
    } catch (error) {
      await this.handleSagaFailure(sagaId, error);
      throw error;
    }
  }

  // =========================================================================
  // TODO-SAGA2: Implémentez l'étape de réservation
  // =========================================================================
  /**
   * Cette étape doit vérifier la disponibilité et créer la réservation.
   * 
   * Actions :
   * 1. Appeler le service de réservation avec les données du Saga
   * 2. Enregistrer l'étape dans l'historique du Saga
   * 3. Stocker l'ID de réservation pour compensation future
   * 4. Gérer les erreurs et exceptions
   */
  async executeReservationStep(sagaId) {
    // ⚠️  TODO: À implémenter par les étudiants
    
    // Exemple de solution :
    // const saga = this.activeSagas.get(sagaId);
    // if (!saga) throw new Error(`Saga ${sagaId} not found`);
    // 
    // try {
    //   console.log(`📝 Executing reservation step for Saga ${sagaId}`);
    //   
    //   const reservationData = {
    //     eventId: saga.data.eventId,
    //     userId: saga.data.userId,
    //     userName: saga.data.userName,
    //     userEmail: saga.data.userEmail,
    //     seats: saga.data.seats
    //   };
    //   
    //   const response = await axios.post(
    //     `${this.serviceEndpoints.reservations}/api/reservations`,
    //     reservationData
    //   );
    //   
    //   // Enregistrer l'ID de réservation pour compensation future
    //   saga.data.reservationId = response.data.reservation._id;
    //   
    //   await this.recordSagaStep(sagaId, 'RESERVATION_CREATED', {
    //     reservationId: response.data.reservation._id,
    //     seats: saga.data.seats
    //   });
    //   
    //   console.log(`✅ Reservation step completed for Saga ${sagaId}`);
    //   
    // } catch (error) {
    //   await this.recordSagaStep(sagaId, 'RESERVATION_FAILED', { error: error.message }, 'FAILED');
    //   throw error;
    // }
    
    console.log('⚠️  TODO: Implement executeReservationStep');
  }

  // =========================================================================
  // TODO-SAGA3: Implémentez l'étape de paiement
  // =========================================================================
  /**
   * Cette étape doit traiter le paiement si la réservation a réussi.
   * 
   * Actions :
   * 1. Calculer le montant basé sur le nombre de places et le prix
   * 2. Appeler le service de paiement
   * 3. Enregistrer l'ID de paiement pour compensation
   * 4. Mettre à jour l'historique du Saga
   */
  async executePaymentStep(sagaId) {
    // ⚠️  TODO: À implémenter par les étudiants
    
    // Exemple de solution :
    // const saga = this.activeSagas.get(sagaId);
    // if (!saga) throw new Error(`Saga ${sagaId} not found`);
    // 
    // try {
    //   console.log(`💳 Executing payment step for Saga ${sagaId}`);
    //   
    //   const paymentData = {
    //     reservation_id: saga.data.reservationId,
    //     user_id: saga.data.userId,
    //     amount: saga.data.seats * saga.data.ticketPrice,
    //     currency: 'XOF',
    //     payment_method: saga.data.paymentMethod || 'card'
    //   };
    //   
    //   const response = await axios.post(
    //     `${this.serviceEndpoints.payments}/api/payments`,
    //     paymentData
    //   );
    //   
    //   saga.data.paymentId = response.data.payment.id;
    //   
    //   await this.recordSagaStep(sagaId, 'PAYMENT_COMPLETED', {
    //     paymentId: response.data.payment.id,
    //     amount: paymentData.amount
    //   });
    //   
    //   console.log(`✅ Payment step completed for Saga ${sagaId}`);
    //   
    // } catch (error) {
    //   await this.recordSagaStep(sagaId, 'PAYMENT_FAILED', { error: error.message }, 'FAILED');
    //   throw error;
    // }
    
    console.log('⚠️  TODO: Implement executePaymentStep');
  }

  // =========================================================================
  // TODO-SAGA4: Implémentez la gestion des compensations
  // =========================================================================
  /**
   * Cette méthode doit annuler les étapes précédentes en cas d'échec.
   * 
   * Principe de compensation :
   * 1. Identifier quelles étapes ont été complétées
   * 2. Exécuter les compensations dans l'ordre inverse
   * 3. Enregistrer chaque compensation effectuée
   * 4. Marquer le Saga comme compensé
   */
  async executeSagaCompensation(sagaId, failedStep) {
    // ⚠️  TODO: À implémenter par les étudiants
    
    // Exemple de solution :
    // const saga = this.activeSagas.get(sagaId);
    // if (!saga) return;
    // 
    // console.log(`🔄 Starting compensation for Saga ${sagaId} at step ${failedStep}`);
    // 
    // try {
    //   // Compenser les étapes dans l'ordre inverse
    //   const completedSteps = saga.steps.filter(step => step.status === 'COMPLETED');
    //   
    //   for (let i = completedSteps.length - 1; i >= 0; i--) {
    //     const step = completedSteps[i];
    //     
    //     if (step.name === 'PAYMENT_COMPLETED' && saga.data.paymentId) {
    //       await this.compensatePayment(sagaId, saga.data.paymentId);
    //     } else if (step.name === 'RESERVATION_CREATED' && saga.data.reservationId) {
    //       await this.compensateReservation(sagaId, saga.data.reservationId);
    //     }
    //   }
    //   
    //   saga.status = 'COMPENSATED';
    //   await this.recordSagaStep(sagaId, 'SAGA_COMPENSATED', {}, 'COMPENSATED');
    //   
    // } catch (error) {
    //   console.error(`❌ Error during compensation for Saga ${sagaId}:`, error);
    //   saga.status = 'COMPENSATION_FAILED';
    // }
    
    console.log('⚠️  TODO: Implement executeSagaCompensation');
  }

  // Méthodes utilitaires
  generateSagaId() {
    return `SAGA-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`;
  }

  async recordSagaStep(sagaId, stepName, data, status = 'COMPLETED') {
    const saga = this.activeSagas.get(sagaId);
    if (!saga) return;

    const step = {
      name: stepName,
      status,
      data,
      timestamp: new Date()
    };

    saga.steps.push(step);
    saga.updatedAt = new Date();
    
    console.log(`📝 Saga ${sagaId} - Step recorded: ${stepName} (${status})`);
    this.emit('saga-step', { sagaId, step });
  }

  async handleSagaFailure(sagaId, error) {
    const saga = this.activeSagas.get(sagaId);
    if (!saga) return;

    console.error(`❌ Saga ${sagaId} failed:`, error.message);
    saga.status = 'FAILED';
    saga.error = error.message;
    
    await this.recordSagaStep(sagaId, 'SAGA_FAILED', { error: error.message }, 'FAILED');
    
    // Déclencher les compensations
    await this.executeSagaCompensation(sagaId, saga.currentStep);
  }

  async compensateReservation(sagaId, reservationId) {
    try {
      console.log(`🔄 Compensating reservation ${reservationId} for Saga ${sagaId}`);
      
      await axios.post(
        `${this.serviceEndpoints.reservations}/api/reservations/${reservationId}/compensate`,
        { reason: 'Saga compensation' }
      );
      
      await this.recordSagaStep(sagaId, 'RESERVATION_COMPENSATED', { reservationId });
      
    } catch (error) {
      console.error(`❌ Failed to compensate reservation ${reservationId}:`, error);
      throw error;
    }
  }

  async compensatePayment(sagaId, paymentId) {
    try {
      console.log(`🔄 Compensating payment ${paymentId} for Saga ${sagaId}`);
      
      await axios.post(
        `${this.serviceEndpoints.payments}/api/payments/${paymentId}/compensate`,
        { reason: 'Saga compensation' }
      );
      
      await this.recordSagaStep(sagaId, 'PAYMENT_COMPENSATED', { paymentId });
      
    } catch (error) {
      console.error(`❌ Failed to compensate payment ${paymentId}:`, error);
      throw error;
    }
  }

  getSaga(sagaId) {
    return this.activeSagas.get(sagaId);
  }

  getAllSagas() {
    return Array.from(this.activeSagas.values());
  }
}

module.exports = SagaOrchestrator;
EOF

    # Controller du Saga
    cat > src/controllers/saga.controller.js << 'EOF'
const SagaOrchestrator = require('../orchestrators/saga.orchestrator');
const Joi = require('joi');

const sagaOrchestrator = new SagaOrchestrator();

// Schema de validation
const startSagaSchema = Joi.object({
  eventId: Joi.number().required(),
  userId: Joi.string().required(),
  userName: Joi.string().required(),
  userEmail: Joi.string().email().required(),
  userPhone: Joi.string().optional(),
  seats: Joi.number().min(1).required(),
  ticketPrice: Joi.number().required(),
  paymentMethod: Joi.string().valid('card', 'mobile_money', 'bank_transfer').required(),
  preferences: Joi.object().optional()
});

class SagaController {
  
  async startBookingSaga(req, res) {
    try {
      const { error, value } = startSagaSchema.validate(req.body);
      if (error) {
        return res.status(400).json({ 
          error: 'Validation error', 
          details: error.details 
        });
      }
      
      console.log('🎭 Starting new booking saga with data:', value);
      
      const sagaId = await sagaOrchestrator.startBookingProcessSaga(value);
      
      res.status(202).json({
        message: 'Booking process started',
        sagaId,
        status: 'PROCESSING'
      });
      
    } catch (error) {
      console.error('❌ Error starting saga:', error);
      res.status(500).json({ 
        error: 'Failed to start booking process', 
        message: error.message 
      });
    }
  }

  async getSagaStatus(req, res) {
    try {
      const { sagaId } = req.params;
      const saga = sagaOrchestrator.getSaga(sagaId);
      
      if (!saga) {
        return res.status(404).json({
          error: 'Saga not found',
          sagaId
        });
      }
      
      res.json({
        sagaId: saga.id,
        type: saga.type,
        status: saga.status,
        currentStep: saga.currentStep,
        steps: saga.steps,
        createdAt: saga.createdAt,
        updatedAt: saga.updatedAt,
        error: saga.error
      });
      
    } catch (error) {
      console.error('❌ Error getting saga status:', error);
      res.status(500).json({ 
        error: 'Failed to get saga status', 
        message: error.message 
      });
    }
  }

  async getAllSagas(req, res) {
    try {
      const sagas = sagaOrchestrator.getAllSagas();
      
      res.json({
        count: sagas.length,
        sagas: sagas.map(saga => ({
          sagaId: saga.id,
          type: saga.type,
          status: saga.status,
          createdAt: saga.createdAt,
          updatedAt: saga.updatedAt
        }))
      });
      
    } catch (error) {
      console.error('❌ Error getting all sagas:', error);
      res.status(500).json({ 
        error: 'Failed to get sagas', 
        message: error.message 
      });
    }
  }
}

module.exports = new SagaController();
EOF

    # Application principale
    cat > src/app.js << 'EOF'
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
require('dotenv').config();

const sagaController = require('./controllers/saga.controller');

const app = express();
const PORT = process.env.PORT || 3002;

// Middleware
app.use(helmet());
app.use(cors());
app.use(morgan('combined'));
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));

// Routes principales
app.get('/', (req, res) => {
  res.json({
    message: '🎭 Saga Orchestrator - Distributed Transaction Management',
    version: '1.0.0',
    patterns: ['Saga Pattern', 'Orchestration', 'Compensation'],
    capabilities: [
      'Distributed transaction coordination',
      'Automatic compensation on failure',
      'Step-by-step transaction tracking',
      'Idempotent operations'
    ],
    endpoints: {
      startSaga: '/api/saga/booking',
      sagaStatus: '/api/saga/:sagaId',
      allSagas: '/api/saga',
      health: '/health'
    }
  });
});

app.get('/health', (req, res) => {
  res.json({ 
    status: 'OK', 
    timestamp: new Date().toISOString(),
    service: 'saga-orchestrator'
  });
});

// Routes du Saga
app.post('/api/saga/booking', sagaController.startBookingSaga);
app.get('/api/saga/:sagaId', sagaController.getSagaStatus);
app.get('/api/saga', sagaController.getAllSagas);

// Gestionnaire d'erreurs global
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({
    error: 'Internal Server Error',
    message: process.env.NODE_ENV === 'development' ? err.message : 'Something went wrong'
  });
});

// 404 handler
app.use('*', (req, res) => {
  res.status(404).json({
    error: 'Not Found',
    message: `Route ${req.originalUrl} not found`
  });
});

app.listen(PORT, () => {
  console.log(`🚀 Saga Orchestrator running on port ${PORT}`);
  console.log(`🎭 Managing distributed transactions across microservices`);
});

module.exports = app;
EOF

    # Dockerfile CORRIGÉ - utilise npm install au lieu de npm ci
    cat > Dockerfile << 'EOF'
FROM node:18-alpine

WORKDIR /app

# Copier package.json uniquement
COPY package.json ./

# Installer les dépendances et générer package-lock.json
RUN npm install --production

# Copier le code source
COPY src ./src

EXPOSE 3002

CMD ["npm", "start"]
EOF

    cd ../..
    echo "✅ Saga Orchestrator créé"
}

# =============================================================================
# SERVICE NOTIFICATIONS (Python/Flask + MongoDB)
# =============================================================================

create_notification_service() {
    echo "📦 Service Notifications (Python/Flask + MongoDB)..."
    
    cd tp4-microservices-persistence/notification-service
    
    # Créer les répertoires nécessaires
    mkdir -p {models,services,controllers,config,utils,templates}
    
    # requirements.txt
    cat > requirements.txt << 'EOF'
Flask==3.0.0
pymongo==4.6.1
flask-cors==4.0.0
requests==2.31.0
python-dotenv==1.0.0
marshmallow==3.20.1
gunicorn==21.2.0
pika==1.3.2
jinja2==3.1.2
EOF

    # Configuration
    cat > config.py << 'EOF'
import os
from pymongo import MongoClient

# Configuration MongoDB
MONGODB_URI = os.getenv('MONGODB_URI', 'mongodb://localhost:27017/')
MONGODB_DB = os.getenv('MONGODB_DB', 'notifications_db')

# Configuration RabbitMQ
RABBITMQ_HOST = os.getenv('RABBITMQ_HOST', 'localhost')
RABBITMQ_PORT = int(os.getenv('RABBITMQ_PORT', '5672'))

# Connexion MongoDB
mongo_client = MongoClient(MONGODB_URI)
db = mongo_client[MONGODB_DB]

# Collections
notifications_collection = db['notifications']
templates_collection = db['templates']
EOF

    # Modèle de notification
    cat > models/notification.py << 'EOF'
from datetime import datetime
from config import notifications_collection
import uuid

class Notification:
    def __init__(self, user_id, type, subject, content, channel='email'):
        self.id = str(uuid.uuid4())
        self.user_id = user_id
        self.type = type  # booking_confirmation, payment_success, etc.
        self.subject = subject
        self.content = content
        self.channel = channel  # email, sms, push
        self.status = 'pending'  # pending, sent, failed
        self.created_at = datetime.now()
        self.sent_at = None
        self.metadata = {}
    
    def to_dict(self):
        return {
            '_id': self.id,
            'user_id': self.user_id,
            'type': self.type,
            'subject': self.subject,
            'content': self.content,
            'channel': self.channel,
            'status': self.status,
            'created_at': self.created_at,
            'sent_at': self.sent_at,
            'metadata': self.metadata
        }
    
    def save(self):
        notifications_collection.insert_one(self.to_dict())
        return self
    
    @staticmethod
    def find_by_id(notification_id):
        return notifications_collection.find_one({'_id': notification_id})
    
    @staticmethod
    def find_by_user(user_id):
        return list(notifications_collection.find({'user_id': user_id}).sort('created_at', -1))
    
    @staticmethod
    def mark_as_sent(notification_id):
        notifications_collection.update_one(
            {'_id': notification_id},
            {'$set': {'status': 'sent', 'sent_at': datetime.now()}}
        )
EOF

    # Service de notification
    cat > services/notification_service.py << 'EOF'
from models.notification import Notification
from config import templates_collection
import logging

logger = logging.getLogger(__name__)

class NotificationService:
    
    def create_booking_notification(self, booking_data):
        """Crée une notification de confirmation de réservation"""
        try:
            notification = Notification(
                user_id=booking_data['user_id'],
                type='booking_confirmation',
                subject=f'Confirmation de réservation - {booking_data["event_name"]}',
                content=self._render_booking_template(booking_data),
                channel='email'
            )
            
            notification.metadata = {
                'reservation_id': booking_data.get('reservation_id'),
                'event_id': booking_data.get('event_id'),
                'seats': booking_data.get('seats')
            }
            
            notification.save()
            logger.info(f"✅ Booking notification created: {notification.id}")
            
            # Simuler l'envoi (dans un vrai système, cela serait asynchrone)
            self._send_notification(notification)
            
            return notification
            
        except Exception as e:
            logger.error(f"❌ Error creating booking notification: {e}")
            raise e
    
    def create_payment_notification(self, payment_data):
        """Crée une notification de confirmation de paiement"""
        try:
            notification = Notification(
                user_id=payment_data['user_id'],
                type='payment_success',
                subject='Paiement confirmé',
                content=self._render_payment_template(payment_data),
                channel='email'
            )
            
            notification.metadata = {
                'payment_id': payment_data.get('payment_id'),
                'amount': payment_data.get('amount'),
                'currency': payment_data.get('currency', 'XOF')
            }
            
            notification.save()
            logger.info(f"✅ Payment notification created: {notification.id}")
            
            self._send_notification(notification)
            
            return notification
            
        except Exception as e:
            logger.error(f"❌ Error creating payment notification: {e}")
            raise e
    
    def _render_booking_template(self, data):
        """Génère le contenu HTML pour une notification de réservation"""
        return f"""
        <h2>Réservation confirmée !</h2>
        <p>Bonjour {data.get('user_name', 'Client')},</p>
        <p>Votre réservation pour l'événement <strong>{data.get('event_name', 'N/A')}</strong> a été confirmée.</p>
        <ul>
            <li>Nombre de places : {data.get('seats', 0)}</li>
            <li>Date de l'événement : {data.get('event_date', 'N/A')}</li>
            <li>Lieu : {data.get('location', 'N/A')}</li>
        </ul>
        <p>Numéro de réservation : <strong>{data.get('reservation_id', 'N/A')}</strong></p>
        <p>Merci pour votre confiance !</p>
        """
    
    def _render_payment_template(self, data):
        """Génère le contenu HTML pour une notification de paiement"""
        return f"""
        <h2>Paiement confirmé !</h2>
        <p>Bonjour,</p>
        <p>Votre paiement de <strong>{data.get('amount', 0)} {data.get('currency', 'XOF')}</strong> a été confirmé.</p>
        <p>Référence de paiement : <strong>{data.get('payment_id', 'N/A')}</strong></p>
        <p>Merci pour votre transaction !</p>
        """
    
    def _send_notification(self, notification):
        """Simule l'envoi de notification (email, SMS, etc.)"""
        try:
            # Dans un vrai système, on utiliserait un service d'email (SendGrid, AWS SES, etc.)
            logger.info(f"📧 Sending {notification.channel} notification to user {notification.user_id}")
            logger.info(f"   Subject: {notification.subject}")
            
            # Simuler un délai d'envoi
            import time
            time.sleep(0.5)
            
            # Marquer comme envoyé
            Notification.mark_as_sent(notification.id)
            logger.info(f"✅ Notification {notification.id} sent successfully")
            
        except Exception as e:
            logger.error(f"❌ Failed to send notification {notification.id}: {e}")
            raise e

notification_service = NotificationService()
EOF

    # API Flask
    cat > app.py << 'EOF'
from flask import Flask, request, jsonify
from flask_cors import CORS
import logging
from datetime import datetime
from services.notification_service import notification_service
from models.notification import Notification

app = Flask(__name__)
CORS(app)

# Configuration du logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

@app.route('/', methods=['GET'])
def health_check():
    return jsonify({
        'message': '📬 Notification Service API - MongoDB',
        'version': '1.0.0',
        'status': 'healthy',
        'database': 'MongoDB',
        'patterns': ['Database per Service', 'Event-Driven Notifications'],
        'endpoints': {
            'notifications': '/api/notifications',
            'user_notifications': '/api/notifications/user/{user_id}',
            'health': '/health'
        }
    })

@app.route('/health', methods=['GET'])
def health():
    return jsonify({
        'status': 'OK',
        'service': 'notification-service',
        'timestamp': datetime.now().isoformat(),
        'database': 'MongoDB'
    })

@app.route('/api/notifications/booking', methods=['POST'])
def create_booking_notification():
    try:
        data = request.get_json()
        logger.info(f"📧 Creating booking notification: {data}")
        
        notification = notification_service.create_booking_notification(data)
        
        return jsonify({
            'success': True,
            'notification_id': notification.id,
            'message': 'Booking notification created and sent'
        }), 201
        
    except Exception as e:
        logger.error(f"❌ Error creating booking notification: {e}")
        return jsonify({
            'error': 'Failed to create notification',
            'message': str(e)
        }), 500

@app.route('/api/notifications/payment', methods=['POST'])
def create_payment_notification():
    try:
        data = request.get_json()
        logger.info(f"💳 Creating payment notification: {data}")
        
        notification = notification_service.create_payment_notification(data)
        
        return jsonify({
            'success': True,
            'notification_id': notification.id,
            'message': 'Payment notification created and sent'
        }), 201
        
    except Exception as e:
        logger.error(f"❌ Error creating payment notification: {e}")
        return jsonify({
            'error': 'Failed to create notification',
            'message': str(e)
        }), 500

@app.route('/api/notifications/<notification_id>', methods=['GET'])
def get_notification(notification_id):
    try:
        notification = Notification.find_by_id(notification_id)
        if not notification:
            return jsonify({'error': 'Notification not found'}), 404
        
        return jsonify(notification)
        
    except Exception as e:
        logger.error(f"❌ Error getting notification {notification_id}: {e}")
        return jsonify({
            'error': 'Failed to get notification',
            'message': str(e)
        }), 500

@app.route('/api/notifications/user/<user_id>', methods=['GET'])
def get_user_notifications(user_id):
    try:
        notifications = Notification.find_by_user(user_id)
        
        return jsonify({
            'user_id': user_id,
            'count': len(notifications),
            'notifications': notifications
        })
        
    except Exception as e:
        logger.error(f"❌ Error getting notifications for user {user_id}: {e}")
        return jsonify({
            'error': 'Failed to get user notifications',
            'message': str(e)
        }), 500

@app.errorhandler(404)
def not_found(error):
    return jsonify({'error': 'Not found'}), 404

@app.errorhandler(500)
def internal_error(error):
    return jsonify({'error': 'Internal server error'}), 500

if __name__ == '__main__':
    import os
    port = int(os.environ.get('PORT', 5001))
    debug = os.environ.get('DEBUG', 'false').lower() == 'true'
    logger.info(f"🚀 Starting Notification Service on port {port}")
    logger.info(f"💾 Using MongoDB for storage")
    app.run(host='0.0.0.0', port=port, debug=debug)
EOF

    # Dockerfile
    cat > Dockerfile << 'EOF'
FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 5001

CMD ["gunicorn", "--bind", "0.0.0.0:5001", "--workers", "4", "app:app"]
EOF

    cd ../..
    echo "✅ Service Notifications créé (MongoDB)"
}

# =============================================================================
# CRÉATION DU FICHIER DOCKER-COMPOSE
# =============================================================================

create_docker_compose() {
    echo "📦 Création du fichier docker-compose.yml..."
    
    cd tp4-microservices-persistence
    
    cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  # =============================================================================
  # BASES DE DONNÉES
  # =============================================================================
  
  # PostgreSQL pour événements
  postgres-events:
    image: postgres:16-alpine
    container_name: postgres-events
    environment:
      POSTGRES_DB: events_db
      POSTGRES_USER: events_user
      POSTGRES_PASSWORD: events_password
    ports:
      - "5432:5432"
    volumes:
      - postgres-events-data:/var/lib/postgresql/data
    networks:
      - microservices-network
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U events_user -d events_db"]
      interval: 10s
      timeout: 5s
      retries: 5

  # PostgreSQL pour paiements
  postgres-payments:
    image: postgres:16-alpine
    container_name: postgres-payments
    environment:
      POSTGRES_DB: payments_db
      POSTGRES_USER: payments_user
      POSTGRES_PASSWORD: payments_password
    ports:
      - "5433:5432"
    volumes:
      - postgres-payments-data:/var/lib/postgresql/data
    networks:
      - microservices-network
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U payments_user -d payments_db"]
      interval: 10s
      timeout: 5s
      retries: 5

  # MongoDB pour réservations
  mongo-reservations:
    image: mongo:7.0
    container_name: mongo-reservations
    ports:
      - "27017:27017"
    volumes:
      - mongo-reservations-data:/data/db
    networks:
      - microservices-network
    healthcheck:
      test: ["CMD", "mongosh", "--eval", "db.adminCommand('ping')"]
      interval: 10s
      timeout: 5s
      retries: 5

  # MongoDB pour event store
  mongo-event-store:
    image: mongo:7.0
    container_name: mongo-event-store
    ports:
      - "27018:27017"
    volumes:
      - mongo-event-store-data:/data/db
    networks:
      - microservices-network
    healthcheck:
      test: ["CMD", "mongosh", "--eval", "db.adminCommand('ping')"]
      interval: 10s
      timeout: 5s
      retries: 5

  # MongoDB pour notifications
  mongo-notifications:
    image: mongo:7.0
    container_name: mongo-notifications
    ports:
      - "27019:27017"
    volumes:
      - mongo-notifications-data:/data/db
    networks:
      - microservices-network
    healthcheck:
      test: ["CMD", "mongosh", "--eval", "db.adminCommand('ping')"]
      interval: 10s
      timeout: 5s
      retries: 5

  # Redis pour cache
  redis-cache:
    image: redis:7-alpine
    container_name: redis-cache
    ports:
      - "6379:6379"
    volumes:
      - redis-data:/data
    networks:
      - microservices-network
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 5s
      retries: 5

  # Elasticsearch pour analytics
  elasticsearch:
    image: docker.elastic.co/elasticsearch/elasticsearch:8.11.1
    container_name: elasticsearch
    environment:
      - discovery.type=single-node
      - xpack.security.enabled=false
      - "ES_JAVA_OPTS=-Xms512m -Xmx512m"
    ports:
      - "9200:9200"
    volumes:
      - elasticsearch-data:/usr/share/elasticsearch/data
    networks:
      - microservices-network
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:9200/_cluster/health"]
      interval: 10s
      timeout: 5s
      retries: 5

  # RabbitMQ pour messaging
  rabbitmq:
    image: rabbitmq:3.12-management-alpine
    container_name: rabbitmq
    ports:
      - "5672:5672"
      - "15672:15672"
    environment:
      RABBITMQ_DEFAULT_USER: guest
      RABBITMQ_DEFAULT_PASS: guest
    volumes:
      - rabbitmq-data:/var/lib/rabbitmq
    networks:
      - microservices-network
    healthcheck:
      test: ["CMD", "rabbitmq-diagnostics", "ping"]
      interval: 10s
      timeout: 5s
      retries: 5

  # =============================================================================
  # MICROSERVICES
  # =============================================================================

  # Service Événements
  event-service:
    build: ./event-service
    container_name: event-service
    ports:
      - "8080:8080"
    environment:
      POSTGRES_HOST: postgres-events
      POSTGRES_PORT: 5432
      POSTGRES_DB: events_db
      POSTGRES_USER: events_user
      POSTGRES_PASSWORD: events_password
      RABBITMQ_HOST: rabbitmq
      RABBITMQ_PORT: 5672
    depends_on:
      postgres-events:
        condition: service_healthy
      rabbitmq:
        condition: service_healthy
    networks:
      - microservices-network

  # Service Réservations
  reservation-service:
    build: ./reservation-service
    container_name: reservation-service
    ports:
      - "3000:3000"
    environment:
      MONGODB_URI: mongodb://mongo-reservations:27017/reservations_db
      EVENT_SERVICE_URL: http://event-service:8080/api/events
      RABBITMQ_HOST: rabbitmq
      RABBITMQ_PORT: 5672
    depends_on:
      mongo-reservations:
        condition: service_healthy
      rabbitmq:
        condition: service_healthy
      event-service:
        condition: service_started
    networks:
      - microservices-network

  # Service Paiements
  payment-service:
    build: ./payment-service
    container_name: payment-service
    ports:
      - "5000:5000"
    environment:
      POSTGRES_URL: postgresql://payments_user:payments_password@postgres-payments:5432/payments_db
      REDIS_URL: redis://redis-cache:6379/0
      RABBITMQ_HOST: rabbitmq
      RABBITMQ_PORT: 5672
    depends_on:
      postgres-payments:
        condition: service_healthy
      redis-cache:
        condition: service_healthy
      rabbitmq:
        condition: service_healthy
    networks:
      - microservices-network

  # Service Analytics
  analytics-service:
    build: ./analytics-service
    container_name: analytics-service
    ports:
      - "8081:8080"
    environment:
      ELASTICSEARCH_HOST: elasticsearch
      ELASTICSEARCH_PORT: 9200
      RABBITMQ_HOST: rabbitmq
      RABBITMQ_PORT: 5672
    depends_on:
      elasticsearch:
        condition: service_healthy
      rabbitmq:
        condition: service_healthy
    networks:
      - microservices-network

  # Service Event Store
  event-store-service:
    build: ./event-store-service
    container_name: event-store-service
    ports:
      - "3001:3001"
    environment:
      MONGODB_URI: mongodb://mongo-event-store:27017/event_store_db
      EVENTS_SERVICE_URL: http://event-service:8080
      RABBITMQ_HOST: rabbitmq
      RABBITMQ_PORT: 5672
    depends_on:
      mongo-event-store:
        condition: service_healthy
      rabbitmq:
        condition: service_healthy
    networks:
      - microservices-network

  # Saga Orchestrator
  saga-orchestrator:
    build: ./saga-orchestrator
    container_name: saga-orchestrator
    ports:
      - "3002:3002"
    environment:
      EVENTS_SERVICE_URL: http://event-service:8080
      RESERVATIONS_SERVICE_URL: http://reservation-service:3000
      PAYMENTS_SERVICE_URL: http://payment-service:5000
      NOTIFICATIONS_SERVICE_URL: http://notification-service:5001
      RABBITMQ_HOST: rabbitmq
      RABBITMQ_PORT: 5672
    depends_on:
      event-service:
        condition: service_started
      reservation-service:
        condition: service_started
      payment-service:
        condition: service_started
      rabbitmq:
        condition: service_healthy
    networks:
      - microservices-network

  # Service Notifications
  notification-service:
    build: ./notification-service
    container_name: notification-service
    ports:
      - "5001:5001"
    environment:
      MONGODB_URI: mongodb://mongo-notifications:27017/
      MONGODB_DB: notifications_db
      RABBITMQ_HOST: rabbitmq
      RABBITMQ_PORT: 5672
    depends_on:
      mongo-notifications:
        condition: service_healthy
      rabbitmq:
        condition: service_healthy
    networks:
      - microservices-network

# =============================================================================
# RÉSEAUX
# =============================================================================

networks:
  microservices-network:
    driver: bridge

# =============================================================================
# VOLUMES
# =============================================================================

volumes:
  postgres-events-data:
  postgres-payments-data:
  mongo-reservations-data:
  mongo-event-store-data:
  mongo-notifications-data:
  redis-data:
  elasticsearch-data:
  rabbitmq-data:
EOF

    cd ..
    echo "✅ docker-compose.yml créé"
}

# =============================================================================
# CRÉATION DES SCRIPTS UTILITAIRES
# =============================================================================

create_utility_scripts() {
    echo "📦 Création des scripts utilitaires..."
    
    cd tp4-microservices-persistence/scripts
    
    # Script de démarrage
    cat > start-dev.sh << 'EOF'
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
EOF

    # Script de nettoyage
    cat > cleanup.sh << 'EOF'
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
EOF

    # Script de test
    cat > test-system.sh << 'EOF'
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
EOF

    # Rendre les scripts exécutables
    chmod +x start-dev.sh cleanup.sh test-system.sh
    
    cd ../..
    echo "✅ Scripts utilitaires créés"
}

# =============================================================================
# FICHIER README PRINCIPAL
# =============================================================================

create_main_readme() {
    echo "📦 Création du README principal..."
    
    cd tp4-microservices-persistence
    
    cat > README.md << 'EOF'

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
EOF

    cd ..
    echo "✅ README principal créé"
}

# =============================================================================
# FONCTION PRINCIPALE
# =============================================================================

main() {
    echo "🚀 Démarrage de la génération du TP4..."
    echo ""
    
    # Vérifier les dépendances
    check_dependencies
    
    # Créer la structure du projet
    create_project_structure
    
    # Créer les microservices
    create_event_service
    create_reservation_service
    create_payment_service
    create_analytics_service
    create_event_store_service
    create_saga_orchestrator
    create_notification_service
    
    # Créer les fichiers de configuration
    create_docker_compose
    create_utility_scripts
    create_main_readme
    
    echo ""
    echo "✅ TP4 généré avec succès !"
    echo ""
    echo "📋 Prochaines étapes :"
    echo "   1. cd tp4-microservices-persistence"
    echo "   2. ./scripts/start-dev.sh"
    echo "   3. Compléter les TODOs dans le code"
    echo "   4. docker-compose up -d"
    echo "   5. ./scripts/test-system.sh"
    echo ""
    echo "📚 Consultez le README.md pour plus de détails."
    echo ""
    echo "🎯 Bon apprentissage !"
}

# Exécuter le script principal
main