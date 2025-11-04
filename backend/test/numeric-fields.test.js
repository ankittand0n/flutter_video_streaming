const request = require('supertest');
const axios = require('axios');
const FormData = require('form-data');
const app = require('../src/server');
const { isExternal, getBaseUrl, getTestType } = require('./test-config');

// axios instance for external tests
const axiosInstance = isExternal() ? axios.create({ baseURL: getBaseUrl() }) : null;

/**
 * Helper for making HTTP requests with multipart/form-data
 */
const postForm = async (path, fields, headers = {}) => {
  if (isExternal()) {
    const formData = new FormData();
    Object.entries(fields).forEach(([key, value]) => {
      formData.append(key, value);
    });
    
    try {
      const res = await axiosInstance.post(path, formData, {
        headers: {
          ...headers,
          ...formData.getHeaders()
        }
      });
      return { body: res.data, statusCode: res.status };
    } catch (error) {
      if (error.response) {
        return { body: error.response.data, statusCode: error.response.status };
      }
      throw error;
    }
  }
  
  const req = request(app).post(path);
  Object.keys(headers).forEach(key => req.set(key, headers[key]));
  Object.entries(fields).forEach(([key, value]) => {
    req.field(key, value);
  });
  return req;
};

const putForm = async (path, fields, headers = {}) => {
  if (isExternal()) {
    const formData = new FormData();
    Object.entries(fields).forEach(([key, value]) => {
      formData.append(key, value);
    });
    
    try {
      const res = await axiosInstance.put(path, formData, {
        headers: {
          ...headers,
          ...formData.getHeaders()
        }
      });
      return { body: res.data, statusCode: res.status };
    } catch (error) {
      if (error.response) {
        return { body: error.response.data, statusCode: error.response.status };
      }
      throw error;
    }
  }
  
  const req = request(app).put(path);
  Object.keys(headers).forEach(key => req.set(key, headers[key]));
  Object.entries(fields).forEach(([key, value]) => {
    req.field(key, value);
  });
  return req;
};

const deleteReq = async (path, headers = {}) => {
  if (isExternal()) {
    try {
      const res = await axiosInstance.delete(path, { headers });
      return { body: res.data, statusCode: res.status };
    } catch (error) {
      if (error.response) {
        return { body: error.response.data, statusCode: error.response.status };
      }
      throw error;
    }
  }
  
  const req = request(app).delete(path);
  Object.keys(headers).forEach(key => req.set(key, headers[key]));
  return req;
};

const post = async (path, data, headers = {}) => {
  if (isExternal()) {
    try {
      const res = await axiosInstance.post(path, data, { headers });
      return { body: res.data, statusCode: res.status };
    } catch (error) {
      if (error.response) {
        return { body: error.response.data, statusCode: error.response.status };
      }
      throw error;
    }
  }
  const req = request(app).post(path);
  Object.keys(headers).forEach(key => req.set(key, headers[key]));
  return req.send(data);
};

describe(`Numeric Field Handling Tests - ${getTestType()}`, () => {
  let token = '';
  let movieId = '';

  beforeAll(async () => {
    console.log(`\n🧪 Running numeric field tests against: ${getTestType()}`);
    if (isExternal()) {
      console.log(`📡 External URL: ${getBaseUrl()}\n`);
    }

    const response = await post('/api/auth/login', {
      username: 'admin',
      password: 'admin123'
    });

    expect(response.statusCode || response.status).toBe(200);
    token = response.body.token;
    expect(token).toBeDefined();
  });

  test('Admin login successful', () => {
    expect(token).toBeTruthy();
  });

  test('Create movie with empty vote_average', async () => {
    const response = await postForm('/api/movies', {
      title: 'Test Movie with Empty Rating',
      overview: 'Testing empty vote_average field',
      release_date: '2024-01-01',
      vote_average: '', // Empty string
      genre_ids: '["Action"]'
    }, { 'Authorization': `Bearer ${token}` });

    expect(response.statusCode || response.status).toBe(201);
    expect(response.body.success).toBe(true);
    movieId = response.body.data.id;
  });

  test('Update movie with empty vote_average', async () => {
    const response = await putForm(`/api/movies/${movieId}`, {
      title: 'Updated Test Movie',
      vote_average: '' // Empty string
    }, { 'Authorization': `Bearer ${token}` });

    expect(response.statusCode || response.status).toBe(200);
    expect(response.body.success).toBe(true);
  });

  test('Update movie with valid vote_average', async () => {
    const response = await putForm(`/api/movies/${movieId}`, {
      vote_average: '8.5'
    }, { 'Authorization': `Bearer ${token}` });

    expect(response.statusCode || response.status).toBe(200);
    expect(response.body.success).toBe(true);
  });

  test('Clean up test movie', async () => {
    const response = await deleteReq(`/api/movies/${movieId}`, {
      'Authorization': `Bearer ${token}`
    });

    expect(response.statusCode || response.status).toBe(200);
    expect(response.body.success).toBe(true);
  });

  afterAll(async () => {
    // Clean up and close any open connections
    await new Promise(resolve => setTimeout(resolve, 100));
  });
});