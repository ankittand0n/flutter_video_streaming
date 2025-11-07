const request = require('supertest');
const app = require('../src/server');
const prisma = require('../src/prisma/client');
const { Watchlist } = require('../src/models');

describe('Watchlist API', () => {
  let authToken;
  let userId;
  let testMovie;
  let testTvShow;

  beforeAll(async () => {
    // Create a test user and login
    const uniqueEmail = `watchlisttest${Date.now()}@example.com`;
    const uniqueUsername = `watchlistuser${Date.now()}`;
    
    const registerResponse = await request(app)
      .post('/api/auth/register')
      .send({
        email: uniqueEmail,
        password: 'password123',
        username: uniqueUsername,
        profile_name: 'Watchlist Test User'
      });

    authToken = registerResponse.body.token;
    userId = registerResponse.body.user.id;

    // Create test movie
    testMovie = await prisma.movie.create({
      data: {
        title: 'Test Movie for Watchlist',
        overview: 'Test movie overview',
        release_date: new Date('2024-01-01'),
        vote_average: 8.5,
        poster_path: '/test-poster.jpg',
        backdrop_path: '/test-backdrop.jpg'
      }
    });

    // Create test TV show
    testTvShow = await prisma.tv_series.create({
      data: {
        name: 'Test TV Show for Watchlist',
        overview: 'Test TV show overview',
        first_air_date: new Date('2024-01-01'),
        vote_average: 8.0,
        poster_path: '/test-tv-poster.jpg'
      }
    });
  });

  afterAll(async () => {
    // Clean up test data
    if (userId) {
      await prisma.watchlist.deleteMany({ where: { user_id: userId } });
      await prisma.rating.deleteMany({ where: { user_id: userId } });
      await prisma.user.delete({ where: { id: userId } });
    }
    if (testMovie) {
      await prisma.movie.delete({ where: { id: testMovie.id } });
    }
    if (testTvShow) {
      await prisma.tv_series.delete({ where: { id: testTvShow.id } });
    }
    await prisma.$disconnect();
  });

  describe('POST /api/watchlist', () => {
    it('should add a movie to watchlist', async () => {
      const response = await request(app)
        .post('/api/watchlist')
        .set('Authorization', `Bearer ${authToken}`)
        .send({
          media_id: testMovie.id.toString(),
          media_type: 'movie',
          title: testMovie.title,
          posterPath: testMovie.poster_path
        });

      expect(response.status).toBe(201);
      expect(response.body.message).toBe('Item added to watchlist successfully');
      expect(response.body.data).toHaveProperty('id');
      expect(response.body.data.media_id).toBe(testMovie.id.toString());
      expect(response.body.data.media_type).toBe('movie');
      expect(response.body.data.title).toBe(testMovie.title);
      expect(response.body.data.user_id).toBe(userId);
    });

    it('should add a TV show to watchlist', async () => {
      const response = await request(app)
        .post('/api/watchlist')
        .set('Authorization', `Bearer ${authToken}`)
        .send({
          media_id: testTvShow.id.toString(),
          media_type: 'tv',
          title: testTvShow.name,
          posterPath: testTvShow.poster_path
        });

      expect(response.status).toBe(201);
      expect(response.body.message).toBe('Item added to watchlist successfully');
      expect(response.body.data.media_id).toBe(testTvShow.id.toString());
      expect(response.body.data.media_type).toBe('tv');
    });

    it('should not add duplicate items to watchlist', async () => {
      const response = await request(app)
        .post('/api/watchlist')
        .set('Authorization', `Bearer ${authToken}`)
        .send({
          media_id: testMovie.id.toString(),
          media_type: 'movie',
          title: testMovie.title
        });

      expect(response.status).toBe(400);
      expect(response.body.error).toBe('Item already exists in watchlist');
    });

    it('should require authentication', async () => {
      const response = await request(app)
        .post('/api/watchlist')
        .send({
          media_id: '123',
          media_type: 'movie',
          title: 'Test Movie'
        });

      expect(response.status).toBe(401);
    });

    it('should validate required fields', async () => {
      const response = await request(app)
        .post('/api/watchlist')
        .set('Authorization', `Bearer ${authToken}`)
        .send({
          media_id: '123'
          // missing media_type and title
        });

      expect(response.status).toBe(400);
      expect(response.body.error).toBe('Validation failed');
    });

    it('should validate media_type values', async () => {
      const response = await request(app)
        .post('/api/watchlist')
        .set('Authorization', `Bearer ${authToken}`)
        .send({
          media_id: '123',
          media_type: 'invalid_type',
          title: 'Test'
        });

      expect(response.status).toBe(400);
      expect(response.body.error).toBe('Validation failed');
    });
  });

  describe('GET /api/watchlist', () => {
    it('should get user watchlist', async () => {
      const response = await request(app)
        .get('/api/watchlist')
        .set('Authorization', `Bearer ${authToken}`);

      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
      expect(Array.isArray(response.body.data)).toBe(true);
      expect(response.body.data.length).toBeGreaterThanOrEqual(2);
      expect(response.body.pagination).toHaveProperty('page');
      expect(response.body.pagination).toHaveProperty('limit');
      expect(response.body.pagination).toHaveProperty('total');
      expect(response.body.pagination).toHaveProperty('totalPages');
    });

    it('should support pagination', async () => {
      const response = await request(app)
        .get('/api/watchlist?page=1&limit=1')
        .set('Authorization', `Bearer ${authToken}`);

      expect(response.status).toBe(200);
      expect(response.body.data.length).toBeLessThanOrEqual(1);
      expect(response.body.pagination.page).toBe(1);
      expect(response.body.pagination.limit).toBe(1);
    });

    it('should filter by media_type', async () => {
      const response = await request(app)
        .get('/api/watchlist?media_type=movie')
        .set('Authorization', `Bearer ${authToken}`);

      expect(response.status).toBe(200);
      
      // Check that all returned items are movies, or the list is empty
      if (response.body.data.length > 0) {
        const types = response.body.data.map(item => item.media_type);
        expect(types).toEqual(expect.arrayContaining(['movie']));
        expect(response.body.data.every(item => item.media_type === 'movie')).toBe(true);
      }
    });

    it('should require authentication', async () => {
      const response = await request(app)
        .get('/api/watchlist');

      expect(response.status).toBe(401);
    });
  });

  describe('GET /api/watchlist/:id', () => {
    let watchlistItemId;

    beforeAll(async () => {
      // Get the first watchlist item
      const items = await prisma.watchlist.findMany({
        where: { user_id: userId },
        take: 1
      });
      watchlistItemId = items[0].id;
    });

    it('should get a specific watchlist item', async () => {
      const response = await request(app)
        .get(`/api/watchlist/${watchlistItemId}`)
        .set('Authorization', `Bearer ${authToken}`);

      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
      expect(response.body.data.id).toBe(watchlistItemId);
    });

    it('should return 404 for non-existent item', async () => {
      const response = await request(app)
        .get('/api/watchlist/999999')
        .set('Authorization', `Bearer ${authToken}`);

      expect(response.status).toBe(404);
      expect(response.body.error).toBe('Watchlist item not found');
    });

    it('should require authentication', async () => {
      const response = await request(app)
        .get(`/api/watchlist/${watchlistItemId}`);

      expect(response.status).toBe(401);
    });
  });

  describe('DELETE /api/watchlist/:id', () => {
    let itemToDelete;
    let deleteTestCounter = 0;

    beforeEach(async () => {
      // Create a new item to delete with unique media_id
      deleteTestCounter++;
      itemToDelete = await prisma.watchlist.create({
        data: {
          user_id: userId,
          media_id: `delete-test-${deleteTestCounter}-${Date.now()}`,
          media_type: 'movie',
          title: 'Item to Delete',
          poster_path: '/delete-test.jpg'
        }
      });
    });

    it('should delete a watchlist item', async () => {
      const response = await request(app)
        .delete(`/api/watchlist/${itemToDelete.id}`)
        .set('Authorization', `Bearer ${authToken}`);

      expect(response.status).toBe(200);
      expect(response.body.message).toBe('Item removed from watchlist successfully');

      // Verify it's deleted
      const deleted = await prisma.watchlist.findUnique({
        where: { id: itemToDelete.id }
      });
      expect(deleted).toBeNull();
    });

    it('should return 404 for non-existent item', async () => {
      const response = await request(app)
        .delete('/api/watchlist/999999')
        .set('Authorization', `Bearer ${authToken}`);

      expect(response.status).toBe(404);
      expect(response.body.error).toBe('Watchlist item not found');
    });

    it('should require authentication', async () => {
      const response = await request(app)
        .delete(`/api/watchlist/${itemToDelete.id}`);

      expect(response.status).toBe(401);
    });
  });

  describe('POST /api/watchlist/bulk', () => {
    beforeEach(async () => {
      // Clean up any existing bulk test items
      await prisma.watchlist.deleteMany({
        where: {
          user_id: userId,
          media_id: { in: ['bulk1', 'bulk2', 'bulk3'] }
        }
      });
    });

    it('should add multiple items to watchlist', async () => {
      const items = [
        {
          media_id: 'bulk1',
          media_type: 'movie',
          title: 'Bulk Movie 1'
        },
        {
          media_id: 'bulk2',
          media_type: 'movie',
          title: 'Bulk Movie 2'
        },
        {
          media_id: 'bulk3',
          media_type: 'tv',
          title: 'Bulk TV Show 1'
        }
      ];

      const response = await request(app)
        .post('/api/watchlist/bulk')
        .set('Authorization', `Bearer ${authToken}`)
        .send({ items });

      expect(response.status).toBe(200);
      expect(response.body.message).toBe('Bulk operation completed');
      expect(response.body.data.added).toBe(3);
      expect(response.body.data.failed).toBe(0);
      expect(response.body.data.results.length).toBe(3);
    });

    it('should handle duplicate items in bulk operation', async () => {
      const items = [
        {
          media_id: testMovie.id.toString(),
          media_type: 'movie',
          title: testMovie.title
        }
      ];

      const response = await request(app)
        .post('/api/watchlist/bulk')
        .set('Authorization', `Bearer ${authToken}`)
        .send({ items });

      expect(response.status).toBe(200);
      expect(response.body.data.added).toBe(0);
      expect(response.body.data.failed).toBe(1);
      expect(response.body.data.errors[0].error).toBe('Item already exists in watchlist');
    });

    it('should require items array', async () => {
      const response = await request(app)
        .post('/api/watchlist/bulk')
        .set('Authorization', `Bearer ${authToken}`)
        .send({});

      expect(response.status).toBe(400);
      expect(response.body.error).toBe('Items array is required and must not be empty');
    });

    it('should require authentication', async () => {
      const response = await request(app)
        .post('/api/watchlist/bulk')
        .send({ items: [] });

      expect(response.status).toBe(401);
    });
  });

  describe('Field Name Consistency', () => {
    it('should use media_id and media_type (not contentid/contenttype)', async () => {
      const response = await request(app)
        .get('/api/watchlist')
        .set('Authorization', `Bearer ${authToken}`);

      expect(response.status).toBe(200);
      const item = response.body.data[0];
      
      // Should have correct field names
      expect(item).toHaveProperty('media_id');
      expect(item).toHaveProperty('media_type');
      expect(item).toHaveProperty('user_id');
      expect(item).toHaveProperty('created_at');
      
      // Should NOT have old field names
      expect(item).not.toHaveProperty('contentid');
      expect(item).not.toHaveProperty('contenttype');
      expect(item).not.toHaveProperty('userid');
      expect(item).not.toHaveProperty('createdat');
    });

    it('should accept poster_path field when creating', async () => {
      const tempItem = await request(app)
        .post('/api/watchlist')
        .set('Authorization', `Bearer ${authToken}`)
        .send({
          media_id: 'poster-test-123',
          media_type: 'movie',
          title: 'Poster Path Test',
          posterPath: '/test-poster-path.jpg'
        });

      expect(tempItem.status).toBe(201);
      expect(tempItem.body.data.poster_path).toBe('/test-poster-path.jpg');

      // Clean up
      await prisma.watchlist.delete({ where: { id: tempItem.body.data.id } });
    });
  });

  describe('PUT /api/watchlist/:id', () => {
    let itemToUpdate;

    beforeAll(async () => {
      // Create an item to update
      const item = await prisma.watchlist.create({
        data: {
          user_id: userId,
          media_id: 'update-test-456',
          media_type: 'movie',
          title: 'Item to Update',
          poster_path: '/update-poster.jpg'
        }
      });
      itemToUpdate = item;
    });

    it('should update a watchlist item', async () => {
      const response = await request(app)
        .put(`/api/watchlist/${itemToUpdate.id}`)
        .set('Authorization', `Bearer ${authToken}`)
        .send({
          title: 'Updated Title',
          priority: 'high',
          notes: 'Updated notes'
        });

      expect(response.status).toBe(200);
      expect(response.body.message).toBe('Watchlist item updated successfully');
      expect(response.body.data.title).toBe('Updated Title');
    });

    it('should return 404 for non-existent item', async () => {
      const response = await request(app)
        .put('/api/watchlist/999999')
        .set('Authorization', `Bearer ${authToken}`)
        .send({ title: 'Updated' });

      expect(response.status).toBe(404);
    });

    it('should require authentication', async () => {
      const response = await request(app)
        .put(`/api/watchlist/${itemToUpdate.id}`)
        .send({ title: 'Updated' });

      expect(response.status).toBe(401);
    });
  });

  describe('POST /api/watchlist/:id/watch', () => {
    let itemToWatch;

    beforeAll(async () => {
      // Create an item to mark as watched
      const item = await prisma.watchlist.create({
        data: {
          user_id: userId,
          media_id: 'watch-test-789',
          media_type: 'movie',
          title: 'Item to Watch',
          poster_path: '/watch-poster.jpg'
        }
      });
      itemToWatch = item;
    });

    it('should mark item as watched', async () => {
      const response = await request(app)
        .post(`/api/watchlist/${itemToWatch.id}/watch`)
        .set('Authorization', `Bearer ${authToken}`)
        .send();

      expect(response.status).toBe(200);
      expect(response.body.message).toBe('Item marked as watched successfully');
    });

    it('should mark as watched for TV show', async () => {
      // Create another item
      const item = await prisma.watchlist.create({
        data: {
          user_id: userId,
          media_id: 'watch-test-tv',
          media_type: 'tv',
          title: 'Watch TV Show',
          poster_path: '/watch-poster-2.jpg'
        }
      });

      const response = await request(app)
        .post(`/api/watchlist/${item.id}/watch`)
        .set('Authorization', `Bearer ${authToken}`)
        .send();

      expect(response.status).toBe(200);

      // Clean up
      await prisma.watchlist.delete({ where: { id: item.id } });
    });

    it('should return 404 for non-existent item', async () => {
      const response = await request(app)
        .post('/api/watchlist/999999/watch')
        .set('Authorization', `Bearer ${authToken}`);

      expect(response.status).toBe(404);
    });

    it('should require authentication', async () => {
      const response = await request(app)
        .post(`/api/watchlist/${itemToWatch.id}/watch`);

      expect(response.status).toBe(401);
    });
  });

  describe('POST /api/watchlist/:id/unwatch', () => {
    let itemToUnwatch;

    beforeAll(async () => {
      // Create a watched item to unwatch
      const item = await prisma.watchlist.create({
        data: {
          user_id: userId,
          media_id: 'unwatch-test-101',
          media_type: 'movie',
          title: 'Item to Unwatch',
          poster_path: '/unwatch-poster.jpg'
        }
      });
      // Mark it as watched using the model
      const watchlistItem = await Watchlist.findOne({ _id: item.id, user_id: userId });
      await watchlistItem.markAsWatched();
      itemToUnwatch = item;
    });

    it('should mark item as unwatched', async () => {
      const response = await request(app)
        .post(`/api/watchlist/${itemToUnwatch.id}/unwatch`)
        .set('Authorization', `Bearer ${authToken}`);

      expect(response.status).toBe(200);
      expect(response.body.message).toBe('Item marked as unwatched successfully');
    });

    it('should return 404 for non-existent item', async () => {
      const response = await request(app)
        .post('/api/watchlist/999999/unwatch')
        .set('Authorization', `Bearer ${authToken}`);

      expect(response.status).toBe(404);
    });

    it('should require authentication', async () => {
      const response = await request(app)
        .post(`/api/watchlist/${itemToUnwatch.id}/unwatch`);

      expect(response.status).toBe(401);
    });
  });

  describe('GET /api/watchlist/stats', () => {
    it('should get watchlist statistics', async () => {
      const response = await request(app)
        .get('/api/watchlist/stats')
        .set('Authorization', `Bearer ${authToken}`);

      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
      expect(response.body.data).toHaveProperty('total');
      expect(response.body.data).toHaveProperty('watched');
      expect(response.body.data).toHaveProperty('unwatched');
      expect(response.body.data).toHaveProperty('byType');
      expect(response.body.data.byType).toHaveProperty('movies');
      expect(response.body.data.byType).toHaveProperty('tvShows');
      expect(response.body.data).toHaveProperty('byPriority');
      expect(response.body.data).toHaveProperty('recentAdditions');
    });

    it('should require authentication', async () => {
      const response = await request(app)
        .get('/api/watchlist/stats');

      expect(response.status).toBe(401);
    });
  });
});
