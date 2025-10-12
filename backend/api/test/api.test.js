const request = require('supertest');
const app = require('../src/server');

describe('API Integration Tests', () => {
  test('API Info endpoint returns correct data', async () => {
    const response = await request(app)
      .get('/')
      .expect(200);
    expect(response.statusCode).toBe(200);
  });

  test('Health check endpoint is working', async () => {
    const response = await request(app)
      .get('/health')
      .expect(200);
    expect(response.statusCode).toBe(200);
  });

  test('Movies endpoint returns data', async () => {
    const response = await request(app)
      .get('/movies')
      .expect(200);
    expect(Array.isArray(response.body.data || response.body)).toBe(true);
  });

  test('Can get movie by ID', async () => {
    const response = await request(app)
      .get('/movies/1')
      .expect(200);
    expect(response.body.id || response.body.data?.id).toBeDefined();
  });

  test('TV Series endpoint returns data', async () => {
    const response = await request(app)
      .get('/tv')
      .expect(200);
    expect(Array.isArray(response.body.data || response.body)).toBe(true);
  });

  test('Genres endpoint returns data', async () => {
    const response = await request(app)
      .get('/genres')
      .expect(200);
    expect(Array.isArray(response.body.data || response.body)).toBe(true);
  });
});
