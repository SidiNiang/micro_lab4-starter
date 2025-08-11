const mongoose = require('mongoose');

// Schéma de vue de lecture optimisée (dénormalisée)
const reservationViewSchema = new mongoose.Schema({
  reservationId: { type: String, required: true, unique: true, index: true },
  eventId: { type: Number, required: true, index: true },
  eventName: String,
  eventDate: Date,
  eventLocation: String,
  userId: { type: String, required: true, index: true },
  userName: String,
  userEmail: String,
  seats: { type: Number, required: true },
  totalAmount: Number,
  currency: String,
  status: { type: String, required: true, index: true },
  paymentStatus: String,
  paymentId: String,
  createdAt: { type: Date, required: true },
  confirmedAt: Date,
  cancelledAt: Date,
  lastUpdated: { type: Date, default: Date.now }
}, {
  collection: 'reservation_views'
});

const ReservationView = mongoose.model('ReservationView', reservationViewSchema);

class ReservationProjectionHandler {
  
  // =========================================================================
  // TODO-ES7: Implémentez la gestion de l'événement ReservationCreated
  // =========================================================================
  /**
   * Cette méthode doit créer une nouvelle vue de lecture lors de la création
   * 
   * Actions :
   * 1. Extraire les données de l'événement
   * 2. Enrichir avec des données du service Event si nécessaire
   * 3. Créer la vue de lecture dénormalisée
   * 4. Sauvegarder dans la collection reservation_views
   * 
   * @param {Object} event - Événement ReservationCreated
   */
  async handleReservationCreated(event) {
    try {
      // ⚠️  TODO: À implémenter par les étudiants
      
      // Exemple de solution :
      // const { eventData } = event;
      // 
      // // Enrichir avec les données de l'événement
      // const eventDetails = await this.enrichWithEventData(eventData.eventId);
      // 
      // // Créer la vue de lecture
      // const view = new ReservationView({
      //   reservationId: eventData.reservationId,
      //   eventId: eventData.eventId,
      //   eventName: eventDetails?.name || 'Unknown Event',
      //   eventDate: eventDetails?.eventDate,
      //   eventLocation: eventDetails?.location,
      //   userId: eventData.userId,
      //   userName: eventData.userName,
      //   userEmail: eventData.userEmail,
      //   seats: eventData.seats,
      //   totalAmount: eventData.totalAmount,
      //   currency: eventData.currency,
      //   status: eventData.status,
      //   createdAt: event.timestamp
      // });
      // 
      // await view.save();
      // console.log(`✅ Reservation view created for ${eventData.reservationId}`);
      
    } catch (error) {
      console.error('Error handling ReservationCreated projection:', error);
      throw error;
    }
  }

  // =========================================================================
  // TODO-ES8: Implémentez la gestion de l'événement ReservationConfirmed
  // =========================================================================
  /**
   * Cette méthode doit mettre à jour la vue existante lors de la confirmation
   * 
   * Actions :
   * 1. Trouver la vue existante par reservationId
   * 2. Mettre à jour le statut à 'confirmed'
   * 3. Ajouter confirmedAt avec le timestamp
   * 4. Sauvegarder les modifications
   * 
   * @param {Object} event - Événement ReservationConfirmed
   */
  async handleReservationConfirmed(event) {
    try {
      // ⚠️  TODO: À implémenter par les étudiants
      
      // Exemple de solution :
      // const { eventData } = event;
      // 
      // const view = await ReservationView.findOne({ 
      //   reservationId: eventData.reservationId 
      // });
      // 
      // if (!view) {
      //   throw new Error(`View not found for reservation ${eventData.reservationId}`);
      // }
      // 
      // view.status = 'confirmed';
      // view.confirmedAt = eventData.confirmedAt || event.timestamp;
      // view.lastUpdated = new Date();
      // 
      // await view.save();
      // console.log(`✅ Reservation view updated to confirmed for ${eventData.reservationId}`);
      
    } catch (error) {
      console.error('Error handling ReservationConfirmed projection:', error);
      throw error;
    }
  }

  // =========================================================================
  // TODO-ES9: Implémentez une requête optimisée pour les réservations par utilisateur
  // =========================================================================
  /**
   * Cette méthode doit utiliser la vue dénormalisée pour des performances optimales
   * 
   * Fonctionnalités :
   * 1. Filtrer par userId
   * 2. Appliquer les filtres optionnels (status, dates)
   * 3. Trier par date de création décroissante
   * 4. Paginer les résultats
   * 
   * @param {String} userId - ID de l'utilisateur
   * @param {Object} options - Options de filtrage et pagination
   * @returns {Array} Liste des réservations de l'utilisateur
   */
  async getUserReservations(userId, options = {}) {
    // ⚠️  TODO: À implémenter par les étudiants
    
    // Exemple de solution :
    // try {
    //   const { 
    //     status, 
    //     fromDate, 
    //     toDate, 
    //     limit = 20, 
    //     offset = 0 
    //   } = options;
    //   
    //   // Construire la requête
    //   const query = { userId };
    //   
    //   if (status) {
    //     query.status = status;
    //   }
    //   
    //   if (fromDate || toDate) {
    //     query.createdAt = {};
    //     if (fromDate) query.createdAt.$gte = new Date(fromDate);
    //     if (toDate) query.createdAt.$lte = new Date(toDate);
    //   }
    //   
    //   // Exécuter la requête optimisée
    //   const reservations = await ReservationView
    //     .find(query)
    //     .sort({ createdAt: -1 })
    //     .skip(offset)
    //     .limit(limit)
    //     .lean();
    //   
    //   return reservations;
    //   
    // } catch (error) {
    //   console.error('Error getting user reservations:', error);
    //   throw error;
    // }
    
    return []; // Placeholder - à remplacer
  }

  // Méthode utilitaire pour enrichir les données
  async enrichWithEventData(eventId) {
    try {
      // Appel au service Event pour récupérer les détails
      // En production, pourrait utiliser un cache Redis
      const response = await fetch(`http://localhost:8080/api/events/${eventId}`);
      if (response.ok) {
        return await response.json();
      }
      return null;
    } catch (error) {
      console.warn(`Could not enrich with event data for eventId ${eventId}:`, error);
      return null;
    }
  }
}

module.exports = { ReservationView, ReservationProjectionHandler };
