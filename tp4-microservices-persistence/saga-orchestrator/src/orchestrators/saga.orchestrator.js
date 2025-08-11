const EventEmitter = require('events');
const axios = require('axios');

/**
 * Orchestrateur Saga - Gestion des transactions distribuées
 * 
 * Implémente le pattern Saga avec orchestration centralisée pour :
 * - Coordonner les transactions entre microservices
 * - Gérer les compensations en cas d'échec
 * - Maintenir la cohérence sans verrouillage distribué
 * - Tracer toutes les étapes pour l'audit
 */
class SagaOrchestrator extends EventEmitter {
  constructor() {
    super();
    this.activeSagas = new Map();
    this.serviceEndpoints = {
      events: process.env.EVENTS_SERVICE_URL || 'http://localhost:8080',
      reservations: process.env.RESERVATIONS_SERVICE_URL || 'http://localhost:3000',
      payments: process.env.PAYMENTS_SERVICE_URL || 'http://localhost:5000',
      notifications: process.env.NOTIFICATIONS_SERVICE_URL || 'http://localhost:5001'
    };

    console.log('🎭 Saga Orchestrator initialized with endpoints:', this.serviceEndpoints);
  }

  // =========================================================================
  // TODO-SAGA1: Implémentez la méthode pour démarrer un nouveau Saga
  // =========================================================================
  /**
   * Cette méthode doit initialiser le state du Saga et exécuter la première étape.
   * 
   * Flux complet : Réservation → Paiement → Confirmation → Notification
   * 
   * Logique :
   * 1. Générer un ID unique pour le Saga
   * 2. Initialiser la structure de données du Saga
   * 3. Exécuter la première étape (réservation)
   * 4. Si succès, passer à l'étape suivante
   * 5. Si échec, déclencher la compensation
   * 6. Retourner l'ID du Saga pour le suivi
   */
  async startBookingProcessSaga(sagaData) {
    const sagaId = this.generateSagaId();
    const saga = {
      id: sagaId,
      type: 'BOOKING_PROCESS',
      status: 'STARTED',
      data: sagaData,
      steps: [],
      currentStep: 0,
      createdAt: new Date(),
      updatedAt: new Date()
    };

    this.activeSagas.set(sagaId, saga);

    try {
      console.log(`🚀 Starting Saga ${sagaId} for booking process`);

      await this.executeReservationStep(sagaId);

      // Si réservation réussie, passer au paiement
      saga.currentStep = 1;
      await this.executePaymentStep(sagaId);

      // Si tout réussit, marquer comme complété
      saga.status = 'COMPLETED';
      await this.recordSagaStep(sagaId, 'SAGA_COMPLETED', {}, 'COMPLETED');

    } catch (error) {
      await this.handleSagaFailure(sagaId, error);
      throw error;
    }
    return sagaId; // Placeholder - à améliorer
  }

  // =========================================================================
  // TODO-SAGA2: Implémentez l'étape de réservation
  // =========================================================================
  /**
   * Cette étape doit vérifier la disponibilité et créer la réservation.
   * 
   * Actions :
   * 1. Appeler le service de réservation avec les données du Saga
   * 2. Enregistrer l'étape dans l'historique du Saga
   * 3. Stocker l'ID de réservation pour compensation future
   * 4. Gérer les erreurs et exceptions
   */
  async executeReservationStep(sagaId) {
    const saga = this.activeSagas.get(sagaId);
    if (!saga) throw new Error(`Saga ${sagaId} not found`);
    try {
      console.log(`Executing reservation step for Saga ${sagaId}`);
      const reservationData = {
        eventId: saga.data.eventId,
        userId: saga.data.userId,
        userName: saga.data.userName,
        userEmail: saga.data.userEmail,
        seats: saga.data.seats
      };
      const response = await axios.post(
        `${this.serviceEndpoints.reservations}/api/reservations`,
        reservationData
      );
      // Enregistrer l'ID de réservation pour compensation future
      saga.data.reservationId = response.data.reservation._id;
      await this.recordSagaStep(sagaId, 'RESERVATION_CREATED', {
        reservationId: response.data.reservation._id,
        seats: saga.data.seats
      });
      console.log(`Reservation step completed for Saga ${sagaId}`);
    } catch (error) {
      await this.recordSagaStep(sagaId, 'RESERVATION_FAILED', { error: error.message }, 'FAILED');
      throw error;
    }
  }

  // =========================================================================
  // TODO-SAGA3: Implémentez l'étape de paiement
  // =========================================================================
  /**
   * Cette étape doit traiter le paiement si la réservation a réussi.
   * 
   * Actions :
   * 1. Calculer le montant basé sur le nombre de places et le prix
   * 2. Appeler le service de paiement
   * 3. Enregistrer l'ID de paiement pour compensation
   * 4. Mettre à jour l'historique du Saga
   */
  async executePaymentStep(sagaId) {
    const saga = this.activeSagas.get(sagaId);
    if (!saga) throw new Error(`Saga \ ${sagaId} not found`);
    try {
      console.log(`Executing payment step for Saga \ ${sagaId}`);
      const paymentData = {
        reservation_id: saga.data.reservationId,
        user_id: saga.data.userId,
        amount: saga.data.seats * saga.data.ticketPrice,
        currency: 'XOF',
        payment_method: saga.data.paymentMethod || 'card'
      };
      const response = await axios.post(
        `${this.serviceEndpoints.payments}/api/payments`,
        paymentData
      );
      saga.data.paymentId = response.data.payment.id;
      await this.recordSagaStep(sagaId, 'PAYMENT_COMPLETED', {
        paymentId: response.data.payment.id,
        amount: paymentData.amount
      });
      console.log(`Payment step completed for Saga \ ${sagaId}`);
    } catch (error) {
      await this.recordSagaStep(sagaId, 'PAYMENT_FAILED', { error: error.message }, 'FAILED');
      throw error;
    }
  }

