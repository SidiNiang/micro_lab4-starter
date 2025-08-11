const eventStoreService = require('../services/event.store.service');
const { DataSyncService } = require('../sync/data.sync.service');
const ConflictResolutionService = require('../sync/conflict.resolution');
const Joi = require('joi');

const dataSyncService = new DataSyncService();
const conflictResolver = new ConflictResolutionService();

const appendEventSchema = Joi.object({
  aggregateId: Joi.string().required(),
  aggregateType: Joi.string().valid('Event', 'Reservation', 'Payment', 'User').required(),
  eventType: Joi.string().required(),
  eventData: Joi.object().required(),
  metadata: Joi.object().optional()
});

class EventStoreController {
  
  async appendEvent(req, res) {
    try {
      const { error, value } = appendEventSchema.validate(req.body);
      if (error) {
        return res.status(400).json({ 
          error: 'Validation error', 
          details: error.details 
        });
      }
      
      const { aggregateId, aggregateType, eventType, eventData, metadata } = value;
      
      const domainEvent = await eventStoreService.appendEvent(
        aggregateId, 
        aggregateType, 
        eventType, 
        eventData, 
        metadata
      );
      
      res.status(201).json({
        success: true,
        event: domainEvent,
        message: 'Event appended successfully to event store'
      });
      
    } catch (error) {
      console.error('❌ Error appending event:', error);
      if (error.message.includes('Version conflict')) {
        res.status(409).json({ 
          error: 'Version conflict', 
          message: error.message 
        });
      } else {
        res.status(500).json({ 
          error: 'Failed to append event', 
          message: error.message 
        });
      }
    }
  }

  async getAggregateHistory(req, res) {
    try {
      const { aggregateId } = req.params;
      const { fromVersion = 0 } = req.query;
      
      const events = await eventStoreService.getAggregateHistory(
        aggregateId, 
        parseInt(fromVersion)
      );
      
      res.json({
        aggregateId,
        events,
        count: events.length,
        fromVersion: parseInt(fromVersion)
      });
      
    } catch (error) {
      console.error('❌ Error getting aggregate history:', error);
      res.status(500).json({ 
        error: 'Failed to get aggregate history', 
        message: error.message 
      });
    }
  }

  async getEventsByType(req, res) {
    try {
      const { eventType } = req.params;
      const { fromDate, toDate, limit = 100 } = req.query;
      
      const events = await eventStoreService.getEventsByType(eventType, {
        fromDate: fromDate ? new Date(fromDate) : undefined,
        toDate: toDate ? new Date(toDate) : undefined,
        limit: parseInt(limit)
      });
      
      res.json({
        eventType,
        events,
        count: events.length,
        filters: { fromDate, toDate, limit: parseInt(limit) }
      });
      
    } catch (error) {
      console.error('❌ Error getting events by type:', error);
      res.status(500).json({ 
        error: 'Failed to get events by type', 
        message: error.message 
      });
    }
  }

  async getAllEvents(req, res) {
    try {
      const { 
        limit = 100, 
        offset = 0, 
        aggregateType, 
        eventType 
      } = req.query;
      
      const events = await eventStoreService.getAllEvents({
        limit: parseInt(limit),
        offset: parseInt(offset),
        aggregateType,
        eventType
      });
      
      res.json({
        events,
        count: events.length,
        pagination: {
          limit: parseInt(limit),
          offset: parseInt(offset)
        },
        filters: { aggregateType, eventType }
      });
      
    } catch (error) {
      console.error('❌ Error getting all events:', error);
      res.status(500).json({ 
        error: 'Failed to get events', 
        message: error.message 
      });
    }
  }

  async reconstructAggregateState(req, res) {
    try {
      const { aggregateId } = req.params;
      const { toVersion } = req.query;
      
      const state = await eventStoreService.reconstructAggregateState(
        aggregateId, 
        toVersion ? parseInt(toVersion) : null
      );
      
      if (!state) {
        return res.status(404).json({
          error: 'Aggregate not found',
          aggregateId
        });
      }
      
      res.json({
        reconstructedState: state,
        aggregateId,
        toVersion: toVersion ? parseInt(toVersion) : 'latest'
      });
      
    } catch (error) {
      console.error('❌ Error reconstructing aggregate state:', error);
      res.status(500).json({ 
        error: 'Failed to reconstruct aggregate state', 
        message: error.message 
      });
    }
  }

  async getMetrics(req, res) {
    try {
      const metrics = await eventStoreService.getEventStreamMetrics();
      res.json({
        message: '📊 Event Store Metrics',
        metrics
      });
    } catch (error) {
      console.error('❌ Error getting metrics:', error);
      res.status(500).json({ 
        error: 'Failed to get metrics', 
        message: error.message 
      });
    }
  }

  // Endpoints de synchronisation
  async performSync(req, res) {
    try {
      const { type = 'incremental' } = req.body;
      
      let result;
      if (type === 'initial') {
        result = await dataSyncService.performInitialSync();
      } else {
        result = await dataSyncService.performIncrementalSync();
      }
      
      res.json({
        success: true,
        syncType: type,
        result
      });
      
    } catch (error) {
      console.error('❌ Error performing sync:', error);
      res.status(500).json({ 
        error: 'Failed to perform sync', 
        message: error.message 
      });
    }
  }

  async handleRealtimeUpdate(req, res) {
    try {
      const updateMessage = req.body;
      await dataSyncService.handleEventUpdated(updateMessage);
      
      res.json({
        success: true,
        message: 'Realtime update processed'
      });
      
    } catch (error) {
      console.error('❌ Error handling realtime update:', error);
      res.status(500).json({ 
        error: 'Failed to process realtime update', 
        message: error.message 
      });
    }
  }

  async resolveConflict(req, res) {
    try {
      const { localData, remoteData, strategy = 'LAST_WRITER_WINS' } = req.body;
      
      // Détecter le conflit
      const conflict = conflictResolver.detectVersionConflict(localData, remoteData);
      
      if (!conflict.hasConflict) {
        return res.json({
          hasConflict: false,
          message: 'No conflict detected'
        });
      }
      
      // Résoudre selon la stratégie
      const strategies = conflictResolver.getResolutionStrategies();
      const resolveFunction = strategies[strategy];
      
      if (!resolveFunction) {
        return res.status(400).json({
          error: 'Invalid resolution strategy',
          availableStrategies: Object.keys(strategies)
        });
      }
      
      const resolved = resolveFunction(localData, remoteData);
      
      res.json({
        hasConflict: true,
        conflictType: conflict.type,
        conflictDetails: conflict.details,
        resolution: {
          strategy,
          resolvedData: resolved
        }
      });
      
    } catch (error) {
      console.error('❌ Error resolving conflict:', error);
      res.status(500).json({ 
        error: 'Failed to resolve conflict', 
        message: error.message 
      });
    }
  }
}

module.exports = new EventStoreController();
