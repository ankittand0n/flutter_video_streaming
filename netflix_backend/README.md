# 🚀 Netflix Backend API

A comprehensive backend API for the Flutter Netflix Clone, built with Node.js, Express, and MongoDB. This backend provides user authentication, TMDB proxy functionality, watchlist management, ratings, and user data management.

## ✨ Features

- 🔐 **JWT Authentication** - Secure user registration, login, and profile management
- 🎬 **TMDB Proxy** - Cached access to The Movie Database API with rate limiting
- 📝 **Watchlist Management** - Add, remove, and organize content in personal watchlists
- ⭐ **Rating System** - Rate and review movies/TV shows with helpful voting
- 👤 **User Profiles** - Customizable user profiles with preferences and watch history
- 📊 **Statistics** - Comprehensive user and content statistics
- 🛡️ **Security** - Rate limiting, input validation, and secure password handling
- 📱 **Mobile Optimized** - Designed for Flutter mobile applications

## 🏗️ Architecture

```
Backend/
├── src/
│   ├── config/          # Database and configuration
│   ├── middleware/      # Authentication and validation
│   ├── models/          # MongoDB schemas
│   ├── routes/          # API endpoints
│   └── server.js        # Main server file
├── package.json         # Dependencies and scripts
└── env.example          # Environment variables template
```

## 🚀 Quick Start

### Prerequisites

- Node.js (v16 or higher)
- MongoDB (local or cloud)
- TMDB API key

### Installation

1. **Clone and install dependencies:**
   ```bash
   cd netflix_backend
   npm install
   ```

2. **Set up environment variables:**
   ```bash
   cp env.example .env
   # Edit .env with your configuration
   ```

3. **Configure MongoDB:**
   - Set `MONGODB_URI` in your `.env` file
   - For local development: `mongodb://localhost:27017/netflix_clone`
   - For production: Use MongoDB Atlas or similar

4. **Get TMDB API key:**
   - Visit [The Movie Database](https://www.themoviedb.org/documentation/api)
   - Create an account and get your API key
   - Add it to `TMDB_API_KEY` in your `.env`

5. **Start the server:**
   ```bash
   # Development mode
   npm run dev
   
   # Production mode
   npm start
   ```

The server will start on `http://localhost:3000` (or your configured PORT).

## 🔧 Environment Variables

```env
# Server Configuration
PORT=3000
NODE_ENV=development

# JWT Configuration
JWT_SECRET=your-super-secret-jwt-key-change-this-in-production
JWT_EXPIRES_IN=7d

# MongoDB Configuration
MONGODB_URI=mongodb://localhost:27017/netflix_clone
MONGODB_URI_PROD=mongodb+srv://username:password@cluster.mongodb.net/netflix_clone

# TMDB API Configuration
TMDB_API_KEY=your-tmdb-api-key-here
TMDB_BASE_URL=https://api.themoviedb.org/3

# Rate Limiting
RATE_LIMIT_WINDOW_MS=900000
RATE_LIMIT_MAX_REQUESTS=100

# CORS Configuration
CORS_ORIGIN=http://localhost:3000,http://localhost:8080

# Security
BCRYPT_ROUNDS=12
```

## 📚 API Documentation

### Authentication Endpoints

#### `POST /api/auth/register`
Register a new user account.

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "password123",
  "username": "username",
  "profile": {
    "name": "Full Name",
    "age": 25,
    "language": "en",
    "maturityLevel": "adults"
  }
}
```

#### `POST /api/auth/login`
Authenticate user and get JWT token.

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "password123"
}
```

#### `GET /api/auth/me`
Get current user profile (requires authentication).

#### `PUT /api/auth/profile`
Update user profile (requires authentication).

### TMDB Proxy Endpoints

#### `GET /api/tmdb/trending`
Get trending content from TMDB.

**Query Parameters:**
- `type`: `all`, `movie`, `tv` (default: `all`)
- `time`: `day`, `week` (default: `week`)
- `page`: Page number (default: 1)

#### `GET /api/tmdb/search`
Search for movies/TV shows.

**Query Parameters:**
- `query`: Search term (required)
- `type`: `movie`, `tv`, `multi` (default: `multi`)
- `page`: Page number (default: 1)

#### `GET /api/tmdb/movie/:id`
Get detailed movie information.

#### `GET /api/tmdb/tv/:id`
Get detailed TV show information.

### Watchlist Endpoints

#### `POST /api/watchlist`
Add item to watchlist (requires authentication).

**Request Body:**
```json
{
  "contentId": "123",
  "contentType": "movie",
  "title": "Movie Title",
  "overview": "Movie description",
  "posterPath": "https://image.tmdb.org/t/p/w500/path.jpg",
  "priority": "high"
}
```

