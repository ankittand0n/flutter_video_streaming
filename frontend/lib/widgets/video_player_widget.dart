import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class VideoPlayerWidget extends StatefulWidget {
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
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  VideoPlayerController? _videoController;
  YoutubePlayerController? _youtubeController;
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;
  bool _showControls = true;
  bool _isMuted = false;
  bool _isFullscreen = false;
  // ignore: unused_field
  bool _isSystemUIVisible = true;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
    // Set initial system UI mode
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _isSystemUIVisible = false;
  }

  void _initializePlayer() async {
    try {
      if (widget.isTrailer && widget.trailerUrl != null) {
        // Play YouTube trailer
        final videoId = YoutubePlayer.convertUrlToId(widget.trailerUrl!);
        if (videoId != null) {
          _youtubeController = YoutubePlayerController(
            initialVideoId: videoId,
            flags: const YoutubePlayerFlags(
              autoPlay: true,
              mute: false,
              isLive: false,
              forceHD: true,
              enableCaption: false,
              hideControls: false,
            ),
          );
          setState(() {
            _isLoading = false;
          });
        } else {
          throw Exception('Invalid YouTube URL');
        }
      } else {
        // Play movie video
        if (widget.videoUrl.isEmpty) {
          throw Exception('Video URL is empty');
        }
        
        _videoController = VideoPlayerController.network(
          widget.videoUrl,
        );
        
        await _videoController!.initialize();
        _videoController!.setLooping(false);
        _videoController!.play();
        
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = e.toString();
      });
    }
  }

  void _toggleFullscreen() {
    setState(() {
      _isFullscreen = !_isFullscreen;
    });
    
    if (_isFullscreen) {
      // Enter fullscreen
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      _isSystemUIVisible = false;
    } else {
      // Exit fullscreen
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      _isSystemUIVisible = true;
    }
  }

  void _skipForward() {
    if (_videoController != null) {
      final currentPosition = _videoController!.value.position;
      final newPosition = currentPosition + const Duration(seconds: 10);
      final duration = _videoController!.value.duration;
      
      if (newPosition < duration) {
        _videoController!.seekTo(newPosition);
      } else {
        _videoController!.seekTo(duration);
      }
    }
  }

  void _skipBackward() {
    if (_videoController != null) {
      final currentPosition = _videoController!.value.position;
      final newPosition = currentPosition - const Duration(seconds: 10);
      
      if (newPosition > Duration.zero) {
        _videoController!.seekTo(newPosition);
      } else {
        _videoController!.seekTo(Duration.zero);
      }
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _youtubeController?.dispose();
    // Restore system UI and orientation
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () {
          setState(() {
            _showControls = !_showControls;
          });
        },
        child: Stack(
          children: [
            // Video Player
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(color: Colors.white),
              )
            else if (_hasError)
              _buildErrorWidget()
            else if (widget.isTrailer && _youtubeController != null)
              _buildYouTubePlayer()
            else if (_videoController != null)
              _buildVideoPlayer()
            else
              _buildErrorWidget(),

            // Controls overlay
            if (_showControls && !_isLoading && !_hasError)
              _buildControlsOverlay(),

            // Close button
            if (_showControls)
              Positioned(
                top: MediaQuery.of(context).padding.top + 10,
                right: 20,
                child: IconButton(
                  onPressed: widget.onClose ?? () => Navigator.of(context).pop(),
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),

            // Play trailer button (only for movie videos)
            if (!widget.isTrailer && 
                widget.trailerUrl != null && 
                !_isLoading && 
                !_hasError &&
                _showControls)
              Positioned(
                bottom: 50,
                right: 20,
                child: FloatingActionButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => VideoPlayerWidget(
                          videoUrl: widget.videoUrl,
                          trailerUrl: widget.trailerUrl,
                          isTrailer: true,
                          onClose: widget.onClose,
                        ),
                      ),
                    );
                  },
                  backgroundColor: Colors.red,
                  child: const Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildYouTubePlayer() {
    return Center(
      child: YoutubePlayer(
        controller: _youtubeController!,
        showVideoProgressIndicator: true,
        progressIndicatorColor: Colors.red,
        topActions: <Widget>[
          const SizedBox(width: 8.0),
          Expanded(
            child: Text(
              _youtubeController!.metadata.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18.0,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
        onReady: () {
          _youtubeController!.play();
        },
      ),
    );
  }

  Widget _buildVideoPlayer() {
    return Center(
      child: AspectRatio(
        aspectRatio: _videoController!.value.aspectRatio,
        child: VideoPlayer(_videoController!),
      ),
    );
  }

  Widget _buildControlsOverlay() {
    if (widget.isTrailer && _youtubeController != null) {
      return const SizedBox.shrink(); // YouTube player has its own controls
    }

    if (_videoController == null) return const SizedBox.shrink();

    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withValues(alpha: 0.3),
              Colors.transparent,
              Colors.black.withValues(alpha: 0.7),
            ],
          ),
        ),
        child: Column(
          children: [
            // Top controls
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _isMuted = !_isMuted;
                      });
                      _videoController!.setVolume(_isMuted ? 0.0 : 1.0);
                    },
                    icon: Icon(
                      _isMuted ? Icons.volume_off : Icons.volume_up,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  IconButton(
                    onPressed: _toggleFullscreen,
                    icon: Icon(
                      _isFullscreen ? Icons.fullscreen_exit : Icons.fullscreen,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ],
              ),
            ),
            
            // Center play/pause and skip controls
            Expanded(
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Skip backward button
                    IconButton(
                      onPressed: _skipBackward,
                      icon: const Icon(
                        Icons.replay_10,
                        color: Colors.white,
                        size: 48,
                      ),
                    ),
                    
                    // Play/pause button
                    IconButton(
                      onPressed: () {
                        setState(() {
                          if (_videoController!.value.isPlaying) {
                            _videoController!.pause();
                          } else {
                            _videoController!.play();
                          }
                        });
                      },
                      icon: Icon(
                        _videoController!.value.isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                        size: 64,
                      ),
                    ),
                    
                    // Skip forward button
                    IconButton(
                      onPressed: _skipForward,
                      icon: const Icon(
                        Icons.forward_10,
                        color: Colors.white,
                        size: 48,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Bottom controls
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Progress bar
                  VideoProgressIndicator(
                    _videoController!,
                    allowScrubbing: true,
                    colors: const VideoProgressColors(
                      playedColor: Colors.red,
                      backgroundColor: Colors.white24,
                      bufferedColor: Colors.white54,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Time and controls
                  Row(
                    children: [
                      Text(
                        _formatDuration(_videoController!.value.position),
                        style: const TextStyle(color: Colors.white),
                      ),
                      const Spacer(),
                      Text(
                        _formatDuration(_videoController!.value.duration),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    
    if (hours > 0) {
      return '${twoDigits(hours)}:${twoDigits(minutes)}:${twoDigits(seconds)}';
    } else {
      return '${twoDigits(minutes)}:${twoDigits(seconds)}';
    }
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.white,
            size: 64,
          ),
          const SizedBox(height: 16),
          const Text(
            'Unable to play video',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage ?? 'Unknown error occurred',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _isLoading = true;
                _hasError = false;
                _errorMessage = null;
              });
              _initializePlayer();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}