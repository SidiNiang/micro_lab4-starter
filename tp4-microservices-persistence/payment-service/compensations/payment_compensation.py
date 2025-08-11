from sqlalchemy.orm import Session
from models.payment import Payment
from config import SessionLocal
import logging

class PaymentCompensationService:
    
    def __init__(self):
        self.logger = logging.getLogger(__name__)
    
    # =========================================================================
    # TODO-SAGA7: Implémentez la compensation de paiement (remboursement)
    # =========================================================================
    """
    Cette méthode doit initier un remboursement et mettre à jour le statut
    
    Actions :
    1. Trouver le paiement par ID
    2. Vérifier qu'il est dans un état remboursable (completed)
    3. Initier le processus de remboursement
    4. Mettre à jour le statut à 'refunding' puis 'refunded'
    5. Enregistrer la raison du remboursement dans les métadonnées
    
    @param payment_id: ID du paiement à rembourser
    @param reason: Raison du remboursement
    """
    def compensate_payment(self, payment_id: int, reason: str = "Saga compensation"):
        db: Session = SessionLocal()
        try:
            # ⚠️  TODO: À implémenter par les étudiants
            
            # Exemple de solution :
            # payment = db.query(Payment).filter(Payment.id == payment_id).first()
            # if not payment:
            #     raise ValueError(f"Payment {payment_id} not found")
            # 
            # if payment.status == 'refunded':
            #     self.logger.info(f"Payment {payment_id} already refunded")
            #     return
            # 
            # if payment.status != 'completed':
            #     raise ValueError(f"Cannot refund payment in status {payment.status}")
            # 
            # # Mettre à jour le statut
            # payment.status = 'refunding'
            # db.commit()
            # 
            # # Simuler le processus de remboursement
            # if self.process_refund(payment, reason):
            #     payment.status = 'refunded'
            # else:
            #     payment.status = 'refund_failed'
            # 
            # # Enregistrer la raison
            # metadata = json.loads(payment.metadata) if payment.metadata else {}
            # metadata['refund_reason'] = reason
            # metadata['refunded_at'] = datetime.now().isoformat()
            # payment.metadata = json.dumps(metadata)
            # 
            # db.commit()
            # self.logger.info(f"✅ Payment {payment_id} compensated")
            
            pass  # Placeholder - à remplacer
            
        except Exception as e:
            self.logger.error(f"Failed to compensate payment {payment_id}: {e}")
            db.rollback()
            raise e
        finally:
            db.close()
    
    # =========================================================================
    # TODO-SAGA8: Implémentez la vérification de l'état de compensation
    # =========================================================================
    """
    Cette méthode doit vérifier si un paiement peut être remboursé
    
    Critères :
    1. Le paiement existe
    2. Le statut est 'completed' (pas déjà remboursé)
    3. Le paiement n'est pas trop ancien (ex: moins de 30 jours)
    4. Le montant est supérieur à 0
    
    @param payment_id: ID du paiement
    @returns: True si le remboursement est possible
    """
    def can_compensate_payment(self, payment_id: int) -> bool:
        # ⚠️  TODO: À implémenter par les étudiants
        
        # Exemple de solution :
        # db: Session = SessionLocal()
        # try:
        #     payment = db.query(Payment).filter(Payment.id == payment_id).first()
        #     if not payment:
        #         return False
        #     
        #     if payment.status != 'completed':
        #         return False
        #     
        #     # Vérifier l'âge du paiement (30 jours max)
        #     if payment.completed_at:
        #         days_since_payment = (datetime.now() - payment.completed_at).days
        #         if days_since_payment > 30:
        #             return False
        #     
        #     # Vérifier le montant
        #     if float(payment.amount) <= 0:
        #         return False
        #     
        #     return True
        #     
        # except Exception as e:
        #     self.logger.error(f"Error checking compensation eligibility: {e}")
        #     return False
        # finally:
        #     db.close()
        
        return False  # Placeholder - à remplacer
    
    def process_refund(self, payment: Payment, reason: str):
        """Simulate refund processing with external payment provider"""
        try:
            # En production, ici on appellerait l'API du provider de paiement
            # Pour la simulation, on marque comme remboursé
            
            payment.status = 'refunded'
            payment.metadata = f"Refunded: {reason}"
            
            self.logger.info(f"Refund processed for payment {payment.id}")
            return True
            
        except Exception as e:
            self.logger.error(f"Refund processing failed for payment {payment.id}: {e}")
            return False

compensation_service = PaymentCompensationService()
