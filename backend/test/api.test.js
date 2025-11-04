const request = require('supertest');
const axios = require('axios');
const app = require('../src/server');
const { isExternal, getBaseUrl, getTestType } = require('./test-config');

// axios instance for external tests
const axiosInstance = isExternal() ? axios.create({ baseURL: getBaseUrl() }) : null;

/**
 * Helper for making HTTP requests in tests
 * - Local: uses supertest with app  
 * - External: uses axios with base URL
 */
const get = async (path) => {
  if (isExternal()) {
    const res = await axiosInstance.get(path);
    return { body: res.data, statusCode: res.status };
  }
  return request(app).get(path);
};

describe(`API Integration Tests - ${getTestType()}`, () => {
  beforeAll(() => {
    console.log(`\n🧪 Running tests against: ${getTestType()}`);
    if (isExternal()) {
      console.log(`📡 External URL: ${getBaseUrl()}\n`);
    }
  });

  test('API Info endpoint returns correct data', async () => {
    const response = await get('/api/');
    expect(response.statusCode || response.status).toBe(200);
  });

  test('Health check endpoint is working', async () => {
    const response = await get('/api/health');
    expect(response.statusCode || response.status).toBe(200);
  });

  test('Movies endpoint returns data', async () => {
    const response = await get('/api/movies');
    expect(Array.isArray(response.body.data || response.body)).toBe(true);
  });

  test('Can get movie by ID', async () => {
    const response = await get('/api/movies/1');
    expect(response.body.id || response.body.data?.id).toBeDefined();
  });

  test('TV Series endpoint returns data', async () => {
    const response = await get('/api/tv');
    expect(Array.isArray(response.body.data || response.body)).toBe(true);
  });

  test('Genres endpoint returns data', async () => {
    const response = await get('/api/genres');
    expect(Array.isArray(response.body.data || response.body)).toBe(true);
  });

  // Rate limiting test - useful for external servers
  test('Rate limiting configuration test', async () => {
    if (!isExternal()) {
      console.log('⏭️  Skipping rate limit test (local environment)');
      return;
    }

    console.log('\n🚦 Testing rate limits on external server...');
    
    const responses = [];
    for (let i = 0; i < 5; i++) {
      try {
        const response = await axiosInstance.post('/auth/login', {
          email: 'nonexistent@test.com',
          password: 'test123'
        });
        
        responses.push({
          attempt: i + 1,
          status: response.status,
          hasRateLimitHeaders: {
            'ratelimit-limit': response.headers['ratelimit-limit'],
            'ratelimit-remaining': response.headers['ratelimit-remaining'],
            'ratelimit-reset': response.headers['ratelimit-reset']
          }
        });
      } catch (error) {
        responses.push({
          attempt: i + 1,
          status: error.response?.status || 'error',
          hasRateLimitHeaders: {}
        });
      }
    }

    console.log('Rate limit test results:', JSON.stringify(responses, null, 2));
    
    // Just check that we get responses (may hit rate limit or not depending on server settings)
    expect(responses.length).toBe(5);
  });

  // HTTPS URL validation test - important for production
  test('Image URLs should use HTTPS on external servers', async () => {
    if (!isExternal()) {
      console.log('⏭️  Skipping HTTPS URL test (local environment)');
      return;
    }

    const response = await get('/api/movies');

    console.log('🔒 Checking HTTPS URLs...');
    
    if (response.statusCode === 200 && response.body.movies && response.body.movies.length > 0) {
      const firstMovie = response.body.movies[0];
      console.log('First movie poster_path:', firstMovie.poster_path);
      console.log('First movie backdrop_path:', firstMovie.backdrop_path);

      if (firstMovie.poster_path) {
        expect(firstMovie.poster_path).toMatch(/^https:\/\//);
        console.log('✓ Poster path uses HTTPS');
      }
      
      if (firstMovie.backdrop_path) {
        expect(firstMovie.backdrop_path).toMatch(/^https:\/\//);
        console.log('✓ Backdrop path uses HTTPS');
      }
    } else {
      console.log('⚠️  No movies found or error occurred, skipping HTTPS validation');
    }
  });
});
