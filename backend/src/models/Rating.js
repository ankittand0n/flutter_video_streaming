const mongoose = require('mongoose');

const ratingSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  contentId: {
    type: String,
    required: true
  },
  contentType: {
    type: String,
    enum: ['movie', 'tv'],
    required: true
  },
  rating: {
    type: Number,
    required: true,
    min: 1,
    max: 10
  },
  review: {
    type: String,
    maxlength: [1000, 'Review cannot exceed 1000 characters']
  },
  title: {
    type: String,
    maxlength: [100, 'Review title cannot exceed 100 characters']
  },
  helpful: {
    count: {
      type: Number,
      default: 0
    },
    users: [{
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User'
    }]
  },
  spoiler: {
    type: Boolean,
    default: false
  },
  tags: [String],
  createdAt: {
    type: Date,
    default: Date.now
  },
  updatedAt: {
    type: Date,
    default: Date.now
  }
}, {
  timestamps: true
});

// Compound index for unique user-content rating
ratingSchema.index({ userId: 1, contentId: 1, contentType: 1 }, { unique: true });

// Index for better query performance
ratingSchema.index({ contentId: 1, contentType: 1, rating: -1 });
ratingSchema.index({ userId: 1, createdAt: -1 });
ratingSchema.index({ rating: -1, createdAt: -1 });

// Virtual for rating percentage
ratingSchema.virtual('ratingPercentage').get(function() {
  return (this.rating / 10) * 100;
});

// Virtual for rating stars (out of 5)
ratingSchema.virtual('ratingStars').get(function() {
  return (this.rating / 2).toFixed(1);
});

// Method to mark review as helpful
ratingSchema.methods.markAsHelpful = function(userId) {
  if (!this.helpful.users.includes(userId)) {
    this.helpful.users.push(userId);
    this.helpful.count += 1;
    return this.save();
  }
  return Promise.resolve(this);
};

// Method to remove helpful mark
ratingSchema.methods.removeHelpful = function(userId) {
  const index = this.helpful.users.indexOf(userId);
  if (index > -1) {
    this.helpful.users.splice(index, 1);
    this.helpful.count -= 1;
    return this.save();
  }
  return Promise.resolve(this);
};

// Method to update rating
ratingSchema.methods.updateRating = function(newRating, newReview = null, newTitle = null) {
  this.rating = newRating;
  if (newReview !== null) this.review = newReview;
  if (newTitle !== null) this.title = newTitle;
  this.updatedAt = new Date();
  return this.save();
};

// Static method to get content ratings
ratingSchema.statics.getContentRatings = function(contentId, contentType, options = {}) {
  const query = { contentId, contentType };
  
  if (options.rating) {
    query.rating = { $gte: options.rating };
  }
  
  if (options.spoiler !== undefined) {
    query.spoiler = options.spoiler;
  }
  
  return this.find(query)
    .populate('userId', 'username profile.name profile.avatar')
    .sort({ createdAt: -1 })
    .limit(options.limit || 20)
    .skip(options.skip || 0);
};

// Static method to get user's ratings
ratingSchema.statics.getUserRatings = function(userId, options = {}) {
  const query = { userId };
  
  if (options.contentType) {
    query.contentType = options.contentType;
  }
  
  if (options.rating) {
    query.rating = { $gte: options.rating };
  }
  
  return this.find(query)
    .sort({ createdAt: -1 })
    .limit(options.limit || 50)
    .skip(options.skip || 0);
};

// Static method to get average rating for content
ratingSchema.statics.getAverageRating = function(contentId, contentType) {
  return this.aggregate([
    { $match: { contentId, contentType } },
    { $group: { _id: null, avgRating: { $avg: '$rating' }, count: { $sum: 1 } } }
  ]);
};

// Static method to check if user has rated content
ratingSchema.statics.hasUserRated = function(userId, contentId, contentType) {
  return this.exists({ userId, contentId, contentType });
};

// Pre-save middleware to update updatedAt
ratingSchema.pre('save', function(next) {
  this.updatedAt = new Date();
  next();
});

module.exports = mongoose.model('Rating', ratingSchema);
