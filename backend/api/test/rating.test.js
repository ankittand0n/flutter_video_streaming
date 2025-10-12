const axios = require('axios');

const API_BASE = 'http://localhost:3000';

describe('Rating Functionality Tests', () => {
  let adminToken = '';

  test('Admin login', async () => {
    const adminLoginResponse = await axios.post(`${API_BASE}/auth/login`, {
      username: 'admin',
      password: 'admin123'
    });

    expect(adminLoginResponse.data.token).toBeDefined();
    adminToken = adminLoginResponse.data.token;
  });

  test('Admin rating creation should be blocked', async () => {
    try {
      await axios.post(`${API_BASE}/rating`, {
        contentId: '12345',
        contentType: 'movie',
        rating: 5,
        review: 'Great movie!',
        title: 'Admin review'
      }, {
        headers: {
          'Authorization': `Bearer ${adminToken}`,
          'Content-Type': 'application/json'
        }
      });
      fail('Admin should not be able to create rating');
    } catch (error) {
      expect(error.response.status).toBe(403);
    }
  });

  test('Rating validation - missing contentId', async () => {
    try {
      await axios.post(`${API_BASE}/rating`, {
        contentType: 'movie',
        rating: 5
      }, {
        headers: {
          'Authorization': `Bearer ${adminToken}`,
          'Content-Type': 'application/json'
        }
      });
      fail('Should have failed for missing contentId');
    } catch (error) {
      expect(error.response.status).toBe(400);
    }
  });

  test('Rating validation - missing contentType', async () => {
    try {
      await axios.post(`${API_BASE}/rating`, {
        contentId: '12345',
        rating: 5
      }, {
        headers: {
          'Authorization': `Bearer ${adminToken}`,
          'Content-Type': 'application/json'
        }
      });
      fail('Should have failed for missing contentType');
    } catch (error) {
      expect(error.response.status).toBe(400);
    }
  });

  test('Rating validation - missing rating', async () => {
    try {
      await axios.post(`${API_BASE}/rating`, {
        contentId: '12345',
        contentType: 'movie'
      }, {
        headers: {
          'Authorization': `Bearer ${adminToken}`,
          'Content-Type': 'application/json'
        }
      });
      fail('Should have failed for missing rating');
    } catch (error) {
      expect(error.response.status).toBe(400);
    }
  });

  test('Rating validation - invalid rating (too high)', async () => {
    try {
      await axios.post(`${API_BASE}/rating`, {
        contentId: '12345',
        contentType: 'movie',
        rating: 15
      }, {
        headers: {
          'Authorization': `Bearer ${adminToken}`,
          'Content-Type': 'application/json'
        }
      });
      fail('Should have failed for invalid rating');
    } catch (error) {
      expect(error.response.status).toBe(400);
    }
  });

  test('Rating validation - invalid contentType', async () => {
    try {
      await axios.post(`${API_BASE}/rating`, {
        contentId: '12345',
        contentType: 'invalid',
        rating: 5
      }, {
        headers: {
          'Authorization': `Bearer ${adminToken}`,
          'Content-Type': 'application/json'
        }
      });
      fail('Should have failed for invalid contentType');
    } catch (error) {
      expect(error.response.status).toBe(400);
    }
  });
});