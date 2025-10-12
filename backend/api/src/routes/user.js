const express = require('express');
const { User } = require('../models');
const { auth } = require('../middleware/auth');
const { validate } = require('../middleware/validation');

const router = express.Router();

// All routes require authentication
router.use(auth);

// @route   GET /api/user/profile
// @desc    Get current user profile
// @access  Private
router.get('/profile', async (req, res) => {
  try {
    res.json({
      success: true,
      data: req.user.getPublicProfile()
    });

  } catch (error) {
    console.error('Get profile error:', error);
    res.status(500).json({
      error: 'Failed to get profile',
      details: process.env.NODE_ENV === 'development' ? error.message : 'Internal server error'
    });
  }
});

// @route   PUT /api/user/profile
// @desc    Update user profile
// @access  Private
router.put('/profile', validate('updateProfile'), async (req, res) => {
  try {
    const { profile, preferences } = req.body;
    const updateData = {};

    if (profile) {
      updateData.profile = { ...req.user.profile, ...profile };
    }

    if (preferences) {
      updateData.preferences = { ...req.user.preferences, ...preferences };
    }

    const user = await User.findByIdAndUpdate(
      req.user._id,
      updateData,
      { new: true, runValidators: true }
    ).select('-password');

    res.json({
      message: 'Profile updated successfully',
      data: user.getPublicProfile()
    });

  } catch (error) {
    console.error('Profile update error:', error);
    res.status(500).json({
      error: 'Profile update failed',
      details: process.env.NODE_ENV === 'development' ? error.message : 'Internal server error'
    });
  }
});

