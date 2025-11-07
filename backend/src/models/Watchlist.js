const prisma = require('../prisma/client');

class WatchlistModel {
  constructor(data) {
    Object.assign(this, data);
  }

  async save() {
    // Map to Prisma schema field names
    const data = {
      media_type: this.media_type,
      media_id: this.media_id,
      title: this.title,
      poster_path: this.posterPath || this.poster_path || null,
      user: {
        connect: {
          id: Number(this.user_id)
        }
      }
    };

    if (this.id) {
      // For updates, don't include the user relation
      const updateData = { ...data };
      delete updateData.user;
      const updated = await prisma.watchlist.update({ where: { id: this.id }, data: updateData });
      Object.assign(this, updated);
      return this;
    }
    const created = await prisma.watchlist.create({ data });
    Object.assign(this, created);
    return this;
  }

  async markAsWatched(rating = null) {
    this.watched = true;
    this.watchedAt = new Date();
    if (rating) this.rating = rating;
    await prisma.watchlist.update({ where: { id: this.id }, data: { watched: this.watched, watchedAt: this.watchedAt, rating: this.rating } });
    return this;
  }

  async markAsUnwatched() {
    this.watched = false;
    this.watchedAt = null;
    this.rating = null;
    await prisma.watchlist.update({ where: { id: this.id }, data: { watched: this.watched, watchedAt: this.watchedAt, rating: this.rating } });
    return this;
  }

  static async findOne(query) {
    const where = {};
    if (query._id || query.id) where.id = Number(query._id || query.id);
    if (query.user_id) where.user_id = Number(query.user_id);
    if (query.media_id) where.media_id = query.media_id;
    if (query.media_type) where.media_type = query.media_type;

    const item = await prisma.watchlist.findFirst({ where });
    return item ? new WatchlistModel(item) : null;
  }

  static async find(query) {
    const where = {};
    if (query.user_id) where.user_id = Number(query.user_id);
    if (query.watched !== undefined) where.watched = query.watched;
    if (query.priority) where.priority = query.priority;
    if (query.media_type) where.media_type = query.media_type;

    const items = await prisma.watchlist.findMany({ 
      where, 
      orderBy: { created_at: 'desc' }, 
      take: query.limit ? Number(query.limit) : undefined, 
      skip: query.skip ? Number(query.skip) : undefined 
    });
    return items.map(i => new WatchlistModel(i));
  }

  static async countDocuments(query) {
    const where = {};
    if (query.user_id) where.user_id = Number(query.user_id);
    if (query.watched !== undefined) where.watched = query.watched;
    if (query.priority) where.priority = query.priority;
    if (query.media_type) where.media_type = query.media_type;
    return await prisma.watchlist.count({ where });
  }

  static async findByIdAndUpdate(id, data, opts = {}) {
    const updated = await prisma.watchlist.update({ where: { id: Number(id) }, data });
    return new WatchlistModel(updated);
  }

  static async findOneAndUpdate(query, data, opts = {}) {
    const item = await WatchlistModel.findOne(query);
    if (!item) return null;
    const updated = await prisma.watchlist.update({ where: { id: Number(item.id) }, data });
    return new WatchlistModel(updated);
  }

  static async findOneAndDelete(query) {
    const item = await WatchlistModel.findOne(query);
    if (!item) return null;
    const deleted = await prisma.watchlist.delete({ where: { id: Number(item.id) } });
    return new WatchlistModel(deleted);
  }
}

module.exports = WatchlistModel;
