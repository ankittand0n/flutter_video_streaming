import 'dart:convert';

class Movie {
  final int id;
  final int tmdbId;
  final String title;
  final String overview;
  final String releaseDate;
  final double voteAverage;
  final String posterPath;
  final String backdropPath;
  final List<int> genreIds;
  final bool adult;
  final String originalLanguage;
  final double popularity;
  final bool video;
  final int voteCount;
  final String? videoUrl;
  final String? trailerUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  Movie({
    required this.id,
    required this.tmdbId,
    required this.title,
    required this.overview,
    required this.releaseDate,
    required this.voteAverage,
    required this.posterPath,
    required this.backdropPath,
    required this.genreIds,
    required this.adult,
    required this.originalLanguage,
    required this.popularity,
    required this.video,
    required this.voteCount,
    this.videoUrl,
    this.trailerUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'] ?? 0,
      tmdbId: json['tmdb_id'] ?? 0,
      title: json['title'] ?? '',
      overview: json['overview'] ?? '',
      releaseDate: json['release_date'] ?? '',
      voteAverage: (json['vote_average'] ?? 0.0).toDouble(),
      posterPath: json['poster_path'] ?? '',
      backdropPath: json['backdrop_path'] ?? '',
      genreIds: json['genre_ids'] != null 
          ? (json['genre_ids'] is String 
              ? List<int>.from(jsonDecode(json['genre_ids']))
              : List<int>.from(json['genre_ids']))
          : [],
      adult: (json['adult'] == 1 || json['adult'] == true),
      originalLanguage: json['original_language'] ?? '',
      popularity: (json['popularity'] ?? 0.0).toDouble(),
      video: (json['video'] == 1 || json['video'] == true),
      voteCount: json['vote_count'] ?? 0,
      videoUrl: json['video_url'],
      trailerUrl: json['trailer_url'],
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tmdb_id': tmdbId,
      'title': title,
      'overview': overview,
      'release_date': releaseDate,
      'vote_average': voteAverage,
      'poster_path': posterPath,
      'backdrop_path': backdropPath,
      'genre_ids': jsonEncode(genreIds),
      'adult': adult ? 1 : 0,
      'original_language': originalLanguage,
      'popularity': popularity,
      'video': video ? 1 : 0,
      'vote_count': voteCount,
      'video_url': videoUrl,
      'trailer_url': trailerUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Helper methods
  String get fullPosterPath => posterPath.startsWith('http') 
      ? posterPath 
      : 'http://127.0.0.1:3000$posterPath';
      
  String get fullBackdropPath => backdropPath.startsWith('http') 
      ? backdropPath 
      : 'http://127.0.0.1:3000$backdropPath';

  bool get hasVideo => videoUrl != null && videoUrl!.isNotEmpty;
  bool get hasTrailer => trailerUrl != null && trailerUrl!.isNotEmpty;
  
  String get year => releaseDate.isNotEmpty 
      ? releaseDate.split('-')[0] 
      : '';
}
