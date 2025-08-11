import os
from pymongo import MongoClient

# Configuration MongoDB
MONGODB_URI = os.getenv('MONGODB_URI', 'mongodb://localhost:27017/')
MONGODB_DB = os.getenv('MONGODB_DB', 'notifications_db')

# Configuration RabbitMQ
RABBITMQ_HOST = os.getenv('RABBITMQ_HOST', 'localhost')
RABBITMQ_PORT = int(os.getenv('RABBITMQ_PORT', '5672'))

# Connexion MongoDB
mongo_client = MongoClient(MONGODB_URI)
db = mongo_client[MONGODB_DB]

# Collections
notifications_collection = db['notifications']
templates_collection = db['templates']
