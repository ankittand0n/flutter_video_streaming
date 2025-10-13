const jwt = require('jsonwebtoken');
const prisma = require('../prisma/client');

const auth = async (req, res, next) => {
  try {
    const token = req.header('Authorization')?.replace('Bearer ', '');
    
    if (!token) {
      return res.status(401).json({ 
        error: 'Access denied. No token provided.' 
      });
    }

    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    const user = await prisma.user.findUnique({ where: { id: decoded.userid } });
    
    if (!user) {
      return res.status(401).json({ 
        error: 'Invalid token. User not found.' 
      });
    }

    if (!user.isActive) {
      return res.status(401).json({ 
        error: 'Account is deactivated.' 
      });
    }

    req.user = user;
    req.token = token;
    next();
  } catch (error) {
    if (error.name === 'JsonWebTokenError') {
      return res.status(401).json({ 
        error: 'Invalid token.' 
      });
    }
    if (error.name === 'TokenExpiredError') {
      return res.status(401).json({ 
        error: 'Token expired.' 
      });
    }
    res.status(500).json({ 
      error: 'Token verification failed.' 
    });
  }
};

// Optional auth middleware for routes that can work with or without authentication
const optionalAuth = async (req, res, next) => {
  try {
    const token = req.header('Authorization')?.replace('Bearer ', '');
    
    if (token) {
      const decoded = jwt.verify(token, process.env.JWT_SECRET);
      const user = await prisma.user.findUnique({ 
        where: { id: decoded.userid },
        select: { id: true, email: true, username: true, profilename: true, isactive: true }
      });
      
      if (user && user.isActive) {
        req.user = user;
        req.token = token;
      }
    }
    
    next();
  } catch (error) {
    // Continue without authentication
    next();
  }
};

// Admin middleware (you can extend this based on your needs)
const adminAuth = async (req, res, next) => {
  try {
    await auth(req, res, () => {});
    
    // Add admin check logic here if needed
    // For now, we'll just check if user exists
    if (!req.user) {
      return res.status(403).json({ 
        error: 'Access denied. Admin privileges required.' 
      });
    }
    
    next();
  } catch (error) {
    res.status(403).json({ 
      error: 'Access denied. Admin privileges required.' 
    });
  }
};

// Rate limiting middleware for auth routes
const authRateLimit = {
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 5, // limit each IP to 5 requests per windowMs
  message: 'Too many authentication attempts, please try again later.',
  standardHeaders: true,
  legacyHeaders: false,
};

module.exports = {
  auth,
  optionalAuth,
  adminAuth,
  authRateLimit
};
