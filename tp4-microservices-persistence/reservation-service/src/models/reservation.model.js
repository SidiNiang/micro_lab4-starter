const mongoose = require('mongoose');

/**
 * Modèle de Réservation - Démontre Polyglot Persistence avec MongoDB
 * 
 * Ce modèle illustre :
 * - La flexibilité du schéma NoSQL (documents imbriqués)
 * - Les index composés pour optimiser les requêtes
 * - Les validations au niveau du schéma
 * - L'agrégation de données avec MongoDB
 */

const reservationSchema = new mongoose.Schema({
  eventId: {
    type: Number,
    required: true,
    index: true
  },
  userId: {
    type: String,
    required: true,
    index: true
  },
  userDetails: {
    name: { type: String, required: true },
    email: { type: String, required: true },
    phone: { type: String },
    preferences: {
      seatType: { type: String, enum: ['standard', 'premium', 'vip'] },
      accessibilityNeeds: { type: Boolean, default: false },
      dietaryRestrictions: [String]
    }
  },
  bookingDetails: {
    seats: { type: Number, required: true, min: 1 },
    seatNumbers: [String], // Peut être vide si places non assignées
    totalAmount: { type: Number, required: true },
    currency: { type: String, default: 'XOF' }
  },
  status: {
    type: String,
    enum: ['pending', 'confirmed', 'cancelled', 'refunded'],
    default: 'pending',
    index: true
  },
  timeline: [{
    status: String,
    timestamp: { type: Date, default: Date.now },
    reason: String,
    updatedBy: String
  }],
  metadata: {
    source: { type: String, default: 'web' }, // web, mobile, api
    channel: String,
    promotionCode: String,
    referralId: String
  }
}, {
  timestamps: true,
  versionKey: '__v'
});

// Index composé pour optimiser les requêtes fréquentes
reservationSchema.index({ eventId: 1, status: 1 });
reservationSchema.index({ userId: 1, createdAt: -1 });

// =========================================================================
// TODO-DB3: Implémentez la méthode statique pour calculer les statistiques de réservation
// =========================================================================
/**
 * Cette méthode doit agréger les données par événement et retourner un résumé
 * utilisant le pipeline d'agrégation MongoDB.
 * 
 * Doit retourner :
 * - totalReservations: nombre total de réservations
 * - totalSeats: nombre total de places réservées
 * - confirmedSeats: places confirmées
 * - pendingSeats: places en attente
 * - revenue: revenus des réservations confirmées
 * 
 * @param {Number} eventId - ID de l'événement
 * @returns {Object} Statistiques de réservation
 */
reservationSchema.statics.getEventReservationStats = async function (eventId) {
  const stats = await this.aggregate([
    { $match: { eventId: parseInt(eventId) } },
    {
      $group: {
        _id: '$status',
        count: { $sum: 1 },
        totalSeats: { $sum: '$bookingDetails.seats' },
        totalRevenue: { $sum: '$bookingDetails.totalAmount' }
      }
    }
  ]);
  // Consolider les résultats
  const result = {
    totalReservations: 0,
    totalSeats: 0,
    confirmedSeats: 0,
    pendingSeats: 0,
    revenue: 0
  };
  stats.forEach(stat => {
    result.totalReservations += stat.count;
    result.totalSeats += stat.totalSeats;
    if (stat._id === 'confirmed') {
      result.confirmedSeats = stat.totalSeats;
    } else if (stat._id === 'pending') {
      result.pendingSeats = stat.totalSeats;
    }
    if (stat._id === 'confirmed') {
      result.revenue = stat.totalRevenue;
    }
  });
  return result;
};


// =========================================================================
// TODO-DB4: Implémentez le middleware pre-save pour mettre à jour la timeline
// =========================================================================
/**
 * Ce middleware doit automatiquement ajouter une entrée timeline quand le status change.
 * 
 * Logique :
 * 1. Vérifier si le status a été modifié (this.isModified('status'))
 * 2. Si oui, ajouter une entrée dans timeline avec le nouveau status
 * 3. Inclure timestamp, reason et updatedBy
 */
reservationSchema.pre('save', function (next) {
  // Vérifier si le status a changé
  if (this.isModified('status')) {
    this.timeline.push({
      status: this.status,
      timestamp: new Date(),
      reason: `Status changed to ${this.status}`,
      updatedBy: 'system'
    });
  }
  next();
});


module.exports = mongoose.model('Reservation', reservationSchema);
