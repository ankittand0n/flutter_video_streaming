# Backend Test Suite# Testing Guide



This directory contains comprehensive tests for the backend API. All tests can be run against both local and external servers.This guide explains how to run tests against both local and external (production) servers.



## Test Configuration## Test Configuration



The test configuration is managed by `test-config.js` which provides:Tests can be configured to run against:

- Single source of truth for test endpoints- **Local Server**: Tests run against your local development server

- Automatic switching between local and external servers- **External Server**: Tests run against a deployed production/staging server

- External API URL configured in `package.json` under `config.external_api_url`

## Available Test Commands

### Environment Variables

### Run All Tests Locally (Default)

- `TEST_EXTERNAL=true` - Run tests against external server```bash

- `EXTERNAL_API_URL` - Override the external API URL (optional, defaults to package.json config)npm test              # Run all tests against local server

npm run test:local    # Explicitly run all tests locally

## Test Files```



### 🌐 Tests Supporting Both Local & External### Run All Tests Against External Server

```bash

These tests work seamlessly with both local and external servers:npm run test:server   # Run all tests against external server

```

#### `api.test.js` - API Integration Tests

- API info endpoint### Run Specific API Tests

- Health check endpoint  

- Movies endpoint#### Local API Tests

- Get movie by ID```bash

- TV Series endpointnpm run test:api        # Run API tests locally (default)

- Genres endpointnpm run test:api:local  # Explicitly run API tests locally

- Rate limiting test```

- HTTPS URL validation

#### External API Tests

**Run Commands:**```bash

```bashnpm run test:api:server # Run API tests against external server

npm run test:api:local   # Local server```

npm run test:api:server  # External server

```### Other Specific Tests

```bash

#### `integration.test.js` - Public Endpoint Testsnpm run test:rating      # Run rating tests

- Health checknpm run test:numeric     # Run numeric field tests

- Movies endpointnpm run test:integration # Run integration tests

- Movie by ID```

- TV Series endpoint

- Genres endpoint## Configuration



**Run Commands:**### Setting External API URL

```bash

npm run test:integration:local   # Local serverEdit `package.json` to change the external API URL:

npm run test:integration:server  # External server

``````json

"test:server": "cross-env TEST_EXTERNAL=true EXTERNAL_API_URL=https://your-production-api.com jest",

#### `rating.test.js` - Rating Validation Tests```

- Admin rating creation (should be blocked)

- Validation tests (missing fields, invalid values)Or set it temporarily from command line:



**Run Commands:****Windows (cmd):**

```bash```cmd

npm run test:rating:local   # Local serverset TEST_EXTERNAL=true&& set EXTERNAL_API_URL=https://your-api.com&& npm test

npm run test:rating:server  # External server```

```

**Windows (PowerShell):**

#### `numeric-fields.test.js` - Numeric Field Handling```powershell

- Create movie with empty vote_average$env:TEST_EXTERNAL="true"; $env:EXTERNAL_API_URL="https://your-api.com"; npm test

- Update movie with empty/valid vote_average```

- Field validation

**Linux/Mac:**

**Run Commands:**```bash

```bashTEST_EXTERNAL=true EXTERNAL_API_URL=https://your-api.com npm test

npm run test:numeric:local   # Local server```

npm run test:numeric:server  # External server

```### Test Configuration File



#### `auth-flow.test.js` - Authentication FlowThe `test/test-config.js` file controls test behavior:

- User registration

- Login with email/username```javascript

- Duplicate email/username validationconst USE_EXTERNAL = process.env.TEST_EXTERNAL === 'true';

- Invalid credentials validationconst EXTERNAL_URL = process.env.EXTERNAL_API_URL || 'https://your-production-api.com';

- Phone number as username```



**Note:** When running against external server, cleanup is skipped (no database access).## Example Output



**Run Commands:**### Local Tests

```bash```bash

npm run test:auth-flow:local   # Local server$ npm run test:api:local

npm run test:auth-flow:server  # External server

```🧪 Running tests against: LOCAL SERVER



### 🏠 Local-Only TestsPASS test/api.test.js

  API Integration Tests - LOCAL SERVER

These tests require direct database access and only work locally:    ✓ API Info endpoint returns correct data (332 ms)

    ✓ Health check endpoint is working (50 ms)

