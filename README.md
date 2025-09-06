# Namkeen TV - Full Stack Streaming Platform

A complete Netflix clone built with Flutter (frontend) and Node.js (backend), featuring local image assets and a custom streaming experience.

## 🏗️ Project Structure

```
Development/
├── flutter_netflix/          # Flutter mobile/web app (Namkeen TV)
├── netflix_backend/          # Node.js/Express API backend
└── README.md                 # This file
```

## 📱 Flutter App (Namkeen TV)

**Location:** `flutter_netflix/`

A cross-platform streaming app built with Flutter that works on:
- ✅ Android
- ✅ iOS  
- ✅ Web (Chrome)
- ✅ Windows
- ✅ macOS
- ✅ Linux

### Features
- **Local Image Assets** - No external API dependencies for images
- **Netflix-like UI** - Authentic streaming platform design
- **Cross-platform** - Single codebase for all platforms
- **Custom Branding** - "Namkeen TV" with local assets

### Quick Start
```bash
cd flutter_netflix
flutter pub get
flutter run
```

### Building APK
```bash
cd flutter_netflix
flutter build apk --debug
```

## 🚀 Backend API (Node.js)

**Location:** `netflix_backend/`

A RESTful API built with Node.js and Express providing:
- User authentication and management
- Movie/TV show data from TMDB API
- User watchlists and ratings
- JWT-based security

### Features
- **Authentication** - JWT tokens, user registration/login
- **TMDB Integration** - Movie and TV show data
- **User Management** - Profiles, watchlists, ratings
- **Database** - SQLite with Sequelize ORM
- **Security** - Input validation, CORS, rate limiting

### Quick Start
```bash
cd netflix_backend
npm install
npm start
```

### Environment Setup
1. Copy `env.example` to `.env`
2. Add your TMDB API key
3. Configure database settings

## 🛠️ Development

### Prerequisites
- Flutter SDK (latest stable)
- Node.js (v14 or higher)
- Android Studio (for Android development)
- Xcode (for iOS development)

### Getting Started
1. **Clone the repository**
2. **Setup Flutter app:**
   ```bash
   cd flutter_netflix
   flutter pub get
   ```
3. **Setup Backend:**
   ```bash
   cd netflix_backend
   npm install
   cp env.example .env
   # Edit .env with your API keys
   npm start
   ```

## 📦 What's Included

### Flutter App
- Complete Netflix clone UI
- Local image asset system
- Cross-platform compatibility
- Custom "Namkeen TV" branding
- Movie/TV show browsing
- Profile management
- Responsive design

### Backend API
- User authentication system
- TMDB API integration
- Database models (User, Watchlist, Rating)
- RESTful endpoints
- Input validation
- Error handling
- CORS configuration

## 🔧 Recent Fixes

- ✅ **APK Startup Issue** - Fixed package name mismatch in Android MainActivity
- ✅ **Local Images** - Implemented local asset system replacing TMDB images
- ✅ **Git Repository** - Properly structured both projects in single repository
- ✅ **Cross-platform** - App works on all supported Flutter platforms

## 📄 License

This project is for educational purposes. Please respect TMDB's terms of service when using their API.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

---

**Note:** This is a learning project and not affiliated with Netflix or TMDB.
