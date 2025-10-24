const prisma = require('../src/prisma/client');
const { execSync } = require('child_process');

async function recreateAdmin() {
    try {
        // Delete existing admin
        await prisma.user.deleteMany({
            where: {
                email: 'admin@example.com'
            }
        });
        console.log('Deleted existing admin user');

        // Run the create admin script
        execSync('node scripts/create-admin-prisma.js', { stdio: 'inherit' });

        await prisma.$disconnect();
    } catch (error) {
        console.error('Error recreating admin:', error);
        process.exit(1);
    }
}

recreateAdmin();