const prisma = require('../prisma/client');

class RatingModel {
  constructor(data) {
    Object.assign(this, data);
  }

  async save() {
    if (this.id) {
      const updated = await prisma.rating.update({ where: { id: this.id }, data: { ...this } });
      Object.assign(this, updated);
      return this;
    }
    const created = await prisma.rating.create({ data: { ...this } });
    Object.assign(this, created);
    return this;
  }

  static async find(query) {
    const where = {};
    if (query.contentId) where.contentId = query.contentId;
    if (query.contentType) where.contentType = query.contentType;
    if (query.userId) where.userId = Number(query.userId);

    const items = await prisma.rating.findMany({ where, orderBy: { createdAt: 'desc' }, take: query.limit ? Number(query.limit) : undefined, skip: query.skip ? Number(query.skip) : undefined });
    return items.map(i => new RatingModel(i));
  }

  static async findById(id) {
    const r = await prisma.rating.findUnique({ where: { id: Number(id) } });
    return r ? new RatingModel(r) : null;
  }

  static async findOne(query) {
    const where = {};
    if (query.userId) where.userId = Number(query.userId);
    if (query.contentId) where.contentId = query.contentId;
    if (query.contentType) where.contentType = query.contentType;

    const item = await prisma.rating.findFirst({ where });
    return item ? new RatingModel(item) : null;
  }

  static async countDocuments(query) {
    const where = {};
    if (query.userId) where.userId = Number(query.userId);
    if (query.contentId) where.contentId = query.contentId;
    if (query.contentType) where.contentType = query.contentType;
    return await prisma.rating.count({ where });
  }

  static async findByIdAndUpdate(id, data, opts = {}) {
    const updated = await prisma.rating.update({ where: { id: Number(id) }, data });
    return new RatingModel(updated);
  }

  static async findByIdAndDelete(id) {
    const deleted = await prisma.rating.delete({ where: { id: Number(id) } });
    return deleted ? new RatingModel(deleted) : null;
  }
}

module.exports = RatingModel;
