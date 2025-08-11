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
