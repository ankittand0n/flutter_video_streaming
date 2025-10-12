const express = require('express');
const Rating = require('../models/Rating');
const { auth, optionalAuth } = require('../middleware/auth');
const { validate, validateQuery } = require('../middleware/validation');

const router = express.Router();

// @route   POST /api/rating
// @desc    Add or update user rating
// @access  Private
router.post('/', auth, validate('rating'), async (req, res) => {
  try {
    const { contentId, contentType } = req.body;
    
    // Check if user already rated this content
    let rating = await Rating.findOne({
      userId: Number(req.user.id),
      contentId,
      contentType
    });

    if (rating) {
      // Update existing rating
      rating = await Rating.findByIdAndUpdate(rating.id, {
        rating: req.body.rating,
        review: req.body.review,
        title: req.body.title,
        updatedAt: new Date()
      });
    } else {
      // Create new rating
      const ratingData = {
        userId: Number(req.user.id),
        ...req.body
      };
      rating = new Rating(ratingData);
      await rating.save();
      rating = await Rating.findById(rating.id);
    }

    res.status(201).json({
      message: rating ? 'Rating updated successfully' : 'Rating added successfully',
      data: rating
    });

  } catch (error) {
    console.error('Add/update rating error:', error);
    res.status(500).json({
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

    // Get ratings
    const ratings = await Rating.find({
      ...where,
      limit: parseInt(limit),
      skip
    });

    // Get total count
    const total = await Rating.countDocuments(where);

    // Get average rating using Prisma's aggregate
    const allRatings = await Rating.find({ contentId, contentType });
    const avgRating = {
      avgRating: allRatings.length > 0 ? allRatings.reduce((acc, r) => acc + r.rating, 0) / allRatings.length : 0,
      count: allRatings.length
    };

    res.json({
      success: true,
      data: {
        ratings,
        averageRating: avgRating.avgRating || 0,
        totalRatings: avgRating.count || 0
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
    console.error('Get content ratings error:', error);
    res.status(500).json({
      error: 'Failed to get content ratings',
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
    const ratings = await Rating.getUserRatings(req.user._id, {
      contentType,
      rating: rating ? parseInt(rating) : undefined,
      limit: parseInt(limit),
      skip
    });

    // Get total count
    const total = await Rating.countDocuments({
      userId: req.user._id,
      ...(contentType && { contentType }),
      ...(rating && { rating: { $gte: parseInt(rating) } })
    });

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
    
    const rating = await Rating.findById(id)
      .populate('userId', 'username profile.name profile.avatar');

    if (!rating) {
      return res.status(404).json({
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
      error: 'Failed to get rating',
      details: process.env.NODE_ENV === 'development' ? error.message : 'Internal server error'
    });
  }
});

// @route   PUT /api/rating/:id
// @desc    Update user's own rating
// @access  Private
router.put('/:id', auth, async (req, res) => {
  try {
    const { id } = req.params;
    const updateData = req.body;
    
    // Remove fields that shouldn't be updated
    delete updateData.userId;
    delete updateData.contentId;
    delete updateData.contentType;
    
    const rating = await Rating.findOneAndUpdate(
      {
        _id: id,
        userId: req.user._id
      },
      updateData,
      { new: true, runValidators: true }
    ).populate('userId', 'username profile.name profile.avatar');

    if (!rating) {
      return res.status(404).json({
        error: 'Rating not found or you are not authorized to update it'
      });
    }

    res.json({
      message: 'Rating updated successfully',
      data: rating
    });

  } catch (error) {
    console.error('Update rating error:', error);
    res.status(500).json({
      error: 'Failed to update rating',
      details: process.env.NODE_ENV === 'development' ? error.message : 'Internal server error'
    });
  }
});

// @route   DELETE /api/rating/:id
// @desc    Delete user's own rating
// @access  Private
router.delete('/:id', auth, async (req, res) => {
  try {
    const { id } = req.params;
    
    const rating = await Rating.findOneAndDelete({
      _id: id,
      userId: req.user._id
    });

    if (!rating) {
      return res.status(404).json({
        error: 'Rating not found or you are not authorized to delete it'
      });
    }

    res.json({
      message: 'Rating deleted successfully'
    });

  } catch (error) {
    console.error('Delete rating error:', error);
    res.status(500).json({
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
    
    const rating = await Rating.findById(id);
    if (!rating) {
      return res.status(404).json({
        error: 'Rating not found'
      });
    }

    // Check if user already marked this as helpful
    if (rating.helpful.users.includes(req.user._id)) {
      return res.status(400).json({
        error: 'You have already marked this rating as helpful'
      });
    }

    await rating.markAsHelpful(req.user._id);

    res.json({
      message: 'Rating marked as helpful successfully',
      data: rating
    });

  } catch (error) {
    console.error('Mark helpful error:', error);
    res.status(500).json({
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
    
    const rating = await Rating.findById(id);
    if (!rating) {
      return res.status(404).json({
        error: 'Rating not found'
      });
    }

    await rating.removeHelpful(req.user._id);

    res.json({
      message: 'Helpful mark removed successfully',
      data: rating
    });

  } catch (error) {
    console.error('Remove helpful error:', error);
    res.status(500).json({
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
    const userId = req.user._id;
    
    // Get total ratings
    const totalRatings = await Rating.countDocuments({ userId });
    
    // Get ratings by content type
    const movieRatings = await Rating.countDocuments({ userId, contentType: 'movie' });
    const tvRatings = await Rating.countDocuments({ userId, contentType: 'tv' });
    
    // Get average rating
    const avgRatingResult = await Rating.aggregate([
      { $match: { userId } },
      { $group: { _id: null, avgRating: { $avg: '$rating' } } }
    ]);
    const avgRating = avgRatingResult.length > 0 ? avgRatingResult[0].avgRating : 0;
    
    // Get rating distribution
    const ratingDistribution = await Rating.aggregate([
      { $match: { userId } },
      { $group: { _id: '$rating', count: { $sum: 1 } } },
      { $sort: { _id: 1 } }
    ]);
    
    // Get recent ratings
    const recentRatings = await Rating.find({ userId })
      .sort({ createdAt: -1 })
      .limit(5)
      .select('contentId contentType rating title createdAt');
    
    res.json({
      success: true,
      data: {
        totalRatings,
        averageRating: Math.round(avgRating * 10) / 10,
        byType: {
          movies: movieRatings,
          tvShows: tvRatings
        },
        ratingDistribution,
        recentRatings
      }
    });

  } catch (error) {
    console.error('Get user rating stats error:', error);
    res.status(500).json({
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
        error: 'Content type is required'
      });
    }

    // Get average rating and total count
    const avgRatingResult = await Rating.getAverageRating(contentId, contentType);
    const avgRating = avgRatingResult.length > 0 ? avgRatingResult[0] : { avgRating: 0, count: 0 };
    
    // Get rating distribution
    const ratingDistribution = await Rating.aggregate([
      { $match: { contentId, contentType } },
      { $group: { _id: '$rating', count: { $sum: 1 } } },
      { $sort: { _id: 1 } }
    ]);
    
    // Get recent ratings
    const recentRatings = await Rating.find({ contentId, contentType })
      .sort({ createdAt: -1 })
      .limit(5)
      .populate('userId', 'username profile.name profile.avatar')
      .select('rating review title createdAt userId');
    
    res.json({
      success: true,
      data: {
        averageRating: Math.round(avgRating.avgRating * 10) / 10,
        totalRatings: avgRating.count,
        ratingDistribution,
        recentRatings
      }
    });

  } catch (error) {
    console.error('Get content rating stats error:', error);
    res.status(500).json({
      error: 'Failed to get content rating statistics',
      details: process.env.NODE_ENV === 'development' ? error.message : 'Internal server error'
    });
  }
});

module.exports = router;
