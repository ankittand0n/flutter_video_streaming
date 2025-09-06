import 'package:flutter/material.dart';
import '../services/local_image_service.dart';
import '../widgets/local_poster_image.dart';

class LocalImagesDemo extends StatelessWidget {
  const LocalImagesDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Local Images Demo'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Movie Images (with repetition)',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 20, // More than available images to show repetition
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: LocalPosterImage(
                      imagePath: LocalImageService.getMovieImage(index),
                      width: 120,
                      height: 180,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'TV Series Images (with repetition)',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 20, // More than available images to show repetition
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: LocalPosterImage(
                      imagePath: LocalImageService.getTvSeriesImage(index),
                      width: 120,
                      height: 180,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Backdrop Images',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 150,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 11,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: LocalBackdropImage(
                      imagePath: LocalImageService.getMovieImage(index),
                      width: 200,
                      height: 120,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
