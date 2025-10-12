const prisma = require('../src/prisma/client');

async function main() {
  const email = process.env.ADMIN_EMAIL || 'admin@example.com'
  const username = process.env.ADMIN_USERNAME || 'admin'
  const password = 'admin123' // Simplified password for testing
  
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

  // Let Prisma handle password hashing

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
