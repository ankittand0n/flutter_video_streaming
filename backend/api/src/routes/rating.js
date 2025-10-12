const express = require('express');
const prisma = require('../prisma/client');
const { auth, optionalAuth } = require('../middleware/auth');
const { validate, validateQuery } = require('../middleware/validation');

const router = express.Router();

// @route   POST /api/rating
// @desc    Add or update user rating
// @access  Private (Users only, not admin)
router.post('/', auth, validate('rating'), async (req, res) => {
  try {
    // Check if user is admin - admins cannot rate content
    const user = await prisma.user.findUnique({
      where: { id: Number(req.user.id) }
    });

    if (!user || user.username === 'admin') {
      return res.status(403).json({
        error: 'Admins cannot rate content'
      });
    }

    const { contentId, contentType } = req.body;

    // Check if user already rated this content
    let existingRating = await prisma.rating.findFirst({
      where: {
        userId: Number(req.user.id),
        contentId,
        contentType
      }
    });

    let rating;
    if (existingRating) {
      // Update existing rating
      rating = await prisma.rating.update({
        where: { id: existingRating.id },
        data: {
          rating: req.body.rating,
          review: req.body.review,
          title: req.body.title,
          spoiler: req.body.spoiler || false,
          tags: req.body.tags,
          helpful: req.body.helpful,
          updatedAt: new Date()
        }
      });
    } else {
      // Create new rating
      rating = await prisma.rating.create({
        data: {
          userId: Number(req.user.id),
          contentId,
          contentType,
          rating: req.body.rating,
          review: req.body.review,
          title: req.body.title,
          spoiler: req.body.spoiler || false,
          tags: req.body.tags,
          helpful: req.body.helpful
        }
      });
    }

    res.status(201).json({
      success: true,
      message: existingRating ? 'Rating updated successfully' : 'Rating added successfully',
      data: rating
    });

  } catch (error) {
    console.error('Add/update rating error:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to add/update rating',
      details: process.env.NODE_ENV === 'development' ? error.message : 'Internal server error'
    });
  }
});

// @route   GET /api/rating/content/:contentId
// @desc    Get ratings for specific content
// @access  Public
router.get('/content/:contentId', validateQuery('pagination'), async (req, res) => {
  try {
    const { contentId } = req.params;
    const { contentType, page = 1, limit = 20, rating, spoiler } = req.query;

    if (!contentType) {
      return res.status(400).json({
        success: false,
        error: 'Content type is required'
      });
    }

    const skip = (page - 1) * limit;

    // Get ratings with query conditions
    const where = {
      contentId,
      contentType,
      ...(rating && { rating: { gte: parseInt(rating) } }),
      ...(spoiler !== undefined && { spoiler: spoiler === 'true' })
    };

    // Get ratings with user information
    const ratings = await prisma.rating.findMany({
      where,
      take: parseInt(limit),
      skip,
      include: {
        user: {
          select: {
            id: true,
            username: true,
            profileName: true,
            profileAvatar: true
          }
        }
      },
      orderBy: { createdAt: 'desc' }
    });

    // Get total count
    const total = await prisma.rating.count({ where });

    // Get average rating using Prisma's aggregate
    const avgResult = await prisma.rating.aggregate({
      where: { contentId, contentType },
      _avg: { rating: true },
      _count: true
    });

    res.json({
      success: true,
      data: {
        ratings,
        averageRating: avgResult._avg.rating || 0,
        totalRatings: avgResult._count
      },
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
    console.error('Get ratings error:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch ratings',
      details: process.env.NODE_ENV === 'development' ? error.message : 'Internal server error'
    });
  }
});

// @route   GET /api/rating/user
// @desc    Get current user's ratings
// @access  Private
router.get('/user', auth, validateQuery('pagination'), async (req, res) => {
  try {
    const { page = 1, limit = 20, contentType, rating } = req.query;

    const skip = (page - 1) * limit;

    // Get user's ratings
    const where = {
      userId: Number(req.user.id),
      ...(contentType && { contentType }),
      ...(rating && { rating: { gte: parseInt(rating) } })
    };

    const ratings = await prisma.rating.findMany({
      where,
      take: parseInt(limit),
      skip,
      include: {
        user: {
          select: {
            id: true,
            username: true,
            profileName: true,
            profileAvatar: true
          }
        }
      },
      orderBy: { createdAt: 'desc' }
    });

    // Get total count
    const total = await prisma.rating.count({ where });

    res.json({
      success: true,
      data: ratings,
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
    console.error('Get user ratings error:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to get user ratings',
      details: process.env.NODE_ENV === 'development' ? error.message : 'Internal server error'
    });
  }
});

// @route   GET /api/rating/:id
// @desc    Get specific rating
// @access  Public
router.get('/:id', async (req, res) => {
  try {
    const { id } = req.params;

    const rating = await prisma.rating.findUnique({
      where: { id: parseInt(id) },
      include: {
        user: {
          select: {
            id: true,
            username: true,
            profileName: true,
            profileAvatar: true
          }
        }
      }
    });

    if (!rating) {
      return res.status(404).json({
        success: false,
        error: 'Rating not found'
      });
    }

    res.json({
      success: true,
      data: rating
    });

  } catch (error) {
    console.error('Get rating error:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to get rating',
      details: process.env.NODE_ENV === 'development' ? error.message : 'Internal server error'
    });
  }
});

// @route   PUT /api/rating/:id
// @desc    Update user's own rating
// @access  Private (Users only, not admin)
router.put('/:id', auth, async (req, res) => {
  try {
    // Check if user is admin - admins cannot modify ratings
    const user = await prisma.user.findUnique({
      where: { id: Number(req.user.id) }
    });

    if (!user || user.username === 'admin') {
      return res.status(403).json({
        success: false,
        error: 'Admins cannot modify ratings'
      });
    }

    const { id } = req.params;
    const updateData = req.body;

    // Remove fields that shouldn't be updated
    delete updateData.userId;
    delete updateData.contentId;
    delete updateData.contentType;

    const rating = await prisma.rating.updateMany({
      where: {
        id: parseInt(id),
        userId: Number(req.user.id)
      },
      data: {
        ...updateData,
        updatedAt: new Date()
      }
    });

    if (rating.count === 0) {
      return res.status(404).json({
        success: false,
        error: 'Rating not found or you are not authorized to update it'
      });
    }

    // Get the updated rating
    const updatedRating = await prisma.rating.findUnique({
      where: { id: parseInt(id) },
      include: {
        user: {
          select: {
            id: true,
            username: true,
            profileName: true,
            profileAvatar: true
          }
        }
      }
    });

    res.json({
      success: true,
      message: 'Rating updated successfully',
      data: updatedRating
    });

  } catch (error) {
    console.error('Update rating error:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to update rating',
      details: process.env.NODE_ENV === 'development' ? error.message : 'Internal server error'
    });
  }
});

