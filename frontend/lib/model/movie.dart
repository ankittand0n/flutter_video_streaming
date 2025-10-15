import 'dart:convert';

class Movie {
  final int id;
  final String name;
  final String overview;
  final String? posterPath;
  final String originalName;
  final String originalLanguage;
  final String type;
  final List<int> genreIds;
  final double popularity;
  final DateTime? releaseDate;
  final double voteAverage;
  final int voteCount;
  final List<String> originCountry;
  final String? backdropPath;
  final bool adult;
  final bool video;
  final int? runtime;
  final int? episodes;
  final int? seasons;
  final String? videoUrl;
  final String? trailerUrl;
  final bool details;

  Movie.fromJson(Map<String, dynamic> json, {medialType, bool details = false})
      : id = json['id'] ?? 0,
        name = (json['name'] ?? json['title'] ?? '').toString(),
        overview = (json['overview'] ?? '').toString(),
        posterPath = json['poster_path']?.toString(),
        originalName = (json['original_name'] ?? json['original_title'] ?? json['title'] ?? '').toString(),
        originalLanguage = (json['original_language'] ?? '').toString(),
        type = (json['media_type'] ?? medialType ?? 'movie').toString(),
        genreIds = (() {
          final g = json['genre_ids'];
          try {
            if (g == null) return <int>[];
            if (g is String) {
              final decoded = g.isNotEmpty ? jsonDecode(g) : [];
              return List<int>.from(decoded);
            }
            return List<int>.from(g);
          } catch (e) {
            return <int>[];
          }
        })(),
        popularity = (() {
          final p = json['popularity'];
          if (p == null) return 0.0;
          if (p is num) return p.toDouble();
          return double.tryParse(p.toString()) ?? 0.0;
        })(),
        releaseDate = (() {
          final dateStr = json['first_air_date'] ?? json['release_date'];
          if (dateStr == null) return null;
          return DateTime.tryParse(dateStr.toString());
        })(),
        voteAverage = (() {
          final va = json['vote_average'];
          if (va == null) return 0.0;
          if (va is num) return va.toDouble();
          return double.tryParse(va.toString()) ?? 0.0;
        })(),
        voteCount = json['vote_count'] ?? 0,
        originCountry = (() {
          final oc = json['origin_country'];
          try {
            if (oc == null) return <String>[];
            return List.castFrom<dynamic, String>(oc);
          } catch (e) {
            return <String>[];
          }
        })(),
        backdropPath = json['backdrop_path']?.toString(),
        adult = (json['adult'] == 1 || json['adult'] == true),
        video = (json['video'] == 1 || json['video'] == true),
        runtime = json['runtime'],
        episodes = json['number_of_episodes'],
        seasons = json['number_of_seasons'],
        videoUrl = json['video_url']?.toString(),
        trailerUrl = json['trailer_url']?.toString(),
        details = details;

  // Getter for backward compatibility - some widgets use 'title' instead of 'name'
  String get title => name;

  String getRuntime() {
    if (type == 'movie') {
      final rt = runtime ?? 0;
      if (rt == 0) return 'N/A';
      var hours = rt / 60,
          justHours = hours.floor(),
          minutes = ((hours - hours.floor()) * 60).floor();
      return '${justHours > 0 ? '${justHours}h' : ''}${minutes > 0 ? '${justHours > 0 ? ' ' : ''}${minutes}m' : ''}';
    }

    final eps = episodes ?? 0;
    final seas = seasons ?? 0;
    if (eps == 0 && seas == 0) return 'N/A';
    return eps < 20 ? '$eps Episodes' : '$seas Seasons';
  }
}
