const EventEmitter = require('events');
const mongoose = require('mongoose');
const axios = require('axios');

// Schéma pour les données d'événements répliquées
const replicatedEventSchema = new mongoose.Schema({
  originalEventId: { type: Number, required: true, unique: true },
  name: { type: String, required: true },
  description: String,
  eventDate: Date,
  location: String,
  totalCapacity: Number,
  currentBookedSeats: { type: Number, default: 0 },
  ticketPrice: Number,
  category: String,
  status: { type: String, default: 'active' },
  lastSyncedAt: { type: Date, default: Date.now },
  version: { type: Number, default: 1 }
}, {
  collection: 'replicated_events'
});

const ReplicatedEvent = mongoose.model('ReplicatedEvent', replicatedEventSchema);

class DataSyncService extends EventEmitter {
  constructor() {
    super();
    this.syncInProgress = new Set();
  }

  // =========================================================================
  // TODO-SYNC1: Implémentez la synchronisation initiale des événements
  // =========================================================================
  /**
   * Cette méthode doit récupérer tous les événements et les répliquer localement
   * 
   * Étapes :
   * 1. Récupérer tous les événements du service Events via API
   * 2. Pour chaque événement, créer ou mettre à jour la réplique locale
   * 3. Marquer la date de synchronisation
   * 4. Émettre un événement de synchronisation complète
   * 5. Gérer les erreurs individuelles sans arrêter le processus
   */
  async performInitialSync() {
    try {
      console.log('Starting initial data synchronization...');
      
      // ⚠️  TODO: À implémenter par les étudiants
      
      // Exemple de solution :
      // // 1. Récupérer tous les événements
      // const events = await this.fetchEventsFromService();
      // 
      // let syncedCount = 0;
      // let errorCount = 0;
      // 
      // // 2. Traiter chaque événement
      // for (const event of events) {
      //   try {
      //     await this.createOrUpdateReplica(event);
      //     syncedCount++;
      //   } catch (error) {
      //     console.error(`Failed to sync event ${event.id}:`, error);
      //     errorCount++;
      //   }
      // }
      // 
      // // 3. Émettre l'événement de synchronisation complète
      // this.emit('initialSyncCompleted', {
      //   totalEvents: events.length,
      //   syncedCount,
      //   errorCount,
      //   completedAt: new Date()
      // });
      // 
      // console.log(`Initial sync completed: ${syncedCount} events synced, ${errorCount} errors`);
      // 
      // return {
      //   success: true,
      //   syncedCount,
      //   errorCount
      // };
      
    } catch (error) {
      console.error('Initial sync failed:', error);
      this.emit('syncError', error);
      throw error;
    }
  }

  // =========================================================================
  // TODO-SYNC2: Implémentez la synchronisation incrémentale
  // =========================================================================
  /**
   * Cette méthode doit synchroniser seulement les événements modifiés
   * 
   * Étapes :
   * 1. Déterminer la date de dernière synchronisation
   * 2. Récupérer les événements modifiés depuis cette date
   * 3. Mettre à jour les répliques concernées
   * 4. Gérer les conflits de version si nécessaire
   * 5. Mettre à jour lastSyncedAt pour chaque réplique
   */
  async performIncrementalSync() {
    try {
      // ⚠️  TODO: À implémenter par les étudiants
      
      // Exemple de solution :
      // // 1. Déterminer la date de dernière synchronisation
      // const lastSyncDate = await this.getLastSyncDate();
      // 
      // if (!lastSyncDate) {
      //   console.log('No previous sync found, performing initial sync');
      //   return this.performInitialSync();
      // }
      // 
      // console.log(`Starting incremental sync from ${lastSyncDate.toISOString()}`);
      // 
      // // 2. Récupérer les événements modifiés
      // const modifiedEvents = await this.fetchEventsFromService(lastSyncDate);
      // 
      // let updatedCount = 0;
      // let conflictCount = 0;
      // 
      // // 3. Traiter chaque événement modifié
      // for (const event of modifiedEvents) {
      //   try {
      //     const existingReplica = await ReplicatedEvent.findOne({ 
      //       originalEventId: event.id 
      //     });
      //     
      //     // Vérifier la version pour éviter les régressions
      //     if (existingReplica && event.version < existingReplica.version) {
      //       console.warn(`Skipping event ${event.id}: remote version ${event.version} < local version ${existingReplica.version}`);
      //       conflictCount++;
      //       continue;
      //     }
      //     
      //     await this.createOrUpdateReplica(event);
      //     updatedCount++;
      //     
      //   } catch (error) {
      //     console.error(`Failed to sync modified event ${event.id}:`, error);
      //   }
      // }
      // 
      // this.emit('incrementalSyncCompleted', {
      //   modifiedEvents: modifiedEvents.length,
      //   updatedCount,
      //   conflictCount,
      //   lastSyncDate
      // });
      // 
      // return {
      //   success: true,
      //   updatedCount,
      //   conflictCount
      // };
      
    } catch (error) {
      console.error('Incremental sync failed:', error);
      throw error;
    }
  }

