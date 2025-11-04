const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function checkColumns() {
  try {
    const result = await prisma.$queryRawUnsafe(
      `SELECT column_name, data_type FROM information_schema.columns WHERE table_name='user' ORDER BY ordinal_position`
    );
    console.log('\nCurrent user table columns:');
    result.forEach(col => console.log(`  - ${col.column_name}: ${col.data_type}`));
  } catch (error) {
    console.error('Error:', error.message);
  } finally {
    await prisma.$disconnect();
  }
}

checkColumns();
