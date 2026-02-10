import 'dart:convert';
import '../config/app_config.dart';

class Movie {
  final int id;
  final String title;
  final String overview;
  final String releaseDate; // Keep as String since API returns ISO string
  final double voteAverage;
  final String posterPath;
  final String backdropPath;
  final List<int> genreIds;
  final String originalLanguage;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool video;
  final String? videoUrl;
  final String? trailerUrl;

  Movie({
    required this.id,
    required this.title,
    required this.overview,
    required this.releaseDate,
    required this.voteAverage,
    required this.posterPath,
    required this.backdropPath,
    required this.genreIds,
    required this.originalLanguage,
    required this.createdAt,
    required this.updatedAt,
    required this.video,
    this.videoUrl,
    this.trailerUrl,
  });

  factory Movie.fromJson(Map<String, dynamic> json,
      {String? medialType, bool details = false}) {
    // Safely handle genre_ids which could be String (JSON) or List
    List<int> genreIds = [];
    try {
      if (json['genre_ids'] != null) {
        if (json['genre_ids'] is String) {
          final genreString = json['genre_ids'] as String;
          // Skip empty or whitespace-only strings
          if (genreString.trim().isEmpty) {
            genreIds = [];
          } else {
            // Try to parse as JSON
            try {
              final decoded = jsonDecode(genreString);
              if (decoded is List) {
                genreIds = List<int>.from(
                    decoded.map((x) => x is int ? x : (x is String ? int.tryParse(x) ?? 0 : 0)));
              } else {
                genreIds = [];
              }
            } catch (e) {
              // If JSON parsing fails, try to extract numbers from the string
              print('Warning: Invalid JSON in genre_ids: "$genreString" - $e');
              genreIds = [];
            }
          }
        } else if (json['genre_ids'] is List) {
          genreIds = List<int>.from(json['genre_ids'].map((x) => 
            x is int ? x : (x is String ? int.tryParse(x) ?? 0 : 0)));
        }
      }
    } catch (e) {
      print('Error parsing genre_ids: $e');
      genreIds = [];
    }

    // Safely parse dates
    DateTime parseDate(String? dateString, DateTime defaultDate) {
      if (dateString == null || dateString.isEmpty) return defaultDate;
      try {
        return DateTime.parse(dateString);
      } catch (e) {
        print('Error parsing date: $e');
        return defaultDate;
      }
    }

    return Movie(
      id: json['id'] ?? 0,
      title: json['title'] ??
          json['name'] ??
          '', // Support both 'title' and 'name'
      overview: json['overview'] ?? '',
      releaseDate: json['release_date'] ?? json['first_air_date'] ?? '',
      voteAverage: (json['vote_average'] != null) 
          ? (json['vote_average'] is num ? json['vote_average'].toDouble() : 0.0)
          : 0.0,
      posterPath: json['poster_path'] ?? '',
      backdropPath: json['backdrop_path'] ?? '',
      genreIds: genreIds,
      originalLanguage: json['original_language'] ?? '',
      createdAt: parseDate(
          json['createdAt'] ?? json['created_at'], DateTime.now()),
      updatedAt: parseDate(
          json['updatedAt'] ?? json['updated_at'], DateTime.now()),
      video: json['video'] ?? false,
      videoUrl: json['video_url'],
      trailerUrl: json['trailer_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'overview': overview,
      'release_date': releaseDate,
      'vote_average': voteAverage,
      'poster_path': posterPath,
      'backdrop_path': backdropPath,
      'genre_ids': jsonEncode(genreIds),
      'original_language': originalLanguage,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'video': video,
      'video_url': videoUrl,
      'trailer_url': trailerUrl,
    };
  }

  // Helper methods
  String get fullPosterPath {
    if (posterPath.isEmpty) return '';
    return AppConfig.getImageUrl(posterPath);
  }

  String get fullBackdropPath {
    if (backdropPath.isEmpty) return '';
    return AppConfig.getImageUrl(backdropPath);
  }

  bool get hasVideo => videoUrl != null && videoUrl!.isNotEmpty;
  bool get hasTrailer => trailerUrl != null && trailerUrl!.isNotEmpty;

  String get year =>
      releaseDate.isNotEmpty ? releaseDate.split('T')[0].split('-')[0] : '';

  // Additional compatibility getter for date parsing
  DateTime? get releaseDateAsDateTime {
    if (releaseDate.isEmpty) return null;
    try {
      return DateTime.parse(releaseDate);
    } catch (e) {
      return null;
    }
  }

  // Compatibility getters for widgets that might expect these
  int get voteCount => 0; // Not available from backend
  double get popularity => voteAverage; // Use vote average as popularity
  bool get adult => false; // Not available from backend

  // Legacy compatibility properties for old widgets
  String get name => title; // Old widgets used 'name' instead of 'title'
  String get type => 'movie'; // Always return 'movie' since this is Movie model
  bool get details => true; // Assume details are always available
  int? get seasons => null; // Movies don't have seasons
  int? get episodes => null; // Movies don't have episodes
  int? get runtime => null; // Not available from backend

  // Legacy method for old widgets
  String getRuntime() {
    return 'N/A'; // Runtime not available in current backend
  }
}
