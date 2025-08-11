package com.fst.dmi.eventservice.controller;

import com.fst.dmi.eventservice.model.Event;
import com.fst.dmi.eventservice.service.EventService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/events")
@CrossOrigin(origins = "*")
public class EventController {

    private final EventService eventService;

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
        
        // Exemple de solution :
        Integer seats = bookingRequest.get("seats");
        if (seats == null || seats <= 0) {
            return ResponseEntity.badRequest()
                    .body(Map.of("error", "Invalid number of seats"));
        }
        
        boolean booked = eventService.bookEventSeats(id, seats);
        if (booked) {
            return ResponseEntity.ok(Map.of(
                    "success", true,
                    "message", "Successfully booked " + seats + " seats",
                    "eventId", id,
                    "seatsBooked", seats
            ));
        } else {
            return ResponseEntity.badRequest()
                    .body(Map.of("error", "Could not book seats. Not enough availability."));
        }
        
      //  return ResponseEntity.badRequest().body(Map.of("error", "Not implemented yet"));
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