// @route   DELETE /api/rating/:id
// @desc    Delete user's own rating
// @access  Private (Users only, not admin)
router.delete('/:id', auth, async (req, res) => {
  try {
    // Check if user is admin - admins cannot delete ratings
    const user = await prisma.user.findUnique({
      where: { id: Number(req.user.id) }
    });

    if (!user || user.username === 'admin') {
      return res.status(403).json({
        success: false,
        error: 'Admins cannot delete ratings'
      });
    }

    const { id } = req.params;

    const rating = await prisma.rating.deleteMany({
      where: {
        id: parseInt(id),
        userId: Number(req.user.id)
      }
    });

    if (rating.count === 0) {
      return res.status(404).json({
        success: false,
        error: 'Rating not found or you are not authorized to delete it'
      });
    }

    res.json({
      success: true,
      message: 'Rating deleted successfully'
    });

  } catch (error) {
    console.error('Delete rating error:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to delete rating',
      details: process.env.NODE_ENV === 'development' ? error.message : 'Internal server error'
    });
  }
});

// @route   POST /api/rating/:id/helpful
// @desc    Mark rating as helpful
// @access  Private
router.post('/:id/helpful', auth, async (req, res) => {
  try {
    const { id } = req.params;

    const rating = await prisma.rating.findUnique({
      where: { id: parseInt(id) }
    });

    if (!rating) {
      return res.status(404).json({
        success: false,
        error: 'Rating not found'
      });
    }

    // Check current helpful field and update it
    const currentHelpful = rating.helpful ? JSON.parse(rating.helpful) : [];
    if (currentHelpful.includes(req.user.id)) {
      return res.status(400).json({
        success: false,
        error: 'You have already marked this rating as helpful'
      });
    }

    currentHelpful.push(req.user.id);

    const updatedRating = await prisma.rating.update({
      where: { id: parseInt(id) },
      data: {
        helpful: JSON.stringify(currentHelpful)
      },
      include: {
        user: {
          select: {
            id: true,
            username: true,
            profileName: true,
            profileAvatar: true
          }
        }
      }
    });

    res.json({
      success: true,
      message: 'Rating marked as helpful successfully',
      data: updatedRating
    });

  } catch (error) {
    console.error('Mark helpful error:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to mark rating as helpful',
      details: process.env.NODE_ENV === 'development' ? error.message : 'Internal server error'
    });
  }
});

