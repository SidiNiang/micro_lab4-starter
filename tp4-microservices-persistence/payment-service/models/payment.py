"""
Modèle Payment - Démontre Polyglot Persistence avec PostgreSQL + Redis

PostgreSQL: Stockage persistant des transactions (ACID)
Redis: Cache des données fréquemment accédées (performance)
"""

from sqlalchemy import Column, Integer, String, DateTime, Boolean, Text, Numeric, Sequence
from decimal import Decimal
from sqlalchemy.sql import func
from config import Base, CacheManager, redis_client, cache_manager
import json
from datetime import datetime, timedelta

class Payment(Base):
    """
    Modèle de paiement combinant PostgreSQL (persistance) et Redis (cache)
    
    Démontre :
    - Transactions ACID critiques en PostgreSQL
    - Cache des données chaudes en Redis
    - Stratégie cache-aside pattern
    """
    
    __tablename__ = 'payments'

    id = Column(Integer, primary_key=True, autoincrement=True)
    #id = Column(Integer, Sequence('payments_id_seq'), primary_key=True)
    reservation_id = Column(String(50), nullable=False, index=True)
    user_id = Column(String(50), nullable=False, index=True)
    amount = Column(Numeric(10, 2), nullable=False)
    currency = Column(String(3), default='XOF')
    payment_method = Column(String(50), nullable=False)  # card, mobile_money, bank_transfer
    status = Column(String(20), default='pending')  # pending, processing, completed, failed, refunded
    transaction_id = Column(String(100), unique=True)
    provider_reference = Column(String(100)) #askip metadata est un mot reserve
    e_metadata = Column(Text)  # JSON string for flexible data
    created_at = Column(DateTime, server_default=func.now())
    updated_at = Column(DateTime, server_default=func.now(), onupdate=func.now())
    completed_at = Column(DateTime)

    # =========================================================================
    # TODO-POLY2: Implémentez la méthode pour mettre en cache les données de paiement
    # =========================================================================
    def cache_payment_data(self, ttl_seconds=3600):
        """
        Cette méthode doit sérialiser l'objet Payment et le stocker dans Redis avec TTL.
        
        Logique :
        1. Créer une clé cache (ex: "payment:{id}")
        2. Sérialiser les données avec self.to_dict()
        3. Stocker en JSON dans Redis avec TTL
        4. Gérer les erreurs gracieusement
        """
        # ⚠️  TODO: À implémenter par les étudiants
        
        # Exemple de solution :
        cache_key = f"payment:{self.id}"
        payment_data = json.dumps(self.to_dict(), default=str)
        
        try:
            cache_manager.set(cache_key, payment_data, ttl_seconds)
            print(f"Payment {self.id} cached with TTL {ttl_seconds}s")
        except Exception as e:
            print(f"Failed to cache payment {self.id}: {e}")
        
       # pass  # Placeholder - à remplacer

    # =========================================================================
    # TODO-POLY3: Implémentez la méthode statique pour récupérer depuis le cache
    # =========================================================================
    @classmethod
    def get_payment_with_cache(cls, payment_id, session):
        """
        Cette méthode doit essayer le cache Redis d'abord, puis la base PostgreSQL.
        
        Pattern Cache-Aside :
        1. Vérifier le cache Redis avec la clé "payment:{id}"
        2. Si trouvé, désérialiser et retourner
        3. Si pas trouvé, requêter PostgreSQL
        4. Mettre à jour le cache avec le résultat
        5. Retourner le résultat
        """
        # ⚠️  TODO: À implémenter par les étudiants
        
        cache_key = f"payment:{payment_id}"
        
        # Essayer le cache d'abord
        cached_data = cache_manager.get(cache_key)
        if cached_data:
            try:
                return json.loads(cached_data)
            except json.JSONDecodeError:
                pass
        
        # Si pas en cache, requêter la base
        payment = session.query(cls).filter(cls.id == payment_id).first()
        if payment:
            # Mettre à jour le cache
            payment.cache_payment_data()
            return payment.to_dict()
        
        return None
        
        #return None  # Placeholder - à remplacer

    def to_dict(self):
        """Sérialise l'objet Payment en dictionnaire"""
        return {
            'id': self.id,
            'reservation_id': self.reservation_id,
            'user_id': self.user_id,
            'amount': float(self.amount),
            'currency': self.currency,
            'payment_method': self.payment_method,
            'status': self.status,
            'transaction_id': self.transaction_id,
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'updated_at': self.updated_at.isoformat() if self.updated_at else None,
            'completed_at': self.completed_at.isoformat() if self.completed_at else None
        }
