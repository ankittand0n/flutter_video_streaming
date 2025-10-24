import 'package:flutter/material.dart';
import 'package:namkeen_tv/widgets/advanced_video_player.dart';

class VideoPlayerWidget extends StatelessWidget {
  final String videoUrl;
  final String? trailerUrl;
  final bool isTrailer;
  final VoidCallback? onClose;

  const VideoPlayerWidget({
    super.key,
    required this.videoUrl,
    this.trailerUrl,
    this.isTrailer = false,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return AdvancedVideoPlayer(
      videoUrl: videoUrl,
      trailerUrl: trailerUrl,
      isTrailer: isTrailer,
      title: isTrailer ? 'Trailer' : 'Movie',
      autoPlay: true,
      onVideoEnded: onClose,
      // You can add subtitle and audio track data here when available
      subtitles: _getDemoSubtitles(),
      audioTracks: _getDemoAudioTracks(),
    );
  }

  List<SubtitleTrack>? _getDemoSubtitles() {
    // In a real implementation, you would get this data from your backend
    return [
      SubtitleTrack(
        language: 'English',
        url: '$videoUrl.en.srt',
        format: 'srt',
      ),
      SubtitleTrack(
        language: 'Spanish',
        url: '$videoUrl.es.srt',
        format: 'srt',
      ),
      SubtitleTrack(
        language: 'French',
        url: '$videoUrl.fr.srt',
        format: 'srt',
      ),
    ];
  }

  List<AudioTrack>? _getDemoAudioTracks() {
    // In a real implementation, you would get this data from your backend
    return [
      AudioTrack(
        language: 'English',
        quality: '320kbps',
        url: '$videoUrl.en.aac',
      ),
      AudioTrack(
        language: 'Spanish',
        quality: '320kbps',
        url: '$videoUrl.es.aac',
      ),
    ];
  }
}
