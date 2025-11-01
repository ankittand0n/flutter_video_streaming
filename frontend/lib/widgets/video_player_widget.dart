import 'package:flutter/material.dart';
import 'package:namkeen_tv/widgets/media_kit_video_player.dart';

class VideoPlayerWidget extends StatelessWidget {
  final String videoUrl;
  final String? trailerUrl;
  final bool isTrailer;
  final String? videoId; // Unique identifier for the video
  final VoidCallback? onClose;

  const VideoPlayerWidget({
    super.key,
    required this.videoUrl,
    this.trailerUrl,
    this.isTrailer = false,
    this.videoId,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return MediaKitVideoPlayer(
      videoUrl: videoUrl,
      trailerUrl: trailerUrl,
      isTrailer: isTrailer,
      title: isTrailer ? 'Trailer' : 'Movie',
      videoId: videoId,
      autoPlay: true,
      onVideoEnded: onClose,
    );
  }
}
