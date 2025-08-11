const Reservation = require('../models/reservation.model');
const eventService = require('../services/event.service');

class ReservationCompensationService {
  
  // =========================================================================
  // TODO-SAGA5: Implémentez la compensation de réservation
  // =========================================================================
  /**
   * Cette méthode doit annuler une réservation et libérer les places
   * 
   * Actions à effectuer :
   * 1. Trouver la réservation par ID
   * 2. Vérifier qu'elle peut être annulée (status != 'cancelled')
   * 3. Libérer les places dans le service événements
   * 4. Marquer la réservation comme annulée
   * 5. Enregistrer la raison de l'annulation dans la timeline
   * 
   * @param {String} reservationId - ID de la réservation à compenser
   * @param {String} reason - Raison de la compensation
   */
  async compensateReservation(reservationId, reason = 'Saga compensation') {
    try {
      // ⚠️  TODO: À implémenter par les étudiants
      
      // Exemple de solution :
      // const reservation = await Reservation.findById(reservationId);
      // if (!reservation) {
      //   throw new Error(`Reservation ${reservationId} not found`);
      // }
      // 
      // if (reservation.status === 'cancelled') {
      //   console.log(`Reservation ${reservationId} already cancelled`);
      //   return;
      // }
      // 
      // // Libérer les places
      // await this.releaseEventSeats(
      //   reservation.eventId, 
      //   reservation.bookingDetails.seats
      // );
      // 
      // // Marquer comme annulée
      // reservation.status = 'cancelled';
      // reservation.timeline.push({
      //   status: 'cancelled',
      //   timestamp: new Date(),
      //   reason: reason,
      //   updatedBy: 'saga-compensator'
      // });
      // 
      // await reservation.save();
      // console.log(`✅ Reservation ${reservationId} compensated`);
      
    } catch (error) {
      console.error(`Failed to compensate reservation ${reservationId}:`, error);
      throw error;
    }
  }

  // =========================================================================
  // TODO-SAGA6: Implémentez la vérification de l'état de compensation
  // =========================================================================
  /**
   * Cette méthode doit vérifier si une réservation peut être compensée
   * 
   * Critères :
   * 1. La réservation existe
   * 2. Le statut n'est pas déjà 'cancelled' ou 'refunded'
   * 3. La réservation n'est pas trop ancienne (ex: moins de 24h)
   * 
   * @param {String} reservationId - ID de la réservation
   * @returns {Boolean} true si la compensation est possible
   */
  async canCompensateReservation(reservationId) {
    // ⚠️  TODO: À implémenter par les étudiants
    
    // Exemple de solution :
    // try {
    //   const reservation = await Reservation.findById(reservationId);
    //   if (!reservation) return false;
    //   
    //   if (['cancelled', 'refunded'].includes(reservation.status)) {
    //     return false;
    //   }
    //   
    //   // Vérifier si pas trop ancienne (24h)
    //   const hoursSinceCreation = (Date.now() - reservation.createdAt) / (1000 * 60 * 60);
    //   if (hoursSinceCreation > 24) {
    //     return false;
    //   }
    //   
    //   return true;
    // } catch (error) {
    //   console.error(`Error checking compensation eligibility:`, error);
    //   return false;
    // }
    
    return false; // Placeholder - à remplacer
  }

  // Méthode pour libérer les places dans le service événements
  async releaseEventSeats(eventId, seats) {
    try {
      const response = await eventService.releaseSeats(eventId, seats);
      return response;
    } catch (error) {
      console.error(`Failed to release ${seats} seats for event ${eventId}:`, error);
      throw error;
    }
  }
}

module.exports = new ReservationCompensationService();
