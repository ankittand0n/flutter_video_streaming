const request = require('supertest');
const app = require('../src/server');
const { isExternal, getBaseUrl, getTestType } = require('./test-config');

/**
 * Helper to create request object based on environment
 * - Local: uses supertest with app (no server needed)
 * - External: uses supertest with base URL
 */
const createRequest = () => {
  if (isExternal()) {
    return request(getBaseUrl());
  }
  return request(app);
};

describe(`API Integration Tests - Public Endpoints Only - ${getTestType()}`, () => {
  beforeAll(() => {
    console.log(`\n🧪 Running integration tests against: ${getTestType()}`);
    if (isExternal()) {
      console.log(`📡 External URL: ${getBaseUrl()}\n`);
    }
  });

  test('Health check endpoint is working', async () => {
    const response = await createRequest()
      .get('/api/health')
      .expect(200);
    expect(response.body.status).toBe('OK');
  });

  test('Movies endpoint returns data', async () => {
    const response = await createRequest()
      .get('/api/movies')
      .expect(200);
    
    // Handle different response formats
    const movies = response.body.movies || response.body.data || response.body;
    expect(Array.isArray(movies)).toBe(true);
  });

  test('Can get movie by ID', async () => {
    // First get a movie from the list
    const moviesResponse = await createRequest()
      .get('/api/movies')
      .expect(200);
    
    // Handle different response formats
    const movies = moviesResponse.body.movies || moviesResponse.body.data || moviesResponse.body;
    expect(Array.isArray(movies)).toBe(true);
    
    if (movies.length > 0) {
      // Try to get the first movie by ID
      const firstMovieId = movies[0].id;
      const response = await createRequest()
        .get(`/api/movies/${firstMovieId}`)
        .expect(200);
      expect(response.body.id || response.body.data?.id).toBeDefined();
    } else {
      console.log('⚠️  No movies found, skipping movie by ID test');
    }
  });

  test('TV Series endpoint returns data', async () => {
    const response = await createRequest()
      .get('/api/tv')
      .expect(200);
    
    // Handle different response formats
    const tvSeries = response.body.tv || response.body.data || response.body;
    expect(Array.isArray(tvSeries)).toBe(true);
  });

  test('Genres endpoint returns data', async () => {
    const response = await createRequest()
      .get('/api/genres')
      .expect(200);
    
    // Handle different response formats
    const genres = response.body.genres || response.body.data || response.body;
    expect(Array.isArray(genres)).toBe(true);
  });
});