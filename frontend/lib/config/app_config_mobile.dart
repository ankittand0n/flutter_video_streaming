// Mobile/native implementation - no JS interop needed

class AppConfig {
  // For mobile, use production URLs directly
  static String get apiBaseUrl {
    return 'https://admin.namkeentv.com/api';
  }

  static String get storageBaseUrl {
    return 'https://storage.googleapis.com/namkeen-tv';
  }

  // Derived configuration
  static String get imageBaseUrl => apiBaseUrl.replaceAll('/api', '');

  // App Configuration
  static const String appName = 'Namkeen TV';
  static const String appVersion = '1.0.0';

  // Development Configuration
  static const bool isDevelopment = false;
  static const int apiTimeout = 30; // seconds

  // Feature Flags
  static const bool enableDebugLogs = isDevelopment;
  static const bool enableErrorReporting = !isDevelopment;

  // Web Configuration
  static const String webUrl = 'https://namkeentv.com';

  // Helper methods
  static String getImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return 'https://via.placeholder.com/300x450?text=No+Image';
    }

    // If it's already a full URL, return as is
    if (imagePath.startsWith('http')) {
      return imagePath;
    }

    // Check if it's a GCS path (starts with /content/)
    if (imagePath.startsWith('/content/')) {
      return '$storageBaseUrl$imagePath';
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

  // Debug helper
  static void printConfig() {
    print('=== AppConfig ===');
    print('apiBaseUrl: $apiBaseUrl');
    print('storageBaseUrl: $storageBaseUrl');
    print('imageBaseUrl: $imageBaseUrl');
  }
}