// @route   GET /api/user/watch-history
// @desc    Get user's watch history
// @access  Private
router.get('/watch-history', async (req, res) => {
  try {
    const { page = 1, limit = 20, contentType, completed } = req.query;
    
    const skip = (page - 1) * limit;
    
    // Build query
    const query = { userId: req.user._id };
    if (contentType) query.contentType = contentType;
    if (completed !== undefined) query.completed = completed === 'true';
    
    // Get watch history
    const watchHistory = await User.findById(req.user._id)
      .select('watchHistory')
      .slice('watchHistory', [skip, parseInt(limit)])
      .sort({ 'watchHistory.watchedAt': -1 });

    if (!watchHistory) {
      return res.status(404).json({
        error: 'User not found'
      });
    }

    // Get total count
    const total = watchHistory.watchHistory.length;

    res.json({
      success: true,
      data: watchHistory.watchHistory,
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
    console.error('Get watch history error:', error);
    res.status(500).json({
      error: 'Failed to get watch history',
      details: process.env.NODE_ENV === 'development' ? error.message : 'Internal server error'
    });
  }
});

// @route   POST /api/user/watch-history
// @desc    Add or update watch history entry
// @access  Private
router.post('/watch-history', async (req, res) => {
  try {
    const { contentId, contentType, progress, completed } = req.body;
    
    if (!contentId || !contentType) {
      return res.status(400).json({
        error: 'Content ID and content type are required'
      });
    }

    const user = await User.findById(req.user._id);
    if (!user) {
      return res.status(404).json({
        error: 'User not found'
      });
    }

    // Check if entry already exists
    const existingIndex = user.watchHistory.findIndex(
      entry => entry.contentId === contentId && entry.contentType === contentType
    );

    if (existingIndex !== -1) {
      // Update existing entry
      user.watchHistory[existingIndex].progress = progress || 0;
      user.watchHistory[existingIndex].completed = completed || false;
      user.watchHistory[existingIndex].watchedAt = new Date();
    } else {
      // Add new entry
      user.watchHistory.push({
        contentId,
        contentType,
        progress: progress || 0,
        completed: completed || false,
        watchedAt: new Date()
      });
    }

    await user.save();

    res.json({
      message: 'Watch history updated successfully',
      data: user.watchHistory
    });

  } catch (error) {
    console.error('Update watch history error:', error);
    res.status(500).json({
      error: 'Failed to update watch history',
      details: process.env.NODE_ENV === 'development' ? error.message : 'Internal server error'
    });
  }
});

// @route   DELETE /api/user/watch-history/:contentId
// @desc    Remove watch history entry
// @access  Private
router.delete('/watch-history/:contentId', async (req, res) => {
  try {
    const { contentId } = req.params;
    const { contentType } = req.query;
    
    if (!contentType) {
      return res.status(400).json({
        error: 'Content type is required'
      });
    }

    const user = await User.findById(req.user._id);
    if (!user) {
      return res.status(404).json({
        error: 'User not found'
      });
    }

    // Remove entry
    user.watchHistory = user.watchHistory.filter(
      entry => !(entry.contentId === contentId && entry.contentType === contentType)
    );

    await user.save();

    res.json({
      message: 'Watch history entry removed successfully'
    });

  } catch (error) {
    console.error('Remove watch history error:', error);
    res.status(500).json({
      error: 'Failed to remove watch history entry',
      details: process.env.NODE_ENV === 'development' ? error.message : 'Internal server error'
    });
  }
});

// @route   GET /api/user/recommendations
// @desc    Get personalized content recommendations
// @access  Private
router.get('/recommendations', async (req, res) => {
  try {
    const user = await User.findById(req.user._id)
      .populate('watchHistory')
      .populate('preferences');

    if (!user) {
      return res.status(404).json({
        error: 'User not found'
      });
    }

    // Get user's preferred genres
    const preferredGenres = user.preferences?.genres || [];
    
    // Get user's watch history to understand preferences
    const watchedGenres = user.watchHistory.reduce((acc, entry) => {
      // This would need to be enhanced with actual genre data from TMDB
      return acc;
    }, {});

    // For now, return basic recommendations based on preferences
    const recommendations = {
      basedOnGenres: preferredGenres,
      basedOnWatchHistory: Object.keys(watchedGenres),
      suggestedContent: [] // This would be populated with actual TMDB API calls
    };

    res.json({
      success: true,
      data: recommendations
    });

  } catch (error) {
    console.error('Get recommendations error:', error);
    res.status(500).json({
      error: 'Failed to get recommendations',
      details: process.env.NODE_ENV === 'development' ? error.message : 'Internal server error'
    });
  }
});

// @route   GET /api/user/stats
// @desc    Get user statistics
// @access  Private
router.get('/stats', async (req, res) => {
  try {
    const user = await User.findById(req.user._id);
    if (!user) {
      return res.status(404).json({
        error: 'User not found'
      });
    }

    // Calculate statistics
    const totalWatched = user.watchHistory.filter(entry => entry.completed).length;
    const totalInProgress = user.watchHistory.filter(entry => !entry.completed).length;
    const averageProgress = user.watchHistory.length > 0 
      ? user.watchHistory.reduce((sum, entry) => sum + entry.progress, 0) / user.watchHistory.length
      : 0;

    // Get watch history by content type
    const movieHistory = user.watchHistory.filter(entry => entry.contentType === 'movie');
    const tvHistory = user.watchHistory.filter(entry => entry.contentType === 'tv');

    const stats = {
      totalWatched,
      totalInProgress,
      averageProgress: Math.round(averageProgress * 100) / 100,
      byType: {
        movies: {
          total: movieHistory.length,
          completed: movieHistory.filter(entry => entry.completed).length,
          inProgress: movieHistory.filter(entry => !entry.completed).length
        },
        tvShows: {
          total: tvHistory.length,
          completed: tvHistory.filter(entry => entry.completed).length,
          inProgress: tvHistory.filter(entry => !entry.completed).length
        }
      },
      preferences: user.preferences,
      subscription: user.subscription,
      memberSince: user.createdAt,
      lastActive: user.lastLogin
    };

    res.json({
      success: true,
      data: stats
    });

  } catch (error) {
    console.error('Get user stats error:', error);
    res.status(500).json({
      error: 'Failed to get user statistics',
      details: process.env.NODE_ENV === 'development' ? error.message : 'Internal server error'
    });
  }
});

// @route   POST /api/user/avatar
// @desc    Update user avatar
// @access  Private
router.post('/avatar', async (req, res) => {
  try {
    const { avatarUrl } = req.body;
    
    if (!avatarUrl) {
      return res.status(400).json({
        error: 'Avatar URL is required'
      });
    }

    // Basic URL validation
    try {
      new URL(avatarUrl);
    } catch {
      return res.status(400).json({
        error: 'Invalid avatar URL'
      });
    }

    const user = await User.findByIdAndUpdate(
      req.user._id,
      { 'profile.avatar': avatarUrl },
      { new: true, runValidators: true }
    ).select('-password');

    res.json({
      message: 'Avatar updated successfully',
      data: user.getPublicProfile()
    });

  } catch (error) {
    console.error('Update avatar error:', error);
    res.status(500).json({
      error: 'Failed to update avatar',
      details: process.env.NODE_ENV === 'development' ? error.message : 'Internal server error'
    });
  }
});

// @route   DELETE /api/user/account
// @desc    Delete user account
// @access  Private
router.delete('/account', async (req, res) => {
  try {
    const { password } = req.body;
    
    if (!password) {
      return res.status(400).json({
        error: 'Password is required to delete account'
      });
    }

    const user = await User.findById(req.user._id);
    if (!user) {
      return res.status(404).json({
        error: 'User not found'
      });
    }

    // Verify password
    const isMatch = await user.comparePassword(password);
    if (!isMatch) {
      return res.status(401).json({
        error: 'Incorrect password'
      });
    }

    // Delete user account
    await User.findByIdAndDelete(req.user._id);

    res.json({
      message: 'Account deleted successfully'
    });

  } catch (error) {
    console.error('Delete account error:', error);
    res.status(500).json({
      error: 'Failed to delete account',
      details: process.env.NODE_ENV === 'development' ? error.message : 'Internal server error'
    });
  }
});

module.exports = router;
