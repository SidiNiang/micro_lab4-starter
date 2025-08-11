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
