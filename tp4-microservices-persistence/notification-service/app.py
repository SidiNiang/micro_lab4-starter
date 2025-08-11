from flask import Flask, request, jsonify
from flask_cors import CORS
import logging
from datetime import datetime
from services.notification_service import notification_service
from models.notification import Notification

app = Flask(__name__)
CORS(app)

# Configuration du logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

@app.route('/', methods=['GET'])
def health_check():
    return jsonify({
        'message': '📬 Notification Service API - MongoDB',
        'version': '1.0.0',
        'status': 'healthy',
        'database': 'MongoDB',
        'patterns': ['Database per Service', 'Event-Driven Notifications'],
        'endpoints': {
            'notifications': '/api/notifications',
            'user_notifications': '/api/notifications/user/{user_id}',
            'health': '/health'
        }
    })

@app.route('/health', methods=['GET'])
def health():
    return jsonify({
        'status': 'OK',
        'service': 'notification-service',
        'timestamp': datetime.now().isoformat(),
        'database': 'MongoDB'
    })

@app.route('/api/notifications/booking', methods=['POST'])
def create_booking_notification():
    try:
        data = request.get_json()
        logger.info(f"📧 Creating booking notification: {data}")
        
        notification = notification_service.create_booking_notification(data)
        
        return jsonify({
            'success': True,
            'notification_id': notification.id,
            'message': 'Booking notification created and sent'
        }), 201
        
    except Exception as e:
        logger.error(f"❌ Error creating booking notification: {e}")
        return jsonify({
            'error': 'Failed to create notification',
            'message': str(e)
        }), 500

@app.route('/api/notifications/payment', methods=['POST'])
def create_payment_notification():
    try:
        data = request.get_json()
        logger.info(f"💳 Creating payment notification: {data}")
        
        notification = notification_service.create_payment_notification(data)
        
        return jsonify({
            'success': True,
            'notification_id': notification.id,
            'message': 'Payment notification created and sent'
        }), 201
        
    except Exception as e:
        logger.error(f"❌ Error creating payment notification: {e}")
        return jsonify({
            'error': 'Failed to create notification',
            'message': str(e)
        }), 500

@app.route('/api/notifications/<notification_id>', methods=['GET'])
def get_notification(notification_id):
    try:
        notification = Notification.find_by_id(notification_id)
        if not notification:
            return jsonify({'error': 'Notification not found'}), 404
        
        return jsonify(notification)
        
    except Exception as e:
        logger.error(f"❌ Error getting notification {notification_id}: {e}")
        return jsonify({
            'error': 'Failed to get notification',
            'message': str(e)
        }), 500

@app.route('/api/notifications/user/<user_id>', methods=['GET'])
def get_user_notifications(user_id):
    try:
        notifications = Notification.find_by_user(user_id)
        
        return jsonify({
            'user_id': user_id,
            'count': len(notifications),
            'notifications': notifications
        })
        
    except Exception as e:
        logger.error(f"❌ Error getting notifications for user {user_id}: {e}")
        return jsonify({
            'error': 'Failed to get user notifications',
            'message': str(e)
        }), 500

@app.errorhandler(404)
def not_found(error):
    return jsonify({'error': 'Not found'}), 404

@app.errorhandler(500)
def internal_error(error):
    return jsonify({'error': 'Internal server error'}), 500

if __name__ == '__main__':
    import os
    port = int(os.environ.get('PORT', 5001))
    debug = os.environ.get('DEBUG', 'false').lower() == 'true'
    logger.info(f"🚀 Starting Notification Service on port {port}")
    logger.info(f"💾 Using MongoDB for storage")
    app.run(host='0.0.0.0', port=port, debug=debug)
