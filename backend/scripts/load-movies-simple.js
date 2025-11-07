const prisma = require('../src/prisma/client');

// Simplified movie data matching the current schema
const movies = [
  {
    title: 'Antervyathaa',
    overview: 'A psychological thriller that explores the depths of human consciousness and the haunting question: "Do you also hear voices?" This award-winning film has been nominated for 15+ awards at national and international film festivals.',
    release_date: new Date('2021-06-01'),
    vote_average: 8.7,
    poster_path: 'https://storage.googleapis.com/namkeen-tv/content/1/images/poster-1.jpeg',
    backdrop_path: 'https://storage.googleapis.com/namkeen-tv/content/1/images/backdrop-1.jpeg',
    genre_ids: '22',
    video_url: 'https://storage.googleapis.com/namkeen-tv/content/1/movie/master.m3u8',
    trailer_url: 'https://storage.googleapis.com/namkeen-tv/content/1/trailer/master.m3u8'
  },
  {
    title: 'Firauti',
    overview: 'Firauti',
    release_date: new Date('2025-10-18'),
    vote_average: 8.0,
    poster_path: 'https://storage.googleapis.com/namkeen-tv/content/2/images/poster-1.jpeg',
    backdrop_path: 'https://storage.googleapis.com/namkeen-tv/content/2/images/backdrop-1.jpeg',
    genre_ids: '22',
    trailer_url: 'https://firebasestorage.googleapis.com/v0/b/namkeen-tv-2e1b5.appspot.com/o/Pahal%20Kaun%20Karega%20Trailer%20_UPDATED.mp4?alt=media&token=40f6c4dc-92c2-40ce-a9e8-0646c3ef2944'
  },
  {
    title: 'Pahal Kaun Karega',
    overview: 'Pahal',
    release_date: new Date('2025-10-18'),
    vote_average: 8.0,
    poster_path: 'https://storage.googleapis.com/namkeen-tv/content/3/images/poster-1.jpeg',
    backdrop_path: 'https://storage.googleapis.com/namkeen-tv/content/3/images/backdrop-1.jpeg',
    genre_ids: '22',
    video_url: 'https://storage.googleapis.com/namkeen-tv/content/3/movie/master.m3u8',
    trailer_url: 'https://storage.googleapis.com/namkeen-tv/content/3/trailer/master.m3u8'
  },
  {
    title: 'Katputali',
    overview: 'Katputali',
    release_date: new Date('2025-10-18'),
    vote_average: 8.0,
    poster_path: 'https://storage.googleapis.com/namkeen-tv/content/4/images/poster-1.jpeg',
    backdrop_path: 'https://storage.googleapis.com/namkeen-tv/content/4/images/backdrop-1.jpeg',
    genre_ids: '22',
    video_url: 'https://storage.googleapis.com/namkeen-tv/content/4/movie/master.m3u8',
    trailer_url: 'https://storage.googleapis.com/namkeen-tv/content/4/trailer/master.m3u8'
  },
  {
    title: 'Love Story 1998',
    overview: 'Love Story 1998',
    release_date: new Date('2025-10-18'),
    vote_average: 8.0,
    poster_path: 'https://storage.googleapis.com/namkeen-tv/content/5/images/poster-1.jpeg',
    backdrop_path: 'https://storage.googleapis.com/namkeen-tv/content/5/images/backdrop-1.jpeg',
    genre_ids: '22',
    video_url: 'https://storage.googleapis.com/namkeen-tv/content/5/movie/master.m3u8',
    trailer_url: 'https://storage.googleapis.com/namkeen-tv/content/5/trailer/master.m3u8'
  },
  {
    title: 'Jaala',
    overview: 'Jaala',
    release_date: new Date('2025-10-18'),
    vote_average: 8.0,
    poster_path: 'https://storage.googleapis.com/namkeen-tv/content/6/images/poster-1.jpeg',
    backdrop_path: 'https://storage.googleapis.com/namkeen-tv/content/6/images/backdrop-1.jpeg',
    genre_ids: '22',
    video_url: 'https://storage.googleapis.com/namkeen-tv/content/6/movie/master.m3u8',
    trailer_url: 'https://storage.googleapis.com/namkeen-tv/content/6/trailer/master.m3u8'
  },
  {
    title: 'Jagamemaya',
    overview: 'Jagamemaya',
    release_date: new Date('2025-10-18'),
    vote_average: 8.0,
    poster_path: 'https://storage.googleapis.com/namkeen-tv/content/7/images/poster-1.jpeg',
    backdrop_path: 'https://storage.googleapis.com/namkeen-tv/content/7/images/backdrop-1.jpeg',
    genre_ids: '22',
    video_url: 'https://storage.googleapis.com/namkeen-tv/content/7/movie/master.m3u8',
    trailer_url: 'https://storage.googleapis.com/namkeen-tv/content/7/trailer/master.m3u8'
  },
  {
    title: 'Skull: The Mask',
    overview: 'Skull: The Mask',
    release_date: new Date('2020-07-30'),
    vote_average: 5.9,
    poster_path: '/uD份K5b5zvKuFPbmARh5b7dC9iIG.jpg',
    backdrop_path: '/aPQWLWRp5bFMEWwGWqviSFAWOkl.jpg',
    genre_ids: '27,53',
    video_url: 'https://test.com/skull.m3u8',
    trailer_url: 'https://www.youtube.com/watch?v=lbRvNo2aLVw'
  },
  {
    title: 'Barbarous Mexico',
    overview: 'Eight Mexican directors unite to bring tales of the most brutally terrifying Mexican traditions and legends to vividly shocking life.',
    release_date: new Date('2014-10-18'),
    vote_average: 5.3,
    poster_path: '/iohVAmRXmkX0h72Z9pJGhcNxc4x.jpg',
    backdrop_path: '/nZPbJJiK4XShgiflg2Fx5NJ0Fva.jpg',
    genre_ids: '27,53',
    video_url: 'https://test.com/barbarous.m3u8',
    trailer_url: 'https://www.youtube.com/watch?v=8tHFsPJFohA'
  },
  {
    title: 'Ghost Killers vs. Bloody Mary',
    overview: 'A group of three youtubers who call themselves experts in supernatural beings decide to win public recognition once and for all...',
    release_date: new Date('2018-09-13'),
    vote_average: 6.1,
    poster_path: '/dZxWFxw5aZEayVq6vHJDfpfBB4s.jpg',
    backdrop_path: '/hAI77MdSH9WTZNvRG0fcvSkRYr.jpg',
    genre_ids: '35,27',
    video_url: 'https://test.com/ghost.m3u8',
    trailer_url: 'https://www.youtube.com/watch?v=JYNcD7V4nF0'
  },
  {
    title: 'The Barge People',
    overview: 'Set on the canals amid the glorious British countryside, two sisters and their boyfriends head off for a relaxing weekend away on a barge...',
    release_date: new Date('2018-08-21'),
    vote_average: 4.7,
    poster_path: '/4EzKKgkAWKv4LdOe8TEiClQpOVD.jpg',
    backdrop_path: '/hHQ6sN8M1padNW7hFBWPGkYT4Js.jpg',
    genre_ids: '27',
    video_url: 'https://test.com/barge.m3u8',
    trailer_url: 'https://www.youtube.com/watch?v=lbRvNo2aLVw'
  },
  {
    title: 'Bangkok Hell',
    overview: 'In a desolate place, a discovery by a mysterious girl leads to the opening of multiple portals...',
    release_date: new Date('2021-08-13'),
    vote_average: 5.5,
    poster_path: '/szp1lxfJcBvyJOZzMWvjPLRNqXp.jpg',
    backdrop_path: '/3HX7V0kCVF4y8xSR3ORLIzVyFqI.jpg',
    genre_ids: '27,28,12',
    video_url: 'https://test.com/bangkok.m3u8',
    trailer_url: 'https://www.youtube.com/watch?v=F5XMj9j2zPM'
  },
  {
    title: 'Test Movie',
    overview: 'This is a test movie for development purposes',
    release_date: new Date('2024-01-01'),
    vote_average: 7.0,
    poster_path: '/test.jpg',
    backdrop_path: '/test-backdrop.jpg',
    genre_ids: '28,12',
    video_url: 'https://test.com/test.m3u8',
    trailer_url: 'https://www.youtube.com/watch?v=test'
  }
];

