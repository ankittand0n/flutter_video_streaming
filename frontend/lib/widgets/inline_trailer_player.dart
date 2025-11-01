import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:go_router/go_router.dart';

class InlineTrailerPlayer extends StatefulWidget {
  final String trailerUrl;
  final String? fullVideoUrl;
  final String title;

  const InlineTrailerPlayer({
    super.key,
    required this.trailerUrl,
    this.fullVideoUrl,
    required this.title,
  });

  @override
  State<InlineTrailerPlayer> createState() => _InlineTrailerPlayerState();
}

class _InlineTrailerPlayerState extends State<InlineTrailerPlayer> {
  late final Player _player;
  late final VideoController _videoController;
  bool _isInitialized = false;
  bool _hasError = false;
  bool _isMuted = true;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      _player = Player();
      _videoController = VideoController(
        _player,
        configuration: const VideoControllerConfiguration(
          enableHardwareAcceleration: true,
        ),
      );

      // Open media (without unsafe headers for web compatibility)
      await _player.open(
        Media(widget.trailerUrl),
        play: true,
      );

      // Start muted and loop
      await _player.setVolume(0.0);
      await _player.setPlaylistMode(PlaylistMode.single); // Loop the trailer

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  void _toggleMute() {
    if (!mounted || !_isInitialized) return;
    setState(() {
      _isMuted = !_isMuted;
      _player.setVolume(_isMuted ? 0.0 : 100.0);
    });
  }

  void _openFullscreen() {
    if (!mounted) return;
    // Pause the inline player before opening fullscreen
    _player.pause();
    context.push('/video-player', extra: {
      'videoUrl': widget.fullVideoUrl ?? widget.trailerUrl,
      'trailerUrl': widget.trailerUrl,
      'isTrailer': true,
    }).then((_) {
      // Resume playing when returning from fullscreen
      if (mounted && _isInitialized) {
        _player.play();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      // Fallback to poster image if video fails
      return Container(
        height: 250,
        color: Colors.grey[900],
        child: const Center(
          child: Icon(
            Icons.error_outline,
            color: Colors.white54,
            size: 48,
          ),
        ),
      );
    }

    if (!_isInitialized) {
      return Container(
        height: 250,
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(
            color: Colors.red,
          ),
        ),
      );
    }

    return Stack(
      children: [
        AspectRatio(
          aspectRatio: 16 / 9, // Standard video aspect ratio
          child: Video(
            controller: _videoController,
            controls: NoVideoControls,
          ),
        ),
        // Custom controls overlay
        Positioned(
          bottom: 12.0,
          right: 12.0,
          child: Row(
            children: [
              // Mute/Unmute button
              Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(
                    _isMuted ? Icons.volume_off : Icons.volume_up,
                    color: Colors.white,
                  ),
                  onPressed: _toggleMute,
                ),
              ),
              const SizedBox(width: 8),
              // Fullscreen button
              Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.fullscreen,
                    color: Colors.white,
                  ),
                  onPressed: _openFullscreen,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
