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
     * et respecter les règles métier (ex: pas de sur-réservation, marge de
     * sécurité).
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
        if (requestedSeats <= 0) {
            return false;
        }
        // Calculer les places disponibles avec marge de sécurité (5%)
        int safetyMargin = (int) Math.ceil(totalCapacity * 0.05);
        int availableSeats = totalCapacity - bookedSeats - safetyMargin;
        return availableSeats >= requestedSeats;
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
        if (!canBookSeats(seats)) {
            return false;
        }
        // La mise à jour atomique sera gérée par JPA avec @Version
        this.bookedSeats += seats;
        return true;
    }

    // Getters et setters
    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public LocalDateTime getEventDate() {
        return eventDate;
    }

    public void setEventDate(LocalDateTime eventDate) {
        this.eventDate = eventDate;
    }

    public String getLocation() {
        return location;
    }

    public void setLocation(String location) {
        this.location = location;
    }

    public Integer getTotalCapacity() {
        return totalCapacity;
    }

    public void setTotalCapacity(Integer totalCapacity) {
        this.totalCapacity = totalCapacity;
    }

    public Integer getBookedSeats() {
        return bookedSeats;
    }

    public void setBookedSeats(Integer bookedSeats) {
        this.bookedSeats = bookedSeats;
    }

    public BigDecimal getTicketPrice() {
        return ticketPrice;
    }

    public void setTicketPrice(BigDecimal ticketPrice) {
        this.ticketPrice = ticketPrice;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(LocalDateTime updatedAt) {
        this.updatedAt = updatedAt;
    }

    public Long getVersion() {
        return version;
    }

    public void setVersion(Long version) {
        this.version = version;
    }

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
