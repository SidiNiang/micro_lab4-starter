from flask import Flask, request, jsonify
from flask_cors import CORS
import os
import logging
from datetime import datetime
from config import engine, Base
from services.payment_service import payment_service
from compensations.payment_compensation import compensation_service

app = Flask(__name__)
CORS(app)

# Configuration du logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Créer les tables
Base.metadata.create_all(bind=engine)

@app.route('/', methods=['GET'])
def health_check():
    return jsonify({
        'message': '💳 Payment Service API - PostgreSQL + Redis Cache',
        'version': '1.0.0',
        'status': 'healthy',
        'database': 'PostgreSQL (transactions) + Redis (cache)',
        'patterns': ['Polyglot Persistence', 'Cache-Aside', 'Saga Compensation'],
        'endpoints': {
            'payments': '/api/payments',
            'compensations': '/api/payments/:id/compensate',
            'health': '/health'
        }
    })

@app.route('/health', methods=['GET'])
def health():
    return jsonify({
        'status': 'OK',
        'service': 'payment-service',
        'timestamp': datetime.now().isoformat(),
        'database': 'PostgreSQL + Redis'
    })

@app.route('/api/payments', methods=['POST'])
def create_payment():
    try:
        data = request.get_json()
        logger.info(f"💳 Creating payment: {data}")
        
        # Validation basique
        required_fields = ['reservation_id', 'user_id', 'amount', 'payment_method']
        for field in required_fields:
            if field not in data:
                return jsonify({'error': f'Missing required field: {field}'}), 400
        
        payment = payment_service.create_payment(data)
        
        return jsonify({
            'success': True,
            'payment': payment.to_dict(),
            'message': 'Payment created successfully'
        }), 201
        
    except Exception as e:
        logger.error(f"❌ Error creating payment: {e}")
        return jsonify({
            'error': 'Failed to create payment',
            'message': str(e)
        }), 500

@app.route('/api/payments/<int:payment_id>', methods=['GET'])
def get_payment(payment_id):
    try:
        logger.info(f"🔍 Getting payment {payment_id}")
        payment = payment_service.get_payment_by_id(payment_id)
        if not payment:
            return jsonify({'error': 'Payment not found'}), 404
        
        return jsonify(payment)
        
    except Exception as e:
        logger.error(f"❌ Error getting payment {payment_id}: {e}")
        return jsonify({
            'error': 'Failed to get payment',
            'message': str(e)
        }), 500

@app.route('/api/payments/<int:payment_id>/status', methods=['PUT'])
def update_payment_status(payment_id):
    try:
        data = request.get_json()
        status = data.get('status')
        metadata = data.get('metadata', {})
        
        if not status:
            return jsonify({'error': 'Status is required'}), 400
        
        payment = payment_service.update_payment_status(payment_id, status, metadata)
        
        return jsonify({
            'success': True,
            'payment': payment.to_dict(),
            'message': 'Payment status updated successfully'
        })
        
    except ValueError as e:
        return jsonify({'error': str(e)}), 404
    except Exception as e:
        logger.error(f"❌ Error updating payment status {payment_id}: {e}")
        return jsonify({
            'error': 'Failed to update payment status',
            'message': str(e)
        }), 500

@app.route('/api/payments/<int:payment_id>/compensate', methods=['POST'])
def compensate_payment(payment_id):
    try:
        data = request.get_json()
        reason = data.get('reason', 'Saga compensation')
        
        # Vérifier l'éligibilité
        if not compensation_service.can_compensate_payment(payment_id):
            return jsonify({
                'error': 'Payment cannot be compensated',
                'message': 'Payment is not eligible for refund'
            }), 400
        
        compensation_service.compensate_payment(payment_id, reason)
        
        return jsonify({
            'success': True,
            'message': f'Payment {payment_id} compensated successfully'
        })
        
    except Exception as e:
        logger.error(f"❌ Error compensating payment {payment_id}: {e}")
        return jsonify({
            'error': 'Failed to compensate payment',
            'message': str(e)
        }), 500

@app.errorhandler(404)
def not_found(error):
    return jsonify({'error': 'Not found'}), 404

@app.errorhandler(500)
def internal_error(error):
    return jsonify({'error': 'Internal server error'}), 500

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 5000))
    debug = os.environ.get('DEBUG', 'false').lower() == 'true'
    logger.info(f"🚀 Starting Payment Service on port {port}")
    logger.info(f"💾 Using PostgreSQL + Redis (Polyglot Persistence)")
    app.run(host='0.0.0.0', port=port, debug=debug)
