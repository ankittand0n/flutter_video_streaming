import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:namkeen_tv/model/episode.dart';
import 'package:namkeen_tv/model/movie.dart';
import 'package:shimmer/shimmer.dart';

import '../bloc/netflix_bloc.dart';
import '../services/local_image_service.dart';
import '../utils/utils.dart';
import 'local_poster_image.dart';

class PosterImage extends StatelessWidget {
  const PosterImage(
      {super.key,
      this.movie,
      this.episode,
      this.original = false,
      this.width,
      this.height,
      this.backdrop = false,
      this.borderRadius});

  final Movie? movie;
  final Episode? episode;
  final bool original;
  final bool backdrop;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    // Use local images instead of TMDB API
    String localImagePath;
    
    if (movie != null) {
      // Use movie ID to get local image (with repetition)
      localImagePath = LocalImageService.getMovieImage(movie!.id ?? 0);
    } else if (episode != null) {
      // Use episode ID to get local image (with repetition)
      localImagePath = LocalImageService.getTvSeriesImage(episode!.id ?? 0);
    } else {
      // Fallback to a default image
      localImagePath = LocalImageService.getMovieImage(0);
    }

    if (backdrop) {
      // For backdrop images, use the same local image but with backdrop styling
      return LocalBackdropImage(
        imagePath: localImagePath,
        width: width ?? (original ? double.infinity : 300.0),
        height: height ?? (original ? 400.0 : 180.0),
        borderRadius: borderRadius,
      );
    } else {
      // For poster images
      return LocalPosterImage(
        imagePath: localImagePath,
        width: width ?? (original ? 300.0 : 150.0),
        height: height ?? (original ? 400.0 : 68.0),
        borderRadius: borderRadius,
      );
    }
  }
}
