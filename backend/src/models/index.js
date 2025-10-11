// Re-export model wrappers under original filenames for compatibility
module.exports = {
  User: require('./User.prisma'),
  Watchlist: require('./Watchlist.prisma'),
  Rating: require('./Rating.prisma')
};
