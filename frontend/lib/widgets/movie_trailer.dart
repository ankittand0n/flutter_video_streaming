import 'package:flutter/material.dart';
import 'package:namkeen_tv/model/movie.dart';
import 'package:namkeen_tv/widgets/poster_image.dart';
import 'package:namkeen_tv/widgets/media_kit_video_player.dart';

class MovieTrailer extends StatelessWidget {
  const MovieTrailer(
      {super.key, required this.movie, this.fill = false, this.padding});

  final Movie movie;
  final bool fill;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (movie.trailerUrl != null && movie.trailerUrl!.isNotEmpty) {
          Navigator.of(context, rootNavigator: true).push(
            PageRouteBuilder(
              opaque: true,
              pageBuilder: (context, animation, secondaryAnimation) =>
                  MediaKitVideoPlayer(
                videoUrl: movie.videoUrl ?? '',
                trailerUrl: movie.trailerUrl,
                isTrailer: true,
                title: '${movie.title} - Trailer',
                autoPlay: true,
                autoFullScreen: true,
                onVideoEnded: () =>
                    Navigator.of(context, rootNavigator: true).pop(),
              ),
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
            ),
          );
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              PosterImage(movie: movie, original: true),
              if (movie.trailerUrl != null && movie.trailerUrl!.isNotEmpty)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(12.0),
                  child: const Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                    size: 40.0,
                  ),
                ),
            ],
          ),
          const SizedBox(
            height: 8.0,
          ),
          Text(
            movie.name,
            style: const TextStyle(fontWeight: FontWeight.w400),
          ),
          const SizedBox(
            height: 32.0,
          )
        ],
      ),
    );
  }
}
