const express = require('express');
const axios = require('axios');
const prisma = require('../prisma/client');
const { auth } = require('../middleware/auth');

const router = express.Router();

// List with pagination
router.get('/', async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    const skip = (page - 1) * limit;
    const where = {};
    if (req.query.genre) where.genre_ids = { contains: req.query.genre };
    if (req.query.search) where.title = { contains: req.query.search };

    const [data, total] = await Promise.all([
      prisma.tvSeries.findMany({ where, take: limit, skip, orderBy: { createdAt: 'desc' } }),
      prisma.tvSeries.count({ where })
    ]);

    res.json({ success: true, data, pagination: { page, limit, total, totalPages: Math.ceil(total / limit) } });
  } catch (error) {
    console.error('Error fetching TV series:', error);
    res.status(500).json({ success: false, error: 'Failed to fetch TV series' });
  }
});

// Get by id
router.get('/:id', async (req, res) => {
  try {
    const id = Number(req.params.id);
    const tv = await prisma.tvSeries.findUnique({ where: { id } });
    if (!tv) return res.status(404).json({ success: false, error: 'TV series not found' });
    res.json({ success: true, data: tv });
  } catch (error) {
    console.error('Error fetching TV series:', error);
    res.status(500).json({ success: false, error: 'Failed to fetch TV series' });
  }
});

// Popular
router.get('/popular/list', async (req, res) => {
  try {
    const limit = parseInt(req.query.limit) || 10;
    const data = await prisma.tvSeries.findMany({ take: limit, orderBy: { vote_average: 'desc' } });
    res.json({ success: true, data });
  } catch (error) {
    console.error('Error fetching popular TV series:', error);
    res.status(500).json({ success: false, error: 'Failed to fetch popular TV series' });
  }
});

// Top-rated
router.get('/top-rated/list', async (req, res) => {
  try {
    const limit = parseInt(req.query.limit) || 10;
    const data = await prisma.tvSeries.findMany({ where: { vote_average: { gt: 0 } }, take: limit, orderBy: { vote_average: 'desc' } });
    res.json({ success: true, data });
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
      prisma.tvSeries.findMany({ where, take: limit, skip, orderBy: { createdAt: 'desc' } }),
      prisma.tvSeries.count({ where })
    ]);

    res.json({ success: true, data, pagination: { page, limit, total, totalPages: Math.ceil(total / limit) } });
  } catch (error) {
    console.error('Error fetching TV series by genre:', error);
    res.status(500).json({ success: false, error: 'Failed to fetch TV series by genre' });
  }
});

// Sync from TMDB
router.post('/sync', auth, async (req, res) => {
  try {
    const { tmdbApiKey } = req.body;
    if (!tmdbApiKey) return res.status(400).json({ success: false, error: 'TMDB API key is required' });

    const response = await axios.get(`https://api.themoviedb.org/3/tv/popular?api_key=${tmdbApiKey}&language=en-US&page=1`);
    const tvSeries = response.data.results || [];
    let synced = 0;
    for (const s of tvSeries) {
      try {
        await prisma.tvSeries.upsert({
          where: { id: Number(s.id) },
          update: {},
          create: {
            title: s.name,
            overview: s.overview,
            first_air_date: s.first_air_date ? new Date(s.first_air_date) : null,
            vote_average: s.vote_average,
            poster_path: s.poster_path,
            backdrop_path: s.backdrop_path,
            genre_ids: JSON.stringify(s.genre_ids),
            original_language: s.original_language,
            video: false
          }
        });
        synced++;
      } catch (e) {
        console.error('sync error', e);
      }
    }

    res.json({ success: true, message: `Synced ${synced} series` });
  } catch (error) {
    console.error('Error syncing TV series:', error);
    res.status(500).json({ success: false, error: 'Failed to sync TV series' });
  }
});

module.exports = router;
