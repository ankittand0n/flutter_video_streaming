const express = require('express');
const prisma = require('../prisma/client');
const { auth } = require('../middleware/auth');
const router = express.Router();

router.post('/', auth, async (req, res) => {
  try {
    const seasonData = { ...req.body };

    // Parse date fields
    if (seasonData.air_date) {
      seasonData.air_date = new Date(seasonData.air_date);
    }

    // Parse numeric fields
    if (seasonData.season_number) {
      seasonData.season_number = parseInt(seasonData.season_number);
    }
    if (seasonData.episode_count) {
      seasonData.episode_count = parseInt(seasonData.episode_count);
    }

    const season = await prisma.season.create({ data: seasonData });
    res.status(201).json({ success: true, data: season });
  } catch (error) {
    console.error('Create season error:', error);
    res.status(500).json({ success: false, error: 'Failed to create season' });
  }
});

router.get('/', async (req, res) => {
  try {
    const tvSeriesId = req.query.tvSeriesId ? Number(req.query.tvSeriesId) : undefined;
    const where = {};
    if (tvSeriesId) where.tv_series_id = tvSeriesId;

    const data = await prisma.season.findMany({ where, orderBy: { createdAt: 'desc' } });
    res.json({ success: true, data });
  } catch (error) {
    console.error('Get seasons error:', error);
    res.status(500).json({ success: false, error: 'Failed to fetch seasons' });
  }
});

router.get('/:id', async (req, res) => {
  try {
    const id = Number(req.params.id);
    const season = await prisma.season.findUnique({ where: { id } });
    if (!season) return res.status(404).json({ success: false, error: 'Season not found' });
    res.json({ success: true, data: season });
  } catch (error) {
    console.error('Get season error:', error);
    res.status(500).json({ success: false, error: 'Failed to fetch season' });
  }
});

router.put('/:id', auth, async (req, res) => {
  try {
    const id = Number(req.params.id);
    const seasonData = { ...req.body };

    // Parse date fields
    if (seasonData.air_date) {
      seasonData.air_date = new Date(seasonData.air_date);
    }

    const updated = await prisma.season.update({ where: { id }, data: seasonData });
    res.json({ success: true, data: updated });
  } catch (error) {
    console.error('Update season error:', error);
    res.status(500).json({ success: false, error: 'Failed to update season' });
  }
});

router.delete('/:id', auth, async (req, res) => {
  try {
    const id = Number(req.params.id);
    await prisma.season.delete({ where: { id } });
    res.json({ success: true, message: 'Season deleted' });
  } catch (error) {
    console.error('Delete season error:', error);
    res.status(500).json({ success: false, error: 'Failed to delete season' });
  }
});

module.exports = router;
