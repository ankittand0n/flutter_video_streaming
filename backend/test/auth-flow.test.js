const request = require('supertest');
const app = require('../src/server');
const prisma = require('../src/prisma/client');

describe('Auth Flow - Register and Login', () => {
  let testUser = {
    email: 'testuser@example.com',
    username: 'testuser123',
    password: 'Test123!@#',
    profile_name: 'Test User'
  };

  // Clean up test user before and after tests
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
    } catch (error) {
      console.log('Cleanup error:', error.message);
    }
    await prisma.$disconnect();
  });

  describe('POST /api/auth/register', () => {
    it('should register a new user successfully', async () => {
      const response = await request(app)
        .post('/api/auth/register')
        .send({
          email: testUser.email,
          username: testUser.username,
          password: testUser.password,
          profile_name: testUser.profile_name
        })
        .expect(201);

      expect(response.body).toHaveProperty('token');
      expect(response.body).toHaveProperty('message', 'User registered successfully');
      expect(response.body.user).toHaveProperty('email', testUser.email.toLowerCase());
      expect(response.body.user).toHaveProperty('username', testUser.username.toLowerCase());
      expect(response.body.user).toHaveProperty('profile_name', testUser.profile_name);
      expect(response.body.user).not.toHaveProperty('password');
    });

    it('should not register duplicate email', async () => {
      const response = await request(app)
        .post('/api/auth/register')
        .send({
          email: testUser.email,
          username: 'differentusername',
          password: testUser.password,
          profile_name: 'Different User'
        })
        .expect(400);

      expect(response.body).toHaveProperty('error', 'User already exists');
    });

    it('should not register duplicate username', async () => {
      const response = await request(app)
        .post('/api/auth/register')
        .send({
          email: 'different@example.com',
          username: testUser.username,
          password: testUser.password,
          profile_name: 'Different User'
        })
        .expect(400);

      expect(response.body).toHaveProperty('error', 'User already exists');
    });
  });

  describe('POST /api/auth/login', () => {
    it('should login with email successfully', async () => {
      const response = await request(app)
        .post('/api/auth/login')
        .send({
          email: testUser.email,
          password: testUser.password
        })
        .expect(200);

      console.log('Login with email response:', JSON.stringify(response.body, null, 2));

      expect(response.body).toHaveProperty('token');
      expect(response.body).toHaveProperty('message', 'Login successful');
      expect(response.body.user).toHaveProperty('email', testUser.email.toLowerCase());
      expect(response.body.user).toHaveProperty('username', testUser.username.toLowerCase());
    });

    it('should login with username successfully', async () => {
      const response = await request(app)
        .post('/api/auth/login')
        .send({
          username: testUser.username,
          password: testUser.password
        })
        .expect(200);

      console.log('Login with username response:', JSON.stringify(response.body, null, 2));

      expect(response.body).toHaveProperty('token');
      expect(response.body).toHaveProperty('message', 'Login successful');
      expect(response.body.user).toHaveProperty('email', testUser.email.toLowerCase());
      expect(response.body.user).toHaveProperty('username', testUser.username.toLowerCase());
    });

    it('should not login with wrong password', async () => {
      const response = await request(app)
        .post('/api/auth/login')
        .send({
          email: testUser.email,
          password: 'WrongPassword123'
        })
        .expect(401);

      console.log('Wrong password response:', JSON.stringify(response.body, null, 2));

      expect(response.body).toHaveProperty('error', 'Invalid credentials');
    });

    it('should not login with non-existent email', async () => {
      const response = await request(app)
        .post('/api/auth/login')
        .send({
          email: 'nonexistent@example.com',
          password: testUser.password
        })
        .expect(401);

      console.log('Non-existent email response:', JSON.stringify(response.body, null, 2));

      expect(response.body).toHaveProperty('error', 'Invalid credentials');
    });

    it('should not login with non-existent username', async () => {
      const response = await request(app)
        .post('/api/auth/login')
        .send({
          username: 'nonexistentuser',
          password: testUser.password
        })
        .expect(401);

      console.log('Non-existent username response:', JSON.stringify(response.body, null, 2));

      expect(response.body).toHaveProperty('error', 'Invalid credentials');
    });
  });

  describe('POST /api/auth/login - Phone Number Test', () => {
    const phoneUser = {
      email: '9876543210@phone.com', // Using phone as email
      username: '9876543210',
      password: 'Phone123!@#',
      profile_name: 'Phone User'
    };

    beforeAll(async () => {
      // Clean up phone test user
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

      // Register phone user
      await request(app)
        .post('/api/auth/register')
        .send(phoneUser);
    });

    afterAll(async () => {
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
      const response = await request(app)
        .post('/api/auth/login')
        .send({
          username: phoneUser.username,
          password: phoneUser.password
        })
        .expect(200);

      console.log('Login with phone response:', JSON.stringify(response.body, null, 2));

      expect(response.body).toHaveProperty('token');
      expect(response.body.user).toHaveProperty('username', phoneUser.username.toLowerCase());
    });
  });
});
