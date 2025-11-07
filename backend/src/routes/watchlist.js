const express = require('express');
const { Watchlist } = require('../models');
const { auth } = require('../middleware/auth');
const { validate, validateQuery } = require('../middleware/validation');
const prisma = require('../prisma/client');

const router = express.Router();

// All routes require authentication
router.use(auth);

// @route   POST /api/watchlist
// @desc    Add item to watchlist
// @access  Private
router.post('/', validate('watchlistItem'), async (req, res) => {
  try {
    const { media_id, media_type } = req.body;
    
    // Check if item already exists in user's watchlist
    const existingItem = await Watchlist.findOne({
      user_id: req.user.id,
      media_id,
      media_type
    });

    if (existingItem) {
      return res.status(400).json({
        error: 'Item already exists in watchlist'
      });
    }

    // Create new watchlist item - only include fields that exist in schema
    const watchlistItem = new Watchlist({
      user_id: req.user.id,
      media_id: req.body.media_id,
      media_type: req.body.media_type,
      title: req.body.title,
      posterPath: req.body.posterPath // Will be mapped to posterpath in save()
    });

    await watchlistItem.save();

    res.status(201).json({
      message: 'Item added to watchlist successfully',
      data: watchlistItem
    });

  } catch (error) {
    console.error('Add to watchlist error:', error);
    res.status(500).json({
      error: 'Failed to add item to watchlist',
      details: process.env.NODE_ENV === 'development' ? error.message : 'Internal server error'
    });
  }
});

// @route   GET /api/watchlist
// @desc    Get user's watchlist
// @access  Private
router.get('/', validateQuery('pagination'), async (req, res) => {
  try {
    const { page = 1, limit = 20, watched, priority, media_type, sortBy = 'created_at', sortOrder = 'desc' } = req.query;
    
    const skip = (page - 1) * limit;
    
    // Build query
    const query = { user_id: req.user.id };
    if (watched !== undefined) query.watched = watched === 'true';
    if (priority) query.priority = priority;
    if (media_type) query.media_type = media_type;
    
    // Map sortBy to actual field names
    const sortFieldMap = {
      'addedAt': 'created_at',
      'created_at': 'created_at',
      'title': 'title',
      'media_type': 'media_type'
    };
    const actualSortField = sortFieldMap[sortBy] || 'created_at';
    
    // Get watchlist items with pagination and sorting
    query.limit = Number(limit);
    query.skip = Number(skip);
    const watchlistItems = await Watchlist.find(query);
    
    // Get total count
    const countQuery = { user_id: req.user.id };
    if (watched !== undefined) countQuery.watched = watched === 'true';
    if (priority) countQuery.priority = priority;
    if (media_type) countQuery.media_type = media_type;
    const total = await Watchlist.countDocuments(countQuery);
    
    res.json({
      success: true,
      data: watchlistItems,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total,
        totalPages: Math.ceil(total / limit),
        hasNext: page * limit < total,
        hasPrev: page > 1
      }
    });

  } catch (error) {
    console.error('Get watchlist error:', error);
    res.status(500).json({
      error: 'Failed to get watchlist',
      details: process.env.NODE_ENV === 'development' ? error.message : 'Internal server error'
    });
  }
});

// @route   GET /api/watchlist/stats
// @desc    Get watchlist statistics
// @access  Private
router.get('/stats', async (req, res) => {
  try {
    const user_id = req.user.id;
    
    // Get total counts
    const total = await Watchlist.countDocuments({ user_id });
    const watched = await Watchlist.countDocuments({ user_id, watched: true });
    const unwatched = await Watchlist.countDocuments({ user_id, watched: false });
    
    // Get counts by content type
    const movies = await Watchlist.countDocuments({ user_id, media_type: 'movie' });
    const tvShows = await Watchlist.countDocuments({ user_id, media_type: 'tv' });
    
    // Get counts by priority
    const highPriority = await Watchlist.countDocuments({ user_id, priority: 'high' });
    const mediumPriority = await Watchlist.countDocuments({ user_id, priority: 'medium' });
    const lowPriority = await Watchlist.countDocuments({ user_id, priority: 'low' });
    
    // Get recent additions (using Prisma directly)
    const recentAdditions = await prisma.watchlist.findMany({
      where: { user_id },
      orderBy: { created_at: 'desc' },
      take: 5,
      select: {
        id: true,
        title: true,
        media_type: true,
        created_at: true
      }
    });
    
    res.json({
      success: true,
      data: {
        total,
        watched,
        unwatched,
        byType: {
          movies,
          tvShows
        },
        byPriority: {
          high: highPriority,
          medium: mediumPriority,
          low: lowPriority
        },
        recentAdditions
      }
    });

  } catch (error) {
    console.error('Get watchlist stats error:', error);
    res.status(500).json({
      error: 'Failed to get watchlist statistics',
      details: process.env.NODE_ENV === 'development' ? error.message : 'Internal server error'
    });
  }
});

