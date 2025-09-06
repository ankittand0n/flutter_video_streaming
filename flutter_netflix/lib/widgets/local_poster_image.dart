import 'package:flutter/material.dart';

class LocalPosterImage extends StatelessWidget {
  final String imagePath;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final BoxFit fit;
  final bool showErrorIcon;

  const LocalPosterImage({
    super.key,
    required this.imagePath,
    this.width,
    this.height,
    this.borderRadius,
    this.fit = BoxFit.cover,
    this.showErrorIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(8.0),
      child: Image.asset(
        imagePath,
        fit: fit,
        width: width ?? 150.0,
        height: height ?? 68.0,
        errorBuilder: (context, error, stackTrace) {
          if (!showErrorIcon) {
            return Container(
              width: width ?? 110.0,
              height: height ?? 220.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                color: Colors.grey[800],
              ),
            );
          }
          return Container(
            width: width ?? 110.0,
            height: height ?? 220.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              color: Colors.grey[800],
            ),
            child: const Icon(
              Icons.movie,
              color: Colors.white,
              size: 48.0,
            ),
          );
        },
      ),
    );
  }
}

class LocalBackdropImage extends StatelessWidget {
  final String imagePath;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final BoxFit fit;

  const LocalBackdropImage({
    super.key,
    required this.imagePath,
    this.width,
    this.height,
    this.borderRadius,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(8.0),
      child: Image.asset(
        imagePath,
        fit: fit,
        width: width ?? double.infinity,
        height: height ?? 180.0,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: width ?? double.infinity,
            height: height ?? 180.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              color: Colors.grey[800],
            ),
            child: const Icon(
              Icons.movie,
              color: Colors.white,
              size: 48.0,
            ),
          );
        },
      ),
    );
  }
}
