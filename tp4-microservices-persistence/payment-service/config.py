"""
Configuration du Service Paiements - Polyglot Persistence
Démontre l'utilisation combinée de PostgreSQL + Redis

PostgreSQL: Pour les transactions ACID critiques (paiements)
Redis: Pour le cache haute performance et les sessions
"""

import os
import redis
from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker

# Configuration PostgreSQL pour les transactions
POSTGRES_URL = os.getenv(
    'POSTGRES_URL',
    'postgresql://payments_user:payments_password@localhost:5432/payments_db'
)

# Configuration Redis pour le cache
REDIS_URL = os.getenv('REDIS_URL', 'redis://localhost:6379/0')

# SQLAlchemy setup
engine = create_engine(
    POSTGRES_URL,
    pool_size=20,
    max_overflow=30,
    pool_pre_ping=True,
    echo=True if os.getenv('DEBUG') == 'true' else False
)

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

# Redis setup
redis_client = redis.Redis.from_url(
    REDIS_URL,
    decode_responses=True,
    socket_connect_timeout=5,
    socket_timeout=5,
    retry_on_timeout=True
)

# =========================================================================
# TODO-POLY1: Implémentez la classe CacheManager pour gérer le cache Redis
# =========================================================================

class CacheManager:
    def __init__(self, redis_client):
        self.redis = redis_client

    def get(self, key):
        try:
            return self.redis.get(key)
        except redis.RedisError as e:
            print(f"Redis get error: {e}")
            return None

    def set(self, key, value, ttl=None):
        try:
            if ttl:
                return self.redis.setex(key, ttl, value)
            return self.redis.set(key, value)
        except redis.RedisError as e:
            print(f"Redis set error: {e}")
            return False

    def delete(self, key):
        try:
            return self.redis.delete(key)
        except redis.RedisError as e:
            print(f"Redis delete error: {e}")
            return False

    def exists(self, key):
        try:
            return self.redis.exists(key) > 0  
        except redis.RedisError as e:
            print(f"Redis exists error: {e}")
            return False


cache_manager = CacheManager(redis_client)
