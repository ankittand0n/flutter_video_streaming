import 'package:flutter/material.dart';
import 'package:namkeen_tv/model/movie.dart';
import 'package:namkeen_tv/widgets/poster_image.dart';
import 'package:namkeen_tv/widgets/video_player_widget.dart';
import 'package:namkeen_tv/config/app_config.dart';
import 'package:url_launcher/url_launcher.dart';

class MovieDetailsScreen extends StatelessWidget {
  final Movie movie;

  const MovieDetailsScreen({
    Key? key,
    required this.movie,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        slivers: [
          // App Bar with backdrop
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: Colors.black,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  PosterImage(
                    movie: movie,
                    backdrop: true,
                    width: double.infinity,
                    height: 300,
                  ),
                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share, color: Colors.white),
                onPressed: () => _shareMovie(context),
              ),
            ],
          ),

          // Movie content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and year
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          movie.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (movie.year.isNotEmpty)
                        Text(
                          '(${movie.year})',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 18,
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Rating and duration
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.yellow, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        '${movie.voteAverage.toStringAsFixed(1)}/10',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        '${movie.voteCount} votes',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Action buttons
                  Row(
                    children: [
                      if (movie.hasVideo)
                        ElevatedButton.icon(
                          onPressed: () => _playMovie(context),
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('Play Movie'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      const SizedBox(width: 12),
                      if (movie.hasTrailer)
                        OutlinedButton.icon(
                          onPressed: () => _playTrailer(context),
                          icon: const Icon(Icons.play_circle_outline),
                          label: const Text('Trailer'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Overview
                  const Text(
                    'Overview',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    movie.overview,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Additional info
                  _buildInfoRow(
                      'Language', movie.originalLanguage.toUpperCase()),
                  _buildInfoRow(
                      'Popularity', movie.popularity.toStringAsFixed(1)),
                  _buildInfoRow('Release Date', movie.releaseDate),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _playMovie(BuildContext context) {
    if (movie.hasVideo) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => VideoPlayerWidget(
            videoUrl: movie.videoUrl!,
            trailerUrl: movie.trailerUrl,
            isTrailer: false,
          ),
          fullscreenDialog: true,
        ),
      );
    }
  }

  void _playTrailer(BuildContext context) {
    if (movie.hasTrailer) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => VideoPlayerWidget(
            videoUrl: movie.videoUrl ?? '',
            trailerUrl: movie.trailerUrl,
            isTrailer: true,
          ),
          fullscreenDialog: true,
        ),
      );
    }
  }

  void _shareMovie(BuildContext context) async {
    // Use centralized configuration for share URL
    final Uri url = Uri.parse(AppConfig.getShareUrl(movie.id.toString()));
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not share movie'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
