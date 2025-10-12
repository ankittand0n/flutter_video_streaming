const axios = require('axios');
const FormData = require('form-data');

const API_BASE = 'http://localhost:3000/api';

async function testAuthenticationAndCRUD() {
  console.log('🧪 Testing Authentication and CRUD Operations\n');

  let token = '';
  let createdMovieId = '';

  try {
    // Test 1: Login
    console.log('1. Testing Login...');
    const loginResponse = await axios.post(`${API_BASE}/auth/login`, {
      username: 'admin',
      password: 'admin123'
    });

    if (!loginResponse.data.token) {
      throw new Error('Login failed: ' + JSON.stringify(loginResponse.data));
    }

    console.log('✅ Login successful');
    token = loginResponse.data.token;

    // Test 2: Create a movie
    console.log('\n2. Testing Movie Creation...');
    const formData = new FormData();
    formData.append('title', 'Test Movie');
    formData.append('overview', 'This is a test movie created by the test script');
    formData.append('release_date', '2024-01-01');
    formData.append('vote_average', '8.5');
    formData.append('genre_ids', '["Action", "Adventure"]');
    formData.append('video_url', 'https://example.com/movie.mp4');
    formData.append('trailer_url', 'https://example.com/trailer.mp4');

    const createResponse = await axios.post(`${API_BASE}/movies`, formData, {
      headers: {
        'Authorization': `Bearer ${token}`,
        ...formData.getHeaders()
      }
    });

    if (!createResponse.data.success) {
      console.error('Create response:', createResponse.data);
      throw new Error('Movie creation failed: ' + JSON.stringify(createResponse.data));
    }

    console.log('✅ Movie creation successful');
    const movieId = createResponse.data.data.id;

    // Test 3: Fetch movies
    console.log('\n3. Testing Movie Fetch...');
    const fetchResponse = await axios.get(`${API_BASE}/movies`);

    if (!fetchResponse.data.success) {
      throw new Error('Movie fetch failed: ' + JSON.stringify(fetchResponse.data));
    }

    const testMovie = fetchResponse.data.data.find(m => m.id === movieId);
    if (!testMovie) {
      throw new Error('Created movie not found in fetch results');
    }

    console.log('✅ Movie fetch successful - found created movie');

    // Test 4: Update the movie
    console.log('\n4. Testing Movie Update...');
    const updateFormData = new FormData();
    updateFormData.append('title', 'Updated Test Movie');
    updateFormData.append('overview', 'This movie was updated by the test script');
    updateFormData.append('vote_average', '9.0');

    const updateResponse = await axios.put(`${API_BASE}/movies/${movieId}`, updateFormData, {
      headers: {
        'Authorization': `Bearer ${token}`,
        ...updateFormData.getHeaders()
      }
    });

    if (!updateResponse.data.success) {
      throw new Error('Movie update failed: ' + JSON.stringify(updateResponse.data));
    }

    console.log('✅ Movie update successful');

    // Test 5: Delete the movie
    console.log('\n5. Testing Movie Deletion...');
    const deleteResponse = await axios.delete(`${API_BASE}/movies/${movieId}`, {
      headers: {
        'Authorization': `Bearer ${token}`
      }
    });

    if (!deleteResponse.data.success) {
      throw new Error('Movie deletion failed: ' + JSON.stringify(deleteResponse.data));
    }

    console.log('✅ Movie deletion successful');

    console.log('\n🎉 All tests passed! Authentication and CRUD operations are working correctly.');

  } catch (error) {
    console.error('❌ Test failed:', error.message);
    process.exit(1);
  }
}

// Run the test
testAuthenticationAndCRUD();