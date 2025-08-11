const axios = require('axios');

const EVENT_SERVICE_URL = process.env.EVENT_SERVICE_URL || 'http://localhost:8080/api/events';

class EventService {
  
  constructor() {
    this.apiClient = axios.create({
      timeout: 5000,
      headers: {
        'Content-Type': 'application/json'
      }
    });
  }

  async getEventById(eventId) {
    try {
      console.log(`🔍 Fetching event ${eventId} from ${EVENT_SERVICE_URL}/${eventId}`);
      const response = await this.apiClient.get(`${EVENT_SERVICE_URL}/${eventId}`);
      return response.data;
    } catch (error) {
      console.error(`❌ Error fetching event with ID ${eventId}:`, error.message);
      if (error.response && error.response.status === 404) {
        throw new Error(`Event with ID ${eventId} not found`);
      }
      throw new Error('Failed to fetch event');
    }
  }

  async bookEventSeats(eventId, seats) {
    try {
      console.log(`🎫 Booking ${seats} seats for event ${eventId}`);
      const response = await this.apiClient.post(`${EVENT_SERVICE_URL}/${eventId}/book`, {
        seats: seats
      });
      
      return response.data;
    } catch (error) {
      console.error(`❌ Error booking seats for event ${eventId}:`, error.message);
      if (error.response) {
        throw new Error(error.response.data.error || 'Failed to book seats');
      }
      throw new Error('Failed to book seats');
    }
  }

  async releaseSeats(eventId, seats) {
    try {
      console.log(`🔄 Releasing ${seats} seats for event ${eventId}`);
      const response = await this.apiClient.post(`${EVENT_SERVICE_URL}/${eventId}/release`, {
        seats: seats
      });
      
      return response.data;
    } catch (error) {
      console.error(`❌ Error releasing seats for event ${eventId}:`, error.message);
      if (error.response) {
        throw new Error(error.response.data.error || 'Failed to release seats');
      }
      throw new Error('Failed to release seats');
    }
  }
}

module.exports = new EventService();
