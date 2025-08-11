const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
require('dotenv').config();

const connectDB = require('./config/database');
const eventStoreController = require('./controllers/event.store.controller');

const app = express();
const PORT = process.env.PORT || 3001;

// Middleware
app.use(helmet());
app.use(cors());
app.use(morgan('combined'));
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));

// Connexion à MongoDB
connectDB();

// Routes principales
app.get('/', (req, res) => {
  res.json({
    message: '📚 Event Store Service API - Event Sourcing + CQRS',
    version: '1.0.0',
    database: 'MongoDB',
    patterns: ['Event Sourcing', 'CQRS', 'Immutable Event Log', 'Data Synchronization', 'Conflict Resolution'],
    capabilities: [
      'Immutable event storage',
      'Aggregate reconstruction',
      'Time travel queries',
      'Complete audit trail',
      'Data synchronization',
      'Conflict resolution'
    ],
    endpoints: {
      events: '/api/events',
      aggregates: '/api/aggregates',
      sync: '/api/sync',
      conflicts: '/api/conflicts',
      metrics: '/api/metrics',
      health: '/health'
    }
  });
});

app.get('/health', (req, res) => {
  res.json({ 
    status: 'OK', 
    timestamp: new Date().toISOString(),
    service: 'event-store-service',
    database: 'MongoDB (Event Sourcing)'
  });
});

// Routes de l'Event Store
app.post('/api/events', eventStoreController.appendEvent);
app.get('/api/events', eventStoreController.getAllEvents);
app.get('/api/events/type/:eventType', eventStoreController.getEventsByType);
app.get('/api/aggregates/:aggregateId/history', eventStoreController.getAggregateHistory);
app.get('/api/aggregates/:aggregateId/reconstruct', eventStoreController.reconstructAggregateState);
app.get('/api/metrics', eventStoreController.getMetrics);

// Routes de synchronisation
app.post('/api/sync', eventStoreController.performSync);
app.post('/api/sync/realtime', eventStoreController.handleRealtimeUpdate);

// Routes de résolution de conflits
app.post('/api/conflicts/resolve', eventStoreController.resolveConflict);

// Gestionnaire d'erreurs global
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({
    error: 'Internal Server Error',
    message: process.env.NODE_ENV === 'development' ? err.message : 'Something went wrong'
  });
});

// 404 handler
app.use('*', (req, res) => {
  res.status(404).json({
    error: 'Not Found',
    message: `Route ${req.originalUrl} not found`
  });
});

app.listen(PORT, () => {
  console.log(`🚀 Event Store Service running on port ${PORT}`);
  console.log(`📚 Providing Event Sourcing, CQRS, Sync and Conflict Resolution capabilities`);
});

module.exports = app;
