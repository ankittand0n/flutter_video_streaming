const request = require('supertest');
const app = require('../src/server');

describe('Numeric Field Handling Tests', () => {
  let token = '';
  let movieId = '';

  beforeAll(async () => {
    const response = await request(app)
      .post('/api/auth/login')
      .send({
        username: 'admin',
        password: 'admin123'
      })
      .expect(200);

    token = response.body.token;
    expect(token).toBeDefined();
  });

  test('Admin login successful', () => {
    expect(token).toBeTruthy();
  });

  test('Create movie with empty vote_average', async () => {
    const response = await request(app)
      .post('/api/movies')
      .set('Authorization', `Bearer ${token}`)
      .field('title', 'Test Movie with Empty Rating')
      .field('overview', 'Testing empty vote_average field')
      .field('release_date', '2024-01-01')
      .field('vote_average', '') // Empty string
      .field('genre_ids', '["Action"]')
      .expect(201);

    expect(response.body.success).toBe(true);
    movieId = response.body.data.id;
  });

  test('Update movie with empty vote_average', async () => {
    const response = await request(app)
      .put(`/api/movies/${movieId}`)
      .set('Authorization', `Bearer ${token}`)
      .field('title', 'Updated Test Movie')
      .field('vote_average', '') // Empty string
      .expect(200);

    expect(response.body.success).toBe(true);
  });

  test('Update movie with valid vote_average', async () => {
    const response = await request(app)
      .put(`/api/movies/${movieId}`)
      .set('Authorization', `Bearer ${token}`)
      .field('vote_average', '8.5')
      .expect(200);

    expect(response.body.success).toBe(true);
  });

  test('Clean up test movie', async () => {
    const response = await request(app)
      .delete(`/api/movies/${movieId}`)
      .set('Authorization', `Bearer ${token}`)
      .expect(200);

    expect(response.body.success).toBe(true);
  });

  afterAll(async () => {
    // Clean up and close any open connections
    await new Promise(resolve => setTimeout(resolve, 100));
  });
});