  // =========================================================================
  // TODO-SAGA4: Implémentez la gestion des compensations
  // =========================================================================
  /**
   * Cette méthode doit annuler les étapes précédentes en cas d'échec.
   * 
   * Principe de compensation :
   * 1. Identifier quelles étapes ont été complétées
   * 2. Exécuter les compensations dans l'ordre inverse
   * 3. Enregistrer chaque compensation effectuée
   * 4. Marquer le Saga comme compensé
   */
  async executeSagaCompensation(sagaId, failedStep) {
    const saga = this.activeSagas.get(sagaId);
    if (!saga) return;
    console.log(`Starting compensation for Saga ${sagaId} at step ${failedStep}`);
    try {
      // Compenser les étapes dans l'ordre inverse
      const completedSteps = saga.steps.filter(step => step.status === 'COMPLETED');
      for (let i = completedSteps.length - 1; i >= 0; i--) {
        const step = completedSteps[i];
        if (step.name === 'PAYMENT_COMPLETED' && saga.data.paymentId) {
          await this.compensatePayment(sagaId, saga.data.paymentId);
        }
        if (step.name === 'RESERVATION_CREATED' && saga.data.reservationId) {
          await this.compensateReservation(sagaId, saga.data.reservationId);
        }
      }
      saga.status = 'COMPENSATED';
      await this.recordSagaStep(sagaId, 'SAGA_COMPENSATED', {}, 'COMPLETED');
    } catch (error) {
      console.error(`Compensation failed for Saga ${sagaId}:`, error);
      saga.status = 'COMPENSATION_FAILED';
    }
  }
  async compensatePayment(sagaId, paymentId) {
    try {
      await axios.post(`${this.serviceEndpoints.payments}/api/payments/${paymentId}/compensate`);
      await this.recordSagaStep(sagaId, 'PAYMENT_COMPENSATED', { paymentId });
    } catch (error) {
      console.error('Payment compensation failed:', error);
    }
  }
  async compensateReservation(sagaId, reservationId) {
    try {
      await axios.post(`${this.serviceEndpoints.reservations}/api/reservations/${reservationId}/compensate`);
      await this.recordSagaStep(sagaId, 'RESERVATION_COMPENSATED', { reservationId });
    } catch (error) {
      console.error('Reservation compensation failed:', error);
    }
  }

  // Méthodes utilitaires
  generateSagaId() {
    return `SAGA-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`;
  }

  async recordSagaStep(sagaId, stepName, data, status = 'COMPLETED') {
    const saga = this.activeSagas.get(sagaId);
    if (!saga) return;

    const step = {
      name: stepName,
      status,
      data,
      timestamp: new Date()
    };

    saga.steps.push(step);
    saga.updatedAt = new Date();

    console.log(`📝 Saga ${sagaId} - Step recorded: ${stepName} (${status})`);
    this.emit('saga-step', { sagaId, step });
  }

  async handleSagaFailure(sagaId, error) {
    const saga = this.activeSagas.get(sagaId);
    if (!saga) return;

    console.error(`❌ Saga ${sagaId} failed:`, error.message);
    saga.status = 'FAILED';
    saga.error = error.message;

    await this.recordSagaStep(sagaId, 'SAGA_FAILED', { error: error.message }, 'FAILED');

    // Déclencher les compensations
    await this.executeSagaCompensation(sagaId, saga.currentStep);
  }

  async compensateReservation(sagaId, reservationId) {
    try {
      console.log(`🔄 Compensating reservation ${reservationId} for Saga ${sagaId}`);

      await axios.post(
        `${this.serviceEndpoints.reservations}/api/reservations/${reservationId}/compensate`,
        { reason: 'Saga compensation' }
      );

      await this.recordSagaStep(sagaId, 'RESERVATION_COMPENSATED', { reservationId });

    } catch (error) {
      console.error(`❌ Failed to compensate reservation ${reservationId}:`, error);
      throw error;
    }
  }

  async compensatePayment(sagaId, paymentId) {
    try {
      console.log(`🔄 Compensating payment ${paymentId} for Saga ${sagaId}`);

      await axios.post(
        `${this.serviceEndpoints.payments}/api/payments/${paymentId}/compensate`,
        { reason: 'Saga compensation' }
      );

      await this.recordSagaStep(sagaId, 'PAYMENT_COMPENSATED', { paymentId });

    } catch (error) {
      console.error(`❌ Failed to compensate payment ${paymentId}:`, error);
      throw error;
    }
  }

  getSaga(sagaId) {
    return this.activeSagas.get(sagaId);
  }

  getAllSagas() {
    return Array.from(this.activeSagas.values());
  }
}

module.exports = SagaOrchestrator;
