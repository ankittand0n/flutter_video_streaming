import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';
import 'package:go_router/go_router.dart';

class InlineTrailerPlayer extends StatefulWidget {
  final String trailerUrl;
  final String? fullVideoUrl;
  final String title;

  const InlineTrailerPlayer({
    Key? key,
    required this.trailerUrl,
    this.fullVideoUrl,
    required this.title,
  }) : super(key: key);

  @override
  State<InlineTrailerPlayer> createState() => _InlineTrailerPlayerState();
}

class _InlineTrailerPlayerState extends State<InlineTrailerPlayer> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
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
      _videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(widget.trailerUrl),
        httpHeaders: {
          'User-Agent': 'NamkeenTV/1.0.0',
          'Referer': 'https://namkeentv.com',
        },
      );

      await _videoPlayerController.initialize();
      await _videoPlayerController.setVolume(0.0); // Start muted
      await _videoPlayerController.setLooping(true); // Loop the trailer

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController,
        autoPlay: true,
        looping: true,
        showControls: false, // We'll add custom controls
        allowFullScreen: false,
        aspectRatio: _videoPlayerController.value.aspectRatio,
      );

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
    _chewieController?.dispose();
    _videoPlayerController.dispose();
    super.dispose();
  }

  void _toggleMute() {
    if (!mounted || !_isInitialized) return;
    setState(() {
      _isMuted = !_isMuted;
      _videoPlayerController.setVolume(_isMuted ? 0.0 : 1.0);
    });
  }

  void _openFullscreen() {
    if (!mounted) return;
    // Pause the inline player before opening fullscreen
    _videoPlayerController.pause();
    context.push('/video-player', extra: {
      'videoUrl': widget.fullVideoUrl ?? widget.trailerUrl,
      'trailerUrl': widget.trailerUrl,
      'isTrailer': true,
    }).then((_) {
      // Resume playing when returning from fullscreen
      if (mounted && _isInitialized) {
        _videoPlayerController.play();
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
          aspectRatio: _videoPlayerController.value.aspectRatio,
          child: _chewieController != null
              ? Chewie(controller: _chewieController!)
              : Container(color: Colors.black),
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
