const axios = require('axios');

async function testLogin() {
  try {
    console.log('Testing login with admin credentials...');

    const response = await axios.post('http://localhost:3000/api/auth/login', {
      username: 'admin',
      password: 'admin123'
    });

    const result = response.data;

    if (result.token) {
      console.log('✅ Login successful!');
      console.log('Token received:', result.token.substring(0, 50) + '...');

      // Test the token with a protected endpoint
      console.log('\nTesting token with protected endpoint...');
      const testResponse = await axios.get('http://localhost:3000/api/movies', {
        headers: {
          'Authorization': `Bearer ${result.token}`
        }
      });

      console.log('✅ Token validation successful!');
      console.log('Movies endpoint accessible with token');

    } else {
      console.log('❌ Login failed:', result);
    }

  } catch (error) {
    console.error('❌ Test failed:', error.response?.data || error.message);
  }
}

testLogin();