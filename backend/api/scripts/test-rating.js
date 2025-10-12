const axios = require('axios');

const API_BASE = 'http://localhost:3000/api';

async function testRatingFunctionality() {
  console.log('🧪 Testing Rating Functionality\n');

  let adminToken = '';
  let userToken = '';

  try {
    // Test 1: Admin login
    console.log('1. Testing Admin Login...');
    const adminLoginResponse = await axios.post(`${API_BASE}/auth/login`, {
      username: 'admin',
      password: 'admin123'
    });

    if (!adminLoginResponse.data.token) {
      throw new Error('Admin login failed: ' + JSON.stringify(adminLoginResponse.data));
    }

    console.log('✅ Admin login successful');
    adminToken = adminLoginResponse.data.token;

    // Test 2: Try to create rating as admin (should fail)
    console.log('\n2. Testing Admin Rating Creation (should fail)...');
    try {
      const adminRatingResponse = await axios.post(`${API_BASE}/rating`, {
        contentId: '12345',
        contentType: 'movie',
        rating: 5,
        review: 'Great movie!',
        title: 'Admin review'
      }, {
        headers: {
          'Authorization': `Bearer ${adminToken}`,
          'Content-Type': 'application/json'
        }
      });

      console.log('❌ Admin was able to create rating - this should not happen!');
      throw new Error('Admin rating creation should have failed');
    } catch (error) {
      if (error.response && error.response.status === 403) {
        console.log('✅ Admin rating creation correctly blocked');
      } else {
        throw error;
      }
    }

    // Test 3: Try to create rating as admin (should fail)
    console.log('\n3. Testing Admin Rating Creation (should fail)...');
    try {
      const adminRatingResponse = await axios.post(`${API_BASE}/rating`, {
        contentId: '12345',
        contentType: 'movie',
        rating: 5,
        review: 'Great movie!',
        title: 'Admin review'
      }, {
        headers: {
          'Authorization': `Bearer ${adminToken}`,
          'Content-Type': 'application/json'
        }
      });

      console.log('❌ Admin was able to create rating - this should not happen!');
      throw new Error('Admin rating creation should have failed');
    } catch (error) {
      if (error.response && error.response.status === 403) {
        console.log('✅ Admin rating creation correctly blocked');
      } else {
        throw error;
      }
    }

    // Test 4: Test validation - try to create rating without required fields
    console.log('\n4. Testing Rating Validation...');

    // Test missing contentId
    try {
      await axios.post(`${API_BASE}/rating`, {
        contentType: 'movie',
        rating: 5
      }, {
        headers: {
          'Authorization': `Bearer ${adminToken}`,
          'Content-Type': 'application/json'
        }
      });
      console.log('❌ Should have failed for missing contentId');
    } catch (error) {
      if (error.response && error.response.status === 400) {
        console.log('✅ Validation correctly blocked missing contentId');
      } else {
        console.log('❌ Unexpected error for missing contentId:', error.response?.data);
      }
    }

    // Test missing contentType
    try {
      await axios.post(`${API_BASE}/rating`, {
        contentId: '12345',
        rating: 5
      }, {
        headers: {
          'Authorization': `Bearer ${adminToken}`,
          'Content-Type': 'application/json'
        }
      });
      console.log('❌ Should have failed for missing contentType');
    } catch (error) {
      if (error.response && error.response.status === 400) {
        console.log('✅ Validation correctly blocked missing contentType');
      } else {
        console.log('❌ Unexpected error for missing contentType:', error.response?.data);
      }
    }

    // Test missing rating
    try {
      await axios.post(`${API_BASE}/rating`, {
        contentId: '12345',
        contentType: 'movie'
      }, {
        headers: {
          'Authorization': `Bearer ${adminToken}`,
          'Content-Type': 'application/json'
        }
      });
      console.log('❌ Should have failed for missing rating');
    } catch (error) {
      if (error.response && error.response.status === 400) {
        console.log('✅ Validation correctly blocked missing rating');
      } else {
        console.log('❌ Unexpected error for missing rating:', error.response?.data);
      }
    }

    // Test invalid rating (too high)
    try {
      await axios.post(`${API_BASE}/rating`, {
        contentId: '12345',
        contentType: 'movie',
        rating: 15
      }, {
        headers: {
          'Authorization': `Bearer ${adminToken}`,
          'Content-Type': 'application/json'
        }
      });
      console.log('❌ Should have failed for invalid rating');
    } catch (error) {
      if (error.response && error.response.status === 400) {
        console.log('✅ Validation correctly blocked invalid rating');
      } else {
        console.log('❌ Unexpected error for invalid rating:', error.response?.data);
      }
    }

    // Test invalid contentType
    try {
      await axios.post(`${API_BASE}/rating`, {
        contentId: '12345',
        contentType: 'invalid',
        rating: 5
      }, {
        headers: {
          'Authorization': `Bearer ${adminToken}`,
          'Content-Type': 'application/json'
        }
      });
      console.log('❌ Should have failed for invalid contentType');
    } catch (error) {
      if (error.response && error.response.status === 400) {
        console.log('✅ Validation correctly blocked invalid contentType');
      } else {
        console.log('❌ Unexpected error for invalid contentType:', error.response?.data);
      }
    }

    console.log('\n🎉 Rating validation and admin blocking tests completed successfully!');

  } catch (error) {
    console.error('❌ Test failed:', error.message);
    if (error.response) {
      console.error('Response status:', error.response.status);
      console.error('Response data:', error.response.data);
    }
    process.exit(1);
  }
}

// Run the test
testRatingFunctionality();