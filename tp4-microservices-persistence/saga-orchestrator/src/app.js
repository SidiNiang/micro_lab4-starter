const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
require('dotenv').config();

const sagaController = require('./controllers/saga.controller');

const app = express();
const PORT = process.env.PORT || 3002;

// Middleware
app.use(helmet());
app.use(cors());
app.use(morgan('combined'));
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));

// Routes principales
app.get('/', (req, res) => {
  res.json({
    message: '🎭 Saga Orchestrator - Distributed Transaction Management',
    version: '1.0.0',
    patterns: ['Saga Pattern', 'Orchestration', 'Compensation'],
    capabilities: [
      'Distributed transaction coordination',
      'Automatic compensation on failure',
      'Step-by-step transaction tracking',
      'Idempotent operations'
    ],
    endpoints: {
      startSaga: '/api/saga/booking',
      sagaStatus: '/api/saga/:sagaId',
      allSagas: '/api/saga',
      health: '/health'
    }
  });
});

app.get('/health', (req, res) => {
  res.json({ 
    status: 'OK', 
    timestamp: new Date().toISOString(),
    service: 'saga-orchestrator'
  });
});

// Routes du Saga
app.post('/api/saga/booking', sagaController.startBookingSaga);
app.get('/api/saga/:sagaId', sagaController.getSagaStatus);
app.get('/api/saga', sagaController.getAllSagas);

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
  console.log(`🚀 Saga Orchestrator running on port ${PORT}`);
  console.log(`🎭 Managing distributed transactions across microservices`);
});

module.exports = app;
