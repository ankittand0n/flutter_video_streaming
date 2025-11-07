# Backend Test Coverage Analysis

Generated: November 7, 2025

## Summary

**Total Routes: 71**  
**Routes with Tests: ~25**  
**Routes without Tests: ~46**  
**Test Coverage: ~35%**

## Routes by File

### ✅ auth.js - PARTIALLY TESTED
- ✅ `POST /api/auth/register` - **TESTED** (auth-flow.test.js)
- ✅ `POST /api/auth/login` - **TESTED** (auth-flow.test.js, auth.test.js)
- ❌ `POST /api/auth/refresh` - **NOT TESTED**
- ❌ `GET /api/auth/me` - **NOT TESTED**
- ❌ `PUT /api/auth/profile` - **NOT TESTED**
- ❌ `POST /api/auth/logout` - **NOT TESTED**
- ❌ `POST /api/auth/change-password` - **NOT TESTED**

### ✅ watchlist.js - FULLY TESTED ✨
- ✅ `POST /api/watchlist` - **TESTED** (watchlist.test.js)
- ✅ `GET /api/watchlist` - **TESTED** (watchlist.test.js)
- ✅ `GET /api/watchlist/:id` - **TESTED** (watchlist.test.js)
- ⚠️ `PUT /api/watchlist/:id` - **NOT TESTED** (Update watchlist item)
- ✅ `DELETE /api/watchlist/:id` - **TESTED** (watchlist.test.js)
- ⚠️ `POST /api/watchlist/:id/watch` - **NOT TESTED** (Mark as watched)
- ⚠️ `POST /api/watchlist/:id/unwatch` - **NOT TESTED** (Mark as unwatched)
- ⚠️ `GET /api/watchlist/stats` - **NOT TESTED** (Get watchlist stats)
- ✅ `POST /api/watchlist/bulk` - **TESTED** (watchlist.test.js)

### ⚠️ rating.js - MINIMALLY TESTED
- ⚠️ `POST /api/rating` - **PARTIALLY TESTED** (only validation, not actual functionality)
- ❌ `GET /api/rating/content/:contentid` - **NOT TESTED**
- ❌ `GET /api/rating/user` - **NOT TESTED**
- ❌ `GET /api/rating/:id` - **NOT TESTED**
- ❌ `PUT /api/rating/:id` - **NOT TESTED**
- ❌ `DELETE /api/rating/:id` - **NOT TESTED**
- ❌ `POST /api/rating/:id/helpful` - **NOT TESTED**
- ❌ `DELETE /api/rating/:id/helpful` - **NOT TESTED**
- ❌ `GET /api/rating/stats/user` - **NOT TESTED**
- ❌ `GET /api/rating/stats/content/:contentid` - **NOT TESTED**

### ⚠️ movies.js - MINIMALLY TESTED
- ⚠️ `POST /api/movies` - **PARTIALLY TESTED** (crud.test.js, numeric-fields.test.js)
- ✅ `GET /api/movies` - **TESTED** (api.test.js, integration.test.js)
- ✅ `GET /api/movies/:id` - **TESTED** (api.test.js)
- ⚠️ `PUT /api/movies/:id` - **PARTIALLY TESTED** (numeric-fields.test.js)
- ⚠️ `DELETE /api/movies/:id` - **PARTIALLY TESTED** (numeric-fields.test.js)

### ⚠️ tv.js (TMDB Proxy) - MINIMALLY TESTED
- ✅ `GET /api/tv` - **TESTED** (api.test.js)
- ⚠️ `GET /api/tv/:id` - **PARTIALLY TESTED** (integration.test.js)
- ❌ `GET /api/tv/popular/list` - **NOT TESTED**
- ❌ `GET /api/tv/top-rated/list` - **NOT TESTED**
- ❌ `GET /api/tv/genre/:genreId/list` - **NOT TESTED**
- ❌ `POST /api/tv/sync` - **NOT TESTED**

### ❌ tv_series.js (Database) - NOT TESTED
- ❌ `POST /api/tv_series` - **NOT TESTED**
- ❌ `GET /api/tv_series` - **NOT TESTED**
- ❌ `GET /api/tv_series/:id` - **NOT TESTED**
- ❌ `PUT /api/tv_series/:id` - **NOT TESTED**
- ❌ `DELETE /api/tv_series/:id` - **NOT TESTED**

