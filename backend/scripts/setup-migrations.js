const { PrismaClient } = require('@prisma/client');

const prisma = new PrismaClient();

async function setupMigrations() {
  console.log('Setting up Prisma migrations table...\n');
  
  try {
    // Create _prisma_migrations table if it doesn't exist
    await prisma.$executeRawUnsafe(`
      CREATE TABLE IF NOT EXISTS "_prisma_migrations" (
        "id" VARCHAR(36) PRIMARY KEY,
        "checksum" VARCHAR(64) NOT NULL,
        "finished_at" TIMESTAMP(3),
        "migration_name" VARCHAR(255) NOT NULL,
        "logs" TEXT,
        "rolled_back_at" TIMESTAMP(3),
        "started_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
        "applied_steps_count" INTEGER NOT NULL DEFAULT 0
      );
    `);
    
    console.log('✓ Created _prisma_migrations table');
    
    // Check if init migration is already recorded
    const existing = await prisma.$queryRawUnsafe(`
      SELECT * FROM "_prisma_migrations" 
      WHERE migration_name = '20250104000000_init'
    `);
    
    if (existing.length > 0) {
      console.log('✓ Init migration already recorded');
      return;
    }
    
    // Insert the init migration record
    await prisma.$executeRawUnsafe(`
      INSERT INTO "_prisma_migrations" (
        "id",
        "checksum",
        "finished_at",
        "migration_name",
        "logs",
        "applied_steps_count"
      ) VALUES (
        'baseline-init',
        'baseline',
        CURRENT_TIMESTAMP,
        '20250104000000_init',
        'Baseline migration - existing database schema',
        1
      );
    `);
    
    console.log('✓ Recorded init migration as applied');
    console.log('\n✅ Migration system is now initialized!');
    console.log('You can now run: npx prisma migrate dev\n');
    
  } catch (error) {
    console.error('Error setting up migrations:', error);
    throw error;
  } finally {
    await prisma.$disconnect();
  }
}

setupMigrations();
