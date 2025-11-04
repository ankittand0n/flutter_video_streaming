const request = require('supertest');
const axios = require('axios');
const app = require('../src/server');
const prisma = require('../src/prisma/client');
const { isExternal, getBaseUrl, getTestType } = require('./test-config');

// axios instance for external tests
const axiosInstance = isExternal() ? axios.create({ baseURL: getBaseUrl() }) : null;

/**
 * Helper for making HTTP POST requests in tests
 */
const post = async (path, data) => {
  if (isExternal()) {
    try {
      const res = await axiosInstance.post(path, data);
      return { body: res.data, statusCode: res.status };
    } catch (error) {
      if (error.response) {
        return { body: error.response.data, statusCode: error.response.status };
      }
      throw error;
    }
  }
  return request(app).post(path).send(data);
};

describe(`Auth Flow - Register and Login - ${getTestType()}`, () => {
  let testUser = {
    email: `testuser-${Date.now()}@example.com`,
    username: `testuser${Date.now()}`,
    password: 'Test123!@#',
    profile_name: 'Test User'
  };

  beforeAll(() => {
    console.log(`\n🧪 Running auth flow tests against: ${getTestType()}`);
    if (isExternal()) {
      console.log(`📡 External URL: ${getBaseUrl()}`);
      console.log(`⚠️  Note: Cleanup is skipped for external servers\n`);
    }
  });

  // Clean up test user before and after tests (local only)
  beforeAll(async () => {
    if (isExternal()) {
      return; // Skip cleanup for external servers
    }

    try {
      await prisma.user.deleteMany({
        where: {
          OR: [
            { email: testUser.email.toLowerCase() },
            { username: testUser.username.toLowerCase() }
          ]
        }
      });
    } catch (error) {
      console.log('Cleanup error (expected if user does not exist):', error.message);
    }
  });

  afterAll(async () => {
    if (isExternal()) {
      return; // Skip cleanup for external servers
    }

    try {
      await prisma.user.deleteMany({
        where: {
          OR: [
            { email: testUser.email.toLowerCase() },
            { username: testUser.username.toLowerCase() }
          ]
        }
      });
    } catch (error) {
      console.log('Cleanup error:', error.message);
    }
    await prisma.$disconnect();
  });

  describe('POST /api/auth/register', () => {
    it('should register a new user successfully', async () => {
      const response = await post('/api/auth/register', {
        email: testUser.email,
        username: testUser.username,
        password: testUser.password,
        profile_name: testUser.profile_name
      });

      expect(response.statusCode || response.status).toBe(201);
      expect(response.body).toHaveProperty('token');
      expect(response.body).toHaveProperty('message', 'User registered successfully');
      expect(response.body.user).toHaveProperty('email', testUser.email.toLowerCase());
      expect(response.body.user).toHaveProperty('username', testUser.username.toLowerCase());
      expect(response.body.user).toHaveProperty('profile_name', testUser.profile_name);
      expect(response.body.user).not.toHaveProperty('password');
    });

    it('should not register duplicate email', async () => {
      const response = await post('/api/auth/register', {
        email: testUser.email,
        username: 'differentusername',
        password: testUser.password,
        profile_name: 'Different User'
      });

      expect(response.statusCode || response.status).toBe(400);
      expect(response.body).toHaveProperty('error', 'User already exists');
    });

    it('should not register duplicate username', async () => {
      const response = await post('/api/auth/register', {
        email: 'different@example.com',
        username: testUser.username,
        password: testUser.password,
        profile_name: 'Different User'
      });

      expect(response.statusCode || response.status).toBe(400);
      expect(response.body).toHaveProperty('error', 'User already exists');
    });
  });

  describe('POST /api/auth/login', () => {
    it('should login with email successfully', async () => {
      const response = await post('/api/auth/login', {
        email: testUser.email,
        password: testUser.password
      });

      console.log('Login with email response:', JSON.stringify(response.body, null, 2));

      expect(response.statusCode || response.status).toBe(200);
      expect(response.body).toHaveProperty('token');
      expect(response.body).toHaveProperty('message', 'Login successful');
      expect(response.body.user).toHaveProperty('email', testUser.email.toLowerCase());
      expect(response.body.user).toHaveProperty('username', testUser.username.toLowerCase());
    });

    it('should login with username successfully', async () => {
      const response = await post('/api/auth/login', {
        username: testUser.username,
        password: testUser.password
      });

      console.log('Login with username response:', JSON.stringify(response.body, null, 2));

      expect(response.statusCode || response.status).toBe(200);
      expect(response.body).toHaveProperty('token');
      expect(response.body).toHaveProperty('message', 'Login successful');
      expect(response.body.user).toHaveProperty('email', testUser.email.toLowerCase());
      expect(response.body.user).toHaveProperty('username', testUser.username.toLowerCase());
    });

    it('should not login with wrong password', async () => {
      const response = await post('/api/auth/login', {
        email: testUser.email,
        password: 'WrongPassword123'
      });

      console.log('Wrong password response:', JSON.stringify(response.body, null, 2));

      expect(response.statusCode || response.status).toBe(401);
      expect(response.body).toHaveProperty('error', 'Invalid credentials');
    });

    it('should not login with non-existent email', async () => {
      const response = await post('/api/auth/login', {
        email: 'nonexistent@example.com',
        password: testUser.password
      });

      console.log('Non-existent email response:', JSON.stringify(response.body, null, 2));

      expect(response.statusCode || response.status).toBe(401);
      expect(response.body).toHaveProperty('error', 'Invalid credentials');
    });

    it('should not login with non-existent username', async () => {
      const response = await post('/api/auth/login', {
        username: 'nonexistentuser',
        password: testUser.password
      });

      console.log('Non-existent username response:', JSON.stringify(response.body, null, 2));

      expect(response.statusCode || response.status).toBe(401);
      expect(response.body).toHaveProperty('error', 'Invalid credentials');
    });
  });

  describe('POST /api/auth/login - Phone Number Test', () => {
    const phoneUser = {
      email: `${Date.now()}@phone.com`, // Using timestamp as phone
      username: `${Date.now()}`,
      password: 'Phone123!@#',
      profile_name: 'Phone User'
    };

    beforeAll(async () => {
      // Clean up phone test user (local only)
      if (!isExternal()) {
        try {
          await prisma.user.deleteMany({
            where: {
              OR: [
                { email: phoneUser.email.toLowerCase() },
                { username: phoneUser.username.toLowerCase() }
              ]
            }
          });
        } catch (error) {
          console.log('Cleanup error:', error.message);
        }
      }

      // Register phone user (both local and external)
      await post('/api/auth/register', phoneUser);
    });

    afterAll(async () => {
      if (isExternal()) {
        return; // Skip cleanup for external servers
      }

      try {
        await prisma.user.deleteMany({
          where: {
            OR: [
              { email: phoneUser.email.toLowerCase() },
              { username: phoneUser.username.toLowerCase() }
            ]
          }
        });
      } catch (error) {
        console.log('Cleanup error:', error.message);
      }
    });

    it('should login with phone number as username', async () => {
      const response = await post('/api/auth/login', {
        username: phoneUser.username,
        password: phoneUser.password
      });

      console.log('Login with phone response:', JSON.stringify(response.body, null, 2));

      expect(response.statusCode || response.status).toBe(200);
      expect(response.body).toHaveProperty('token');
      expect(response.body.user).toHaveProperty('username', phoneUser.username.toLowerCase());
    });
  });
});
