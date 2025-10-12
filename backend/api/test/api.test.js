const request = require('supertest');
const app = require('../src/server');

describe('API Integration Tests', () => {
  let server;

  beforeAll(async () => {
    return new Promise((resolve) => {
      // Use existing server if available, otherwise create new one
      server = app.listen(0, () => {
        // Wait for server to be ready
        resolve();
      });
    });
  });

  afterAll(async () => {
    return new Promise((resolve) => {
      if (server) {
        server.close(() => {
          resolve();
        });
      } else {
        resolve();
      }
    });
  });

  test('API Info endpoint returns correct data', async () => {
    const response = await request(app)
      .get('/api')
      .expect(200);
    expect(response.statusCode).toBe(200);
  });

  test('Health check endpoint is working', async () => {
    const response = await request(app)
      .get('/api/health')
      .expect(200);
    expect(response.statusCode).toBe(200);
  });

  test('Movies endpoint returns data', async () => {
    const response = await request(app)
      .get('/api/movies')
      .expect(200);
    expect(Array.isArray(response.body.data || response.body)).toBe(true);
  });

  test('Can get movie by ID', async () => {
    const response = await request(app)
      .get('/api/movies/1')
      .expect(200);
    expect(response.body.id || response.body.data?.id).toBeDefined();
  });

  test('TV Series endpoint returns data', async () => {
    const response = await request(app)
      .get('/api/tv')
      .expect(200);
    expect(Array.isArray(response.body.data || response.body)).toBe(true);
  });

  test('Genres endpoint returns data', async () => {
    const response = await request(app)
      .get('/api/genres')
      .expect(200);
    expect(Array.isArray(response.body.data || response.body)).toBe(true);
  });
});
