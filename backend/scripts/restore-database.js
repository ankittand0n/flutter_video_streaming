const { PrismaClient } = require('@prisma/client');
const fs = require('fs');
const path = require('path');

const prisma = new PrismaClient({
  datasources: {
    db: {
      url: process.env.DIRECT_URL
    }
  }
});

async function restoreData() {
  console.log('Restoring database from backup...\n');
  
  try {
    // Read the backup SQL file
    const backupPath = path.join(__dirname, '..', 'database_backup_data.sql');
    const backupSQL = fs.readFileSync(backupPath, 'utf8');
    
    console.log('Executing SQL statements...\n');
    
    // Split into individual INSERT statements
    const statements = backupSQL
      .split('\n')
      .filter(line => line.trim().startsWith('INSERT INTO'))
      .map(line => line.trim());
    
    console.log(`Found ${statements.length} INSERT statements\n`);
    
    let executed = 0;
    for (const statement of statements) {
      try {
        await prisma.$executeRawUnsafe(statement);
        executed++;
        if (executed % 10 === 0) {
          process.stdout.write(`\rProgress: ${executed}/${statements.length}`);
        }
      } catch (error) {
        console.error(`\nError executing: ${statement.substring(0, 80)}...`);
        console.error(`Error: ${error.message}`);
      }
    }
    
    console.log(`\n\n✓ Restored ${executed}/${statements.length} records`);
    
    // Verify restoration
    const counts = await prisma.$transaction([
      prisma.user.count(),
      prisma.genre.count(),
      prisma.movie.count(),
      prisma.tvSeries.count(),
      prisma.season.count(),
      prisma.watchlist.count(),
      prisma.rating.count()
    ]);
    
    console.log('\nDatabase Summary:');
    console.log(`  - Users: ${counts[0]}`);
    console.log(`  - Genres: ${counts[1]}`);
    console.log(`  - Movies: ${counts[2]}`);
    console.log(`  - TV Series: ${counts[3]}`);
    console.log(`  - Seasons: ${counts[4]}`);
    console.log(`  - Watchlist: ${counts[5]}`);
    console.log(`  - Ratings: ${counts[6]}`);
    
    console.log('\n✅ Database restoration complete!');
    
  } catch (error) {
    console.error('Error restoring data:', error);
    throw error;
  } finally {
    await prisma.$disconnect();
  }
}

restoreData();
