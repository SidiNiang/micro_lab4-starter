const DomainEvent = require('../models/domain.event');
const { v4: uuidv4 } = require('uuid');

/**
 * Service Event Store - Implémentation de l'Event Sourcing
 * 
 * Ce service gère :
 * - L'ajout d'événements immuables
 * - La reconstruction d'état depuis les événements
 * - La validation de cohérence des versions
 * - Les requêtes sur les flux d'événements
 */
class EventStoreService {
  
  async appendEvent(aggregateId, aggregateType, eventType, eventData, metadata = {}) {
    try {
      console.log(`📝 Appending event: ${eventType} for ${aggregateType}:${aggregateId}`);
      
      // Obtenir la prochaine version
      const nextVersion = await this.getNextVersion(aggregateId);
      
      // Valider la version pour éviter les conflits
      await DomainEvent.validateEventVersion(aggregateId, nextVersion);
      
      const domainEvent = new DomainEvent({
        eventId: uuidv4(),
        aggregateId,
        aggregateType,
        eventType,
        eventData,
        version: nextVersion,
        metadata: {
          ...metadata,
          correlationId: metadata.correlationId || uuidv4()
        },
        timestamp: new Date()
      });

      await domainEvent.save();
      
      console.log(`✅ Event appended: ${eventType} for ${aggregateType}:${aggregateId} v${nextVersion}`);
      
      return domainEvent;
      
    } catch (error) {
      console.error('❌ Error appending event:', error);
      throw error;
    }
  }

  async getAggregateHistory(aggregateId, fromVersion = 0) {
    try {
      console.log(`📚 Getting aggregate history for ${aggregateId} from version ${fromVersion}`);
      return await DomainEvent.getAggregateHistory(aggregateId, fromVersion);
    } catch (error) {
      console.error(`❌ Error getting aggregate history for ${aggregateId}:`, error);
      throw error;
    }
  }

  async getEventsByType(eventType, options = {}) {
    try {
      const { fromDate, toDate, limit = 100 } = options;
      console.log(`🔍 Getting events by type: ${eventType} (limit: ${limit})`);
      return await DomainEvent.getEventsByType(eventType, fromDate, toDate, limit);
    } catch (error) {
      console.error(`❌ Error getting events by type ${eventType}:`, error);
      throw error;
    }
  }

  async getAllEvents(options = {}) {
    try {
      const { limit = 100, offset = 0, aggregateType, eventType } = options;
      
      let query = {};
      if (aggregateType) query.aggregateType = aggregateType;
      if (eventType) query.eventType = eventType;
      
      console.log(`📋 Getting all events (limit: ${limit}, offset: ${offset})`);
      
      return await DomainEvent.find(query)
        .sort({ timestamp: -1 })
        .limit(limit)
        .skip(offset);
        
    } catch (error) {
      console.error('❌ Error getting all events:', error);
      throw error;
    }
  }

  async getNextVersion(aggregateId) {
    try {
      const lastEvent = await DomainEvent.findOne({ aggregateId })
        .sort({ version: -1 })
        .select('version');
      
      const nextVersion = lastEvent ? lastEvent.version + 1 : 1;
      console.log(`🔢 Next version for ${aggregateId}: ${nextVersion}`);
      return nextVersion;
    } catch (error) {
      console.error(`❌ Error getting next version for ${aggregateId}:`, error);
      throw error;
    }
  }

  async getEventStreamMetrics() {
    try {
      console.log('📊 Getting event stream metrics...');
      
      const [totalEvents, aggregateTypes, eventTypes] = await Promise.all([
        DomainEvent.countDocuments(),
        DomainEvent.distinct('aggregateType'),
        DomainEvent.distinct('eventType')
      ]);
      
      return {
        totalEvents,
        aggregateTypes: aggregateTypes.length,
        eventTypes: eventTypes.length,
        aggregateTypesList: aggregateTypes,
        eventTypesList: eventTypes,
        timestamp: new Date().toISOString()
      };
    } catch (error) {
      console.error('❌ Error getting event stream metrics:', error);
      throw error;
    }
  }

  async reconstructAggregateState(aggregateId, toVersion = null) {
    try {
      console.log(`🔄 Reconstructing state for aggregate ${aggregateId}`);
      
      const events = await this.getAggregateHistory(aggregateId);
      
      if (events.length === 0) {
        return null;
      }
      
      // Filtrer jusqu'à la version demandée si spécifiée
      const filteredEvents = toVersion ? 
        events.filter(event => event.version <= toVersion) : 
        events;
      
      // Reconstruction basique - peut être étendue selon les besoins
      const state = {
        aggregateId,
        aggregateType: events[0].aggregateType,
        version: filteredEvents[filteredEvents.length - 1].version,
        events: filteredEvents,
        reconstructedAt: new Date().toISOString()
      };
      
      console.log(`✅ State reconstructed for ${aggregateId} with ${filteredEvents.length} events`);
      return state;
      
    } catch (error) {
      console.error(`❌ Error reconstructing state for ${aggregateId}:`, error);
      throw error;
    }
  }
}

module.exports = new EventStoreService();
