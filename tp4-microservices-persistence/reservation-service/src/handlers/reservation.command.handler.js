const DomainEvent = require('../../event-store-service/src/models/domain.event');
const { v4: uuidv4 } = require('uuid');

class ReservationCommandHandler {
  constructor(eventStore, reservationRepository) {
    this.eventStore = eventStore;
    this.reservationRepository = reservationRepository;
  }

  // =========================================================================
  // TODO-ES4: Implémentez le traitement de la commande CreateReservation
  // =========================================================================
  /**
   * Cette méthode doit valider la commande et générer un événement ReservationCreated
   * 
   * Étapes :
   * 1. Valider la commande (champs requis, valeurs valides)
   * 2. Vérifier les règles métier (places disponibles, etc.)
   * 3. Générer l'événement ReservationCreated avec les données
   * 4. Sauvegarder dans l'Event Store
   * 5. Déclencher la mise à jour des vues de lecture
   * 
   * @param {Object} command - Commande CreateReservation
   * @returns {Object} Résultat avec reservationId et event
   */
  async handleCreateReservation(command) {
    try {
      // 1. Valider la commande
      this.validateCreateReservationCommand(command);
      
      // 2. Générer un ID unique pour la réservation
      const reservationId = uuidv4();
      
      // 3. Obtenir la prochaine version
      const version = await this.getNextVersion(reservationId);
      
      // 4. Créer les données de l'événement
      const eventData = {
        reservationId,
        eventId: command.eventId,
        userId: command.userId,
        userName: command.userName,
        userEmail: command.userEmail,
        seats: command.seats,
        totalAmount: command.totalAmount,
        currency: command.currency || 'XOF',
        status: 'pending'
      };
      
      // 5. Sauvegarder l'événement
      const event = await this.saveEvent(
        reservationId,
        'Reservation',
        'ReservationCreated',
        eventData,
        version,
        command.metadata
      );
      
      console.log(`Reservation created: ${reservationId}`);
      return { reservationId, event };
      
    } catch (error) {
      console.error('Error handling CreateReservation command:', error);
      throw error;
    }
  }

  // =========================================================================
  // TODO-ES5: Implémentez le traitement de la commande ConfirmReservation
  // =========================================================================
  /**
   * Cette méthode doit changer le statut de la réservation et générer l'événement approprié
   * 
   * Étapes :
   * 1. Récupérer l'historique de la réservation depuis l'Event Store
   * 2. Reconstruire l'état actuel en rejouant les événements
   * 3. Valider que la confirmation est possible (statut actuel = 'pending')
   * 4. Générer l'événement ReservationConfirmed
   * 5. Sauvegarder et déclencher les mises à jour
   * 
   * @param {Object} command - Commande ConfirmReservation avec reservationId
   */
  async handleConfirmReservation(command) {
    try {
      // ⚠️  TODO: À implémenter par les étudiants
      
      // Exemple de solution :
      const { reservationId } = command;
      
      // 1. Récupérer l'historique
      const history = await this.eventStore.getAggregateHistory(reservationId);
      if (history.length === 0) {
        throw new Error(`Reservation ${reservationId} not found`);
      }
      
      // 2. Reconstruire l'état actuel
      const currentState = await this.reconstructReservationState(reservationId);
      
      // 3. Valider la transition
      if (currentState.status !== 'pending') {
        throw new Error(`Cannot confirm reservation in status ${currentState.status}`);
      }
      
      // 4. Générer l'événement
      const version = await this.getNextVersion(reservationId);
      const eventData = {
        reservationId,
        previousStatus: currentState.status,
        newStatus: 'confirmed',
        confirmedAt: new Date()
      };
      
      // 5. Sauvegarder
      const event = await this.saveEvent(
        reservationId,
        'Reservation',
        'ReservationConfirmed',
        eventData,
        version,
        command.metadata
      );
      
      return { reservationId, event };
      
    } catch (error) {
      console.error('Error handling ConfirmReservation command:', error);
      throw error;
    }
  }

  // =========================================================================
  // TODO-ES6: Implémentez la reconstruction de l'état d'une réservation
  // =========================================================================
  /**
   * Cette méthode doit rejouer tous les événements pour reconstituer l'état actuel
   * 
   * Principe de l'Event Sourcing :
   * 1. Récupérer tous les événements de l'agrégat
   * 2. Partir d'un état initial vide
   * 3. Appliquer chaque événement dans l'ordre pour modifier l'état
   * 4. Retourner l'état final reconstitué
   * 
   * @param {String} reservationId - ID de la réservation
   * @returns {Object} État actuel de la réservation
   */
  async reconstructReservationState(reservationId) {
    // ⚠️  TODO: À implémenter par les étudiants
    
    // Exemple de solution :
    const events = await this.eventStore.getAggregateHistory(reservationId);
    
    // État initial
    let state = {
      reservationId,
      status: null,
      version: 0
    };
    
    // Rejouer chaque événement
    for (const event of events) {
      switch (event.eventType) {
        case 'ReservationCreated':
          state = {
            ...state,
            ...event.eventData,
            status: event.eventData.status || 'pending',
            version: event.version
          };
          break;
          
        case 'ReservationConfirmed':
          state.status = 'confirmed';
          state.confirmedAt = event.eventData.confirmedAt;
          state.version = event.version;
          break;
          
        case 'ReservationCancelled':
          state.status = 'cancelled';
          state.cancelledAt = event.eventData.cancelledAt;
          state.version = event.version;
          break;
      }
    }
    
    return state;
    
    //return {}; // Placeholder - à remplacer
  }

  // Méthodes utilitaires
  async saveEvent(aggregateId, aggregateType, eventType, eventData, version, metadata = {}) {
    const domainEvent = new DomainEvent({
      eventId: uuidv4(),
      aggregateId,
      aggregateType,
      eventType,
      eventData,
      version,
      metadata: {
        ...metadata,
        correlationId: metadata.correlationId || uuidv4()
      },
      timestamp: new Date()
    });

    await domainEvent.save();
    
    // Publier l'événement pour mise à jour des vues de lecture
    await this.publishEvent(domainEvent);
    
    return domainEvent;
  }

  async publishEvent(domainEvent) {
    // Publier l'événement via messaging pour mise à jour des projections
    // Intégration avec RabbitMQ du TP précédent
    console.log(`Event published: ${domainEvent.eventType} for ${domainEvent.aggregateId}`);
  }

  validateCreateReservationCommand(command) {
    if (!command.eventId || !command.userId || !command.seats) {
      throw new Error('Invalid CreateReservation command: missing required fields');
    }
    if (command.seats <= 0) {
      throw new Error('Invalid CreateReservation command: seats must be positive');
    }
  }

  async getNextVersion(aggregateId) {
    const lastEvent = await DomainEvent.findOne({ aggregateId })
      .sort({ version: -1 })
      .select('version');
    
    return lastEvent ? lastEvent.version + 1 : 1;
  }
}

module.exports = ReservationCommandHandler;
