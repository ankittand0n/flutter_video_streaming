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
                        PosterImage(movie: movie, width: 110.0, height: 220.0))
                : PosterImage(movie: movie, width: 110.0, height: 220.0),
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
