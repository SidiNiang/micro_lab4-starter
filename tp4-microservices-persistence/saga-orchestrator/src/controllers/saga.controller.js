const SagaOrchestrator = require('../orchestrators/saga.orchestrator');
const Joi = require('joi');

const sagaOrchestrator = new SagaOrchestrator();

// Schema de validation
const startSagaSchema = Joi.object({
  eventId: Joi.number().required(),
  userId: Joi.string().required(),
  userName: Joi.string().required(),
  userEmail: Joi.string().email().required(),
  userPhone: Joi.string().optional(),
  seats: Joi.number().min(1).required(),
  ticketPrice: Joi.number().required(),
  paymentMethod: Joi.string().valid('card', 'mobile_money', 'bank_transfer').required(),
  preferences: Joi.object().optional()
});

class SagaController {
  
  async startBookingSaga(req, res) {
    try {
      const { error, value } = startSagaSchema.validate(req.body);
      if (error) {
        return res.status(400).json({ 
          error: 'Validation error', 
          details: error.details 
        });
      }
      
      console.log('🎭 Starting new booking saga with data:', value);
      
      const sagaId = await sagaOrchestrator.startBookingProcessSaga(value);
      
      res.status(202).json({
        message: 'Booking process started',
        sagaId,
        status: 'PROCESSING'
      });
      
    } catch (error) {
      console.error('❌ Error starting saga:', error);
      res.status(500).json({ 
        error: 'Failed to start booking process', 
        message: error.message 
      });
    }
  }

  async getSagaStatus(req, res) {
    try {
      const { sagaId } = req.params;
      const saga = sagaOrchestrator.getSaga(sagaId);
      
      if (!saga) {
        return res.status(404).json({
          error: 'Saga not found',
          sagaId
        });
      }
      
      res.json({
        sagaId: saga.id,
        type: saga.type,
        status: saga.status,
        currentStep: saga.currentStep,
        steps: saga.steps,
        createdAt: saga.createdAt,
        updatedAt: saga.updatedAt,
        error: saga.error
      });
      
    } catch (error) {
      console.error('❌ Error getting saga status:', error);
      res.status(500).json({ 
        error: 'Failed to get saga status', 
        message: error.message 
      });
    }
  }

  async getAllSagas(req, res) {
    try {
      const sagas = sagaOrchestrator.getAllSagas();
      
      res.json({
        count: sagas.length,
        sagas: sagas.map(saga => ({
          sagaId: saga.id,
          type: saga.type,
          status: saga.status,
          createdAt: saga.createdAt,
          updatedAt: saga.updatedAt
        }))
      });
      
    } catch (error) {
      console.error('❌ Error getting all sagas:', error);
      res.status(500).json({ 
        error: 'Failed to get sagas', 
        message: error.message 
      });
    }
  }
}

module.exports = new SagaController();
