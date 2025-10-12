const prisma = require('../src/prisma/client');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

async function main() {
  const email = process.env.ADMIN_EMAIL || 'admin@example.com'
  const username = process.env.ADMIN_USERNAME || 'admin'
  const password = 'admin123' // Simplified password for testing
  
  // Note: Password will be hashed automatically by Prisma middleware
  
  // Delete any existing admin users with same email or username
  try {
    await prisma.user.deleteMany({
      where: {
        OR: [
          { email },
          { username }
        ]
      }
    });
    console.log('Cleaned up any existing admin users');
  } catch (error) {
    console.log('No existing admin users to clean up');
  }

  const user = await prisma.user.create({
    data: {
      email: email.toLowerCase(),
      username: username.toLowerCase(),
      password: password,
      profileName: 'Admin',
      subscriptionPlan: 'premium',
      subscriptionStatus: 'active'
    }
  })

  console.log('Created admin user:', {
    id: user.id,
    email: user.email,
    username: user.username
  })

  // Test login functionality
  console.log('\n--- Testing Login Functionality ---')
  
  try {
    // Test password comparison with the stored (hashed) password
    const isPasswordValid = await bcrypt.compare(password, user.password);
    console.log('Password validation test:', isPasswordValid ? 'PASSED' : 'FAILED');
    
    if (!isPasswordValid) {
      throw new Error('Password validation failed');
    }
    
    // Test JWT token generation
    const token = jwt.sign(
      { userId: user.id },
      process.env.JWT_SECRET || 'your-super-secret-jwt-key-change-this-in-production',
      { expiresIn: '7d' }
    );
    console.log('JWT token generation test: PASSED');
    
    // Test JWT token verification
    const decoded = jwt.verify(token, process.env.JWT_SECRET || 'your-super-secret-jwt-key-change-this-in-production');
    console.log('JWT token verification test: PASSED');
    
    // Test user lookup by decoded userId
    const foundUser = await prisma.user.findUnique({ where: { id: decoded.userId } });
    console.log('User lookup test:', foundUser ? 'PASSED' : 'FAILED');
    
    console.log('\n✅ All authentication tests PASSED!');
    console.log('Admin user is ready for login with:');
    console.log('Username: admin');
    console.log('Password: admin123');
    
  } catch (error) {
    console.error('❌ Authentication test FAILED:', error.message);
    throw error;
  }

  // Verify the user can be found
  const foundUser = await prisma.user.findUnique({ 
    where: { username: username.toLowerCase() } 
  })
  
  console.log('Verification - Can find user by username:', !!foundUser)
  console.log('Verification - Found user details:', foundUser ? {
    id: foundUser.id,
    email: foundUser.email,
    username: foundUser.username
  } : 'Not found')
}

main().catch(e => { console.error(e); process.exit(1) }).finally(() => prisma.$disconnect())
