from datetime import datetime
from config import notifications_collection
import uuid

class Notification:
    def __init__(self, user_id, type, subject, content, channel='email'):
        self.id = str(uuid.uuid4())
        self.user_id = user_id
        self.type = type  # booking_confirmation, payment_success, etc.
        self.subject = subject
        self.content = content
        self.channel = channel  # email, sms, push
        self.status = 'pending'  # pending, sent, failed
        self.created_at = datetime.now()
        self.sent_at = None
        self.metadata = {}
    
    def to_dict(self):
        return {
            '_id': self.id,
            'user_id': self.user_id,
            'type': self.type,
            'subject': self.subject,
            'content': self.content,
            'channel': self.channel,
            'status': self.status,
            'created_at': self.created_at,
            'sent_at': self.sent_at,
            'metadata': self.metadata
        }
    
    def save(self):
        notifications_collection.insert_one(self.to_dict())
        return self
    
    @staticmethod
    def find_by_id(notification_id):
        return notifications_collection.find_one({'_id': notification_id})
    
    @staticmethod
    def find_by_user(user_id):
        return list(notifications_collection.find({'user_id': user_id}).sort('created_at', -1))
    
    @staticmethod
    def mark_as_sent(notification_id):
        notifications_collection.update_one(
            {'_id': notification_id},
            {'$set': {'status': 'sent', 'sent_at': datetime.now()}}
        )
