require('dotenv').config();
const prisma = require('../src/prisma/client');

// Use a slightly longer timeout for DB operations
jest.setTimeout(30000);

describe('Full CRUD test for all tables', () => {
  const created = {};

  beforeAll(async () => {
    await prisma.$connect();
  });

  afterAll(async () => {
    // cleanup any remaining created records (ignore errors)
    try {
      if (created.ratingId) await prisma.rating.delete({ where: { id: created.ratingId } }).catch(() => {});
      if (created.watchlistId) await prisma.watchlist.delete({ where: { id: created.watchlistId } }).catch(() => {});
      if (created.seasonId) await prisma.season.delete({ where: { id: created.seasonId } }).catch(() => {});
      if (created.tvId) await prisma.tvSeries.delete({ where: { id: created.tvId } }).catch(() => {});
      if (created.movieId) await prisma.movie.delete({ where: { id: created.movieId } }).catch(() => {});
      if (created.genreId) await prisma.genre.delete({ where: { id: created.genreId } }).catch(() => {});
      if (created.userId) await prisma.user.delete({ where: { id: created.userId } }).catch(() => {});
    } catch (e) {
      // ignore
    }
    await prisma.$disconnect();
  });

  test('Genre CRUD', async () => {
    // Create
    const genre = await prisma.genre.create({ data: { name: `test-genre-${Date.now()}`, type: 'movie' } });
    expect(genre).toHaveProperty('id');
    created.genreId = genre.id;

    // Read
    const found = await prisma.genre.findUnique({ where: { id: genre.id } });
    expect(found.name).toBe(genre.name);

    // Update
    const updated = await prisma.genre.update({ where: { id: genre.id }, data: { name: 'updated-genre' } });
    expect(updated.name).toBe('updated-genre');

    // Delete
    const deleted = await prisma.genre.delete({ where: { id: genre.id } });
    expect(deleted.id).toBe(genre.id);

    // mark for cleanup false
    delete created.genreId;
  });

  test('Movie CRUD', async () => {
    // Create
    const movie = await prisma.movie.create({ data: { title: `Test Movie ${Date.now()}`, overview: 'Overview', genre_ids: JSON.stringify([1,2]) } });
    expect(movie).toHaveProperty('id');
    created.movieId = movie.id;

    // Read
    const found = await prisma.movie.findUnique({ where: { id: movie.id } });
    expect(found.title).toBe(movie.title);

    // Update
    const updated = await prisma.movie.update({ where: { id: movie.id }, data: { vote_average: 7.5 } });
    expect(Number(updated.vote_average)).toBeCloseTo(7.5);

    // Delete
    const deleted = await prisma.movie.delete({ where: { id: movie.id } });
    expect(deleted.id).toBe(movie.id);
    delete created.movieId;
  });

  test('TV Series & Season CRUD', async () => {
    const tv = await prisma.tvSeries.create({ data: { name: `Test TV ${Date.now()}`, overview: 'TV overview', genre_ids: JSON.stringify([1]) } });
    expect(tv).toHaveProperty('id');
    created.tvId = tv.id;

    const found = await prisma.tvSeries.findUnique({ where: { id: tv.id } });
    expect(found.name).toBe(tv.name);

    const updatedTv = await prisma.tvSeries.update({ where: { id: tv.id }, data: { vote_average: 8.1 } });
    expect(Number(updatedTv.vote_average)).toBeCloseTo(8.1);

    const season = await prisma.season.create({ data: { tv_series_id: tv.id, season_number: 1, name: 'S1' } });
    expect(season).toHaveProperty('id');
    created.seasonId = season.id;

    const foundSeason = await prisma.season.findUnique({ where: { id: season.id } });
    expect(foundSeason.name).toBe('S1');

    const updatedSeason = await prisma.season.update({ where: { id: season.id }, data: { name: 'S1 Updated' } });
    expect(updatedSeason.name).toBe('S1 Updated');

    // cleanup season and tv
    await prisma.season.delete({ where: { id: season.id } });
    delete created.seasonId;

    const deletedTv = await prisma.tvSeries.delete({ where: { id: tv.id } });
    expect(deletedTv.id).toBe(tv.id);
    delete created.tvId;
  });

  test('User, Watchlist, Rating CRUD', async () => {
    // Create user
    const email = `testuser+${Date.now()}@example.com`;
    const user = await prisma.user.create({ data: { email, password: 'password123', username: `user${Date.now()}`, profileName: 'Test User' } });
    expect(user).toHaveProperty('id');
    created.userId = user.id;

    // Create watchlist item
    const w = await prisma.watchlist.create({ data: { userId: user.id, contentId: '9999', contentType: 'movie', title: 'WL Item' } });
    expect(w).toHaveProperty('id');
    created.watchlistId = w.id;

    const foundW = await prisma.watchlist.findUnique({ where: { id: w.id } });
    expect(foundW.title).toBe('WL Item');

    const updatedW = await prisma.watchlist.update({ where: { id: w.id }, data: { watched: true, rating: 9 } });
    expect(updatedW.watched).toBe(true);
    expect(updatedW.rating).toBe(9);

    // Create rating
    const r = await prisma.rating.create({ data: { userId: user.id, contentId: '9999', contentType: 'movie', rating: 8, title: 'Good' } });
    expect(r).toHaveProperty('id');
    created.ratingId = r.id;

    const foundR = await prisma.rating.findUnique({ where: { id: r.id } });
    expect(foundR.rating).toBe(8);

    const updatedR = await prisma.rating.update({ where: { id: r.id }, data: { rating: 7 } });
    expect(updatedR.rating).toBe(7);

    // delete rating and watchlist
    await prisma.rating.delete({ where: { id: r.id } });
    delete created.ratingId;

    await prisma.watchlist.delete({ where: { id: w.id } });
    delete created.watchlistId;

    // delete user
    await prisma.user.delete({ where: { id: user.id } });
    delete created.userId;
  });
});
