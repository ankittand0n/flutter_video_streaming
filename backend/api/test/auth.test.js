const bcryptjs = require('bcryptjs');
const { PrismaClient } = require('@prisma/client');

const prisma = new PrismaClient();

describe('Authentication Tests', () => {
    let user;

    beforeAll(async () => {
        // Find the admin user before running tests
        user = await prisma.user.findUnique({
            where: { username: 'admin' }
        });
    });

    afterAll(async () => {
        await prisma.$disconnect();
    });

    test('Admin user exists', () => {
        expect(user).toBeDefined();
        expect(user.username).toBe('admin');
        expect(user.email).toBe('admin@example.com');
    });

    test('Admin password is correctly hashed', () => {
        expect(user.password).toBeDefined();
        expect(user.password.startsWith('$2a$')).toBe(true);
        expect(user.password.length).toBe(60);
    });

    test('Password verification works', async () => {
        const testPassword = 'admin123';
        const isMatch = await bcryptjs.compare(testPassword, user.password);
        expect(isMatch).toBe(true);
    });

    test('Wrong password fails verification', async () => {
        const wrongPassword = 'wrongpassword';
        const isMatch = await bcryptjs.compare(wrongPassword, user.password);
        expect(isMatch).toBe(false);
    });
});