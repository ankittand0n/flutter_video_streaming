import 'dart:js' as js;

class AppConfig {
  // Runtime environment configuration (injected by Docker)
  static String get apiBaseUrl {
    try {
      // Try to read from window.ENV (injected by Docker at runtime)
      if (js.context.hasProperty('ENV')) {
        final env = js.context['ENV'];
        if (env != null && env.hasProperty('apiBaseUrl')) {
          return env['apiBaseUrl'] as String;
        }
      }
    } catch (e) {
      print('Failed to read runtime config: $e');
    }
    // Fallback to default
    return 'https://backend-1040805906877.asia-south2.run.app/api';
  }

  static String get storageBaseUrl {
    try {
      if (js.context.hasProperty('ENV')) {
        final env = js.context['ENV'];
        if (env != null && env.hasProperty('storageBaseUrl')) {
          return env['storageBaseUrl'] as String;
        }
      }
    } catch (e) {
      print('Failed to read runtime config: $e');
    }
    // Fallback to default
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
