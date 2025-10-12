const express = require('express');
const prisma = require('../prisma/client');
const { auth } = require('../middleware/auth');
const router = express.Router();

// Create movie
router.post('/', auth, async (req, res) => {
  try {
    const movie = await prisma.movie.create({ data: req.body });
    res.status(201).json({ success: true, data: movie });
  } catch (error) {
    console.error('Create movie error:', error);
    res.status(500).json({ success: false, error: 'Failed to create movie' });
  }
});

// Get movies with pagination and basic filters
router.get('/', async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    const skip = (page - 1) * limit;
    const where = {};
    if (req.query.genre) where.genre_ids = { contains: req.query.genre };
    if (req.query.search) where.title = { contains: req.query.search };

    const [data, total] = await Promise.all([
      prisma.movie.findMany({ where, take: limit, skip, orderBy: { createdAt: 'desc' } }),
      prisma.movie.count({ where })
    ]);

    res.json({ success: true, data, pagination: { page, limit, total, totalPages: Math.ceil(total / limit) } });
  } catch (error) {
    console.error('Get movies error:', error);
    res.status(500).json({ success: false, error: 'Failed to fetch movies' });
  }
});

// Get movie by id
router.get('/:id', async (req, res) => {
  try {
    const id = Number(req.params.id);
    const movie = await prisma.movie.findUnique({ where: { id } });
    if (!movie) return res.status(404).json({ success: false, error: 'Movie not found' });
    res.json({ success: true, data: movie });
  } catch (error) {
    console.error('Get movie error:', error);
    res.status(500).json({ success: false, error: 'Failed to fetch movie' });
  }
});

// Update movie
router.put('/:id', auth, async (req, res) => {
  try {
    const id = Number(req.params.id);
    const updated = await prisma.movie.update({ where: { id }, data: req.body });
    res.json({ success: true, data: updated });
  } catch (error) {
    console.error('Update movie error:', error);
    res.status(500).json({ success: false, error: 'Failed to update movie' });
  }
});

// Delete movie
router.delete('/:id', auth, async (req, res) => {
  try {
    const id = Number(req.params.id);
    await prisma.movie.delete({ where: { id } });
    res.json({ success: true, message: 'Movie deleted' });
  } catch (error) {
    console.error('Delete movie error:', error);
    res.status(500).json({ success: false, error: 'Failed to delete movie' });
  }
});

module.exports = router;
