const express = require('express');
const axios = require('axios');
const { optionalAuth } = require('../middleware/auth');
const { validateQuery } = require('../middleware/validation');

const router = express.Router();

// TMDB API configuration
const TMDB_BASE_URL = process.env.TMDB_BASE_URL || 'https://api.themoviedb.org/3';
const TMDB_API_KEY = process.env.TMDB_API_KEY;

if (!TMDB_API_KEY) {
  console.error('❌ TMDB_API_KEY is not set in environment variables');
}

// Helper function to make TMDB API calls
const makeTMDBRequest = async (endpoint, params = {}) => {
  try {
    const url = `${TMDB_BASE_URL}${endpoint}`;
    const queryParams = new URLSearchParams({
      api_key: TMDB_API_KEY,
      ...params
    });

    const response = await axios.get(`${url}?${queryParams}`);
    return response.data;
  } catch (error) {
    console.error('TMDB API error:', error.response?.data || error.message);
    throw new Error(error.response?.data?.status_message || 'TMDB API request failed');
  }
};

// @route   GET /api/tmdb/trending
// @desc    Get trending movies/TV shows
// @access  Public
router.get('/trending', validateQuery('pagination'), async (req, res) => {
  try {
    const { type = 'all', time = 'week', page = 1 } = req.query;
    
    const data = await makeTMDBRequest('/trending/all/week', { page });
    
    res.json({
      success: true,
      data,
      pagination: {
        page: data.page,
        totalPages: data.total_pages,
        totalResults: data.total_results
      }
    });

  } catch (error) {
    res.status(500).json({
      error: 'Failed to fetch trending content',
      details: error.message
    });
  }
});

// @route   GET /api/tmdb/movies/trending
// @desc    Get trending movies
// @access  Public
router.get('/movies/trending', validateQuery('pagination'), async (req, res) => {
  try {
    const { time = 'week', page = 1 } = req.query;
    
    const data = await makeTMDBRequest('/trending/movie/week', { page });
    
    res.json({
      success: true,
      data,
      pagination: {
        page: data.page,
        totalPages: data.total_pages,
        totalResults: data.total_results
      }
    });

  } catch (error) {
    res.status(500).json({
      error: 'Failed to fetch trending movies',
      details: error.message
    });
  }
});

// @route   GET /api/tmdb/tv/trending
// @desc    Get trending TV shows
// @access  Public
router.get('/tv/trending', validateQuery('pagination'), async (req, res) => {
  try {
    const { time = 'week', page = 1 } = req.query;
    
    const data = await makeTMDBRequest('/trending/tv/week', { page });
    
    res.json({
      success: true,
      data,
      pagination: {
        page: data.page,
        totalPages: data.total_pages,
        totalResults: data.total_results
      }
    });

  } catch (error) {
    res.status(500).json({
      error: 'Failed to fetch trending TV shows',
      details: error.message
    });
  }
});

// @route   GET /api/tmdb/discover
// @desc    Discover movies/TV shows
// @access  Public
router.get('/discover', validateQuery('pagination'), async (req, res) => {
  try {
    const { type = 'movie', page = 1, genre, year, sortBy = 'popularity.desc' } = req.query;
    
    const params = { page, sort_by: sortBy };
    if (genre) params.with_genres = genre;
    if (year) params.primary_release_year = year;
    
    const data = await makeTMDBRequest(`/discover/${type}`, params);
    
    res.json({
      success: true,
      data,
      pagination: {
        page: data.page,
        totalPages: data.total_pages,
        totalResults: data.total_results
      }
    });

  } catch (error) {
    res.status(500).json({
      error: 'Failed to discover content',
      details: error.message
    });
  }
});

// @route   GET /api/tmdb/search
// @desc    Search for movies/TV shows
// @access  Public
router.get('/search', validateQuery('contentSearch'), async (req, res) => {
  try {
    const { query, type = 'multi', page = 1 } = req.query;
    
    const data = await makeTMDBRequest('/search/multi', { 
      query, 
      page,
      include_adult: false
    });
    
    res.json({
      success: true,
      data,
      pagination: {
        page: data.page,
        totalPages: data.total_pages,
        totalResults: data.total_results
      }
    });

  } catch (error) {
    res.status(500).json({
      error: 'Search failed',
      details: error.message
    });
  }
});

