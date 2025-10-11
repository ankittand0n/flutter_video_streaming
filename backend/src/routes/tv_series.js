const express = require('express');
const prisma = require('../prisma/client');
const { auth } = require('../middleware/auth');
const router = express.Router();

// Create tv series
router.post('/', auth, async (req, res) => {
  try {
    const tv = await prisma.tvSeries.create({ data: req.body });
    res.status(201).json({ success: true, data: tv });
  } catch (error) {
    console.error('Create tv series error:', error);
    res.status(500).json({ success: false, error: 'Failed to create tv series' });
  }
});

// List tv series
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
    console.error('Get tv series error:', error);
    res.status(500).json({ success: false, error: 'Failed to fetch tv series' });
  }
});

// Get tv series by id
router.get('/:id', async (req, res) => {
  try {
    const id = Number(req.params.id);
    const tv = await prisma.tvSeries.findUnique({ where: { id } });
    if (!tv) return res.status(404).json({ success: false, error: 'TV series not found' });
    res.json({ success: true, data: tv });
  } catch (error) {
    console.error('Get tv series error:', error);
    res.status(500).json({ success: false, error: 'Failed to fetch tv series' });
  }
});

// Update
router.put('/:id', auth, async (req, res) => {
  try {
    const id = Number(req.params.id);
    const updated = await prisma.tvSeries.update({ where: { id }, data: req.body });
    res.json({ success: true, data: updated });
  } catch (error) {
    console.error('Update tv series error:', error);
    res.status(500).json({ success: false, error: 'Failed to update tv series' });
  }
});

// Delete
router.delete('/:id', auth, async (req, res) => {
  try {
    const id = Number(req.params.id);
    await prisma.tvSeries.delete({ where: { id } });
    res.json({ success: true, message: 'TV series deleted' });
  } catch (error) {
    console.error('Delete tv series error:', error);
    res.status(500).json({ success: false, error: 'Failed to delete tv series' });
  }
});

module.exports = router;
