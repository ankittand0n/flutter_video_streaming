const { PrismaClient } = require('@prisma/client');
const fs = require('fs');
const path = require('path');

const prisma = new PrismaClient({
  datasources: {
    db: {
      url: process.env.DIRECT_URL || process.env.DATABASE_URL
    }
  }
});

async function exportDatabase() {
  console.log('Starting database export...\n');
  
  let sqlOutput = `-- Database Backup Export
-- Generated: ${new Date().toISOString()}
-- Database: PostgreSQL (Supabase)

-- ============================================
-- SCHEMA CREATION
-- ============================================

`;

  try {
    // Export Users
    console.log('Exporting users...');
    const users = await prisma.user.findMany();
    if (users.length > 0) {
      sqlOutput += `\n-- Users Table\n`;
      for (const user of users) {
        const phone = user.phone ? `'${user.phone.replace(/'/g, "''")}'` : 'NULL';
        const password = user.password ? `'${user.password.replace(/'/g, "''")}'` : 'NULL';
        const role = user.role ? `'${user.role.replace(/'/g, "''")}'` : "'user'";
        const createdAt = user.createdAt ? `'${user.createdAt.toISOString()}'` : 'CURRENT_TIMESTAMP';
        const updatedAt = user.updatedAt ? `'${user.updatedAt.toISOString()}'` : 'CURRENT_TIMESTAMP';
        
        sqlOutput += `INSERT INTO "User" (id, phone, password, role, "createdAt", "updatedAt") VALUES (${user.id}, ${phone}, ${password}, ${role}, ${createdAt}, ${updatedAt});\n`;
      }
    }
    console.log(`✓ Exported ${users.length} users`);

    // Export Genres
    console.log('Exporting genres...');
    const genres = await prisma.genre.findMany();
    if (genres.length > 0) {
      sqlOutput += `\n-- Genres Table\n`;
      for (const genre of genres) {
        const name = genre.name ? `'${genre.name.replace(/'/g, "''")}'` : 'NULL';
        const createdAt = genre.createdAt ? `'${genre.createdAt.toISOString()}'` : 'CURRENT_TIMESTAMP';
        
        sqlOutput += `INSERT INTO "genres" (id, name, "createdAt") VALUES (${genre.id}, ${name}, ${createdAt});\n`;
      }
    }
    console.log(`✓ Exported ${genres.length} genres`);

    // Export Movies
    console.log('Exporting movies...');
    const movies = await prisma.movie.findMany();
    if (movies.length > 0) {
      sqlOutput += `\n-- Movies Table\n`;
      for (const movie of movies) {
        const title = movie.title ? `'${movie.title.replace(/'/g, "''")}'` : 'NULL';
        const overview = movie.overview ? `'${movie.overview.replace(/'/g, "''")}'` : 'NULL';
        const posterPath = movie.poster_path ? `'${movie.poster_path.replace(/'/g, "''")}'` : 'NULL';
        const backdropPath = movie.backdrop_path ? `'${movie.backdrop_path.replace(/'/g, "''")}'` : 'NULL';
        const releaseDate = movie.release_date ? `'${movie.release_date.toISOString()}'` : 'NULL';
        const voteAverage = movie.vote_average !== null ? movie.vote_average : 'NULL';
        const genreIds = movie.genre_ids ? `'${movie.genre_ids.replace(/'/g, "''")}'` : 'NULL';
        const videoUrl = movie.video_url ? `'${movie.video_url.replace(/'/g, "''")}'` : 'NULL';
        const trailerUrl = movie.trailer_url ? `'${movie.trailer_url.replace(/'/g, "''")}'` : 'NULL';
        const createdAt = movie.createdAt ? `'${movie.createdAt.toISOString()}'` : 'CURRENT_TIMESTAMP';
        const updatedAt = movie.updatedAt ? `'${movie.updatedAt.toISOString()}'` : 'CURRENT_TIMESTAMP';
        
        sqlOutput += `INSERT INTO "movies" (id, title, overview, poster_path, backdrop_path, release_date, vote_average, genre_ids, video_url, trailer_url, "createdAt", "updatedAt") VALUES (${movie.id}, ${title}, ${overview}, ${posterPath}, ${backdropPath}, ${releaseDate}, ${voteAverage}, ${genreIds}, ${videoUrl}, ${trailerUrl}, ${createdAt}, ${updatedAt});\n`;
      }
    }
    console.log(`✓ Exported ${movies.length} movies`);

    // Export TV Series
    console.log('Exporting TV series...');
    const tvSeries = await prisma.tvSeries.findMany();
    if (tvSeries.length > 0) {
      sqlOutput += `\n-- TV Series Table\n`;
      for (const tv of tvSeries) {
        const name = tv.name ? `'${tv.name.replace(/'/g, "''")}'` : 'NULL';
        const overview = tv.overview ? `'${tv.overview.replace(/'/g, "''")}'` : 'NULL';
        const posterPath = tv.poster_path ? `'${tv.poster_path.replace(/'/g, "''")}'` : 'NULL';
        const backdropPath = tv.backdrop_path ? `'${tv.backdrop_path.replace(/'/g, "''")}'` : 'NULL';
        const firstAirDate = tv.first_air_date ? `'${tv.first_air_date.toISOString()}'` : 'NULL';
        const lastAirDate = tv.last_air_date ? `'${tv.last_air_date.toISOString()}'` : 'NULL';
        const voteAverage = tv.vote_average !== null ? tv.vote_average : 'NULL';
        const genreIds = tv.genre_ids ? `'${tv.genre_ids.replace(/'/g, "''")}'` : 'NULL';
        const numberOfSeasons = tv.number_of_seasons !== null ? tv.number_of_seasons : 'NULL';
        const numberOfEpisodes = tv.number_of_episodes !== null ? tv.number_of_episodes : 'NULL';
        const status = tv.status ? `'${tv.status.replace(/'/g, "''")}'` : 'NULL';
        const videoUrl = tv.video_url ? `'${tv.video_url.replace(/'/g, "''")}'` : 'NULL';
        const trailerUrl = tv.trailer_url ? `'${tv.trailer_url.replace(/'/g, "''")}'` : 'NULL';
        const seasons = tv.seasons ? `'${tv.seasons.replace(/'/g, "''")}'` : 'NULL';
        const createdAt = tv.createdAt ? `'${tv.createdAt.toISOString()}'` : 'CURRENT_TIMESTAMP';
        const updatedAt = tv.updatedAt ? `'${tv.updatedAt.toISOString()}'` : 'CURRENT_TIMESTAMP';
        
        sqlOutput += `INSERT INTO "tv_series" (id, name, overview, poster_path, backdrop_path, first_air_date, last_air_date, vote_average, genre_ids, number_of_seasons, number_of_episodes, status, video_url, trailer_url, seasons, "createdAt", "updatedAt") VALUES (${tv.id}, ${name}, ${overview}, ${posterPath}, ${backdropPath}, ${firstAirDate}, ${lastAirDate}, ${voteAverage}, ${genreIds}, ${numberOfSeasons}, ${numberOfEpisodes}, ${status}, ${videoUrl}, ${trailerUrl}, ${seasons}, ${createdAt}, ${updatedAt});\n`;
      }
    }
    console.log(`✓ Exported ${tvSeries.length} TV series`);

    // Export Seasons
    console.log('Exporting seasons...');
    const seasons = await prisma.season.findMany();
    if (seasons.length > 0) {
      sqlOutput += `\n-- Seasons Table\n`;
      for (const season of seasons) {
        const tvSeriesId = season.tv_series_id;
        const seasonNumber = season.season_number;
        const name = season.name ? `'${season.name.replace(/'/g, "''")}'` : 'NULL';
        const overview = season.overview ? `'${season.overview.replace(/'/g, "''")}'` : 'NULL';
        const airDate = season.air_date ? `'${season.air_date.toISOString()}'` : 'NULL';
        const episodeCount = season.episode_count !== null ? season.episode_count : 'NULL';
        const posterPath = season.poster_path ? `'${season.poster_path.replace(/'/g, "''")}'` : 'NULL';
        const createdAt = season.createdAt ? `'${season.createdAt.toISOString()}'` : 'CURRENT_TIMESTAMP';
        const updatedAt = season.updatedAt ? `'${season.updatedAt.toISOString()}'` : 'CURRENT_TIMESTAMP';
        
        sqlOutput += `INSERT INTO "seasons" (id, tv_series_id, season_number, name, overview, air_date, episode_count, poster_path, "createdAt", "updatedAt") VALUES (${season.id}, ${tvSeriesId}, ${seasonNumber}, ${name}, ${overview}, ${airDate}, ${episodeCount}, ${posterPath}, ${createdAt}, ${updatedAt});\n`;
      }
    }
    console.log(`✓ Exported ${seasons.length} seasons`);

    // Export Watchlist
    console.log('Exporting watchlist...');
    const watchlist = await prisma.watchlist.findMany();
    if (watchlist.length > 0) {
      sqlOutput += `\n-- Watchlist Table\n`;
      for (const item of watchlist) {
        const userId = item.userid;
        const contentType = item.contenttype ? `'${item.contenttype.replace(/'/g, "''")}'` : 'NULL';
        const contentId = item.contentid;
        const title = item.title ? `'${item.title.replace(/'/g, "''")}'` : 'NULL';
        const posterPath = item.posterpath ? `'${item.posterpath.replace(/'/g, "''")}'` : 'NULL';
        const createdAt = item.createdat ? `'${item.createdat.toISOString()}'` : 'CURRENT_TIMESTAMP';
        
        sqlOutput += `INSERT INTO watchlist (id, userid, contenttype, contentid, title, posterpath, createdat) VALUES (${item.id}, ${userId}, ${contentType}, ${contentId}, ${title}, ${posterPath}, ${createdAt});\n`;
      }
    }
    console.log(`✓ Exported ${watchlist.length} watchlist items`);

    // Export Ratings
    console.log('Exporting ratings...');
    const ratings = await prisma.rating.findMany();
    if (ratings.length > 0) {
      sqlOutput += `\n-- Ratings Table\n`;
      for (const rating of ratings) {
        const userId = rating.userid;
        const contentType = rating.contenttype ? `'${rating.contenttype.replace(/'/g, "''")}'` : 'NULL';
        const contentId = rating.contentid;
        const ratingValue = rating.rating !== null ? rating.rating : 'NULL';
        const createdAt = rating.createdat ? `'${rating.createdat.toISOString()}'` : 'CURRENT_TIMESTAMP';
        const updatedAt = rating.updatedat ? `'${rating.updatedat.toISOString()}'` : 'CURRENT_TIMESTAMP';
        
        sqlOutput += `INSERT INTO rating (id, userid, contenttype, contentid, rating, createdat, updatedat) VALUES (${rating.id}, ${userId}, ${contentType}, ${contentId}, ${ratingValue}, ${createdAt}, ${updatedAt});\n`;
      }
    }
    console.log(`✓ Exported ${ratings.length} ratings`);

    // Add sequence resets at the end
    sqlOutput += `\n-- ============================================\n`;
    sqlOutput += `-- SEQUENCE RESETS (Update max IDs)\n`;
    sqlOutput += `-- ============================================\n\n`;
    
    if (users.length > 0) {
      const maxUserId = Math.max(...users.map(u => u.id));
      sqlOutput += `SELECT setval('"User_id_seq"', ${maxUserId}, true);\n`;
    }
    if (genres.length > 0) {
      const maxGenreId = Math.max(...genres.map(g => g.id));
      sqlOutput += `SELECT setval('genres_id_seq', ${maxGenreId}, true);\n`;
    }
    if (movies.length > 0) {
      const maxMovieId = Math.max(...movies.map(m => m.id));
      sqlOutput += `SELECT setval('movies_id_seq', ${maxMovieId}, true);\n`;
    }
    if (tvSeries.length > 0) {
      const maxTvId = Math.max(...tvSeries.map(t => t.id));
      sqlOutput += `SELECT setval('tv_series_id_seq', ${maxTvId}, true);\n`;
    }
    if (seasons.length > 0) {
      const maxSeasonId = Math.max(...seasons.map(s => s.id));
      sqlOutput += `SELECT setval('seasons_id_seq', ${maxSeasonId}, true);\n`;
    }
    if (watchlist.length > 0) {
      const maxWatchlistId = Math.max(...watchlist.map(w => w.id));
      sqlOutput += `SELECT setval('watchlist_id_seq', ${maxWatchlistId}, true);\n`;
    }
    if (ratings.length > 0) {
      const maxRatingId = Math.max(...ratings.map(r => r.id));
      sqlOutput += `SELECT setval('rating_id_seq', ${maxRatingId}, true);\n`;
    }

    // Write to file
    const backupPath = path.join(__dirname, '..', 'database_backup_data.sql');
    fs.writeFileSync(backupPath, sqlOutput);
    
    console.log(`\n✓ Database backup exported successfully!`);
    console.log(`✓ File: ${backupPath}`);
    console.log(`\nSummary:`);
    console.log(`  - Users: ${users.length}`);
    console.log(`  - Genres: ${genres.length}`);
    console.log(`  - Movies: ${movies.length}`);
    console.log(`  - TV Series: ${tvSeries.length}`);
    console.log(`  - Seasons: ${seasons.length}`);
    console.log(`  - Watchlist: ${watchlist.length}`);
    console.log(`  - Ratings: ${ratings.length}`);

  } catch (error) {
    console.error('Error exporting database:', error);
    throw error;
  } finally {
    await prisma.$disconnect();
  }
}

exportDatabase();
