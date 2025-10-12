const express = require('express');
const prisma = require('../prisma/client');
const { auth } = require('../middleware/auth');
const router = express.Router();

// Create genre
router.post('/', auth, async (req, res) => {
  try {
    const genre = await prisma.genre.create({ data: req.body });
    res.status(201).json({ success: true, data: genre });
  } catch (error) {
    console.error('Create genre error:', error);
    res.status(500).json({ success: false, error: 'Failed to create genre' });
  }
});

// List genres
router.get('/', async (req, res) => {
  try {
    const data = await prisma.genre.findMany({ orderBy: { createdAt: 'desc' } });
    res.json({ success: true, data });
  } catch (error) {
    console.error('Get genres error:', error);
    res.status(500).json({ success: false, error: 'Failed to fetch genres' });
  }
});

// Get by id
router.get('/:id', async (req, res) => {
  try {
    const id = Number(req.params.id);
    const genre = await prisma.genre.findUnique({ where: { id } });
    if (!genre) return res.status(404).json({ success: false, error: 'Genre not found' });
    res.json({ success: true, data: genre });
  } catch (error) {
    console.error('Get genre error:', error);
    res.status(500).json({ success: false, error: 'Failed to fetch genre' });
  }
});

// Update
router.put('/:id', auth, async (req, res) => {
  try {
    const id = Number(req.params.id);
    const updated = await prisma.genre.update({ where: { id }, data: req.body });
    res.json({ success: true, data: updated });
  } catch (error) {
    console.error('Update genre error:', error);
    res.status(500).json({ success: false, error: 'Failed to update genre' });
  }
});

// Delete
router.delete('/:id', auth, async (req, res) => {
  try {
    const id = Number(req.params.id);
    await prisma.genre.delete({ where: { id } });
    res.json({ success: true, message: 'Genre deleted' });
  } catch (error) {
    console.error('Delete genre error:', error);
    res.status(500).json({ success: false, error: 'Failed to delete genre' });
  }
});

module.exports = router;
