import 'package:flutter/material.dart';
import 'package:namkeen_tv/model/episode.dart';
import 'package:namkeen_tv/model/movie.dart';

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
    // Get image URL from backend API (now provides full URLs)
    String? imageUrl;
    
    if (movie != null) {
      // Use backdrop or poster from backend
      imageUrl = backdrop ? movie!.backdropPath : movie!.posterPath;
    } else if (episode != null) {
      // Use episode still or poster
      imageUrl = episode!.stillPath;
    }

    // Fallback to placeholder if no image URL
    if (imageUrl == null || imageUrl.isEmpty) {
      imageUrl = 'https://via.placeholder.com/${width?.toInt() ?? 300}x${height?.toInt() ?? 450}?text=No+Image';
    }

    final imageWidget = Image.network(
      imageUrl,
      width: width ?? (backdrop ? (original ? double.infinity : 300.0) : (original ? 300.0 : 150.0)),
      height: height ?? (backdrop ? (original ? 400.0 : 180.0) : (original ? 400.0 : 225.0)),
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
                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
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
