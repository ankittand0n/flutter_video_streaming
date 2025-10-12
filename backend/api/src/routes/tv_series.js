const express = require('express');
const prisma = require('../prisma/client');
const { auth } = require('../middleware/auth');
const { upload } = require('../config/multer');
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

// Create tv series
router.post('/', auth, upload.fields([{ name: 'poster', maxCount: 1 }, { name: 'backdrop', maxCount: 1 }]), async (req, res) => {
  try {
    const tvData = { ...req.body };

    // Handle file uploads
    if (req.files) {
      if (req.files.poster && req.files.poster[0]) {
        tvData.poster_path = `/images/tv_series/${req.files.poster[0].filename}`;
      }
      if (req.files.backdrop && req.files.backdrop[0]) {
        tvData.backdrop_path = `/images/tv_series/${req.files.backdrop[0].filename}`;
      }
    }

    // Parse JSON fields
    if (tvData.genre_ids) {
      tvData.genre_ids = JSON.stringify(JSON.parse(tvData.genre_ids));
    }
    if (tvData.seasons) {
      tvData.seasons = JSON.stringify(JSON.parse(tvData.seasons));
    }

    // Parse date fields
    if (tvData.first_air_date) {
      tvData.first_air_date = new Date(tvData.first_air_date);
    }
    if (tvData.last_air_date) {
      tvData.last_air_date = new Date(tvData.last_air_date);
    }

    // Parse numeric fields - handle empty strings
    if (tvData.vote_average !== undefined) {
      if (tvData.vote_average === '' || tvData.vote_average === null) {
        tvData.vote_average = null;
      } else {
        const parsed = parseFloat(tvData.vote_average);
        tvData.vote_average = isNaN(parsed) ? null : parsed;
      }
    }
    if (tvData.number_of_seasons !== undefined) {
      if (tvData.number_of_seasons === '' || tvData.number_of_seasons === null) {
        tvData.number_of_seasons = null;
      } else {
        const parsed = parseInt(tvData.number_of_seasons);
        tvData.number_of_seasons = isNaN(parsed) ? null : parsed;
      }
    }
    if (tvData.number_of_episodes !== undefined) {
      if (tvData.number_of_episodes === '' || tvData.number_of_episodes === null) {
        tvData.number_of_episodes = null;
      } else {
        const parsed = parseInt(tvData.number_of_episodes);
        tvData.number_of_episodes = isNaN(parsed) ? null : parsed;
      }
    }

    const tv = await prisma.tvSeries.create({ data: tvData });
    const transformedTV = addImageUrls(req, tv);
    res.status(201).json({ success: true, data: transformedTV });
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
    if (req.query.search) where.name = { contains: req.query.search };

    const [data, total] = await Promise.all([
      prisma.tvSeries.findMany({ where, take: limit, skip, orderBy: { createdAt: 'desc' } }),
      prisma.tvSeries.count({ where })
    ]);

    // Add full URLs to image paths
    const transformedData = data.map(item => addImageUrls(req, item));

    res.json({ success: true, data: transformedData, pagination: { page, limit, total, totalPages: Math.ceil(total / limit) } });
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
    
    // Add full URLs to image paths
    const transformedTV = addImageUrls(req, tv);
    
    res.json({ success: true, data: transformedTV });
  } catch (error) {
    console.error('Get tv series error:', error);
    res.status(500).json({ success: false, error: 'Failed to fetch tv series' });
  }
});

// Update
router.put('/:id', auth, upload.fields([{ name: 'poster', maxCount: 1 }, { name: 'backdrop', maxCount: 1 }]), async (req, res) => {
  try {
    const id = Number(req.params.id);
    const tvData = { ...req.body };

    // Handle file uploads
    if (req.files) {
      if (req.files.poster && req.files.poster[0]) {
        tvData.poster_path = `/images/tv_series/${req.files.poster[0].filename}`;
      }
      if (req.files.backdrop && req.files.backdrop[0]) {
        tvData.backdrop_path = `/images/tv_series/${req.files.backdrop[0].filename}`;
      }
    }

    // Parse JSON fields
    if (tvData.genre_ids) {
      tvData.genre_ids = JSON.stringify(JSON.parse(tvData.genre_ids));
    }
    if (tvData.seasons) {
      tvData.seasons = JSON.stringify(JSON.parse(tvData.seasons));
    }

    // Parse date fields
    if (tvData.first_air_date) {
      tvData.first_air_date = new Date(tvData.first_air_date);
    }
    if (tvData.last_air_date) {
      tvData.last_air_date = new Date(tvData.last_air_date);
    }

    // Parse numeric fields - handle empty strings
    if (tvData.vote_average !== undefined) {
      if (tvData.vote_average === '' || tvData.vote_average === null) {
        tvData.vote_average = null;
      } else {
        const parsed = parseFloat(tvData.vote_average);
        tvData.vote_average = isNaN(parsed) ? null : parsed;
      }
    }
    if (tvData.number_of_seasons !== undefined) {
      if (tvData.number_of_seasons === '' || tvData.number_of_seasons === null) {
        tvData.number_of_seasons = null;
      } else {
        const parsed = parseInt(tvData.number_of_seasons);
        tvData.number_of_seasons = isNaN(parsed) ? null : parsed;
      }
    }
    if (tvData.number_of_episodes !== undefined) {
      if (tvData.number_of_episodes === '' || tvData.number_of_episodes === null) {
        tvData.number_of_episodes = null;
      } else {
        const parsed = parseInt(tvData.number_of_episodes);
        tvData.number_of_episodes = isNaN(parsed) ? null : parsed;
      }
    }

    const updated = await prisma.tvSeries.update({ where: { id }, data: tvData });
    const transformedTV = addImageUrls(req, updated);
    res.json({ success: true, data: transformedTV });
  } catch (error) {
    console.error('Update tv series error:', error);
    
    // Provide more specific error messages
    let errorMessage = 'Failed to update tv series';
    if (error.code === 'P2025') {
      errorMessage = 'TV series not found';
    } else if (error.code === 'P2002') {
      errorMessage = 'A TV series with this data already exists';
    } else if (error.message) {
      errorMessage = error.message;
    }
    
    res.status(500).json({ success: false, error: errorMessage });
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
