import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../model/movie.dart';
import 'poster_image.dart';

class MovieBox extends StatelessWidget {
  const MovieBox(
      {super.key,
      required this.movie,
      this.laughs,
      this.fill = false,
      this.padding});

  final Movie movie;
  final int? laughs;
  final bool fill;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    // Make poster size responsive to screen width
    final screenWidth = MediaQuery.of(context).size.width;
    final posterWidth = screenWidth > 1200 ? 200.0 : (screenWidth > 800 ? 150.0 : 110.0);
    final posterHeight = posterWidth * 2.0; // Maintain aspect ratio
    
    return Padding(
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
      child: InkWell(
        onTap: () {
          context.go('/home/details', extra: movie);
        },
        child: Stack(
          children: [
            fill
                ? Positioned.fill(
                    child:
                        PosterImage(movie: movie, width: posterWidth, height: posterHeight))
                : PosterImage(movie: movie, width: posterWidth, height: posterHeight),
            if (laughs != null)
              Positioned(
                bottom: 2.0,
                left: 4.0,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('\u{1F602}'),
                    Text(
                      '${laughs}K',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              )
          ],
        ),
      ),
    );
  }
}
