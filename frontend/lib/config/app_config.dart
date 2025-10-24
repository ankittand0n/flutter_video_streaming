class AppConfig {
  // API Configuration
  static const String apiBaseUrl = 'http://localhost:3000/api';
  static const String imageBaseUrl = 'http://localhost:3000';

  // App Configuration
  static const String appName = 'Namkeen TV';
  static const String appVersion = '1.0.0';

  // Development Configuration
  static const bool isDevelopment = true;
  static const int apiTimeout = 30; // seconds

  // Feature Flags
  static const bool enableDebugLogs = isDevelopment;
  static const bool enableErrorReporting = !isDevelopment;

  // Web Configuration
  static const String webUrl = 'http://localhost:8080';

  // Helper methods
  static String getImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return 'https://via.placeholder.com/300x450?text=No+Image';
    }

    // If it's already a full URL, return as is
    if (imagePath.startsWith('http')) {
      return imagePath;
    }

    // Otherwise, prepend the backend URL
    return '$imageBaseUrl$imagePath';
  }

  static String getFullApiUrl(String endpoint) {
    return '$apiBaseUrl$endpoint';
  }

  static String getShareUrl(String movieId) {
    return '$webUrl/#/home/movies/details?id=$movieId';
  }
}
