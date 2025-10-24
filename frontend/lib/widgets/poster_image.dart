import 'package:flutter/material.dart';
import 'package:namkeen_tv/model/episode.dart';
import 'package:namkeen_tv/model/movie.dart';
import 'package:namkeen_tv/services/api_service.dart';
import 'dart:math';

class PosterImage extends StatelessWidget {
  const PosterImage(
      {super.key,
      this.movie,
      this.episode,
      this.original = false,
      this.width,
      this.height,
      this.backdrop = false,
      this.borderRadius,
      this.useRandom = false});

  final Movie? movie;
  final Episode? episode;
  final bool original;
  final bool backdrop;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final bool useRandom; // New parameter to enable random content

  @override
  Widget build(BuildContext context) {
    // If useRandom is true and no specific content is provided, show random content
    if (useRandom && movie == null && episode == null) {
      return FutureBuilder<String?>(
        future: _getRandomImageUrl(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
              width: width,
              height: height,
              color: Colors.grey[900],
              child: const Center(child: CircularProgressIndicator()),
            );
          }

          final randomImageUrl = snapshot.data;
          return _buildImageWidget(randomImageUrl);
        },
      );
    }

    // Original logic for specific content
    return _buildImageWidget(_getImageUrl());
  }

  String? _getImageUrl() {
    if (movie != null) {
      // Use full URL getters to ensure proper image loading
      final fullImageUrl =
          backdrop ? movie!.fullBackdropPath : movie!.fullPosterPath;
      return fullImageUrl.isNotEmpty ? fullImageUrl : null;
    } else if (episode != null) {
      // Use episode still or poster
      return episode!.stillPath;
    }
    return null;
  }

  Future<String?> _getRandomImageUrl() async {
    try {
      final random = Random();
      final useMovies =
          random.nextBool(); // Randomly choose between movies and TV series

      if (useMovies) {
        final movies = await ApiService.getMovies(limit: 10);
        if (movies.isNotEmpty) {
          final randomMovie = movies[random.nextInt(movies.length)];
          final movieObj = Movie.fromJson(randomMovie);
          return backdrop ? movieObj.fullBackdropPath : movieObj.fullPosterPath;
        }
      } else {
        final tvSeries = await ApiService.getTvSeries(limit: 10);
        if (tvSeries.isNotEmpty) {
          final randomTv = tvSeries[random.nextInt(tvSeries.length)];
          final tvObj = Movie.fromJson(randomTv, medialType: 'tv');
          return backdrop ? tvObj.fullBackdropPath : tvObj.fullPosterPath;
        }
      }
    } catch (e) {
      print('Error fetching random content: $e');
    }
    return null;
  }

  Widget _buildImageWidget(String? imageUrl) {
    // Fallback to placeholder if no image URL
    if (imageUrl == null || imageUrl.isEmpty) {
      imageUrl =
          'https://via.placeholder.com/${width?.toInt() ?? 300}x${height?.toInt() ?? 450}?text=No+Image';
    }

    final imageWidget = Image.network(
      imageUrl,
      width: width ??
          (backdrop
              ? (original ? double.infinity : 300.0)
              : (original ? 300.0 : 150.0)),
      height: height ??
          (backdrop ? (original ? 400.0 : 180.0) : (original ? 400.0 : 225.0)),
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: width,
          height: height,
          color: Colors.grey[800],
          child: const Icon(Icons.broken_image, color: Colors.grey, size: 48),
        );
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          width: width,
          height: height,
          color: Colors.grey[900],
          child: Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
            ),
          ),
        );
      },
    );

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: imageWidget,
      );
    }

    return imageWidget;
  }
}
