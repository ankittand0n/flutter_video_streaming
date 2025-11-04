const express = require('express');
const prisma = require('../prisma/client');
const { auth } = require('../middleware/auth');
const { upload } = require('../config/multer');
const router = express.Router();
const cache = require('../utils/simpleCache');

// Helper function to add full URLs to image paths
const addImageUrls = (req, item) => {
  // Use X-Forwarded-Proto header if available (for Cloud Run/proxy), otherwise use req.protocol
  const protocol = req.get('x-forwarded-proto') || req.protocol;
  const baseUrl = `${protocol}://${req.get('host')}`;
  if (item.poster_path && !item.poster_path.startsWith('http')) {
    item.poster_path = `${baseUrl}${item.poster_path}`;
  }
  if (item.backdrop_path && !item.backdrop_path.startsWith('http')) {
    item.backdrop_path = `${baseUrl}${item.backdrop_path}`;
  }
  return item;
};

// Create movie
router.post('/', auth, upload.fields([{ name: 'poster', maxCount: 1 }, { name: 'backdrop', maxCount: 1 }]), async (req, res) => {
  try {
    const movieData = { ...req.body };

    // Handle file uploads
    if (req.files) {
      if (req.files.poster && req.files.poster[0]) {
        movieData.poster_path = `/images/movies/${req.files.poster[0].filename}`;
      }
      if (req.files.backdrop && req.files.backdrop[0]) {
        movieData.backdrop_path = `/images/movies/${req.files.backdrop[0].filename}`;
      }
    }

    // Parse JSON fields
    if (movieData.genre_ids) {
      movieData.genre_ids = JSON.stringify(JSON.parse(movieData.genre_ids));
    }

    // Parse trailer_urls array
    if (movieData.trailer_urls) {
      if (typeof movieData.trailer_urls === 'string') {
        try {
          movieData.trailer_urls = JSON.parse(movieData.trailer_urls);
        } catch (e) {
          movieData.trailer_urls = [movieData.trailer_urls];
        }
      }
      // Filter out empty strings
      if (Array.isArray(movieData.trailer_urls)) {
        movieData.trailer_urls = movieData.trailer_urls.filter(url => url && url.trim());
      }
    }

    // Parse date fields
    if (movieData.release_date) {
      movieData.release_date = new Date(movieData.release_date);
    }

    // Parse numeric fields - handle empty strings
    if (movieData.vote_average !== undefined) {
      if (movieData.vote_average === '' || movieData.vote_average === null) {
        movieData.vote_average = null;
      } else {
        const parsed = parseFloat(movieData.vote_average);
        movieData.vote_average = isNaN(parsed) ? null : parsed;
      }
    }

    const movie = await prisma.movie.create({ data: movieData });
    const transformedMovie = addImageUrls(req, movie);
    res.status(201).json({ success: true, data: transformedMovie });
  } catch (error) {
    console.error('Create movie error:', error);
    res.status(500).json({ success: false, error: 'Failed to create movie' });
  }
});

// Get movies with pagination and basic filters
router.get('/', async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = Math.min(parseInt(req.query.limit) || 10, 50); // default 10, max 50
    const skip = (page - 1) * limit;
    const where = {};
    if (req.query.genre) where.genre_ids = { contains: req.query.genre };
    if (req.query.search) where.title = { contains: req.query.search };

    // Cache disabled - always fetch fresh data
    const [data, total] = await Promise.all([
      prisma.movie.findMany({ where, take: limit, skip, orderBy: { created_at: 'desc' } }),
      prisma.movie.count({ where })
    ]);

    // Add full URLs to image paths
    const transformedData = data.map(item => addImageUrls(req, item));

    res.json({ success: true, data: transformedData, pagination: { page, limit, total, totalPages: Math.ceil(total / limit) } });
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
    
    // Add full URLs to image paths
    const transformedMovie = addImageUrls(req, movie);
    
    res.json({ success: true, data: transformedMovie });
  } catch (error) {
    console.error('Get movie error:', error);
    res.status(500).json({ success: false, error: 'Failed to fetch movie' });
  }
});

// Update movie
router.put('/:id', auth, upload.fields([{ name: 'poster', maxCount: 1 }, { name: 'backdrop', maxCount: 1 }]), async (req, res) => {
  try {
    const id = Number(req.params.id);
    const movieData = { ...req.body };

    // Handle file uploads
    if (req.files) {
      if (req.files.poster && req.files.poster[0]) {
        movieData.poster_path = `/images/movies/${req.files.poster[0].filename}`;
      }
      if (req.files.backdrop && req.files.backdrop[0]) {
        movieData.backdrop_path = `/images/movies/${req.files.backdrop[0].filename}`;
      }
    }

    // Parse JSON fields
    if (movieData.genre_ids) {
      movieData.genre_ids = JSON.stringify(JSON.parse(movieData.genre_ids));
    }

    // Parse trailer_urls array
    if (movieData.trailer_urls) {
      if (typeof movieData.trailer_urls === 'string') {
        try {
          movieData.trailer_urls = JSON.parse(movieData.trailer_urls);
        } catch (e) {
          movieData.trailer_urls = [movieData.trailer_urls];
        }
      }
      // Filter out empty strings
      if (Array.isArray(movieData.trailer_urls)) {
        movieData.trailer_urls = movieData.trailer_urls.filter(url => url && url.trim());
      }
    }

    // Parse date fields
    if (movieData.release_date) {
      movieData.release_date = new Date(movieData.release_date);
    }

    // Parse numeric fields - handle empty strings
    if (movieData.vote_average !== undefined) {
      if (movieData.vote_average === '' || movieData.vote_average === null) {
        movieData.vote_average = null;
      } else {
        const parsed = parseFloat(movieData.vote_average);
        movieData.vote_average = isNaN(parsed) ? null : parsed;
      }
    }

    const updated = await prisma.movie.update({ where: { id }, data: movieData });
    const transformedMovie = addImageUrls(req, updated);
    res.json({ success: true, data: transformedMovie });
  } catch (error) {
    console.error('Update movie error:', error);
    
    // Provide more specific error messages
    let errorMessage = 'Failed to update movie';
    if (error.code === 'P2025') {
      errorMessage = 'Movie not found';
    } else if (error.code === 'P2002') {
      errorMessage = 'A movie with this data already exists';
    } else if (error.message) {
      errorMessage = error.message;
    }
    
    res.status(500).json({ success: false, error: errorMessage });
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
