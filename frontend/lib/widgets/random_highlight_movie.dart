import 'package:flutter/material.dart';
import 'package:namkeen_tv/widgets/poster_image.dart';
import 'package:lucide_icons/lucide_icons.dart';

class RandomHighlightMovie extends StatelessWidget {
  const RandomHighlightMovie({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    // Limit highlight height on desktop for better proportions
    final highlightHeight =
        width > 1200 ? 700.0 : (width > 800 ? 600.0 : width + (width * .6));

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
            useRandom: true, // Use random content!
            backdrop: true, // Use backdrop for better hero effect
            width: width,
            height: highlightHeight,
          ),
        ),
        Positioned(
          bottom: 0.0,
          width: width,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 38.0, vertical: 16.0),
            child: Column(
              children: [
                // Random title placeholder since we don't have specific movie data
                SizedBox(
                  height: 80,
                  child: const Center(
                    child: Text(
                      'Featured Content',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                      ),
                      onPressed: () {
                        // Action for play
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Random content selected!')),
                        );
                      },
                      icon: const Icon(Icons.play_arrow, size: 20),
                      label: const Text('Play'),
                    ),
                    const SizedBox(width: 16),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                      ),
                      onPressed: () {
                        // Action for more info
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('More info for random content')),
                        );
                      },
                      icon: const Icon(LucideIcons.info, size: 20),
                      label: const Text('More Info'),
                    ),
                  ],
                ),
                const SizedBox(height: 24.0),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
