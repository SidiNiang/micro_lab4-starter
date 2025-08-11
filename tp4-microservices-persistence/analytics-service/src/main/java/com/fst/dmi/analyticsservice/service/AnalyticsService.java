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
