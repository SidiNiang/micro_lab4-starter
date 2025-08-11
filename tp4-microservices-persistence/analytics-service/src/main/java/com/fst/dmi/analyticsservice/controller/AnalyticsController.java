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
