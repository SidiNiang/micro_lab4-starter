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