  // =========================================================================
  // TODO-SYNC3: Implémentez la gestion des événements de mise à jour en temps réel
  // =========================================================================
  /**
   * Cette méthode doit écouter les événements et mettre à jour les répliques
   * 
   * Étapes :
   * 1. Parser le message d'événement reçu
   * 2. Trouver la réplique correspondante
   * 3. Appliquer la mise à jour si la version est plus récente
   * 4. Résoudre les conflits selon une stratégie définie
   * 5. Émettre un événement de mise à jour réussie/échouée
   */
  async handleEventUpdated(eventUpdateMessage) {
    try {
      // ⚠️  TODO: À implémenter par les étudiants
      
      // Exemple de solution :
      // // 1. Parser le message
      // const { eventId, eventData, version, timestamp } = eventUpdateMessage;
      // 
      // console.log(`📡 Received update for event ${eventId} v${version}`);
      // 
      // // 2. Trouver la réplique
      // const replica = await ReplicatedEvent.findOne({ 
      //   originalEventId: eventId 
      // });
      // 
      // if (!replica) {
      //   console.log(`Creating new replica for event ${eventId}`);
      //   await this.createOrUpdateReplica(eventData);
      //   return;
      // }
      // 
      // // 3. Vérifier la version
      // if (version <= replica.version) {
      //   console.log(`Skipping update: version ${version} <= current ${replica.version}`);
      //   return;
      // }
      // 
      // // 4. Appliquer la mise à jour
      // await this.createOrUpdateReplica(eventData);
      // 
      // this.emit('realtimeUpdateCompleted', {
      //   eventId,
      //   version,
      //   timestamp
      // });
      
    } catch (error) {
      console.error('Real-time event update failed:', error);
      this.emit('realtimeUpdateFailed', { error: error.message });
      throw error;
    }
  }

  // Méthodes utilitaires
  async fetchEventsFromService(lastSyncDate = null) {
    const eventsServiceUrl = process.env.EVENTS_SERVICE_URL || 'http://localhost:8080';
    const url = lastSyncDate 
      ? `${eventsServiceUrl}/api/events?modifiedSince=${lastSyncDate.toISOString()}`
      : `${eventsServiceUrl}/api/events`;
    
    const response = await axios.get(url);
    return response.data;
  }

  async getLastSyncDate() {
    const lastSynced = await ReplicatedEvent.findOne()
      .sort({ lastSyncedAt: -1 })
      .select('lastSyncedAt');
    
    return lastSynced ? lastSynced.lastSyncedAt : null;
  }

  async createOrUpdateReplica(eventData) {
    const replica = await ReplicatedEvent.findOneAndUpdate(
      { originalEventId: eventData.id },
      {
        name: eventData.name,
        description: eventData.description,
        eventDate: new Date(eventData.eventDate),
        location: eventData.location,
        totalCapacity: eventData.totalCapacity,
        currentBookedSeats: eventData.bookedSeats || 0,
        ticketPrice: eventData.ticketPrice,
        category: eventData.category?.name,
        status: eventData.status || 'active',
        lastSyncedAt: new Date(),
        version: eventData.version || 1
      },
      { 
        upsert: true, 
        new: true, 
        setDefaultsOnInsert: true 
      }
    );

    return replica;
  }
}

module.exports = { DataSyncService, ReplicatedEvent };
