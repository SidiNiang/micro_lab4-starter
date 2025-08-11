const mongoose = require('mongoose');
const { defaultMaxListeners } = require('../../../saga-orchestrator/src/orchestrators/saga.orchestrator');

/**
 * Modèle d'Événement de Domaine pour Event Sourcing
 * 
 * Ce modèle capture tous les changements d'état du système comme
 * une séquence d'événements immuables, permettant :
 * - Reconstruction complète de l'état à tout moment
 * - Audit trail exhaustif de toutes les opérations
 * - Traçabilité des changements et causation
 * - Support pour CQRS (Command Query Responsibility Segregation)
 */

const domainEventSchema = new mongoose.Schema({
  eventId: {
    type: String,
    required: true,
    unique: true,
    index: true
  },
  aggregateId: {
    type: String,
    required: true,
    index: true
  },
  aggregateType: {
    type: String,
    required: true,
    enum: ['Event', 'Reservation', 'Payment', 'User'],
    index: true
  },
  eventType: {
    type: String,
    required: true,
    index: true
  },
  eventData: {
    type: mongoose.Schema.Types.Mixed,
    required: true
  },
  metadata: {
    userId: String,
    userEmail: String,
    ipAddress: String,
    userAgent: String,
    correlationId: String,
    causationId: String
  },
  version: {
    type: Number,
    required: true,
    min: 1
  },
  timestamp: {
    type: Date,
    default: Date.now,
    index: true
  }
}, {
  timestamps: false, // On gère timestamp manuellement
  versionKey: false
});

// Index composé pour optimiser les requêtes de reconstruction d'agrégat
domainEventSchema.index({ aggregateId: 1, version: 1 });
domainEventSchema.index({ aggregateType: 1, timestamp: -1 });
domainEventSchema.index({ eventType: 1, timestamp: -1 });

// =========================================================================
// TODO-ES1: Implémentez la méthode statique pour récupérer l'historique d'un agrégat
// =========================================================================
/**
 * Cette méthode doit retourner tous les événements d'un agrégat dans l'ordre chronologique.
 * 
 * Paramètres :
 * - aggregateId: ID de l'agrégat (ex: réservation, paiement)
 * - fromVersion: Version de départ (pour reconstruction incrémentale)
 * 
 * Logique :
 * 1. Filtrer par aggregateId et version > fromVersion
 * 2. Trier par version croissante (ordre de création)
 * 3. Retourner la liste d'événements
 * 4. Gérer les erreurs gracieusement
 */
domainEventSchema.statics.getAggregateHistory = async function (aggregateId, fromVersion = 0) {
  try {
    const events = await this.find({
      aggregateId: aggregateId,
      version: { $gt: fromVersion }
    })
      .sort({ version: 1 })
      .lean();
    return events;
  } catch (error) {
    console.error(`Error retrieving aggregate history for ${aggregateId}:`, error);
    throw error;
  }
};


// =========================================================================
// TODO-ES2: Implémentez la méthode statique pour récupérer les événements par type
// =========================================================================
/**
 * Cette méthode doit permettre de filtrer par type d'événement et période.
 * 
 * Paramètres :
 * - eventType: Type d'événement (ex: "ReservationCreated", "PaymentCompleted")
 * - fromDate: Date de début (optionnel)
 * - toDate: Date de fin (optionnel)
 * - limit: Nombre maximum de résultats
 * 
 * Logique :
 * 1. Construire la requête avec eventType
 * 2. Ajouter les filtres de date si fournis
 * 3. Limiter le nombre de résultats
 * 4. Trier par timestamp décroissant (plus récents en premier)
 */
domainEventSchema.statics.getEventsByType = async function (eventType, fromDate, toDate, limit = 100) {
  try {
    const query = { eventType };
    if (fromDate || toDate) {
      query.timestamp = {};
      if (fromDate) query.timestamp.$gte = new Date(fromDate);
      if (toDate) query.timestamp.$lte = new Date(toDate);
    }
    const events = await this.find(query)
      .sort({ timestamp: -1 })
      .limit(limit)
      .lean();
    return events;
  } catch (error) {
    console.error(`Error retrieving events by type ${eventType}:`, error);
    throw error;
  }
};


// =========================================================================
// TODO-ES3: Implémentez la méthode pour valider la cohérence de version
// =========================================================================
/**
 * Cette méthode doit vérifier qu'il n'y a pas de conflit de version.
 * 
 * L'Event Sourcing requiert que les versions soient séquentielles pour
 * chaque agrégat (1, 2, 3, ...) sans trous ni doublons.
 * 
 * Paramètres :
 * - aggregateId: ID de l'agrégat
 * - expectedVersion: Version attendue (dernière version + 1)
 * 
 * Logique :
 * 1. Trouver la dernière version pour cet agrégat
 * 2. Vérifier que expectedVersion = dernière version + 1
 * 3. Lever une erreur explicite en cas de conflit
 */
domainEventSchema.statics.validateEventVersion = async function (aggregateId, expectedVersion) {
  try {
    const lastEvent = await this.findOne({ aggregateId })
      .sort({ version: -1 })
      .select('version');
    const currentVersion = lastEvent ? lastEvent.version : 0;
    if (expectedVersion !== currentVersion + 1) {
      throw new Error(
        `Version conflict for aggregate ${aggregateId}. ` +
        `Expected version ${expectedVersion}, but current version is ${currentVersion}`
      );
    }
    return true;
  } catch (error) {
    console.error(`Version validation error for ${aggregateId}:`, error);
    throw error;
  }
};

module.exports = mongoose.model('DomainEvent', domainEventSchema);
