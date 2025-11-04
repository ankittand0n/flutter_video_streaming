const { PrismaClient } = require('@prisma/client');
const fs = require('fs');
const path = require('path');

// Use DIRECT_URL for migrations
const prisma = new PrismaClient({
  datasources: {
    db: {
      url: process.env.DIRECT_URL
    }
  }
});

async function applyMigration() {
  console.log('Applying trailer_urls migration...\n');
  
  try {
    // Apply each SQL command individually
    console.log('1. Adding trailer_urls column to movies...');
    await prisma.$executeRawUnsafe(`ALTER TABLE "movies" ADD COLUMN IF NOT EXISTS "trailer_urls" TEXT[] DEFAULT '{}'`);
    console.log('✓ Added trailer_urls to movies');
    
    console.log('\n2. Adding trailer_urls column to tv_series...');
    await prisma.$executeRawUnsafe(`ALTER TABLE "tv_series" ADD COLUMN IF NOT EXISTS "trailer_urls" TEXT[] DEFAULT '{}'`);
    console.log('✓ Added trailer_urls to tv_series');
    
    console.log('\n3. Migrating existing movie trailers...');
    const movieResult = await prisma.$executeRawUnsafe(`
      UPDATE "movies" 
      SET "trailer_urls" = ARRAY[trailer_url]::TEXT[] 
      WHERE trailer_url IS NOT NULL AND trailer_url != '' AND (trailer_urls IS NULL OR trailer_urls = '{}')
    `);
    console.log(`✓ Migrated ${movieResult} movie trailers`);
    
    console.log('\n4. Migrating existing TV series trailers...');
    const tvResult = await prisma.$executeRawUnsafe(`
      UPDATE "tv_series" 
      SET "trailer_urls" = ARRAY[trailer_url]::TEXT[]
      WHERE trailer_url IS NOT NULL AND trailer_url != '' AND (trailer_urls IS NULL OR trailer_urls = '{}')
    `);
    console.log(`✓ Migrated ${tvResult} TV series trailers`);
    
    console.log('\n✓ Migration executed successfully');
    
    // Record the migration in _prisma_migrations table
    await prisma.$executeRawUnsafe(`
      INSERT INTO "_prisma_migrations" (
        "id",
        "checksum",
        "finished_at",
        "migration_name",
        "logs",
        "applied_steps_count"
      ) VALUES (
        '${Date.now()}-trailer-urls',
        'manual-apply',
        CURRENT_TIMESTAMP,
        '20250104000001_add_trailer_urls_array',
        'Manually applied - added trailer_urls array field',
        1
      ) ON CONFLICT DO NOTHING;
    `);
    
    console.log('✓ Recorded migration in database');
    
    // Generate Prisma Client
    console.log('\n✓ Now run: npx prisma generate');
    console.log('✓ Then restart your backend server\n');
    
  } catch (error) {
    console.error('Error applying migration:', error);
    throw error;
  } finally {
    await prisma.$disconnect();
  }
}

applyMigration();
