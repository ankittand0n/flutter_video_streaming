import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class ApiService {
  static String get baseUrl => AppConfig.apiBaseUrl;

  // Movies
  static Future<List<Map<String, dynamic>>> getMovies({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/movies?page=$page&limit=$limit'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['data']);
      } else {
        throw Exception('Failed to load movies: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching movies: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>?> getMovie(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/movies/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'];
      } else {
        throw Exception('Failed to load movie: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching movie: $e');
      return null;
    }
  }

  // Get TV details by id (backend)
  static Future<Map<String, dynamic>?> getTv(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/tv/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'];
      } else {
        throw Exception('Failed to load tv: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching tv: $e');
      return null;
    }
  }

  static Future<List<Map<String, dynamic>>> getPopularMovies({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/movies/popular?page=$page&limit=$limit'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['data']);
      } else {
        throw Exception(
            'Failed to load popular movies: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching popular movies: $e');
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> getTopRatedMovies({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/movies/top-rated?page=$page&limit=$limit'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['data']);
      } else {
        throw Exception(
            'Failed to load top rated movies: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching top rated movies: $e');
      return [];
    }
  }

  // TV Series
  static Future<List<Map<String, dynamic>>> getTvSeries({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/tv?page=$page&limit=$limit'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['data']);
      } else {
        throw Exception('Failed to load TV series: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching TV series: $e');
      return [];
    }
  }

  // Genres
  static Future<List<Map<String, dynamic>>> getGenres() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/genres'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['data']);
      } else {
        throw Exception('Failed to load genres: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching genres: $e');
      return [];
    }
  }

  // Search
  static Future<List<Map<String, dynamic>>> search(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/movies?search=$query'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['data']);
      } else {
        return [];
      }
    } catch (e) {
      print('Error searching: $e');
      return [];
    }
  }

  // Watchlist
  static Future<Map<String, dynamic>> addToWatchlist(
    String token,
    String contentId,
    String contentType,
    String title, {
    String? overview,
    String? posterPath,
    String? backdropPath,
  }) async {
    try {
      print('Adding to watchlist - contentId: $contentId, type: $contentType');

      final requestBody = {
        'contentid': contentId,
        'contenttype': contentType,
        'title': title,
        if (overview != null && overview.isNotEmpty) 'overview': overview,
        if (posterPath != null && posterPath.isNotEmpty)
          'posterPath': posterPath,
        if (backdropPath != null && backdropPath.isNotEmpty)
          'backdropPath': backdropPath,
      };

      print('Request body: ${json.encode(requestBody)}');

      final response = await http.post(
        Uri.parse('$baseUrl/watchlist'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(requestBody),
      );

      print('Watchlist response: ${response.statusCode} - ${response.body}');

      final data = json.decode(response.body);
      return {
        'success': response.statusCode == 201 || response.statusCode == 200,
        'message': data['message'] ??
            data['error'] ??
            (data['details'] != null
                ? json.encode(data['details'])
                : 'Unknown error'),
      };
    } catch (e) {
      print('Error adding to watchlist: $e');
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> removeFromWatchlist(
    String token,
    String contentId,
  ) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/watchlist/$contentId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = json.decode(response.body);
      return {
        'success': response.statusCode == 200,
        'message': data['message'] ?? data['error'] ?? 'Unknown error',
      };
    } catch (e) {
      print('Error removing from watchlist: $e');
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<List<Map<String, dynamic>>> getWatchlist(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/watchlist'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['data']);
      } else {
        return [];
      }
    } catch (e) {
      print('Error fetching watchlist: $e');
      return [];
    }
  }

  // Rating
  static Future<Map<String, dynamic>> rateContent(
    String token,
    String contentId,
    String contentType,
    double rating, {
    String? review,
    String? title,
  }) async {
    try {
      print(
          'Rating content - contentId: $contentId, type: $contentType, rating: $rating');

      final requestBody = {
        'contentid': contentId,
        'contenttype': contentType,
        'rating': rating,
        if (review != null && review.isNotEmpty) 'review': review,
        if (title != null && title.isNotEmpty) 'title': title,
      };

      print('Request body: ${json.encode(requestBody)}');

      final response = await http.post(
        Uri.parse('$baseUrl/rating'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(requestBody),
      );

      print('Rating response: ${response.statusCode} - ${response.body}');

      final data = json.decode(response.body);
      return {
        'success': response.statusCode == 201 || response.statusCode == 200,
        'message': data['message'] ??
            data['error'] ??
            (data['details'] != null
                ? json.encode(data['details'])
                : 'Unknown error'),
      };
    } catch (e) {
      print('Error rating content: $e');
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>?> getUserRating(
    String token,
    String contentId,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/rating/content/$contentId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'];
      } else {
        return null;
      }
    } catch (e) {
      print('Error fetching user rating: $e');
      return null;
    }
  }

  // Helper method to get full image URL
  static String getImageUrl(String? imagePath) {
    return AppConfig.getImageUrl(imagePath);
  }
}
