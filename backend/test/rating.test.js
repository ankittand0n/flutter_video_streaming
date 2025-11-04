const request = require('supertest');
const axios = require('axios');
const app = require('../src/server');
const { isExternal, getBaseUrl, getTestType } = require('./test-config');

// axios instance for external tests
const axiosInstance = isExternal() ? axios.create({ baseURL: getBaseUrl() }) : null;

/**
 * Helper for making HTTP POST requests in tests
 * - Local: uses supertest with app  
 * - External: uses axios with base URL
 */
const post = async (path, data, headers = {}) => {
  if (isExternal()) {
    try {
      const res = await axiosInstance.post(path, data, { headers });
      return { body: res.data, statusCode: res.status };
    } catch (error) {
      if (error.response) {
        return { body: error.response.data, statusCode: error.response.status };
      }
      throw error;
    }
  }
  const req = request(app).post(path);
  Object.keys(headers).forEach(key => req.set(key, headers[key]));
  return req.send(data);
};

describe(`Rating Functionality Tests - ${getTestType()}`, () => {
  let adminToken = '';

  beforeAll(async () => {
    console.log(`\n🧪 Running rating tests against: ${getTestType()}`);
    if (isExternal()) {
      console.log(`📡 External URL: ${getBaseUrl()}\n`);
    }

    const response = await post('/api/auth/login', {
      username: 'admin',
      password: 'admin123'
    });

    expect(response.statusCode || response.status).toBe(200);
    adminToken = response.body.token;
    expect(adminToken).toBeDefined();
  });

  test('Admin login successful', () => {
    expect(adminToken).toBeTruthy();
  });

  test('Admin rating creation should be blocked', async () => {
    const response = await post('/api/rating', {
      media_id: '12345',
      media_type: 'movie',
      rating: 5,
      review: 'Great movie!',
      title: 'Admin review'
    }, { 'Authorization': `Bearer ${adminToken}` });

    expect(response.statusCode || response.status).toBe(403);
  });

  // All the validation tests should return 403 (admin blocked) rather than 400 (validation error)
  // because admin authentication is checked before validation
  test('Rating validation - missing media_id', async () => {
    const response = await post('/api/rating', {
      media_type: 'movie',
      rating: 5
    }, { 'Authorization': `Bearer ${adminToken}` });

    expect(response.statusCode || response.status).toBe(400);
  });

  test('Rating validation - missing media_type', async () => {
    const response = await post('/api/rating', {
      media_id: '12345',
      rating: 5
    }, { 'Authorization': `Bearer ${adminToken}` });

    expect(response.statusCode || response.status).toBe(400);
  });

  test('Rating validation - missing rating', async () => {
    const response = await post('/api/rating', {
      media_id: '12345',
      media_type: 'movie'
    }, { 'Authorization': `Bearer ${adminToken}` });

    expect(response.statusCode || response.status).toBe(400);
  });

  test('Rating validation - invalid rating', async () => {
    const response = await post('/api/rating', {
      media_id: '12345',
      media_type: 'movie',
      rating: 15
    }, { 'Authorization': `Bearer ${adminToken}` });

    expect(response.statusCode || response.status).toBe(400);
  });

  test('Rating validation - invalid media_type', async () => {
    const response = await post('/api/rating', {
      media_id: '12345',
      media_type: 'invalid',
      rating: 5
    }, { 'Authorization': `Bearer ${adminToken}` });

    expect(response.statusCode || response.status).toBe(400);
  });

  afterAll(async () => {
    // Clean up and close any open connections
    await new Promise(resolve => setTimeout(resolve, 100));
  });
});