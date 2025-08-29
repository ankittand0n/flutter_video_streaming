const mongoose = require('mongoose');

const watchlistSchema = new mongoose.Schema({
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
  title: {
    type: String,
    required: true
  },
  overview: String,
  posterPath: String,
  backdropPath: String,
  releaseDate: Date,
  voteAverage: Number,
  genreIds: [Number],
  addedAt: {
    type: Date,
    default: Date.now
  },
  priority: {
    type: String,
    enum: ['low', 'medium', 'high'],
    default: 'medium'
  },
  notes: String,
  watched: {
    type: Boolean,
    default: false
  },
  watchedAt: Date,
  rating: {
    type: Number,
    min: 1,
    max: 10
  },
  tags: [String]
}, {
  timestamps: true
});

// Compound index for unique user-content combination
watchlistSchema.index({ userId: 1, contentId: 1, contentType: 1 }, { unique: true });

// Index for better query performance
watchlistSchema.index({ userId: 1, addedAt: -1 });
watchlistSchema.index({ userId: 1, priority: 1 });
watchlistSchema.index({ userId: 1, watched: 1 });

// Virtual for content age
watchlistSchema.virtual('contentAge').get(function() {
  if (!this.releaseDate) return null;
  const now = new Date();
  const diffTime = Math.abs(now - this.releaseDate);
  const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
  return diffDays;
});

// Method to mark as watched
watchlistSchema.methods.markAsWatched = function(rating = null) {
  this.watched = true;
  this.watchedAt = new Date();
  if (rating) {
    this.rating = rating;
  }
  return this.save();
};

// Method to mark as unwatched
watchlistSchema.methods.markAsUnwatched = function() {
  this.watched = false;
  this.watchedAt = undefined;
  this.rating = undefined;
  return this.save();
};

// Static method to get user's watchlist
watchlistSchema.statics.getUserWatchlist = function(userId, options = {}) {
  const query = { userId };
  
  if (options.watched !== undefined) {
    query.watched = options.watched;
  }
  
  if (options.priority) {
    query.priority = options.priority;
  }
  
  if (options.contentType) {
    query.contentType = options.contentType;
  }
  
  return this.find(query)
    .sort({ addedAt: -1 })
    .limit(options.limit || 50)
    .skip(options.skip || 0);
};

// Static method to check if content is in user's watchlist
watchlistSchema.statics.isInWatchlist = function(userId, contentId, contentType) {
  return this.exists({ userId, contentId, contentType });
};

module.exports = mongoose.model('Watchlist', watchlistSchema);
