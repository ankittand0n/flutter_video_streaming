const { PrismaClient } = require('@prisma/client');

const prisma = new PrismaClient();

async function main() {
  console.log('🌱 Seeding database...');

  // Insert genres data
  const genres = [
    { name: 'Action', type: 'movie' },
    { name: 'Adventure', type: 'movie' },
    { name: 'Animation', type: 'tv' },
    { name: 'Comedy', type: 'tv' },
    { name: 'Crime', type: 'tv' },
    { name: 'Documentary', type: 'tv' },
    { name: 'Drama', type: 'tv' },
    { name: 'Family', type: 'tv' },
    { name: 'Fantasy', type: 'movie' },
    { name: 'History', type: 'movie' },
    { name: 'Horror', type: 'movie' },
    { name: 'Music', type: 'movie' },
    { name: 'Mystery', type: 'tv' },
    { name: 'Romance', type: 'movie' },
    { name: 'Science Fiction', type: 'movie' },
    { name: 'TV Movie', type: 'movie' },
    { name: 'Thriller', type: 'movie' },
    { name: 'War', type: 'movie' },
    { name: 'Western', type: 'tv' },
    { name: 'Action & Adventure', type: 'tv' },
    { name: 'Kids', type: 'tv' },
    { name: 'News', type: 'tv' },
    { name: 'Reality', type: 'tv' },
    { name: 'Sci-Fi & Fantasy', type: 'tv' },
    { name: 'Soap', type: 'tv' },
    { name: 'Talk', type: 'tv' },
    { name: 'War & Politics', type: 'tv' }
  ];

  for (const genre of genres) {
    await prisma.genre.create({
      data: genre
    });
  }
  console.log('✅ Genres seeded');

  // Insert movies data
  const movies = [
    {
      title: 'ANTERVYATHAA',
      overview: 'A psychological thriller that explores the depths of human consciousness and the haunting question: "Do you also hear voices?" This award-winning film has been nominated for 15+ awards at national and international film festivals.',
      release_date: new Date('2021-06-01'),
      vote_average: 8.7,
      poster_path: '/images/movies/9.jpeg',
      backdrop_path: '/images/movies/9.jpeg',
      genre_ids: '[53,27,18]',
      original_language: 'hi',
      video: true,
      video_url: 'https://firebasestorage.googleapis.com/v0/b/namkeen-tv-2e1b5.appspot.com/o/ANTERVYATHAA%20-%20AMAZON%20PRIME%20-%20June%202021.mp4?alt=media&token=1c75ecd0-1551-4ea7-9453-a3a60949d5eb',
      trailer_url: 'https://youtu.be/rcERXIpD3SI?si=w8utbsnpzuPMA1AU'
    },
    {
      title: 'Chunky Pandey',
      poster_path: '/images/movies/posterImage-1758264640756-215014902.jpeg',
      backdrop_path: '/images/movies/posterImage-1758264640756-215014902.jpeg',
      genre_ids: '[18]',
      original_language: 'en'
    },
    {
      title: 'Chunky Pandey',
      poster_path: '/images/movies/posterImage-1758264642841-117682372.jpeg',
      backdrop_path: '/images/movies/posterImage-1758264642841-117682372.jpeg',
      genre_ids: '[18]',
      original_language: 'en'
    },
    {
      title: 'Chunky Pandey',
      poster_path: '/images/movies/posterImage-1758264650060-623848046.jpeg',
      backdrop_path: '/images/movies/posterImage-1758264650060-623848046.jpeg',
      genre_ids: '[18]',
      original_language: 'en'
    },
    {
      title: 'Chunky Ponky',
      poster_path: '/images/movies/posterImage-1758264858587-836182551.jpeg',
      backdrop_path: '/images/movies/posterImage-1758264640756-215014902.jpeg',
      genre_ids: '[18]',
      original_language: 'en'
    }
  ];

  for (const movie of movies) {
    await prisma.movie.create({
      data: movie
    });
  }
  console.log('✅ Movies seeded');

  // Insert TV series data
  const tvSeries = [
    {
      name: 'poopoo',
      poster_path: '/images/tv_series/posterImage-1758265351021-660240754.jpeg',
      backdrop_path: '/images/tv_series/posterImage-1758265200614-911729768.jpeg',
      genre_ids: '[18]',
      original_language: 'en'
    }
  ];

  for (const series of tvSeries) {
    await prisma.tvSeries.create({
      data: series
    });
  }
  console.log('✅ TV Series seeded');

  // Insert seasons data
  const seasons = [
    {
      tv_series_id: 1,
      season_number: 1,
      poster_path: '/images/tv_series/default-season-poster.jpg'
    }
  ];

  for (const season of seasons) {
    await prisma.season.create({
      data: season
    });
  }
  console.log('✅ Seasons seeded');

  console.log('🎉 Database seeded successfully!');
}

main()
  .catch((e) => {
    console.error('❌ Error seeding database:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });