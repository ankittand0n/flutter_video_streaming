# Comprehensive API Test Coverage Plan

## Current Status: 78/154 tests (50.6% coverage)

### Test Coverage by Route File

#### ✅ WATCHLIST (Complete - 9/9 routes = 100%)
- [x] POST / - Create watchlist item
- [x] GET / - List with pagination/filters
- [x] GET /stats - Statistics
- [x] GET /:id - Get one item
- [x] PUT /:id - Update item
- [x] DELETE /:id - Delete item
- [x] POST /:id/watch - Mark watched
- [x] POST /:id/unwatch - Mark unwatched
- [x] POST /bulk - Bulk add
**Tests: 34 tests covering all endpoints + edge cases**

#### ✅ AUTH (Partial - 7/8 routes = 87.5%)
- [x] POST /register - Register user (comprehensive)
- [x] POST /login - Login user (comprehensive)
- [x] POST /login-username - Username login
- [x] POST /refresh - Refresh token
- [x] GET /me - Get current user
- [ ] PUT /profile - Update profile (NOT TESTED)
- [ ] POST /logout - Logout (NOT TESTED)
- [ ] POST /change-password - Change password (NOT TESTED)
**Tests: 16 tests (from auth-flow.test.js + auth.test.js)**

#### ❌ RATING (Incomplete - 0/10 routes = 0%)
- [ ] POST / - Create/update rating
- [ ] GET / - List ratings with filters
- [ ] GET /:id - Get single rating
- [ ] PUT /:id - Update rating
- [ ] DELETE /:id - Delete rating
- [ ] GET /by-content/:type/:id - Get ratings for content
- [ ] GET /by-user/:userId - Get user ratings
- [ ] POST /:id/helpful - Mark as helpful
- [ ] DELETE /:id/helpful - Unmark helpful
- [ ] GET /stats - Get statistics
**Tests: 0 tests - NEEDS COMPREHENSIVE SUITE**

#### ❌ USER (Incomplete - 0/11 routes = 0%)
- [ ] GET /profile - Get profile
- [ ] PUT /profile - Update profile
- [ ] GET /watch-history - Get watch history
- [ ] POST /watch-history - Add to watch history
- [ ] DELETE /watch-history/:id - Delete from history
- [ ] GET /recommendations - Get recommendations
- [ ] GET /stats - Get user stats
- [ ] POST /avatar - Upload avatar
- [ ] PUT /:id/activate - Admin activate user
- [ ] DELETE /account - Delete account
- [ ] GET /:id - Get user (admin)
**Tests: 0 tests - NEEDS COMPREHENSIVE SUITE**

#### ❌ TV_SERIES (Not tested - 0/5 routes = 0%)
- [ ] POST / - Create TV series
- [ ] GET / - List with pagination/filters
- [ ] GET /:id - Get single series
- [ ] PUT /:id - Update series
- [ ] DELETE /:id - Delete series
**Tests: 0 tests - NEEDS NEW TEST FILE**

#### ❌ SEASONS (Not tested - 0/5 routes = 0%)
- [ ] POST / - Create season
- [ ] GET / - List with pagination/filters
- [ ] GET /:id - Get single season
- [ ] PUT /:id - Update season
- [ ] DELETE /:id - Delete season
**Tests: 0 tests - NEEDS NEW TEST FILE**

#### ⚠️ GENRES (Minimal - 1/5 routes = 20%)
- [x] GET / - List genres (basic test in api.test.js)
- [ ] POST / - Create genre
- [ ] PUT /:id - Update genre
- [ ] DELETE /:id - Delete genre
- [ ] GET /:id - Get single genre
**Tests: 1 test - NEEDS EXPANSION**

#### ⚠️ MOVIES (Partial - 2/5 routes = 40%)
- [x] GET / - List with pagination (numeric-fields.test.js)
- [x] POST / - Create movie (numeric-fields.test.js)
- [ ] GET /:id - Get single movie
- [ ] PUT /:id - Update movie
- [ ] DELETE /:id - Delete movie
**Tests: 8 tests in numeric-fields.test.js - NEEDS EXPANSION**

### Priority Order for Implementation

1. **HIGH PRIORITY** (Core features)
   - Rating CRUD + helpful votes + stats (10 routes) - Most common user interaction after watchlist
   - User profile + watch history + stats (11 routes) - Core user features

2. **MEDIUM PRIORITY** (Content management)
   - TV Series CRUD (5 routes) - Content type equivalent to movies
   - Seasons CRUD (5 routes) - TV-specific feature

3. **LOW PRIORITY** (Already mostly covered)
   - Auth expansions (1 route) - Mostly complete
   - Genres CRUD (4 routes) - Simple endpoints
   - Movies expansions (3 routes) - Basic CRUD

### Test Suite Pattern to Follow

Each new test file should include:
1. Global setup/teardown (Prisma transactions for data isolation)
2. Helper functions for POST/PUT/GET/DELETE
3. Authentication tests (token, permissions)
4. Validation tests (required fields, data types)
5. Pagination tests (limit, offset, sorting)
6. Filter tests (query parameters)
7. Edge cases (empty results, not found, duplicates)
8. Statistics endpoints
9. Permission/authorization tests
10. Field consistency tests (snake_case)

### Coverage Target

**Current: 78/154 routes = 50.6%**
**Target: 130+/154 routes = 85%+**

**To reach 85%:**
- Complete Rating: +10 routes
- Complete User: +11 routes
- Add TV Series: +5 routes
- Add Seasons: +5 routes
- Complete Auth: +3 routes
- Expand Movies: +3 routes
- Expand Genres: +4 routes
**Total: +41 routes to reach 85% coverage**

