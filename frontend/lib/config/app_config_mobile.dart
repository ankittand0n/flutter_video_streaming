// Mobile/native implementation - no JS interop needed
import 'package:flutter/foundation.dart';

class AppConfig {
  // Check if running in debug mode
  static const bool isDevelopment = kDebugMode;
  
  // Development URLs (local backend - use your computer's IP or localhost)
  static const String _devApiBaseUrl = 'http://10.0.2.2:3000/api'; // Android emulator
  // For iOS simulator, use: 'http://localhost:3000/api'
  // For physical device, use your computer's local IP: 'http://192.168.x.x:3000/api'
  static const String _devStorageBaseUrl = 'http://10.0.2.2:3000/storage';
  
  // Production URLs
  static const String _prodApiBaseUrl = 'https://admin.namkeentv.com/api';
  static const String _prodStorageBaseUrl = 'https://storage.googleapis.com/namkeen-tv';
  
  // Get API base URL based on environment
  static String get apiBaseUrl {
    // Allow override via dart-define
    const defineApiUrl = String.fromEnvironment('API_BASE_URL', defaultValue: '');
    if (defineApiUrl.isNotEmpty) {
      return defineApiUrl;
    }
    
    return isDevelopment ? _devApiBaseUrl : _prodApiBaseUrl;
  }

  static String get storageBaseUrl {
    // Allow override via dart-define
    const defineStorageUrl = String.fromEnvironment('STORAGE_BASE_URL', defaultValue: '');
    if (defineStorageUrl.isNotEmpty) {
      return defineStorageUrl;
    }
    
    return isDevelopment ? _devStorageBaseUrl : _prodStorageBaseUrl;
  }

  // Derived configuration
  static String get imageBaseUrl => apiBaseUrl.replaceAll('/api', '');

  // App Configuration
  static const String appName = 'Namkeen TV';
  static const String appVersion = '1.0.0';

  // API Configuration
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