#### `auth.test.js` - Database Authentication Tests    ✓ Movies endpoint returns data (2054 ms)

- Admin user existence verification    ✓ Can get movie by ID (216 ms)

- Password hashing validation    ✓ TV Series endpoint returns data (214 ms)

- Password verification    ✓ Genres endpoint returns data (240 ms)

```

#### `crud.test.js` - Database CRUD Tests

- Genre CRUD operations### External Tests

- Movie CRUD operations```bash

- TV Series & Season CRUD operations$ npm run test:api:server

- User, Watchlist, Rating CRUD operations

🧪 Running tests against: EXTERNAL SERVER

#### `server.test.js` - Server Startup Tests📡 External URL: https://your-production-api.com

- Server initialization

- Basic endpoint responsePASS test/api.test.js

  API Integration Tests - EXTERNAL SERVER

## Running Tests    ✓ API Info endpoint returns correct data (458 ms)

    ✓ Health check endpoint is working (234 ms)

### Run All Tests Locally    ...

```bash```

npm test

# or## Prerequisites

npm run test:local

```Make sure you have `cross-env` installed (should be in devDependencies):



### Run All Tests Against External Server```bash

```bashnpm install --save-dev cross-env

npm run test:server```

```

## Writing Tests for Both Environments

### Run Specific Test Suites

When writing new tests, use the helper from `test-config.js`:

**Local:**

```bash```javascript

npm run test:api:localconst { isExternal, getBaseUrl, getTestType } = require('./test-config');

npm run test:integration:local

npm run test:rating:localconst createRequest = () => {

npm run test:numeric:local  if (isExternal()) {

npm run test:auth-flow:local    return request(getBaseUrl());

```  }

  return request(app);

**External:**};

```bash

npm run test:api:serverdescribe(`My Test Suite - ${getTestType()}`, () => {

npm run test:integration:server  test('should work on both environments', async () => {

npm run test:rating:server    const response = await createRequest()

npm run test:numeric:server      .get('/api/endpoint')

npm run test:auth-flow:server      .expect(200);

```    // assertions...

  });

## Test Results});

```

### Local Tests

- ✅ 8 test suites, 44 tests pass## Notes

- Tests run against local Express server

- Includes database tests- **Local tests** require the local server dependencies and database

- **External tests** only test API endpoints and don't require local setup

### External Tests  - External tests may have authentication requirements

- ✅ 8 test suites, 44 tests pass (5 suites functional on external, 3 run locally)- Some tests (like database-specific tests) may only work locally

- Tests run against configured external API- Network latency will be higher for external tests

- Database tests fall back to local

- Network latency affects test duration## Troubleshooting



## Changing External API URL### Tests fail with "Cannot connect to database"

- This is expected for external tests if the test tries to access local database

Edit the `config.external_api_url` in `package.json`:- Consider using `isExternal()` to skip database-specific tests when running externally



```json### External tests fail with 404

{- Verify the `EXTERNAL_API_URL` is correct

  "config": {- Check that the external server is running and accessible

    "external_api_url": "https://your-api-url.com"- Ensure the API routes match between local and external

  }

}### Cross-env not found

``````bash

npm install --save-dev cross-env

Or set the environment variable:```

```bash
EXTERNAL_API_URL=https://your-api-url.com npm run test:server
```

## Implementation Details

### Helper Pattern

Tests use a helper pattern to abstract local vs external differences:

```javascript
const { isExternal, getBaseUrl, getTestType } = require('./test-config');

// For GET requests
const get = async (path) => {
  if (isExternal()) {
    const res = await axiosInstance.get(path);
    return { body: res.data, statusCode: res.status };
  }
  return request(app).get(path);
};

// For POST requests
const post = async (path, data, headers = {}) => {
  if (isExternal()) {
    const res = await axiosInstance.post(path, data, { headers });
    return { body: res.data, statusCode: res.status };
  }
  return request(app).post(path).send(data);
};
```

### Response Handling

Tests use flexible assertions to handle both local and external responses:

```javascript
expect(response.statusCode || response.status).toBe(200);
```

This works because:
- Supertest (local) uses `statusCode`
- Axios (external) uses `status`

## Notes

- External tests may be slower due to network latency
- External tests skip database cleanup (no direct DB access)
- Timestamps are used in external tests to avoid conflicts
- The TLSWRAP warning from Jest is harmless (axios connection pool)