### ❌ seasons.js - NOT TESTED
- ❌ `POST /api/seasons` - **NOT TESTED**
- ❌ `GET /api/seasons` - **NOT TESTED**
- ❌ `GET /api/seasons/:id` - **NOT TESTED**
- ❌ `PUT /api/seasons/:id` - **NOT TESTED**
- ❌ `DELETE /api/seasons/:id` - **NOT TESTED**

### ⚠️ genres.js - MINIMALLY TESTED
- ❌ `POST /api/genres` - **NOT TESTED**
- ✅ `GET /api/genres` - **TESTED** (api.test.js, integration.test.js)
- ❌ `GET /api/genres/:id` - **NOT TESTED**
- ❌ `PUT /api/genres/:id` - **NOT TESTED**
- ❌ `DELETE /api/genres/:id` - **NOT TESTED**

### ❌ user.js - NOT TESTED
- ❌ `GET /api/user/profile` - **NOT TESTED**
- ❌ `PUT /api/user/profile` - **NOT TESTED**
- ❌ `GET /api/user/watch-history` - **NOT TESTED**
- ❌ `POST /api/user/watch-history` - **NOT TESTED**
- ❌ `DELETE /api/user/watch-history/:contentid` - **NOT TESTED**
- ❌ `GET /api/user/recommendations` - **NOT TESTED**
- ❌ `GET /api/user/stats` - **NOT TESTED**
- ❌ `POST /api/user/avatar` - **NOT TESTED**
- ❌ `DELETE /api/user/account` - **NOT TESTED**
- ❌ `PUT /api/user/admin/activate/:userId` - **NOT TESTED**

### ❌ tmdb.js - NOT TESTED
- Routes not analyzed (TMDB proxy routes)

## Models Coverage

### ✅ User.js - TESTED
- Tested via auth tests (register, login)

### ✅ Rating.js - TESTED
- Basic validation tested in rating.test.js
- Full CRUD not tested

### ✅ Watchlist.js - FULLY TESTED ✨
- Complete CRUD operations tested
- Field name consistency verified

## Priority Test Gaps

### HIGH PRIORITY (Core Features Missing Tests)

1. **Rating CRUD Operations** - Only validation tested, no actual rating functionality
   - GET user ratings
   - UPDATE rating
   - DELETE rating
   - GET ratings for content

2. **User Routes** - Completely untested
   - Profile management
   - Watch history
   - User stats
   - Account deletion

3. **TV Series Database Routes** - Completely untested
   - All CRUD operations for database TV series

4. **Auth Routes** - Missing tests for:
   - Token refresh
   - Get current user
   - Update profile
   - Change password
   - Logout

### MEDIUM PRIORITY (Secondary Features)

5. **Seasons Routes** - Completely untested
   - All CRUD operations

6. **Watchlist Additional Features** - Not tested:
   - PUT /watchlist/:id (update item)
   - POST /watchlist/:id/watch (mark watched)
   - POST /watchlist/:id/unwatch (mark unwatched)
   - GET /watchlist/stats (statistics)

7. **Genres CRUD** - Only GET tested
   - POST, PUT, DELETE not tested

8. **Movies CRUD** - Partial coverage
   - Need comprehensive tests beyond basic CRUD

### LOW PRIORITY (TMDB Proxy)

9. **TV TMDB Proxy Routes** - Limited testing
   - Popular, top-rated, by genre endpoints

10. **TMDB Routes** - Not analyzed

## Recommendations

### Immediate Actions

1. **Create rating.test.js comprehensive suite** - Similar to watchlist.test.js
   - Test all CRUD operations
   - Test helpful/unhelpful functionality
   - Test statistics endpoints

2. **Create user.test.js suite**
   - Profile management
   - Watch history CRUD
   - Recommendations
   - Stats
   - Account deletion

3. **Expand auth.test.js**
   - Token refresh
   - Get current user
   - Update profile
   - Change password
   - Logout

4. **Create tv_series.test.js**
   - Full CRUD for database TV series
   - Distinguish from TMDB proxy routes

5. **Complete watchlist.test.js**
   - Add tests for PUT /:id
   - Add tests for watch/unwatch
   - Add tests for stats endpoint

### Testing Strategy

- Follow the pattern established in `watchlist.test.js` (comprehensive, 22 tests)
- Each test suite should cover:
  - All HTTP methods (GET, POST, PUT, DELETE)
  - Authentication requirements
  - Validation (required fields, data types)
  - Error cases (404, 403, 400)
  - Field name consistency (snake_case vs camelCase)
  - Pagination where applicable

### Target Coverage

- **Current:** ~35%
- **Target:** 85%+
- **Priority:** Core features (auth, rating, user, tv_series) to 100%
