const request = require('supertest');
const app = require('../src/server');

describe('Rating Functionality Tests', () => {
  let adminToken = '';

  beforeAll(async () => {
    const response = await request(app)
      .post('/api/auth/login')
      .send({
        username: 'admin',
        password: 'admin123'
      })
      .expect(200);

    adminToken = response.body.token;
    expect(adminToken).toBeDefined();
  });

  test('Admin login successful', () => {
    expect(adminToken).toBeTruthy();
  });

  test('Admin rating creation should be blocked', async () => {
    await request(app)
      .post('/api/rating')
      .set('Authorization', `Bearer ${adminToken}`)
      .send({
        contentid: '12345',
        contenttype: 'movie',
        rating: 5,
        review: 'Great movie!',
        title: 'Admin review'
      })
      .expect(403);
  });

  // All the validation tests should return 403 (admin blocked) rather than 400 (validation error)
  // because admin authentication is checked before validation
  test('Rating validation - missing contentid', async () => {
    await request(app)
      .post('/api/rating')
      .set('Authorization', `Bearer ${adminToken}`)
      .send({
        contenttype: 'movie',
        rating: 5
      })
      .expect(400);
  });

  test('Rating validation - missing contenttype', async () => {
    await request(app)
      .post('/api/rating')
      .set('Authorization', `Bearer ${adminToken}`)
      .send({
        contentid: '12345',
        rating: 5
      })
      .expect(400);
  });

  test('Rating validation - missing rating', async () => {
    await request(app)
      .post('/api/rating')
      .set('Authorization', `Bearer ${adminToken}`)
      .send({
        contentid: '12345',
        contenttype: 'movie'
      })
      .expect(400);
  });

  test('Rating validation - invalid rating', async () => {
    await request(app)
      .post('/api/rating')
      .set('Authorization', `Bearer ${adminToken}`)
      .send({
        contentid: '12345',
        contenttype: 'movie',
        rating: 15
      })
      .expect(400);
  });

  test('Rating validation - invalid contenttype', async () => {
    await request(app)
      .post('/api/rating')
      .set('Authorization', `Bearer ${adminToken}`)
      .send({
        contentid: '12345',
        contenttype: 'invalid',
        rating: 5
      })
      .expect(400);
  });

  afterAll(async () => {
    // Clean up and close any open connections
    await new Promise(resolve => setTimeout(resolve, 100));
  });
});