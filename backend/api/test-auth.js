const bcryptjs = require('bcryptjs');
const { PrismaClient } = require('@prisma/client');

const prisma = new PrismaClient();

async function testAuth() {
    try {
        // Find the admin user
        const user = await prisma.user.findUnique({
            where: { username: 'admin' }
        });

        if (!user) {
            console.log('Admin user not found!');
            return;
        }

        console.log('Found user:', {
            id: user.id,
            username: user.username,
            email: user.email,
            hasPassword: !!user.password,
            passwordLength: user.password?.length
        });

        // Test the password
        const testPassword = 'admin123'; // Simplified password for testing
        console.log('Testing with password:', testPassword);
        console.log('Stored password hash:', user.password);
        
        // Use our consistent verification method
        const isMatch = await bcryptjs.compare(testPassword, user.password);
        console.log('Password comparison result:', isMatch);

    } catch (error) {
        console.error('Error:', error);
    } finally {
        await prisma.$disconnect();
    }
}

testAuth();