#### `GET /api/watchlist`
Get user's watchlist (requires authentication).

**Query Parameters:**
- `page`: Page number (default: 1)
- `limit`: Items per page (default: 20)
- `watched`: Filter by watched status
- `priority`: Filter by priority level
- `contentType`: Filter by content type

#### `POST /api/watchlist/:id/watch`
Mark item as watched (requires authentication).

#### `DELETE /api/watchlist/:id`
Remove item from watchlist (requires authentication).

### Rating Endpoints

#### `POST /api/rating`
Add or update rating (requires authentication).

**Request Body:**
```json
{
  "contentId": "123",
  "contentType": "movie",
  "rating": 8,
  "review": "Great movie!",
  "title": "My Review Title",
  "spoiler": false
}
```

#### `GET /api/rating/content/:contentId`
Get ratings for specific content.

**Query Parameters:**
- `contentType`: `movie` or `tv` (required)
- `page`: Page number (default: 1)
- `limit`: Items per page (default: 20)
- `rating`: Filter by minimum rating
- `spoiler`: Filter by spoiler status

#### `POST /api/rating/:id/helpful`
Mark rating as helpful (requires authentication).

### User Endpoints

#### `GET /api/user/profile`
Get user profile (requires authentication).

#### `PUT /api/user/profile`
Update user profile (requires authentication).

#### `GET /api/user/watch-history`
Get user's watch history (requires authentication).

#### `POST /api/user/watch-history`
Update watch history (requires authentication).

#### `GET /api/user/stats`
Get user statistics (requires authentication).

## 🔐 Authentication

All protected endpoints require a JWT token in the Authorization header:

```
Authorization: Bearer <your-jwt-token>
```

## 📊 Database Models

### User Model
- Profile information (name, age, language, maturity level)
- Preferences (genres, content types, languages)
- Subscription details
- Watch history
- Security fields (password hash, verification tokens)

### Watchlist Model
- Content reference (ID, type, title)
- User preferences (priority, notes, tags)
- Watch status and progress
- Timestamps

### Rating Model
- User rating (1-10 scale)
- Optional review and title
- Helpful voting system
- Spoiler warnings

## 🛡️ Security Features

- **JWT Authentication** with configurable expiration
- **Password Hashing** using bcrypt with configurable rounds
- **Rate Limiting** to prevent abuse
- **Input Validation** using Joi schemas
- **CORS Protection** with configurable origins
- **Helmet.js** for security headers
- **Request Sanitization** to prevent injection attacks

## 🚀 Deployment

### Local Development
```bash
npm run dev
```

### Production
```bash
npm start
```

### Docker (Optional)
```dockerfile
FROM node:16-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
EXPOSE 3000
CMD ["npm", "start"]
```

## 📱 Flutter Integration

To integrate with your Flutter app, update the API base URL:

```dart
// In your Flutter app's API configuration
const String baseUrl = 'http://your-backend-url:3000/api';
```

## 🧪 Testing

```bash
# Run tests
npm test

# Run tests in watch mode
npm run test:watch
```

## 📈 Performance

- **Database Indexing** for optimal query performance
- **Connection Pooling** for MongoDB
- **Response Compression** using gzip
- **Rate Limiting** to prevent abuse
- **Efficient Pagination** for large datasets

## 🔧 Configuration

### MongoDB Connection
The backend automatically connects to MongoDB on startup and handles connection events gracefully.

### Rate Limiting
Configurable rate limiting prevents API abuse:
- Default: 100 requests per 15 minutes per IP
- Auth endpoints: 5 requests per 15 minutes per IP

### CORS
Configurable CORS settings for cross-origin requests:
- Development: `http://localhost:3000, http://localhost:8080`
- Production: Configure your domain

## 🐛 Troubleshooting

### Common Issues

1. **MongoDB Connection Failed**
   - Check if MongoDB is running
   - Verify connection string in `.env`
   - Check network connectivity

2. **TMDB API Errors**
   - Verify `TMDB_API_KEY` is set correctly
   - Check TMDB API status
   - Verify API key permissions

3. **JWT Token Issues**
   - Check `JWT_SECRET` is set
   - Verify token expiration
   - Check token format in Authorization header

### Logs
The backend provides detailed logging:
- Development: Morgan HTTP request logging
- Error logging with stack traces
- MongoDB connection status

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License.

## 🙏 Acknowledgments

- [The Movie Database (TMDB)](https://www.themoviedb.org/) for providing the movie/TV show data API
- [Express.js](https://expressjs.com/) for the web framework
- [MongoDB](https://www.mongodb.com/) for the database
- [JWT](https://jwt.io/) for authentication

## 📞 Support

For support and questions:
- Create an issue in the repository
- Check the troubleshooting section
- Review the API documentation

---

**Happy coding! 🎬✨**
