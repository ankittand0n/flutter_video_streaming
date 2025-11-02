require('dotenv').config();

const config = {
  server: {
    port: parseInt(process.env.PORT) || 3000,
    host: process.env.HOST || 'localhost',
    apiPrefix: process.env.API_PREFIX || '/api',
    env: process.env.NODE_ENV || 'development',
    isDev: process.env.NODE_ENV === 'development'
  },

  database: {
    host: process.env.DB_HOST,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    name: process.env.DB_NAME,
    port: parseInt(process.env.DB_PORT) || 3306,
    url: process.env.DATABASE_URL
  },

  auth: {
    jwtSecret: process.env.JWT_SECRET,
    jwtExpiresIn: process.env.JWT_EXPIRES_IN || '7d',
    jwtRefreshExpiresIn: process.env.JWT_REFRESH_EXPIRES_IN || '30d',
    bcryptRounds: parseInt(process.env.BCRYPT_ROUNDS) || 12
  },

  rateLimit: {
    // Enable rate limiting by env var or automatically in production
    enabled: process.env.RATE_LIMIT_ENABLED === 'true' || process.env.NODE_ENV === 'production',
    windowMs: process.env.NODE_ENV === 'development'
      ? parseInt(process.env.DEV_RATE_LIMIT_WINDOW_MS) || 1000
      : parseInt(process.env.RATE_LIMIT_WINDOW_MS) || 900000,
    max: process.env.NODE_ENV === 'development'
      ? parseInt(process.env.DEV_RATE_LIMIT_MAX_REQUESTS) || 50
      : parseInt(process.env.RATE_LIMIT_MAX_REQUESTS) || 60,
    message: process.env.RATE_LIMIT_MESSAGE || 'Too many requests',
    skip: process.env.NODE_ENV === 'development'
  },

  cors: {
    enabled: process.env.CORS_ENABLED !== 'false', // Enable by default
    origin: '*', // Allow all origins for mobile apps and any web clients
    methods: process.env.CORS_METHODS?.split(',') || ['GET', 'HEAD', 'PUT', 'PATCH', 'POST', 'DELETE'],
    allowedHeaders: process.env.CORS_ALLOWED_HEADERS?.split(',') || ['Content-Type', 'Authorization'],
    exposedHeaders: process.env.CORS_EXPOSE_HEADERS?.split(',') || [],
    credentials: false, // Must be false when origin is '*'
    maxAge: parseInt(process.env.CORS_MAX_AGE) || 86400
  },

  security: {
    helmetEnabled: process.env.HELMET_ENABLED === 'true',
    compressionEnabled: process.env.COMPRESSION_ENABLED === 'true'
  },

  api: {
    tmdbKey: process.env.TMDB_API_KEY,
    requestLimit: process.env.API_REQUEST_LIMIT_SIZE || '10mb'
  },

  logging: {
    morganFormat: process.env.MORGAN_FORMAT || 'dev',
    level: process.env.LOG_LEVEL || 'debug'
  },

  development: {
    showErrorTraces: process.env.DEV_ERROR_TRACES === 'true'
  }
};

module.exports = config;