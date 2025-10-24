const prisma = require('../prisma/client');
const config = require('./config');

// Ensure DATABASE_URL has a low connection_limit for shared hosts
function ensureConnectionLimit(url, limit = 3) {
  try {
    if (!url) return url;
    if (url.includes('connection_limit=')) return url;
    const sep = url.includes('?') ? '&' : '?';
    return `${url}${sep}connection_limit=${limit}`;
  } catch (e) {
    return url;
  }
}

const connectDB = async () => {
  try {
    // Attempt to patch process.env.DATABASE_URL if not already limited
    if (process.env.DATABASE_URL) {
      process.env.DATABASE_URL = ensureConnectionLimit(process.env.DATABASE_URL, 3);
    }

    await prisma.$connect();
    console.log('✅ Prisma connected to database');

    process.on('SIGINT', async () => {
      await prisma.$disconnect();
      console.log('Prisma disconnected through app termination');
      process.exit(0);
    });
  } catch (error) {
    console.error('❌ Database connection error:', error);
    // In test environments, don't exit the process to allow test harness to report
    if (process.env.NODE_ENV !== 'test') process.exit(1);
  }
};

module.exports = connectDB;
