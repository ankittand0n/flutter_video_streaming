const { PrismaClient } = require('@prisma/client');
const bcrypt = require('bcryptjs');

const prisma = new PrismaClient();

// Prisma middleware to hash user passwords on create/update
prisma.$use(async (params, next) => {
	try {
		if (params.model === 'user') {
			if ((params.action === 'create' || params.action === 'update') && params.args && params.args.data && params.args.data.password) {
				const rounds = parseInt(process.env.BCRYPT_ROUNDS) || 12
				const salt = await bcrypt.genSalt(rounds)
				params.args.data.password = await bcrypt.hash(params.args.data.password, salt)
			}
		}
	} catch (e) {
		// if hashing fails, rethrow to stop the DB write
		throw e
	}

	return next(params)
});

module.exports = prisma;
