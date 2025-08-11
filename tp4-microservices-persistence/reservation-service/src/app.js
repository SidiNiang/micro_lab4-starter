const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
require('dotenv').config();

const connectDB = require('./config/database');
const reservationController = require('./controllers/reservation.controller');

const app = express();
const PORT = process.env.PORT || 3000;

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
    message: '📝 Reservation Service API - MongoDB + Polyglot Persistence',
    version: '1.0.0',
    database: 'MongoDB',
    patterns: ['Database per Service', 'Polyglot Persistence', 'CQRS', 'Saga Compensation'],
    endpoints: {
      reservations: '/api/reservations',
      compensations: '/api/reservations/:id/compensate',
      health: '/health'
    }
  });
});

app.get('/health', (req, res) => {
  res.json({ 
    status: 'OK', 
    timestamp: new Date().toISOString(),
    service: 'reservation-service',
    database: 'MongoDB'
  });
});

// Routes des réservations
app.post('/api/reservations', reservationController.createReservation);
app.get('/api/reservations/:id', reservationController.getReservationById);
app.get('/api/reservations/user/:userId', reservationController.getUserReservations);
app.get('/api/reservations/event/:eventId', reservationController.getEventReservations);
app.put('/api/reservations/:id/status', reservationController.updateReservationStatus);
app.post('/api/reservations/:id/cancel', reservationController.cancelReservation);
app.post('/api/reservations/:id/compensate', reservationController.compensateReservation);
app.get('/api/reservations/stats/:eventId', reservationController.getReservationStats);

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
  console.log(`🚀 Reservation Service running on port ${PORT}`);
  console.log(`📊 Database: MongoDB (Polyglot Persistence)`);
});

module.exports = app;
