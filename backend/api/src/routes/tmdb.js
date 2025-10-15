const express = require('express');
const router = express.Router();

// TMDB integration disabled - return 503 for all TMDB proxy endpoints.
router.use((req, res) => {
  res.status(503).json({
    success: false,
    error: 'TMDB integration is disabled. External API calls are not allowed.'
  });
});

module.exports = router;
