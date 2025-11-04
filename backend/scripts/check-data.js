const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function checkData() {
  try {
    const users = await prisma.user.count();
    const movies = await prisma.movie.count();
    const genres = await prisma.genre.count();
    const tvSeries = await prisma.tvSeries.count();
    const watchlist = await prisma.watchlist.count();
    const ratings = await prisma.rating.count();
    const seasons = await prisma.season.count();
    
    console.log('\n✓ Database Statistics:');
    console.log('  Users:', users);
    console.log('  Movies:', movies);
    console.log('  Genres:', genres);
    console.log('  TV Series:', tvSeries);
    console.log('  Seasons:', seasons);
    console.log('  Watchlist Items:', watchlist);
    console.log('  Ratings:', ratings);
    console.log('\nTotal Records:', users + movies + genres + tvSeries + seasons + watchlist + ratings);
    
  } catch (error) {
    console.error('Error:', error.message);
  } finally {
    await prisma.$disconnect();
  }
}

checkData();
