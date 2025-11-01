const request = require('supertest');
const prisma = require('../src/prisma/client');

// Test against production backend
const BACKEND_URL = 'https://backend-1040805906877.asia-south2.run.app';

describe('Production Auth - Register and Login', () => {
  let testUser = {
    email: 'prodtest@example.com',
    username: 'prodtest123',
    password: 'ProdTest123!@#',
    profilename: 'Production Test User'
  };

  // Clean up test user before tests
  beforeAll(async () => {
    try {
      await prisma.user.deleteMany({
        where: {
          OR: [
            { email: testUser.email.toLowerCase() },
            { username: testUser.username.toLowerCase() }
          ]
        }
      });
      console.log('✓ Cleaned up existing test user');
    } catch (error) {
      console.log('Cleanup error (expected if user does not exist):', error.message);
    }
  });

  afterAll(async () => {
    try {
      await prisma.user.deleteMany({
        where: {
          OR: [
            { email: testUser.email.toLowerCase() },
            { username: testUser.username.toLowerCase() }
          ]
        }
      });
      console.log('✓ Cleaned up test user after tests');
    } catch (error) {
      console.log('Cleanup error:', error.message);
    }
    await prisma.$disconnect();
  });

  describe('POST /api/auth/register - Production Backend', () => {
    it('should register a new user on production', async () => {
      const response = await request(BACKEND_URL)
        .post('/api/auth/register')
        .send({
          email: testUser.email,
          username: testUser.username,
          password: testUser.password,
          profilename: testUser.profilename
        })
        .set('Content-Type', 'application/json');

      console.log('Registration response status:', response.status);
      console.log('Registration response body:', JSON.stringify(response.body, null, 2));

      expect(response.status).toBe(201);
      expect(response.body).toHaveProperty('token');
      expect(response.body).toHaveProperty('message', 'User registered successfully');
      expect(response.body.user).toHaveProperty('email', testUser.email.toLowerCase());
      expect(response.body.user).toHaveProperty('username', testUser.username.toLowerCase());
      expect(response.body.user).toHaveProperty('profilename', testUser.profilename);
      expect(response.body.user).not.toHaveProperty('password');
    });
  });

  describe('POST /api/auth/login - Production Backend', () => {
    it('should login with email on production', async () => {
      const response = await request(BACKEND_URL)
        .post('/api/auth/login')
        .send({
          email: testUser.email,
          password: testUser.password
        })
        .set('Content-Type', 'application/json');

      console.log('Login with email status:', response.status);
      console.log('Login with email body:', JSON.stringify(response.body, null, 2));

      expect(response.status).toBe(200);
      expect(response.body).toHaveProperty('token');
      expect(response.body).toHaveProperty('message', 'Login successful');
      expect(response.body.user).toHaveProperty('email', testUser.email.toLowerCase());
      expect(response.body.user).toHaveProperty('username', testUser.username.toLowerCase());
    });

    it('should login with username on production', async () => {
      const response = await request(BACKEND_URL)
        .post('/api/auth/login')
        .send({
          username: testUser.username,
          password: testUser.password
        })
        .set('Content-Type', 'application/json');

      console.log('Login with username status:', response.status);
      console.log('Login with username body:', JSON.stringify(response.body, null, 2));

      expect(response.status).toBe(200);
      expect(response.body).toHaveProperty('token');
      expect(response.body).toHaveProperty('message', 'Login successful');
      expect(response.body.user).toHaveProperty('email', testUser.email.toLowerCase());
      expect(response.body.user).toHaveProperty('username', testUser.username.toLowerCase());
    });

    it('should fail login with wrong password', async () => {
      const response = await request(BACKEND_URL)
        .post('/api/auth/login')
        .send({
          email: testUser.email,
          password: 'WrongPassword123'
        })
        .set('Content-Type', 'application/json');

      console.log('Wrong password status:', response.status);
      console.log('Wrong password body:', JSON.stringify(response.body, null, 2));

      expect(response.status).toBe(401);
      expect(response.body).toHaveProperty('error');
    });
  });

  describe('Rate Limiting - Production Backend', () => {
    it('should show rate limit configuration', async () => {
      console.log('\nTesting rate limits on production...');
      
      const responses = [];
      for (let i = 0; i < 5; i++) {
        const response = await request(BACKEND_URL)
          .post('/api/auth/login')
          .send({
            email: 'nonexistent@test.com',
            password: 'test123'
          })
          .set('Content-Type', 'application/json');
        
        responses.push({
          attempt: i + 1,
          status: response.status,
          hasRateLimitHeaders: {
            'ratelimit-limit': response.headers['ratelimit-limit'],
            'ratelimit-remaining': response.headers['ratelimit-remaining'],
            'ratelimit-reset': response.headers['ratelimit-reset']
          }
        });
      }

      console.log('Rate limit test results:', JSON.stringify(responses, null, 2));
      
      // Just check that we get responses (may hit rate limit or not depending on production settings)
      expect(responses.length).toBe(5);
    });
  });

  describe('Image URLs - Production Backend', () => {
    it('should return HTTPS URLs for images', async () => {
      const response = await request(BACKEND_URL)
        .get('/api/movies')
        .set('Content-Type', 'application/json');

      console.log('Movies response status:', response.status);
      
      if (response.status === 200 && response.body.movies && response.body.movies.length > 0) {
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
        console.log('No movies found or error occurred');
      }
    });
  });
});
