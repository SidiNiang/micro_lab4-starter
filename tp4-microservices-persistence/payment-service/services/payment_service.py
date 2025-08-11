from sqlalchemy.orm import Session
from models.payment import Payment
from config import SessionLocal, cache_manager
import uuid
import logging
from datetime import datetime
import json

class PaymentService:
    """
    Service de gestion des paiements avec cache Redis
    Démontre l'architecture Polyglot Persistence
    """
    
    def __init__(self):
        self.logger = logging.getLogger(__name__)
    
    def create_payment(self, payment_data):
        """Crée un nouveau paiement avec mise en cache automatique"""
        db: Session = SessionLocal()
        try:
            payment = Payment(
                reservation_id=payment_data['reservation_id'],
                user_id=payment_data['user_id'],
                amount=payment_data['amount'],
                currency=payment_data.get('currency', 'XOF'),
                payment_method=payment_data['payment_method'],
                transaction_id=str(uuid.uuid4()),
                metadata=json.dumps(payment_data.get('metadata', {}))
            )
            
            db.add(payment)
            db.commit()
            db.refresh(payment)
            
            # Mettre en cache automatiquement
            payment.cache_payment_data()
            
            self.logger.info(f"✅ Payment created: {payment.id}")
            return payment
            
        except Exception as e:
            db.rollback()
            self.logger.error(f"❌ Failed to create payment: {e}")
            raise e
        finally:
            db.close()
    
    def get_payment_by_id(self, payment_id: int):
        """Récupère un paiement avec cache-aside pattern"""
        db: Session = SessionLocal()
        try:
            # Utiliser la méthode avec cache
            cached_payment = Payment.get_payment_with_cache(payment_id, db)
            if cached_payment:
                self.logger.info(f"🎯 Payment {payment_id} found (cache hit)")
                return cached_payment
                
            # Fallback direct si le cache échoue
            payment = db.query(Payment).filter(Payment.id == payment_id).first()
            if payment:
                payment.cache_payment_data()
                self.logger.info(f"💾 Payment {payment_id} found (database)")
                return payment.to_dict()
            
            self.logger.warning(f"❌ Payment {payment_id} not found")
            return None
            
        except Exception as e:
            self.logger.error(f"❌ Failed to get payment {payment_id}: {e}")
            raise e
        finally:
            db.close()
    
    def update_payment_status(self, payment_id: int, status: str, metadata: dict = None):
        """Met à jour le statut d'un paiement et invalide le cache"""
        db: Session = SessionLocal()
        try:
            payment = db.query(Payment).filter(Payment.id == payment_id).first()
            if not payment:
                raise ValueError(f"Payment {payment_id} not found")
            
            payment.status = status
            if metadata:
                existing_metadata = json.loads(payment.metadata) if payment.metadata else {}
                existing_metadata.update(metadata)
                payment.metadata = json.dumps(existing_metadata)
            
            if status == 'completed':
                payment.completed_at = datetime.now()
            
            db.commit()
            db.refresh(payment)
            
            # Mettre à jour le cache
            payment.cache_payment_data()
            
            self.logger.info(f"✅ Payment {payment_id} status updated to {status}")
            return payment
            
        except Exception as e:
            db.rollback()
            self.logger.error(f"❌ Failed to update payment {payment_id}: {e}")
            raise e
        finally:
            db.close()

payment_service = PaymentService()
