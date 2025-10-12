const axios = require('axios');
const FormData = require('form-data');

const API_BASE = 'http://localhost:3000/api';

async function testNumericFieldHandling() {
  console.log('🧪 Testing Numeric Field Handling\n');

  let token = '';

  try {
    // Test 1: Login
    console.log('1. Testing Admin Login...');
    const loginResponse = await axios.post(`${API_BASE}/auth/login`, {
      username: 'admin',
      password: 'admin123'
    });

    if (!loginResponse.data.token) {
      throw new Error('Admin login failed');
    }

    console.log('✅ Admin login successful');
    token = loginResponse.data.token;

    // Test 2: Create movie with empty vote_average
    console.log('\n2. Testing Movie Creation with Empty vote_average...');
    const formData = new FormData();
    formData.append('title', 'Test Movie with Empty Rating');
    formData.append('overview', 'Testing empty vote_average field');
    formData.append('release_date', '2024-01-01');
    formData.append('vote_average', ''); // Empty string
    formData.append('genre_ids', '["Action"]');

    const createResponse = await axios.post(`${API_BASE}/movies`, formData, {
      headers: {
        'Authorization': `Bearer ${token}`,
        ...formData.getHeaders()
      }
    });

    if (!createResponse.data.success) {
      throw new Error('Movie creation with empty vote_average failed: ' + JSON.stringify(createResponse.data));
    }

    console.log('✅ Movie created successfully with empty vote_average');
    const movieId = createResponse.data.data.id;

    // Test 3: Update movie with empty vote_average
    console.log('\n3. Testing Movie Update with Empty vote_average...');
    const updateFormData = new FormData();
    updateFormData.append('title', 'Updated Test Movie');
    updateFormData.append('vote_average', ''); // Empty string

    const updateResponse = await axios.put(`${API_BASE}/movies/${movieId}`, updateFormData, {
      headers: {
        'Authorization': `Bearer ${token}`,
        ...updateFormData.getHeaders()
      }
    });

    if (!updateResponse.data.success) {
      throw new Error('Movie update with empty vote_average failed: ' + JSON.stringify(updateResponse.data));
    }

    console.log('✅ Movie updated successfully with empty vote_average');

    // Test 4: Update movie with valid vote_average
    console.log('\n4. Testing Movie Update with Valid vote_average...');
    const validUpdateFormData = new FormData();
    validUpdateFormData.append('vote_average', '8.5');

    const validUpdateResponse = await axios.put(`${API_BASE}/movies/${movieId}`, validUpdateFormData, {
      headers: {
        'Authorization': `Bearer ${token}`,
        ...validUpdateFormData.getHeaders()
      }
    });

    if (!validUpdateResponse.data.success) {
      throw new Error('Movie update with valid vote_average failed: ' + JSON.stringify(validUpdateResponse.data));
    }

    console.log('✅ Movie updated successfully with valid vote_average');

    // Clean up - delete the test movie
    console.log('\n5. Cleaning up test movie...');
    await axios.delete(`${API_BASE}/movies/${movieId}`, {
      headers: {
        'Authorization': `Bearer ${token}`
      }
    });

    console.log('✅ Test movie deleted');

    console.log('\n🎉 All numeric field handling tests passed!');

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
testNumericFieldHandling();