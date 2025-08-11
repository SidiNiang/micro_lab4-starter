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

        if (totalCapacity != null && totalCapacity > 0 && bookedSeats != null) {
            this.occupancyRate = Math.round((bookedSeats.doubleValue() / totalCapacity.doubleValue()) * 100.0 * 100.0) / 100.0;
        } else {
            this.occupancyRate = 0.0;
        }
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
        this.bookedSeats = newBookedSeats;
        this.totalRevenue = newRevenue;
        this.totalReservations = newReservations;
        this.lastUpdated = LocalDateTime.now();
        
        // Recalculer le taux d'occupation
        calculateOccupancyRate();
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
