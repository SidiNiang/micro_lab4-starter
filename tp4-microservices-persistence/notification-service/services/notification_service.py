from models.notification import Notification
from config import templates_collection
import logging

logger = logging.getLogger(__name__)

class NotificationService:
    
    def create_booking_notification(self, booking_data):
        """Crée une notification de confirmation de réservation"""
        try:
            notification = Notification(
                user_id=booking_data['user_id'],
                type='booking_confirmation',
                subject=f'Confirmation de réservation - {booking_data["event_name"]}',
                content=self._render_booking_template(booking_data),
                channel='email'
            )
            
            notification.metadata = {
                'reservation_id': booking_data.get('reservation_id'),
                'event_id': booking_data.get('event_id'),
                'seats': booking_data.get('seats')
            }
            
            notification.save()
            logger.info(f"✅ Booking notification created: {notification.id}")
            
            # Simuler l'envoi (dans un vrai système, cela serait asynchrone)
            self._send_notification(notification)
            
            return notification
            
        except Exception as e:
            logger.error(f"❌ Error creating booking notification: {e}")
            raise e
    
    def create_payment_notification(self, payment_data):
        """Crée une notification de confirmation de paiement"""
        try:
            notification = Notification(
                user_id=payment_data['user_id'],
                type='payment_success',
                subject='Paiement confirmé',
                content=self._render_payment_template(payment_data),
                channel='email'
            )
            
            notification.metadata = {
                'payment_id': payment_data.get('payment_id'),
                'amount': payment_data.get('amount'),
                'currency': payment_data.get('currency', 'XOF')
            }
            
            notification.save()
            logger.info(f"✅ Payment notification created: {notification.id}")
            
            self._send_notification(notification)
            
            return notification
            
        except Exception as e:
            logger.error(f"❌ Error creating payment notification: {e}")
            raise e
    
    def _render_booking_template(self, data):
        """Génère le contenu HTML pour une notification de réservation"""
        return f"""
        <h2>Réservation confirmée !</h2>
        <p>Bonjour {data.get('user_name', 'Client')},</p>
        <p>Votre réservation pour l'événement <strong>{data.get('event_name', 'N/A')}</strong> a été confirmée.</p>
        <ul>
            <li>Nombre de places : {data.get('seats', 0)}</li>
            <li>Date de l'événement : {data.get('event_date', 'N/A')}</li>
            <li>Lieu : {data.get('location', 'N/A')}</li>
        </ul>
        <p>Numéro de réservation : <strong>{data.get('reservation_id', 'N/A')}</strong></p>
        <p>Merci pour votre confiance !</p>
        """
    
    def _render_payment_template(self, data):
        """Génère le contenu HTML pour une notification de paiement"""
        return f"""
        <h2>Paiement confirmé !</h2>
        <p>Bonjour,</p>
        <p>Votre paiement de <strong>{data.get('amount', 0)} {data.get('currency', 'XOF')}</strong> a été confirmé.</p>
        <p>Référence de paiement : <strong>{data.get('payment_id', 'N/A')}</strong></p>
        <p>Merci pour votre transaction !</p>
        """
    
    def _send_notification(self, notification):
        """Simule l'envoi de notification (email, SMS, etc.)"""
        try:
            # Dans un vrai système, on utiliserait un service d'email (SendGrid, AWS SES, etc.)
            logger.info(f"📧 Sending {notification.channel} notification to user {notification.user_id}")
            logger.info(f"   Subject: {notification.subject}")
            
            # Simuler un délai d'envoi
            import time
            time.sleep(0.5)
            
            # Marquer comme envoyé
            Notification.mark_as_sent(notification.id)
            logger.info(f"✅ Notification {notification.id} sent successfully")
            
        except Exception as e:
            logger.error(f"❌ Failed to send notification {notification.id}: {e}")
            raise e

notification_service = NotificationService()
