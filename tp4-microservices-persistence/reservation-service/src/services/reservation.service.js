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
