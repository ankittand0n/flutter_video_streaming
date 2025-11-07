const { PrismaClient } = require('@prisma/client');

const prisma = new PrismaClient({
  datasources: {
    db: {
      url: process.env.DIRECT_URL || process.env.DATABASE_URL
    }
  }
});

async function createTables() {
  console.log('Creating database tables...\n');
  
  try {
    // Create tables using raw SQL based on the Prisma schema
    
    // 1. Create user table
    console.log('Creating user table...');
    await prisma.$executeRawUnsafe(`
      CREATE TABLE IF NOT EXISTS "user" (
        "id" SERIAL PRIMARY KEY,
        "email" VARCHAR(255) UNIQUE NOT NULL,
        "password" TEXT NOT NULL,
        "username" VARCHAR(255) UNIQUE NOT NULL,
        "profile_name" VARCHAR(255),
        "profile_avatar" TEXT,
        "is_active" BOOLEAN DEFAULT true,
        "last_login" TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP,
        "created_at" TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP,
        "updated_at" TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP
      );
    `);
    console.log('✓ User table created');
    
    // 2. Create genre table
    console.log('Creating genre table...');
    await prisma.$executeRawUnsafe(`
      CREATE TABLE IF NOT EXISTS "genres" (
        "id" SERIAL PRIMARY KEY,
        "name" VARCHAR(255) NOT NULL,
        "type" VARCHAR(50) NOT NULL,
        "created_at" TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP
      );
    `);
    console.log('✓ Genres table created');
    
    // 3. Create movies table
    console.log('Creating movies table...');
    await prisma.$executeRawUnsafe(`
      CREATE TABLE IF NOT EXISTS "movies" (
        "id" SERIAL PRIMARY KEY,
        "title" VARCHAR(255) NOT NULL,
        "overview" TEXT,
        "release_date" TIMESTAMP(3),
        "vote_average" DOUBLE PRECISION,
        "poster_path" TEXT,
        "backdrop_path" TEXT,
        "genre_ids" TEXT,
        "video_url" TEXT,
        "trailer_url" TEXT,
        "trailer_urls" TEXT[] DEFAULT '{}',
        "created_at" TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP,
        "updated_at" TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP
      );
    `);
    console.log('✓ Movies table created');
    
    // 4. Create tv_series table
    console.log('Creating tv_series table...');
    await prisma.$executeRawUnsafe(`
      CREATE TABLE IF NOT EXISTS "tv_series" (
        "id" SERIAL PRIMARY KEY,
        "name" VARCHAR(255) NOT NULL,
        "overview" TEXT,
        "first_air_date" TIMESTAMP(3),
        "last_air_date" TIMESTAMP(3),
        "vote_average" DOUBLE PRECISION,
        "poster_path" TEXT,
        "backdrop_path" TEXT,
        "genre_ids" TEXT,
        "number_of_seasons" INTEGER,
        "number_of_episodes" INTEGER,
        "status" VARCHAR(50),
        "seasons" TEXT,
        "video_url" TEXT,
        "trailer_url" TEXT,
        "trailer_urls" TEXT[] DEFAULT '{}',
        "created_at" TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP,
        "updated_at" TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP
      );
    `);
    console.log('✓ TV Series table created');
    
    // 5. Create seasons table
    console.log('Creating seasons table...');
    await prisma.$executeRawUnsafe(`
      CREATE TABLE IF NOT EXISTS "seasons" (
        "id" SERIAL PRIMARY KEY,
        "tv_series_id" INTEGER,
        "season_number" INTEGER,
        "name" VARCHAR(255),
        "overview" TEXT,
        "poster_path" TEXT,
        "air_date" TIMESTAMP(3),
        "episode_count" INTEGER,
        "created_at" TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP,
        "updated_at" TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP
      );
    `);
    console.log('✓ Seasons table created');
    
    // 6. Create rating table
    console.log('Creating rating table...');
    await prisma.$executeRawUnsafe(`
      CREATE TABLE IF NOT EXISTS "rating" (
        "id" SERIAL PRIMARY KEY,
        "user_id" INTEGER NOT NULL,
        "media_type" VARCHAR(50) NOT NULL,
        "media_id" VARCHAR(255) NOT NULL,
        "rating" DECIMAL(3,1) NOT NULL,
        "created_at" TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP,
        "updated_at" TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP,
        CONSTRAINT "rating_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "user"("id") ON DELETE CASCADE,
        CONSTRAINT "rating_unique_user_rating" UNIQUE ("user_id", "media_type", "media_id")
      );
    `);
    
    await prisma.$executeRawUnsafe(`
      CREATE INDEX IF NOT EXISTS "rating_user_id_idx" ON "rating"("user_id");
    `);
    console.log('✓ Rating table created');
    
    // 7. Create watchlist table
    console.log('Creating watchlist table...');
    await prisma.$executeRawUnsafe(`
      CREATE TABLE IF NOT EXISTS "watchlist" (
        "id" SERIAL PRIMARY KEY,
        "user_id" INTEGER NOT NULL,
        "media_type" VARCHAR(50) NOT NULL,
        "media_id" VARCHAR(255) NOT NULL,
        "title" VARCHAR(255) NOT NULL,
        "poster_path" TEXT,
        "created_at" TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP,
        CONSTRAINT "watchlist_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "user"("id") ON DELETE CASCADE,
        CONSTRAINT "watchlist_unique_user_media" UNIQUE ("user_id", "media_type", "media_id")
      );
    `);
    
    await prisma.$executeRawUnsafe(`
      CREATE INDEX IF NOT EXISTS "watchlist_user_id_idx" ON "watchlist"("user_id");
    `);
    console.log('✓ Watchlist table created');
    
    console.log('\n✅ All tables created successfully!');
    
    // Verify tables
    const tables = await prisma.$queryRawUnsafe(`
      SELECT table_name 
      FROM information_schema.tables 
      WHERE table_schema = 'public' AND table_name != '_prisma_migrations'
      ORDER BY table_name;
    `);
    
    console.log('\nCreated tables:');
    tables.forEach(t => console.log(`  - ${t.table_name}`));
    
  } catch (error) {
    console.error('Error creating tables:', error);
    throw error;
  } finally {
    await prisma.$disconnect();
  }
}

createTables();
