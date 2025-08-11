package com.fst.dmi.eventservice.service;

import com.fst.dmi.eventservice.model.Event;
import com.fst.dmi.eventservice.repository.EventRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Service
@Transactional
public class EventService {

    private final EventRepository eventRepository;

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