async function loadMovies() {
  try {
    console.log('🎬 Starting movie seed process...\n');
    
    // Connect to database
    await prisma.$connect();
    console.log('✅ Database connected\n');
    
    // Clear existing movies
    const deleted = await prisma.movie.deleteMany({});
    console.log(`🗑️  Deleted ${deleted.count} existing movies\n`);
    
    // Reset the ID sequence
    await prisma.$executeRawUnsafe('ALTER SEQUENCE movies_id_seq RESTART WITH 1');
    console.log('🔄 Reset movie ID sequence to 1\n');
    
    // Insert movies
    let created = 0;
    for (const movie of movies) {
      try {
        await prisma.movie.create({ data: movie });
        console.log(`✅ Created: ${movie.title}`);
        created++;
      } catch (error) {
        console.error(`❌ Failed to create "${movie.title}":`, error.message);
      }
    }
    
    console.log(`\n📊 Summary: Created ${created}/${movies.length} movies`);
    
    // Verify
    const count = await prisma.movie.count();
    console.log(`✅ Total movies in database: ${count}\n`);
    
  } catch (error) {
    console.error('❌ Error:', error.message);
    throw error;
  } finally {
    await prisma.$disconnect();
  }
}

loadMovies()
  .then(() => {
    console.log('✅ Movie seed completed successfully!');
    process.exit(0);
  })
  .catch((error) => {
    console.error('❌ Movie seed failed:', error);
    process.exit(1);
  });
