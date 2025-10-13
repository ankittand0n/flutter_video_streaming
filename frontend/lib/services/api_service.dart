import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://api.namkeentv.com';
  
  // Movies
  static Future<List<Map<String, dynamic>>> getMovies({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      print('Making API request to: $baseUrl/movies?page=$page&limit=$limit');
      final response = await http.get(
        Uri.parse('$baseUrl/movies?page=$page&limit=$limit'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      
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
        throw Exception('Failed to load popular movies: ${response.statusCode}');
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
        throw Exception('Failed to load top rated movies: ${response.statusCode}');
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

  // Helper method to get full image URL
  static String getImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return 'https://via.placeholder.com/300x450?text=No+Image';
    }
    
    // If it's already a full URL, return as is
    if (imagePath.startsWith('http')) {
      return imagePath;
    }
    
    // Otherwise, prepend the backend URL
    final fullUrl = 'http://api.namkeentv.com$imagePath';
    print('Generated image URL: $fullUrl');
    return fullUrl;
  }
}
