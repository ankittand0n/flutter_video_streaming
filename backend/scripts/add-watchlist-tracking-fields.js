const { PrismaClient } = require('@prisma/client');

const prisma = new PrismaClient({
  datasources: {
    db: {
      url: process.env.DIRECT_URL || process.env.DATABASE_URL
    }
  }
});

async function addWatchlistFields() {
  console.log('Adding tracking fields to watchlist table...\n');
  
  try {
    // Add watched column
    console.log('Adding watched column...');
    await prisma.$executeRawUnsafe(`
      ALTER TABLE "watchlist" 
      ADD COLUMN IF NOT EXISTS "watched" BOOLEAN DEFAULT false;
    `);
    console.log('✓ watched column added');
    
    // Add watched_at column
    console.log('Adding watched_at column...');
    await prisma.$executeRawUnsafe(`
      ALTER TABLE "watchlist" 
      ADD COLUMN IF NOT EXISTS "watched_at" TIMESTAMP(3);
    `);
    console.log('✓ watched_at column added');
    
    // Add priority column
    console.log('Adding priority column...');
    await prisma.$executeRawUnsafe(`
      ALTER TABLE "watchlist" 
      ADD COLUMN IF NOT EXISTS "priority" VARCHAR(50);
    `);
    console.log('✓ priority column added');
    
    // Add notes column
    console.log('Adding notes column...');
    await prisma.$executeRawUnsafe(`
      ALTER TABLE "watchlist" 
      ADD COLUMN IF NOT EXISTS "notes" TEXT;
    `);
    console.log('✓ notes column added');
    
    console.log('\n✅ All watchlist tracking fields added successfully!');
    
    // Show table structure
    const columns = await prisma.$queryRawUnsafe(`
      SELECT column_name, data_type, is_nullable, column_default
      FROM information_schema.columns
      WHERE table_name = 'watchlist'
      ORDER BY ordinal_position;
    `);
    
    console.log('\nWatchlist table structure:');
    columns.forEach(col => {
      console.log(`  - ${col.column_name} (${col.data_type}) ${col.is_nullable === 'NO' ? 'NOT NULL' : 'NULL'} ${col.column_default ? `DEFAULT ${col.column_default}` : ''}`);
    });
    
  } catch (error) {
    console.error('Error adding fields:', error);
    throw error;
  } finally {
    await prisma.$disconnect();
  }
}

addWatchlistFields();
