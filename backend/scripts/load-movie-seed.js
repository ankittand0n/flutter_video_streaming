const prisma = require('../src/prisma/client');

async function loadMovieSeedData() {
  console.log('��� Loading movie seed data...\n');

  const movies = [
    {
      id: 1,
      title: 'Antervyathaa',
      description: 'A psychological thriller that explores the depths of human consciousness and the haunting question: "Do you also hear voices?" This award-winning film has been nominated for 15+ awards at national and international film festivals.',
      release_date: new Date('2021-06-01'),
      director: 'Unknown',
      genre_id: 22,
      poster_path: 'https://storage.googleapis.com/namkeen-tv/content/1/images/poster-1.jpeg',
      backdrop_path: 'https://storage.googleapis.com/namkeen-tv/content/1/images/backdrop-1.jpeg',
      duration: 120,
      language: 'hi',
      rating_imdb: 8.7,
      video_url: 'https://storage.googleapis.com/namkeen-tv/content/1/movie/master.m3u8',
      trailer_url: 'https://storage.googleapis.com/namkeen-tv/content/1/trailer/master.m3u8'
    },
    {
      id: 2,
      title: 'Firauti',
      description: 'Firauti',
      release_date: new Date('2025-10-18'),
      director: 'Unknown',
      genre_id: 22,
      poster_path: 'https://storage.googleapis.com/namkeen-tv/content/2/images/poster-1.jpeg',
      backdrop_path: 'https://storage.googleapis.com/namkeen-tv/content/2/images/backdrop-1.jpeg',
      duration: 120,
      language: 'hi',
      rating_imdb: 8.0,
      trailer_url: 'https://firebasestorage.googleapis.com/v0/b/namkeen-tv-2e1b5.appspot.com/o/Pahal%20Kaun%20Karega%20Trailer%20_UPDATED.mp4?alt=media&token=40f6c4dc-92c2-40ce-a9e8-0646c3ef2944'
    },
    {
      id: 3,
      title: 'Pahal Kaun Karega',
      description: 'Pahal',
      release_date: new Date('2025-10-18'),
      director: 'Unknown',
      genre_id: 22,
      poster_path: 'https://storage.googleapis.com/namkeen-tv/content/3/images/poster-1.jpeg',
      backdrop_path: 'https://storage.googleapis.com/namkeen-tv/content/3/images/backdrop-1.jpeg',
      duration: 120,
      language: 'hi',
      rating_imdb: 8.0,
      video_url: 'https://storage.googleapis.com/namkeen-tv/content/3/movie/master.m3u8',
      trailer_url: 'https://storage.googleapis.com/namkeen-tv/content/3/trailer/master.m3u8'
    },
    {
      id: 4,
      title: 'Katputali',
      description: 'Katputali',
      release_date: new Date('2025-10-18'),
      director: 'Unknown',
      genre_id: 22,
      poster_path: 'https://storage.googleapis.com/namkeen-tv/content/4/images/poster-1.jpeg',
      backdrop_path: 'https://storage.googleapis.com/namkeen-tv/content/4/images/backdrop-1.jpeg',
      duration: 120,
      language: 'hi',
      rating_imdb: 8.0,
      video_url: 'https://storage.googleapis.com/namkeen-tv/content/4/movie/master.m3u8',
      trailer_url: 'https://storage.googleapis.com/namkeen-tv/content/4/trailer/master.m3u8'
    },
    {
      id: 5,
      title: 'Love Story 1998',
      description: 'Love Story 1998',
      release_date: new Date('1998-01-01'),
      director: 'Unknown',
      genre_id: 14,
      poster_path: 'https://storage.googleapis.com/namkeen-tv/content/5/images/poster-1.jpeg',
      backdrop_path: 'https://storage.googleapis.com/namkeen-tv/content/5/images/backdrop-1.jpeg',
      duration: 120,
      language: 'hi',
      rating_imdb: 7.5,
      video_url: 'https://storage.googleapis.com/namkeen-tv/content/5/movie/master.m3u8',
      trailer_url: 'https://storage.googleapis.com/namkeen-tv/content/5/trailer/master.m3u8'
    },
    {
      id: 6,
      title: 'Jaala',
      description: 'Jaala',
      release_date: new Date('2025-10-18'),
      director: 'Unknown',
      genre_id: 17,
      poster_path: 'https://storage.googleapis.com/namkeen-tv/content/6/images/poster-1.jpeg',
      backdrop_path: 'https://storage.googleapis.com/namkeen-tv/content/6/images/backdrop-1.jpeg',
      duration: 120,
      language: 'hi',
      rating_imdb: 7.8,
      video_url: 'https://storage.googleapis.com/namkeen-tv/content/6/movie/master.m3u8',
      trailer_url: 'https://storage.googleapis.com/namkeen-tv/content/6/trailer/master.m3u8'
    },
    {
      id: 7,
      title: 'Jagamemaya',
      description: 'Jagamemaya',
      release_date: new Date('2025-10-18'),
      director: 'Unknown',
      genre_id: 7,
      poster_path: 'https://storage.googleapis.com/namkeen-tv/content/7/images/poster-1.jpeg',
      backdrop_path: 'https://storage.googleapis.com/namkeen-tv/content/7/images/backdrop-1.jpeg',
      duration: 120,
      language: 'hi',
      rating_imdb: 7.9,
      video_url: 'https://storage.googleapis.com/namkeen-tv/content/7/movie/master.m3u8',
      trailer_url: 'https://storage.googleapis.com/namkeen-tv/content/7/trailer/master.m3u8'
    },
    {
      id: 8,
      title: 'Skull: The Mask',
      description: 'A supernatural thriller about an ancient mask',
      release_date: new Date('2020-01-01'),
      director: 'Armando Fonseca',
      genre_id: 11,
      poster_path: 'https://storage.googleapis.com/namkeen-tv/content/8/images/poster-1.jpeg',
      backdrop_path: 'https://storage.googleapis.com/namkeen-tv/content/8/images/backdrop-1.jpeg',
      duration: 90,
      language: 'pt',
      rating_imdb: 6.5,
      video_url: 'https://storage.googleapis.com/namkeen-tv/content/8/movie/master.m3u8',
      trailer_url: 'https://storage.googleapis.com/namkeen-tv/content/8/trailer/master.m3u8'
    },
    {
      id: 9,
      title: 'Barbarous Mexico',
      description: 'Eight tales of horror from Mexico',
      release_date: new Date('2014-10-18'),
      director: 'Various',
      genre_id: 11,
      poster_path: 'https://storage.googleapis.com/namkeen-tv/content/9/images/poster-1.jpeg',
      backdrop_path: 'https://storage.googleapis.com/namkeen-tv/content/9/images/backdrop-1.jpeg',
      duration: 146,
      language: 'es',
      rating_imdb: 5.8,
      video_url: 'https://storage.googleapis.com/namkeen-tv/content/9/movie/master.m3u8',
      trailer_url: 'https://storage.googleapis.com/namkeen-tv/content/9/trailer/master.m3u8'
    },
    {
      id: 10,
      title: 'Ghost Killers vs. Bloody Mary',
      description: 'Comedy horror about ghost hunters',
      release_date: new Date('2018-09-06'),
      director: 'Rodrigo Van Der Put',
      genre_id: 11,
      poster_path: 'https://storage.googleapis.com/namkeen-tv/content/10/images/poster-1.jpeg',
      backdrop_path: 'https://storage.googleapis.com/namkeen-tv/content/10/images/backdrop-1.jpeg',
      duration: 103,
      language: 'pt',
      rating_imdb: 6.2,
      video_url: 'https://storage.googleapis.com/namkeen-tv/content/10/movie/master.m3u8',
      trailer_url: 'https://storage.googleapis.com/namkeen-tv/content/10/trailer/master.m3u8'
    },
    {
      id: 11,
      title: 'The Barge People',
      description: 'Horror on the canal',
      release_date: new Date('2018-08-21'),
      director: 'Charlie Steeds',
      genre_id: 11,
      poster_path: 'https://storage.googleapis.com/namkeen-tv/content/11/images/poster-1.jpeg',
      backdrop_path: 'https://storage.googleapis.com/namkeen-tv/content/11/images/backdrop-1.jpeg',
      duration: 83,
      language: 'en',
      rating_imdb: 4.2,
      video_url: 'https://storage.googleapis.com/namkeen-tv/content/11/movie/master.m3u8',
      trailer_url: 'https://storage.googleapis.com/namkeen-tv/content/11/trailer/master.m3u8'
    },
    {
      id: 12,
      title: 'Bangkok Hell',
      description: 'Horror film set in Bangkok',
      release_date: new Date('2019-01-01'),
      director: 'Unknown',
      genre_id: 11,
      poster_path: 'https://storage.googleapis.com/namkeen-tv/content/12/images/poster-1.jpeg',
      backdrop_path: 'https://storage.googleapis.com/namkeen-tv/content/12/images/backdrop-1.jpeg',
      duration: 95,
      language: 'th',
      rating_imdb: 5.5,
      video_url: 'https://storage.googleapis.com/namkeen-tv/content/12/movie/master.m3u8',
      trailer_url: 'https://storage.googleapis.com/namkeen-tv/content/12/trailer/master.m3u8'
    },
    {
      id: 13,
      title: 'Test Movie',
      description: 'Test movie for development',
      release_date: new Date('2023-01-01'),
      director: 'Test Director',
      genre_id: 1,
      poster_path: '/test-poster.jpg',
      backdrop_path: '/test-backdrop.jpg',
      duration: 120,
      language: 'en',
      rating_imdb: 7.0
    }
  ];

  let created = 0;
  let skipped = 0;

  for (const movie of movies) {
    try {
      const existing = await prisma.movies.findUnique({
        where: { id: movie.id }
      });

      if (existing) {
        console.log(`⏭️  Movie ${movie.id} "${movie.title}" already exists, skipping...`);
        skipped++;
      } else {
        await prisma.movies.create({
          data: movie
        });
        console.log(`✅ Created movie ${movie.id}: ${movie.title}`);
        created++;
      }
    } catch (error) {
      console.error(`❌ Error creating movie ${movie.id} "${movie.title}":`, error.message);
    }
  }

  console.log(`\n��� Summary:`);
  console.log(`   ✅ Created: ${created} movies`);
  console.log(`   ⏭️  Skipped: ${skipped} movies (already existed)`);
  console.log(`   ��️  Total: ${movies.length} movies processed\n`);
}

loadMovieSeedData()
  .then(() => {
    console.log('✅ Movie seed data loaded successfully!');
    prisma.$disconnect();
  })
  .catch((error) => {
    console.error('❌ Error loading movie seed data:', error);
    prisma.$disconnect();
    process.exit(1);
  });