// @route   GET /api/watchlist/:id
// @desc    Get specific watchlist item
// @access  Private
router.get('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    
    const watchlistItem = await Watchlist.findOne({
      _id: id,
      user_id: req.user.id
    });

    if (!watchlistItem) {
      return res.status(404).json({
        error: 'Watchlist item not found'
      });
    }

    res.json({
      success: true,
      data: watchlistItem
    });

  } catch (error) {
    console.error('Get watchlist item error:', error);
    res.status(500).json({
      error: 'Failed to get watchlist item',
      details: process.env.NODE_ENV === 'development' ? error.message : 'Internal server error'
    });
  }
});

// @route   PUT /api/watchlist/:id
// @desc    Update watchlist item
// @access  Private
router.put('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const updateData = req.body;
    
    // Remove fields that shouldn't be updated
    delete updateData.user_id;
    delete updateData.media_id;
    delete updateData.media_type;
    
    const watchlistItem = await Watchlist.findOneAndUpdate(
      {
        _id: id,
        user_id: req.user.id
      },
      updateData,
      { new: true, runValidators: true }
    );

    if (!watchlistItem) {
      return res.status(404).json({
        error: 'Watchlist item not found'
      });
    }

    res.json({
      message: 'Watchlist item updated successfully',
      data: watchlistItem
    });

  } catch (error) {
    console.error('Update watchlist item error:', error);
    res.status(500).json({
      error: 'Failed to update watchlist item',
      details: process.env.NODE_ENV === 'development' ? error.message : 'Internal server error'
    });
  }
});

// @route   DELETE /api/watchlist/:id
// @desc    Remove item from watchlist
// @access  Private
router.delete('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    
    const watchlistItem = await Watchlist.findOneAndDelete({
      _id: id,
      user_id: req.user.id
    });

    if (!watchlistItem) {
      return res.status(404).json({
        error: 'Watchlist item not found'
      });
    }

    res.json({
      message: 'Item removed from watchlist successfully'
    });

  } catch (error) {
    console.error('Remove from watchlist error:', error);
    res.status(500).json({
      error: 'Failed to remove item from watchlist',
      details: process.env.NODE_ENV === 'development' ? error.message : 'Internal server error'
    });
  }
});

// @route   POST /api/watchlist/:id/watch
// @desc    Mark item as watched
// @access  Private
router.post('/:id/watch', async (req, res) => {
  try {
    const { id } = req.params;
    
    const watchlistItem = await Watchlist.findOne({
      _id: id,
      user_id: req.user.id
    });

    if (!watchlistItem) {
      return res.status(404).json({
        error: 'Watchlist item not found'
      });
    }

    await watchlistItem.markAsWatched();

    res.json({
      message: 'Item marked as watched successfully',
      data: watchlistItem
    });

  } catch (error) {
    console.error('Mark as watched error:', error);
    res.status(500).json({
      error: 'Failed to mark item as watched',
      details: process.env.NODE_ENV === 'development' ? error.message : 'Internal server error'
    });
  }
});

// @route   POST /api/watchlist/:id/unwatch
// @desc    Mark item as unwatched
// @access  Private
router.post('/:id/unwatch', async (req, res) => {
  try {
    const { id } = req.params;
    
    const watchlistItem = await Watchlist.findOne({
      _id: id,
      user_id: req.user.id
    });

    if (!watchlistItem) {
      return res.status(404).json({
        error: 'Watchlist item not found'
      });
    }

    await watchlistItem.markAsUnwatched();

    res.json({
      message: 'Item marked as unwatched successfully',
      data: watchlistItem
    });

  } catch (error) {
    console.error('Mark as unwatched error:', error);
    res.status(500).json({
      error: 'Failed to mark item as unwatched',
      details: process.env.NODE_ENV === 'development' ? error.message : 'Internal server error'
    });
  }
});

// @route   POST /api/watchlist/bulk
// @desc    Add multiple items to watchlist
// @access  Private
router.post('/bulk', async (req, res) => {
  try {
    const { items } = req.body;
    
    if (!Array.isArray(items) || items.length === 0) {
      return res.status(400).json({
        error: 'Items array is required and must not be empty'
      });
    }

    const results = [];
    const errors = [];

    for (const item of items) {
      try {
        // Check if item already exists
        const existingItem = await Watchlist.findOne({
          user_id: req.user.id,
          media_id: item.media_id,
          media_type: item.media_type
        });

        if (existingItem) {
          errors.push({
            media_id: item.media_id,
            media_type: item.media_type,
            error: 'Item already exists in watchlist'
          });
          continue;
        }

        // Create new watchlist item
        const watchlistItem = new Watchlist({
          user_id: req.user.id,
          ...item
        });

        await watchlistItem.save();
        results.push(watchlistItem);

      } catch (error) {
        errors.push({
          media_id: item.media_id,
          media_type: item.media_type,
          error: error.message
        });
      }
    }

    res.status(200).json({
      message: 'Bulk operation completed',
      data: {
        added: results.length,
        failed: errors.length,
        results,
        errors
      }
    });

  } catch (error) {
    console.error('Bulk add to watchlist error:', error);
    res.status(500).json({
      error: 'Failed to perform bulk operation',
      details: process.env.NODE_ENV === 'development' ? error.message : 'Internal server error'
    });
  }
});

module.exports = router;
