import 'package:namkeen_tv/services/api_service.dart';
import 'package:namkeen_tv/model/configuration.dart';
import 'package:namkeen_tv/model/season.dart';
import 'package:namkeen_tv/model/tmdb_image.dart';
import 'package:namkeen_tv/config/app_config.dart';

import '../model/movie.dart';

class TMDBRepository {
  // Use the application's backend ApiService for all data

  Future<List<Movie>> getTrending({type = 'all', time = 'week'}) async {
    // Our backend exposes /movies and /tv endpoints with pagination
    if (type == 'tv') {
      final tvs = await ApiService.getTvSeries();
      return tvs
          .map((item) => Movie.fromJson(item, medialType: 'tv'))
          .toList()
          .cast<Movie>();
    }

    final movies = await ApiService.getMovies();
    return movies
        .map((item) => Movie.fromJson(item, medialType: 'movie'))
        .toList()
        .cast<Movie>();
  }

  Future<Configuration> getConfiguration() async {
    // Backend doesn't currently expose TMDB configuration; return defaults
    return Configuration.fromJson({
      'images': {
        'base_url': AppConfig.imageBaseUrl,
        'secure_base_url': AppConfig.imageBaseUrl,
        'backdrop_sizes': ['original'],
        'logo_sizes': ['original'],
        'poster_sizes': ['original'],
        'profile_sizes': ['original'],
        'still_sizes': ['original']
      },
      'change_keys': []
    });
  }

  Future<Movie> getDetails(id, type) async {
    if (type == 'tv') {
      final tv = await ApiService.getTv(id);
      return Movie.fromJson(tv!, medialType: 'tv', details: true);
    }

    final movie = await ApiService.getMovie(id);
    return Movie.fromJson(movie!, medialType: 'movie', details: true);
  }

  Future<Season> getSeason(id, season) async {
    // Backend may provide seasons; return an empty Season as a safe default
    return Season.fromJson({});
  }

  Future<List<Movie>> discover(type) async {
    if (type == 'tv') {
      final tvs = await ApiService.getTvSeries();
      return tvs
          .map((item) => Movie.fromJson(item, medialType: 'tv'))
          .toList()
          .cast<Movie>();
    }

    final movies = await ApiService.getMovies();
    return movies
        .map((item) => Movie.fromJson(item, medialType: 'movie'))
        .toList()
        .cast<Movie>();
  }

  Future<TMDBImages> getImages(id, type) async {
    // Fetch movie/tv details from backend and build a TMDBImages-like structure
    try {
      Map<String, dynamic>? data;
      if (type == 'tv') {
        data = await ApiService.getTv(id);
      } else {
        data = await ApiService.getMovie(id);
      }

      final posters = <Map<String, dynamic>>[];
      final backdrops = <Map<String, dynamic>>[];
      final logos = <Map<String, dynamic>>[];

      if (data != null) {
        final posterPath = data['poster_path'];
        final backdropPath = data['backdrop_path'];
        if (posterPath != null &&
            posterPath is String &&
            posterPath.isNotEmpty) {
          posters.add({
            'file_path': posterPath,
            'width': 0,
            'height': 0,
            'aspect_ratio': 1.0
          });
        }
        if (backdropPath != null &&
            backdropPath is String &&
            backdropPath.isNotEmpty) {
          backdrops.add({
            'file_path': backdropPath,
            'width': 0,
            'height': 0,
            'aspect_ratio': 1.0
          });
        }
      }

      return TMDBImages.fromJson({
        'id': id,
        'posters': posters,
        'backdrops': backdrops,
        'logos': logos
      });
    } catch (e) {
      return TMDBImages.fromJson(
          {'id': id, 'posters': [], 'backdrops': [], 'logos': []});
    }
  }
}
