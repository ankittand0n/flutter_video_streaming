const prisma = require('../src/prisma/client');

async function fixGenreIds() {
  console.log('Starting genre_ids cleanup...');
  
  try {
    // Get all movies
    const movies = await prisma.movie.findMany();
    console.log(`Found ${movies.length} movies to check`);
    
    let fixed = 0;
    
    for (const movie of movies) {
      if (movie.genre_ids) {
        let needsUpdate = false;
        let newGenreIds = movie.genre_ids;
        
        try {
          // Try to parse as JSON
          const parsed = JSON.parse(movie.genre_ids);
          
          // If it's not an array, we need to fix it
          if (!Array.isArray(parsed)) {
            needsUpdate = true;
            // Convert single number to array
            newGenreIds = `[${parsed}]`;
          }
        } catch (e) {
          // Not valid JSON, needs fixing
          needsUpdate = true;
          
          // Check if it's a plain number
          if (/^\d+$/.test(movie.genre_ids.trim())) {
            // Convert "22" to "[22]"
            newGenreIds = `[${movie.genre_ids.trim()}]`;
          } else {
            // Try to extract numbers and make an array
            const numbers = movie.genre_ids.match(/\d+/g);
            if (numbers && numbers.length > 0) {
              newGenreIds = `[${numbers.join(',')}]`;
            } else {
              // Can't fix, set to empty array
              newGenreIds = '[]';
            }
          }
        }
        
        if (needsUpdate) {
          await prisma.movie.update({
            where: { id: movie.id },
            data: { genre_ids: newGenreIds }
          });
          console.log(`Fixed movie ${movie.id}: "${movie.genre_ids}" -> "${newGenreIds}"`);
          fixed++;
        }
      }
    }
    
    console.log(`\n✅ Fixed ${fixed} movies`);
    console.log(`✅ ${movies.length - fixed} movies were already OK`);
    
  } catch (error) {
    console.error('Error:', error);
  } finally {
    await prisma.$disconnect();
  }
}

fixGenreIds();