// @route   GET /api/tmdb/movie/:id
// @desc    Get movie details
// @access  Public
router.get('/movie/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const { append_to_response = 'credits,videos,images,similar,recommendations' } = req.query;
    
    const data = await makeTMDBRequest(`/movie/${id}`, { append_to_response });
    
    res.json({
      success: true,
      data
    });

  } catch (error) {
    res.status(500).json({
      error: 'Failed to fetch movie details',
      details: error.message
    });
  }
});

// @route   GET /api/tmdb/tv/:id
// @desc    Get TV show details
// @access  Public
router.get('/tv/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const { append_to_response = 'credits,videos,images,similar,recommendations' } = req.query;
    
    const data = await makeTMDBRequest(`/tv/${id}`, { append_to_response });
    
    res.json({
      success: true,
      data
    });

  } catch (error) {
    res.status(500).json({
      error: 'Failed to fetch TV show details',
      details: error.message
    });
  }
});

// @route   GET /api/tmdb/tv/:id/season/:seasonNumber
// @desc    Get TV show season details
// @access  Public
router.get('/tv/:id/season/:seasonNumber', async (req, res) => {
  try {
    const { id, seasonNumber } = req.params;
    
    const data = await makeTMDBRequest(`/tv/${id}/season/${seasonNumber}`);
    
    res.json({
      success: true,
      data
    });

  } catch (error) {
    res.status(500).json({
      error: 'Failed to fetch season details',
      details: error.message
    });
  }
});

// @route   GET /api/tmdb/genres
// @desc    Get available genres
// @access  Public
router.get('/genres', async (req, res) => {
  try {
    const { type = 'movie' } = req.query;
    
    const data = await makeTMDBRequest(`/genre/${type}/list`);
    
    res.json({
      success: true,
      data
    });

  } catch (error) {
    res.status(500).json({
      error: 'Failed to fetch genres',
      details: error.message
    });
  }
});

// @route   GET /api/tmdb/configuration
// @desc    Get TMDB configuration (image URLs, etc.)
// @access  Public
router.get('/configuration', async (req, res) => {
  try {
    const data = await makeTMDBRequest('/configuration');
    
    res.json({
      success: true,
      data
    });

  } catch (error) {
    res.status(500).json({
      error: 'Failed to fetch configuration',
      details: error.message
    });
  }
});

// @route   GET /api/tmdb/popular
// @desc    Get popular movies/TV shows
// @access  Public
router.get('/popular', validateQuery('pagination'), async (req, res) => {
  try {
    const { type = 'movie', page = 1 } = req.query;
    
    const data = await makeTMDBRequest(`/${type}/popular`, { page });
    
    res.json({
      success: true,
      data,
      pagination: {
        page: data.page,
        totalPages: data.total_pages,
        totalResults: data.total_results
      }
    });

  } catch (error) {
    res.status(500).json({
      error: 'Failed to fetch popular content',
      details: error.message
    });
  }
});

// @route   GET /api/tmdb/now-playing
// @desc    Get now playing movies
// @access  Public
router.get('/now-playing', validateQuery('pagination'), async (req, res) => {
  try {
    const { page = 1 } = req.query;
    
    const data = await makeTMDBRequest('/movie/now_playing', { page });
    
    res.json({
      success: true,
      data,
      pagination: {
        page: data.page,
        totalPages: data.total_pages,
        totalResults: data.total_results
      }
    });

  } catch (error) {
    res.status(500).json({
      error: 'Failed to fetch now playing movies',
      details: error.message
    });
  }
});

// @route   GET /api/tmdb/on-the-air
// @desc    Get on the air TV shows
// @access  Public
router.get('/on-the-air', validateQuery('pagination'), async (req, res) => {
  try {
    const { page = 1 } = req.query;
    
    const data = await makeTMDBRequest('/tv/on_the_air', { page });
    
    res.json({
      success: true,
      data,
      pagination: {
        page: data.page,
        totalPages: data.total_pages,
        totalResults: data.total_results
      }
    });

  } catch (error) {
    res.status(500).json({
      error: 'Failed to fetch on the air TV shows',
      details: error.message
    });
  }
});

module.exports = router;
