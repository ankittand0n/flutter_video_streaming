const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const compression = require('compression');
const morgan = require('morgan');
const rateLimit = require('express-rate-limit');
const path = require('path');

const config = require('./config/config');
const connectDB = require('./config/database');

const authRoutes = require('./routes/auth');
const userRoutes = require('./routes/user');
const tmdbRoutes = require('./routes/tmdb');
const watchlistRoutes = require('./routes/watchlist');
const ratingRoutes = require('./routes/rating');
const moviesRoutes = require('./routes/movies');
const tvSeriesRoutes = require('./routes/tv_series');
const seasonsRoutes = require('./routes/seasons');
const genresRoutes = require('./routes/genres');

const app = express();

// Connect to Database (non-blocking - continues in background)
connectDB().catch(err => {
  console.error('❌ Failed to connect to database:', err);
  // Don't exit immediately - let health checks fail gracefully
});

// Security middleware
if (config.security.helmetEnabled) {
  app.use(helmet());
}

// CORS configuration
if (config.cors.enabled) {
  app.use(cors({
    origin: config.cors.origin,
    methods: config.cors.methods,
    allowedHeaders: config.cors.allowedHeaders,
    exposedHeaders: config.cors.exposedHeaders,
    credentials: config.cors.credentials,
    maxAge: config.cors.maxAge
  }));
}

// Rate limiting - attach to apiRouter to limit API endpoints
let limiter;
if (config.rateLimit.enabled) {
  limiter = rateLimit({
    windowMs: config.rateLimit.windowMs,
    max: config.rateLimit.max,
    message: config.rateLimit.message,
    standardHeaders: true,
    legacyHeaders: false,
    skip: () => config.rateLimit.skip
  });
  // Note: limiter will be applied to apiRouter after it's declared below
}

// Body parsing middleware
app.use(express.json({ limit: config.api.requestLimit }));
app.use(express.urlencoded({ extended: true, limit: config.api.requestLimit }));

// Compression middleware
if (config.security.compressionEnabled) {
  app.use(compression());
}

// Logging middleware - only verbose in development
if (config.server.isDev) {
  app.use(morgan(config.logging.morganFormat));
} else if (config.logging.level === 'debug') {
  app.use(morgan('combined'));
}

// API routes
const apiRouter = express.Router();

// Root API endpoint
apiRouter.get('/', (req, res) => {
  res.status(200).json({
    name: 'Netflix Clone API',
    version: '1.0.0',
    environment: config.server.env,
    timestamp: new Date().toISOString()
  });
});

// Health check endpoint
apiRouter.get('/health', (req, res) => {
  res.status(200).json({ 
    status: 'OK', 
    environment: config.server.env,
    timestamp: new Date().toISOString(),
    uptime: process.uptime()
  });
});
// Apply rate limiter to apiRouter if enabled (BEFORE routes)
if (limiter) {
  apiRouter.use(limiter);
}

apiRouter.use('/auth', authRoutes);
apiRouter.use('/user', userRoutes);
apiRouter.use('/tmdb', tmdbRoutes);
apiRouter.use('/watchlist', watchlistRoutes);
apiRouter.use('/rating', ratingRoutes);
apiRouter.use('/movies', moviesRoutes);
apiRouter.use('/tv', tvSeriesRoutes);
apiRouter.use('/seasons', seasonsRoutes);
apiRouter.use('/genres', genresRoutes);

// Mount all API routes at /api prefix
app.use('/api', apiRouter);

// Serve admin GUI static files
const adminDistPath = path.join(__dirname, '../public/admin');
app.use(express.static(adminDistPath));

// SPA fallback - serve index.html ONLY for non-API GET requests
app.get('*', (req, res, next) => {
  // If it's an API request, let it fall through to error handler
  if (req.path.startsWith('/api')) {
    return next();
  }
  // Otherwise serve admin SPA
  res.sendFile(path.join(adminDistPath, 'index.html'));
});

// Global error handler
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(err.status || 500).json({
    error: config.server.isDev ? err.message : 'Internal server error',
    ...(config.development.showErrorTraces && { stack: err.stack })
  });
});

// Start server
const startServer = () => {
  try {
    app.listen(config.server.port, config.server.host, () => {
      console.log(`🚀 Server running on http://${config.server.host}:${config.server.port}`);
      console.log(`📱 Environment: ${config.server.env}`);
      console.log(`🔗 Health check: http://${config.server.host}:${config.server.port}/api/health`);
      console.log(`🌐 API Base URL: http://${config.server.host}:${config.server.port}/api`);
      console.log(`🖥️  Admin GUI: http://${config.server.host}:${config.server.port}/`);
    });
  } catch (error) {
    console.error('Failed to start server:', error);
    process.exit(1);
  }
};

// Start server only if this file is run directly (not required as module)
if (require.main === module) {
  startServer();
}

module.exports = app;
