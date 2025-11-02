const prisma = require('../prisma/client');

class WatchlistModel {
  constructor(data) {
    Object.assign(this, data);
  }

  async save() {
    // Map camelCase to snake_case for Prisma
    const data = {
      userid: Number(this.userid),
      contenttype: this.contenttype,
      contentid: this.contentid,
      title: this.title,
      posterpath: this.posterPath || this.posterpath || null
    };

    if (this.id) {
      const updated = await prisma.watchlist.update({ where: { id: this.id }, data });
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
    if (query.userid) where.userid = Number(query.userid);
    if (query.contentid) where.contentid = query.contentid;
    if (query.contenttype) where.contenttype = query.contenttype;

    const item = await prisma.watchlist.findFirst({ where });
    return item ? new WatchlistModel(item) : null;
  }

  static async find(query) {
    const where = {};
    if (query.userid) where.userid = Number(query.userid);
    if (query.watched !== undefined) where.watched = query.watched;
    if (query.priority) where.priority = query.priority;
    if (query.contenttype) where.contenttype = query.contenttype;

    const items = await prisma.watchlist.findMany({ where, orderBy: { addedAt: 'desc' }, take: query.limit ? Number(query.limit) : undefined, skip: query.skip ? Number(query.skip) : undefined });
    return items.map(i => new WatchlistModel(i));
  }

  static async countDocuments(query) {
    const where = {};
    if (query.userid) where.userid = Number(query.userid);
    if (query.watched !== undefined) where.watched = query.watched;
    if (query.priority) where.priority = query.priority;
    if (query.contenttype) where.contenttype = query.contenttype;
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
