/**
 * ════════════════════════════════════════════════════════════════════════════
 * TEST CONFIGURATION - SINGLE SOURCE OF TRUTH
 * ════════════════════════════════════════════════════════════════════════════
 * 
 * This is the ONLY place where test endpoints are configured.
 * All test files should import from this file, never hardcode URLs.
 * 
 * ────────────────────────────────────────────────────────────────────────────
 * ENVIRONMENT VARIABLES
 * ────────────────────────────────────────────────────────────────────────────
 * 
 * TEST_EXTERNAL: Set to 'true' to test against external/production server
 *                Default: undefined (tests run against local server)
 * 
 * EXTERNAL_API_URL: Full URL of your external server
 *                   Default: https://admin.namkeentv.com
 *                   Example: https://your-api.com or http://192.168.1.100:3000
 * 
 * ────────────────────────────────────────────────────────────────────────────
 * NPM SCRIPTS USAGE
 * ────────────────────────────────────────────────────────────────────────────
 * 
 * Local Tests (default):
 *   npm test                      # Run all tests locally
 *   npm run test:api:local        # API tests only
 *   npm run test:integration      # Integration tests only
 * 
 * External Server Tests:
 *   npm run test:server           # Run all tests against external server
 *   npm run test:api:server       # API tests against external
 *   npm run test:integration:server # Integration tests against external
 * 
 * ────────────────────────────────────────────────────────────────────────────
 * CHANGING THE EXTERNAL URL
 * ────────────────────────────────────────────────────────────────────────────
 * 
 * Option 1: Change the default below (affects all developers)
 * Option 2: Override via environment variable (personal testing)
 *   
 *   Windows CMD:
 *     set EXTERNAL_API_URL=https://your-api.com && npm run test:server
 *   
 *   Windows PowerShell:
 *     $env:EXTERNAL_API_URL="https://your-api.com"; npm run test:server
 *   
 *   Linux/Mac:
 *     EXTERNAL_API_URL=https://your-api.com npm run test:server
 * 
 * ════════════════════════════════════════════════════════════════════════════
 */

// ── Configuration ──
// Precedence: explicit EXTERNAL_API_URL env var -> npm package config (npm_package_config_external_api_url) -> default
const USE_EXTERNAL = process.env.TEST_EXTERNAL === 'true';
const EXTERNAL_URL = process.env.EXTERNAL_API_URL || process.env.npm_package_config_external_api_url || 'https://admin.namkeentv.com';

// ── Exports ──
module.exports = {
  // Raw values
  USE_EXTERNAL,
  EXTERNAL_URL,
  
  // Helper functions
  isExternal: () => USE_EXTERNAL,
  getBaseUrl: () => USE_EXTERNAL ? EXTERNAL_URL : null,
  getTestType: () => USE_EXTERNAL ? 'EXTERNAL SERVER' : 'LOCAL SERVER',
  
  // Test behavior helpers
  shouldSkipDbTests: () => USE_EXTERNAL,
  shouldSkipAuthTests: () => false, // Auth tests work for both local and external
  
  // Logging helper
  logConfig: () => {
    console.log('\n╔══════════════════════════════════════════════════════════╗');
    console.log('║           TEST CONFIGURATION                             ║');
    console.log('╠══════════════════════════════════════════════════════════╣');
    console.log(`║  Mode:     ${USE_EXTERNAL ? 'EXTERNAL SERVER' : 'LOCAL SERVER'}`.padEnd(59) + '║');
    if (USE_EXTERNAL) {
      console.log(`║  URL:      ${EXTERNAL_URL}`.padEnd(59) + '║');
    }
    console.log('╚══════════════════════════════════════════════════════════╝\n');
  }
};
