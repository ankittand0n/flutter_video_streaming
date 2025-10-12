const axios = require('axios');
const FormData = require('form-data');

const API_BASE = 'http://localhost:3000';

describe('Authentication and CRUD Integration Tests', () => {
  let token = '';
  let createdMovieId = '';

  test('Login with admin credentials', async () => {
    const loginResponse = await axios.post(`${API_BASE}/auth/login`, {
      username: 'admin',
      password: 'admin123'
    });

    expect(loginResponse.data.token).toBeDefined();
    token = loginResponse.data.token;
  });

  test('Verify token works with protected endpoint', async () => {
    const testResponse = await axios.get(`${API_BASE}/movies`, {
      headers: {
        'Authorization': `Bearer ${token}`
      }
    });

    expect(testResponse.status).toBe(200);
  });

  test('Create a movie', async () => {
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

    expect(createResponse.data.success).toBe(true);
    expect(createResponse.data.data.id).toBeDefined();
    createdMovieId = createResponse.data.data.id;
  });

  test('Fetch movies and verify created movie exists', async () => {
    const fetchResponse = await axios.get(`${API_BASE}/movies`);

    expect(fetchResponse.data.success).toBe(true);
    expect(Array.isArray(fetchResponse.data.data)).toBe(true);

    const testMovie = fetchResponse.data.data.find(m => m.id === createdMovieId);
    expect(testMovie).toBeDefined();
    expect(testMovie.title).toBe('Test Movie');
  });

  test('Update the movie', async () => {
    const updateFormData = new FormData();
    updateFormData.append('title', 'Updated Test Movie');
    updateFormData.append('overview', 'This movie was updated by the test script');
    updateFormData.append('vote_average', '9.0');

    const updateResponse = await axios.put(`${API_BASE}/movies/${createdMovieId}`, updateFormData, {
      headers: {
        'Authorization': `Bearer ${token}`,
        ...updateFormData.getHeaders()
      }
    });

    expect(updateResponse.data.success).toBe(true);
  });

  test('Delete the movie', async () => {
    const deleteResponse = await axios.delete(`${API_BASE}/movies/${createdMovieId}`, {
      headers: {
        'Authorization': `Bearer ${token}`
      }
    });

    expect(deleteResponse.data.success).toBe(true);
  });
});