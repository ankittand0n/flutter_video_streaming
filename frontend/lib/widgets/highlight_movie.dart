import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:namkeen_tv/widgets/poster_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:go_router/go_router.dart';
import 'dart:math';

import '../bloc/netflix_bloc.dart';
import '../utils/utils.dart';
import 'genre.dart';
import 'logo_image.dart';

class HighlightMovie extends StatefulWidget {
  const HighlightMovie({super.key});

  @override
  State<HighlightMovie> createState() => _HighlightMovieState();
}

class _HighlightMovieState extends State<HighlightMovie> {
  dynamic _selectedMovie;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final movies = context.watch<DiscoverMoviesBloc>().state;
    if (_selectedMovie == null && movies is DiscoverMovies) {
      if (movies.list.isNotEmpty) {
        final random = Random();
        _selectedMovie = movies.list[random.nextInt(movies.list.length)];
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      final movies = context.watch<DiscoverMoviesBloc>().state;
      final width = MediaQuery.of(context).size.width;
      // Limit highlight height on desktop for better proportions
      final highlightHeight =
          width > 1200 ? 700.0 : (width > 800 ? 600.0 : width + (width * .6));

      if (movies is DiscoverMovies) {
        final randomMovie = _selectedMovie ??
            (movies.list.isNotEmpty ? movies.list.first : null);

        if (randomMovie == null) {
          return const SizedBox(); // Return empty if no movies
        }

        return Stack(
          children: [
            Container(
              foregroundDecoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: const Alignment(0.0, 0.2),
                      colors: [
                    Colors.black,
                    Colors.black.withOpacity(.92),
                    Colors.black.withOpacity(.8),
                    Colors.transparent
                  ])),
              child: PosterImage(
                original: true,
                borderRadius: BorderRadius.zero,
                movie: randomMovie,
                backdrop: true, // Use backdrop for better visual
                width: width,
                height: highlightHeight,
              ),
            ),
            Positioned(
              bottom: 0.0,
              width: width,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 38.0, vertical: 16.0),
                child: Column(
                  children: [
                    LogoImage(
                      movie: randomMovie,
                      size: 3,
                    ),
                    const SizedBox(
                      height: 16.0,
                    ),
                    const Genre(
                      genres: ['Pshychological', 'Dark', 'Drama', 'Movie'],
                      color: redColor,
                    ),
                    Center(
                      child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24.0, vertical: 12.0),
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black),
                          onPressed: () {
                            // Navigate to movie details and play
                            context.push('/home/movies/details',
                                extra: randomMovie);
                          },
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('Play')),
                    )
                  ],
                ),
              ),
            )
          ],
        );
      }
      return Shimmer(
        gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              Colors.grey[900]!,
              Colors.grey[900]!,
              Colors.grey[800]!,
              Colors.grey[900]!,
              Colors.grey[900]!
            ],
            stops: const <double>[
              0.0,
              0.35,
              0.5,
              0.65,
              1.0
            ]),
        child: SizedBox(
          width: width,
          height: width + (width * .6),
        ),
      );
    });
  }
}
