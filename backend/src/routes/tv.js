const express = require('express');
const axios = require('axios');
const prisma = require('../prisma/client');
const { auth } = require('../middleware/auth');

const router = express.Router();

// Helper function to add full URLs to image paths
const addImageUrls = (req, item) => {
  const baseUrl = `${req.protocol}://${req.get('host')}`;
  if (item.poster_path && !item.poster_path.startsWith('http')) {
    item.poster_path = `${baseUrl}${item.poster_path}`;
  }
  if (item.backdrop_path && !item.backdrop_path.startsWith('http')) {
    item.backdrop_path = `${baseUrl}${item.backdrop_path}`;
  }
  return item;
};

// List with pagination
router.get('/', async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    const skip = (page - 1) * limit;
    const where = {};
    if (req.query.genre) where.genre_ids = { contains: req.query.genre };
    // Fix: Use 'name' field instead of 'title' to match schema
    if (req.query.search) where.name = { contains: req.query.search };

    const [data, total] = await Promise.all([
      prisma.tv_series.findMany({ where, take: limit, skip, orderBy: { created_at: 'desc' } }),
      prisma.tv_series.count({ where })
    ]);

    // Add full URLs to image paths
    const transformedData = data.map(item => addImageUrls(req, item));

    res.json({ success: true, data: transformedData, pagination: { page, limit, total, totalPages: Math.ceil(total / limit) } });
  } catch (error) {
    console.error('Error fetching TV series:', error);
    res.status(500).json({ success: false, error: 'Failed to fetch TV series' });
  }
});

// Get by id
router.get('/:id', async (req, res) => {
  try {
    const id = Number(req.params.id);
    const tv = await prisma.tv_series.findUnique({ where: { id } });
    if (!tv) return res.status(404).json({ success: false, error: 'TV series not found' });
    
    // Add full URLs to image paths
    const transformedTv = addImageUrls(req, tv);
    
    res.json({ success: true, data: transformedTv });
  } catch (error) {
    console.error('Error fetching TV series:', error);
    res.status(500).json({ success: false, error: 'Failed to fetch TV series' });
  }
});

// Popular
router.get('/popular/list', async (req, res) => {
  try {
    const limit = parseInt(req.query.limit) || 10;
    const data = await prisma.tv_series.findMany({ take: limit, orderBy: { vote_average: 'desc' } });
    
    // Add full URLs to image paths
    const transformedData = data.map(item => addImageUrls(req, item));
    
    res.json({ success: true, data: transformedData });
  } catch (error) {
    console.error('Error fetching popular TV series:', error);
    res.status(500).json({ success: false, error: 'Failed to fetch popular TV series' });
  }
});

// Top-rated
router.get('/top-rated/list', async (req, res) => {
  try {
    const limit = parseInt(req.query.limit) || 10;
    const data = await prisma.tv_series.findMany({ where: { vote_average: { gt: 0 } }, take: limit, orderBy: { vote_average: 'desc' } });
    
    // Add full URLs to image paths
    const transformedData = data.map(item => addImageUrls(req, item));
    
    res.json({ success: true, data: transformedData });
  } catch (error) {
    console.error('Error fetching top rated TV series:', error);
    res.status(500).json({ success: false, error: 'Failed to fetch top rated TV series' });
  }
});

// By genre
router.get('/genre/:genreId/list', async (req, res) => {
  try {
    const genreId = req.params.genreId;
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    const skip = (page - 1) * limit;

    const where = { genre_ids: { contains: genreId } };
    const [data, total] = await Promise.all([
      prisma.tv_series.findMany({ where, take: limit, skip, orderBy: { created_at: 'desc' } }),
      prisma.tv_series.count({ where })
    ]);

    // Add full URLs to image paths
    const transformedData = data.map(item => addImageUrls(req, item));

    res.json({ success: true, data: transformedData, pagination: { page, limit, total, totalPages: Math.ceil(total / limit) } });
  } catch (error) {
    console.error('Error fetching TV series by genre:', error);
    res.status(500).json({ success: false, error: 'Failed to fetch TV series by genre' });
  }
});

// Sync from TMDB is disabled to prevent external API calls in this deployment.
router.post('/sync', auth, async (req, res) => {
  res.status(503).json({ success: false, error: 'Sync with external TMDB API is disabled on this server.' });
});

module.exports = router;
