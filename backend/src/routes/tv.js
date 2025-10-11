const express = require('express');
const { allQuery, getQuery, runQuery } = require('../config/database');
const axios = require('axios');

const router = express.Router();

// Get all TV series with pagination
router.get('/', async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    const offset = (page - 1) * limit;
    const genre = req.query.genre;
    const search = req.query.search;

    let sql = 'SELECT * FROM tv_series WHERE 1=1';
    let params = [];

    if (genre) {
      sql += ' AND genre_ids LIKE ?';
      params.push(`%${genre}%`);
    }

    if (search) {
      sql += ' AND (name LIKE ? OR overview LIKE ?)';
      params.push(`%${search}%`, `%${search}%`);
    }

    sql += ' ORDER BY popularity DESC, vote_average DESC LIMIT ? OFFSET ?';
    params.push(limit, offset);

    const tvSeries = await allQuery(sql, params);

    // Get total count for pagination
    let countSql = 'SELECT COUNT(*) as total FROM tv_series WHERE 1=1';
    let countParams = [];

    if (genre) {
      countSql += ' AND genre_ids LIKE ?';
      countParams.push(`%${genre}%`);
    }

    if (search) {
      countSql += ' AND (name LIKE ? OR overview LIKE ?)';
      countParams.push(`%${search}%`, `%${search}%`);
    }

    const countResult = await getQuery(countSql, countParams);
    const total = countResult.total;

    res.json({
      success: true,
      data: tvSeries,
      pagination: {
        page,
        limit,
        total,
        pages: Math.ceil(total / limit)
      }
    });
  } catch (error) {
    console.error('Error fetching TV series:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch TV series'
    });
  }
});

// Get TV series by ID
router.get('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const tvSeries = await getQuery('SELECT * FROM tv_series WHERE id = ? OR tmdb_id = ?', [id, id]);

    if (!tvSeries) {
      return res.status(404).json({
        success: false,
        error: 'TV series not found'
      });
    }

    res.json({
      success: true,
      data: tvSeries
    });
  } catch (error) {
    console.error('Error fetching TV series:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch TV series'
    });
  }
});

// Get popular TV series
router.get('/popular', async (req, res) => {
  try {
    const limit = parseInt(req.query.limit) || 10;
    const tvSeries = await allQuery(
      'SELECT * FROM tv_series ORDER BY popularity DESC, vote_average DESC LIMIT ?',
      [limit]
    );

    res.json({
      success: true,
      data: tvSeries
    });
  } catch (error) {
    console.error('Error fetching popular TV series:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch popular TV series'
    });
  }
});

// Get top rated TV series
router.get('/top-rated', async (req, res) => {
  try {
    const limit = parseInt(req.query.limit) || 10;
    const tvSeries = await allQuery(
      'SELECT * FROM tv_series WHERE vote_count > 100 ORDER BY vote_average DESC LIMIT ?',
      [limit]
    );

    res.json({
      success: true,
      data: tvSeries
    });
  } catch (error) {
    console.error('Error fetching top rated TV series:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch top rated TV series'
    });
  }
});

// Get TV series by genre
router.get('/genre/:genreId', async (req, res) => {
  try {
    const { genreId } = req.params;
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    const offset = (page - 1) * limit;

    const tvSeries = await allQuery(
      'SELECT * FROM tv_series WHERE genre_ids LIKE ? ORDER BY popularity DESC LIMIT ? OFFSET ?',
      [`%${genreId}%`, limit, offset]
    );

    const countResult = await getQuery(
      'SELECT COUNT(*) as total FROM tv_series WHERE genre_ids LIKE ?',
      [`%${genreId}%`]
    );

    res.json({
      success: true,
      data: tvSeries,
      pagination: {
        page,
        limit,
        total: countResult.total,
        pages: Math.ceil(countResult.total / limit)
      }
    });
  } catch (error) {
    console.error('Error fetching TV series by genre:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch TV series by genre'
    });
  }
});

// Sync TV series from TMDB (for initial data population)
router.post('/sync', async (req, res) => {
  try {
    const { tmdbApiKey } = req.body;
    
    if (!tmdbApiKey) {
      return res.status(400).json({
        success: false,
        error: 'TMDB API key is required'
      });
    }

    // Fetch popular TV series from TMDB
    const response = await axios.get(
      `https://api.themoviedb.org/3/tv/popular?api_key=${tmdbApiKey}&language=en-US&page=1`
    );

    const tvSeries = response.data.results;
    let syncedCount = 0;

    for (const series of tvSeries) {
      try {
        await runQuery(`
          INSERT OR REPLACE INTO tv_series (
            tmdb_id, name, overview, first_air_date, vote_average,
            poster_path, backdrop_path, genre_ids, adult, original_language,
            popularity, vote_count
          ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        `, [
          series.id,
          series.name,
          series.overview,
          series.first_air_date,
          series.vote_average,
          series.poster_path,
          series.backdrop_path,
          JSON.stringify(series.genre_ids),
          series.adult ? 1 : 0,
          series.original_language,
          series.popularity,
          series.vote_count
        ]);
        syncedCount++;
      } catch (error) {
        console.error(`Error syncing TV series ${series.name}:`, error);
      }
    }

    res.json({
      success: true,
      message: `Synced ${syncedCount} TV series from TMDB`,
      syncedCount
    });
  } catch (error) {
    console.error('Error syncing TV series:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to sync TV series from TMDB'
    });
  }
});

module.exports = router;
