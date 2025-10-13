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
    if (query.contentid) where.contentid = query.contentid;
    if (query.contenttype) where.contenttype = query.contenttype;
    if (query.userid) where.userid = Number(query.userid);

    const items = await prisma.rating.findMany({ where, orderBy: { createdAt: 'desc' }, take: query.limit ? Number(query.limit) : undefined, skip: query.skip ? Number(query.skip) : undefined });
    return items.map(i => new RatingModel(i));
  }

  static async findById(id) {
    const r = await prisma.rating.findUnique({ where: { id: Number(id) } });
    return r ? new RatingModel(r) : null;
  }

  static async findOne(query) {
    const where = {};
    if (query.userid) where.userid = Number(query.userid);
    if (query.contentid) where.contentid = query.contentid;
    if (query.contenttype) where.contenttype = query.contenttype;

    const item = await prisma.rating.findFirst({ where });
    return item ? new RatingModel(item) : null;
  }

  static async countDocuments(query) {
    const where = {};
    if (query.userid) where.userid = Number(query.userid);
    if (query.contentid) where.contentid = query.contentid;
    if (query.contenttype) where.contenttype = query.contenttype;
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
