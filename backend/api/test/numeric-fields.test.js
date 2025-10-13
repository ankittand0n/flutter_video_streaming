const axios = require('axios');
const FormData = require('form-data');

const API_BASE = 'http://api.namkeentv.com';

describe('Numeric Field Handling Tests', () => {
  let token = '';
  let movieId = '';

  test('Admin login', async () => {
    const loginResponse = await axios.post(`${API_BASE}/auth/login`, {
      username: 'admin',
      password: 'admin123'
    });

    expect(loginResponse.data.token).toBeDefined();
    token = loginResponse.data.token;
  });

  test('Create movie with empty vote_average', async () => {
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

    expect(createResponse.data.success).toBe(true);
    movieId = createResponse.data.data.id;
  });

  test('Update movie with empty vote_average', async () => {
    const updateFormData = new FormData();
    updateFormData.append('title', 'Updated Test Movie');
    updateFormData.append('vote_average', ''); // Empty string

    const updateResponse = await axios.put(`${API_BASE}/movies/${movieId}`, updateFormData, {
      headers: {
        'Authorization': `Bearer ${token}`,
        ...updateFormData.getHeaders()
      }
    });

    expect(updateResponse.data.success).toBe(true);
  });

  test('Update movie with valid vote_average', async () => {
    const validUpdateFormData = new FormData();
    validUpdateFormData.append('vote_average', '8.5');

    const validUpdateResponse = await axios.put(`${API_BASE}/movies/${movieId}`, validUpdateFormData, {
      headers: {
        'Authorization': `Bearer ${token}`,
        ...validUpdateFormData.getHeaders()
      }
    });

    expect(validUpdateResponse.data.success).toBe(true);
  });

  test('Clean up test movie', async () => {
    const deleteResponse = await axios.delete(`${API_BASE}/movies/${movieId}`, {
      headers: {
        'Authorization': `Bearer ${token}`
      }
    });

    expect(deleteResponse.data.success).toBe(true);
  });
});