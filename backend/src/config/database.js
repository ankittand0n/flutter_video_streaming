const prisma = require('../prisma/client');

const connectDB = async () => {
  try {
    await prisma.$connect();
    console.log('� Prisma connected to database');

    process.on('SIGINT', async () => {
      await prisma.$disconnect();
      console.log('Prisma disconnected through app termination');
      process.exit(0);
    });
  } catch (error) {
    console.error('❌ Database connection error:', error);
    process.exit(1);
  }
};

module.exports = connectDB;