// @route   DELETE /api/rating/:id/helpful
// @desc    Remove helpful mark from rating
// @access  Private
router.delete('/:id/helpful', auth, async (req, res) => {
  try {
    const { id } = req.params;

    const rating = await prisma.rating.findUnique({
      where: { id: parseInt(id) }
    });

    if (!rating) {
      return res.status(404).json({
        success: false,
        error: 'Rating not found'
      });
    }

    // Remove user from helpful list
    const currentHelpful = rating.helpful ? JSON.parse(rating.helpful) : [];
    const updatedHelpful = currentHelpful.filter(userId => userId !== req.user.id);

    const updatedRating = await prisma.rating.update({
      where: { id: parseInt(id) },
      data: {
        helpful: JSON.stringify(updatedHelpful)
      },
      include: {
        user: {
          select: {
            id: true,
            username: true,
            profileName: true,
            profileAvatar: true
          }
        }
      }
    });

    res.json({
      success: true,
      message: 'Helpful mark removed successfully',
      data: updatedRating
    });

  } catch (error) {
    console.error('Remove helpful error:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to remove helpful mark',
      details: process.env.NODE_ENV === 'development' ? error.message : 'Internal server error'
    });
  }
});

// @route   GET /api/rating/stats/user
// @desc    Get current user's rating statistics
// @access  Private
router.get('/stats/user', auth, async (req, res) => {
  try {
    const userId = Number(req.user.id);

    // Get total ratings
    const totalRatings = await prisma.rating.count({
      where: { userId }
    });

    // Get ratings by content type
    const movieRatings = await prisma.rating.count({
      where: { userId, contentType: 'movie' }
    });
    const tvRatings = await prisma.rating.count({
      where: { userId, contentType: 'tv' }
    });

    // Get average rating
    const avgResult = await prisma.rating.aggregate({
      where: { userId },
      _avg: { rating: true }
    });

    // Get rating distribution
    const ratingDistribution = await prisma.rating.groupBy({
      by: ['rating'],
      where: { userId },
      _count: { rating: true },
      orderBy: { rating: 'asc' }
    });

    // Get recent ratings
    const recentRatings = await prisma.rating.findMany({
      where: { userId },
      take: 5,
      orderBy: { createdAt: 'desc' },
      select: {
        contentId: true,
        contentType: true,
        rating: true,
        title: true,
        createdAt: true
      }
    });

    res.json({
      success: true,
      data: {
        totalRatings,
        averageRating: Math.round((avgResult._avg.rating || 0) * 10) / 10,
        byType: {
          movies: movieRatings,
          tvShows: tvRatings
        },
        ratingDistribution: ratingDistribution.map(item => ({
          rating: item.rating,
          count: item._count.rating
        })),
        recentRatings
      }
    });

  } catch (error) {
    console.error('Get user rating stats error:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to get user rating statistics',
      details: process.env.NODE_ENV === 'development' ? error.message : 'Internal server error'
    });
  }
});

// @route   GET /api/rating/stats/content/:contentId
// @desc    Get rating statistics for specific content
// @access  Public
router.get('/stats/content/:contentId', async (req, res) => {
  try {
    const { contentId } = req.params;
    const { contentType } = req.query;

    if (!contentType) {
      return res.status(400).json({
        success: false,
        error: 'Content type is required'
      });
    }

    // Get average rating and total count
    const avgResult = await prisma.rating.aggregate({
      where: { contentId, contentType },
      _avg: { rating: true },
      _count: true
    });

    // Get rating distribution
    const ratingDistribution = await prisma.rating.groupBy({
      by: ['rating'],
      where: { contentId, contentType },
      _count: { rating: true },
      orderBy: { rating: 'asc' }
    });

    // Get recent ratings
    const recentRatings = await prisma.rating.findMany({
      where: { contentId, contentType },
      take: 5,
      orderBy: { createdAt: 'desc' },
      include: {
        user: {
          select: {
            id: true,
            username: true,
            profileName: true,
            profileAvatar: true
          }
        }
      },
      select: {
        rating: true,
        review: true,
        title: true,
        createdAt: true,
        user: true
      }
    });

    res.json({
      success: true,
      data: {
        averageRating: Math.round((avgResult._avg.rating || 0) * 10) / 10,
        totalRatings: avgResult._count,
        ratingDistribution: ratingDistribution.map(item => ({
          rating: item.rating,
          count: item._count.rating
        })),
        recentRatings
      }
    });

  } catch (error) {
    console.error('Get content rating stats error:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to get content rating statistics',
      details: process.env.NODE_ENV === 'development' ? error.message : 'Internal server error'
    });
  }
});

module.exports = router;
