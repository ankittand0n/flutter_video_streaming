import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdvancedVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final String? trailerUrl;
  final bool isTrailer;
  final String title;
  final String? videoId; // Unique identifier for saving progress
  final List<SubtitleTrack>? subtitles;
  final List<AudioTrack>? audioTracks;
  final bool autoPlay;
  final bool autoFullScreen;
  final bool showControls;
  final bool allowFullScreen;
  final Duration? startAt;
  final VoidCallback? onVideoEnded;
  final Function(Duration)? onPositionChanged;

  const AdvancedVideoPlayer({
    Key? key,
    required this.videoUrl,
    this.trailerUrl,
    this.isTrailer = false,
    required this.title,
    this.videoId,
    this.subtitles,
    this.audioTracks,
    this.autoPlay = false,
    this.autoFullScreen = true,
    this.showControls = true,
    this.allowFullScreen = true,
    this.startAt,
    this.onVideoEnded,
    this.onPositionChanged,
  }) : super(key: key);

  @override
  State<AdvancedVideoPlayer> createState() => _AdvancedVideoPlayerState();
}

class _AdvancedVideoPlayerState extends State<AdvancedVideoPlayer> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  bool _isInitialized = false;
  bool _hasError = false;
  String? _errorMessage;
  int _selectedSubtitleIndex = -1;
  int _selectedAudioIndex = 0;
  bool _isFullScreen = false;
  bool _showControls = true;
  int _currentQuality = 0; // 0: Auto, 1: 360p, 2: 480p, 3: 720p, 4: 1080p
  final List<String> _qualityOptions = [
    'Auto',
    '360p',
    '480p',
    '720p',
    '1080p'
  ];

  @override
  void initState() {
    super.initState();
    _initializePlayer();
    WakelockPlus.enable(); // Keep screen awake during video playback

    // Auto enter fullscreen if enabled
    if (widget.autoFullScreen) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _enterFullScreen();
      });
    }
  }

  // Get saved playback position from SharedPreferences
  Future<Duration?> _getSavedPosition() async {
    if (widget.videoId == null) return null;

    try {
      final prefs = await SharedPreferences.getInstance();
      final savedSeconds = prefs.getInt('video_position_${widget.videoId}');
      if (savedSeconds != null && savedSeconds > 0) {
        return Duration(seconds: savedSeconds);
      }
    } catch (e) {
      debugPrint('Error loading saved position: $e');
    }
    return null;
  }

  // Save current playback position to SharedPreferences
  Future<void> _savePosition(Duration position) async {
    if (widget.videoId == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(
          'video_position_${widget.videoId}', position.inSeconds);
    } catch (e) {
      debugPrint('Error saving position: $e');
    }
  }

  // Clear saved position (called when video ends or user finishes watching)
  Future<void> _clearSavedPosition() async {
    if (widget.videoId == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('video_position_${widget.videoId}');
    } catch (e) {
      debugPrint('Error clearing saved position: $e');
    }
  }

  // Format duration for display (e.g., "1:23:45" or "12:34")
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '$hours:${twoDigits(minutes)}:${twoDigits(seconds)}';
    }
    return '${minutes}:${twoDigits(seconds)}';
  }

  Future<void> _initializePlayer() async {
    try {
      final videoUrl = widget.isTrailer && widget.trailerUrl != null
          ? widget.trailerUrl!
          : widget.videoUrl;

      // Support for different video sources
      if (videoUrl.contains('youtube.com') || videoUrl.contains('youtu.be')) {
        // For YouTube videos, you might want to extract the video ID and use youtube_player_flutter
        _handleYouTubeVideo(videoUrl);
        return;
      }

      // For adaptive streaming, you would typically have multiple quality URLs
      // For now, we'll use the single URL provided
      String adaptiveUrl = _getQualityUrl(videoUrl, _currentQuality);

      _videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(adaptiveUrl),
        httpHeaders: {
          'User-Agent': 'NamkeenTV/1.0.0',
          'Referer': 'https://namkeentv.com',
        },
      );

      await _videoPlayerController.initialize();

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController,
        autoPlay: widget.autoPlay,
        looping: false,
        allowFullScreen: widget.allowFullScreen,
        allowMuting: true,
        allowPlaybackSpeedChanging: true,
        showControls: widget.showControls,
        materialProgressColors: ChewieProgressColors(
          playedColor: Colors.red,
          handleColor: Colors.red,
          backgroundColor: Colors.grey,
          bufferedColor: Colors.lightGreen,
        ),
        placeholder: Container(
          color: Colors.black,
          child: const Center(
            child: CircularProgressIndicator(
              color: Colors.red,
            ),
          ),
        ),
        autoInitialize: true,
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 64,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Error playing video',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                const SizedBox(height: 8),
                Text(
                  errorMessage,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _retryInitialization(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        },
      );

      // Load saved position or use startAt parameter
      Duration? resumePosition;
      if (widget.startAt != null) {
        resumePosition = widget.startAt;
      } else {
        resumePosition = await _getSavedPosition();
      }

      // Start at specific time if provided or from saved position
      if (resumePosition != null && resumePosition.inSeconds > 0) {
        await _videoPlayerController.seekTo(resumePosition);

        // Show a snackbar to inform user about resume
        if (mounted && resumePosition.inSeconds > 10) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Resuming from ${_formatDuration(resumePosition)}'),
              duration: const Duration(seconds: 2),
              backgroundColor: Colors.black87,
            ),
          );
        }
      }

      // Listen for video completion and position changes
      _videoPlayerController.addListener(() {
        final position = _videoPlayerController.value.position;
        final duration = _videoPlayerController.value.duration;

        // Check if video ended (within 5 seconds of the end)
        if (duration.inSeconds > 0 &&
            (duration.inSeconds - position.inSeconds) <= 5) {
          widget.onVideoEnded?.call();
          _clearSavedPosition(); // Clear saved position when video ends
        } else {
          // Save position every 5 seconds (not too frequently to avoid performance issues)
          if (position.inSeconds % 5 == 0 && position.inSeconds > 0) {
            _savePosition(position);
          }
        }

        // Report position changes
        widget.onPositionChanged?.call(position);
      });

      setState(() {
        _isInitialized = true;
        _hasError = false;
      });

      // Enter Chewie fullscreen overlay if autoFullScreen is true
      if (widget.autoFullScreen) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _chewieController?.enterFullScreen();
        });
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
      });
    }
  }

  void _handleYouTubeVideo(String url) {
    // TODO: Implement YouTube player integration
    // You can use youtube_player_flutter for YouTube videos
    setState(() {
      _hasError = true;
      _errorMessage = 'YouTube videos not yet supported in this player';
    });
  }

  Future<void> _retryInitialization() async {
    setState(() {
      _isInitialized = false;
      _hasError = false;
      _errorMessage = null;
    });
    await _initializePlayer();
  }

  String _getQualityUrl(String baseUrl, int qualityIndex) {
    // In a real implementation, you would have different URLs for different qualities
    // For example:
    // - https://example.com/video_360p.m3u8
    // - https://example.com/video_480p.m3u8
    // - https://example.com/video_720p.m3u8
    // - https://example.com/video_1080p.m3u8

    // For demonstration, we'll return the same URL
    // In production, you would implement logic to return different quality URLs
    switch (qualityIndex) {
      case 1: // 360p
        return baseUrl.replaceAll('.mp4', '_360p.mp4');
      case 2: // 480p
        return baseUrl.replaceAll('.mp4', '_480p.mp4');
      case 3: // 720p
        return baseUrl.replaceAll('.mp4', '_720p.mp4');
      case 4: // 1080p
        return baseUrl.replaceAll('.mp4', '_1080p.mp4');
      default: // Auto - return original URL
        return baseUrl;
    }
  }

  Future<void> _changeQuality(int qualityIndex) async {
    if (_currentQuality == qualityIndex) return;

    final currentPosition = _videoPlayerController.value.position;
    final wasPlaying = _videoPlayerController.value.isPlaying;

    // Dispose current controllers
    await _videoPlayerController.dispose();
    _chewieController?.dispose();

    // Update quality and reinitialize
    _currentQuality = qualityIndex;
    await _initializePlayer();

    // Restore position and playing state
    await _videoPlayerController.seekTo(currentPosition);
    if (wasPlaying) {
      await _videoPlayerController.play();
    }
  }

  void _enterFullScreen() {
    if (!_isFullScreen) {
      setState(() {
        _isFullScreen = true;
        _showControls = true; // Show controls when entering fullscreen
      });

      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);

      // Start timer to hide controls
      _startHideControlsTimer();
    }
  }

  void _exitFullScreen() {
    if (_isFullScreen) {
      setState(() {
        _isFullScreen = false;
      });

      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
    }
  }

  void _toggleFullScreen() {
    if (_isFullScreen) {
      _exitFullScreen();
    } else {
      _enterFullScreen();
    }
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });

    if (_showControls) {
      _startHideControlsTimer();
    }
  }

  void _startHideControlsTimer() {
    // Auto-hide controls after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _showControls && _isFullScreen) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  void _showQualitySettings() {
    setState(() {
      _showControls = true;
    });
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black87,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Video Quality',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ..._qualityOptions.asMap().entries.map((entry) {
                final index = entry.key;
                final quality = entry.value;
                return ListTile(
                  title: Text(
                    quality,
                    style: const TextStyle(color: Colors.white),
                  ),
                  leading: Radio<int>(
                    value: index,
                    groupValue: _currentQuality,
                    onChanged: (value) {
                      Navigator.pop(context);
                      _changeQuality(value!);
                    },
                    activeColor: Colors.red,
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _showSubtitleSettings() {
    setState(() {
      _showControls = true;
    });
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black87,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Subtitles',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text(
                  'Off',
                  style: TextStyle(color: Colors.white),
                ),
                leading: Radio<int>(
                  value: -1,
                  groupValue: _selectedSubtitleIndex,
                  onChanged: (value) {
                    setState(() {
                      _selectedSubtitleIndex = value!;
                    });
                    Navigator.pop(context);
                  },
                  activeColor: Colors.red,
                ),
              ),
              if (widget.subtitles != null)
                ...widget.subtitles!.asMap().entries.map((entry) {
                  final index = entry.key;
                  final subtitle = entry.value;
                  return ListTile(
                    title: Text(
                      subtitle.language,
                      style: const TextStyle(color: Colors.white),
                    ),
                    leading: Radio<int>(
                      value: index,
                      groupValue: _selectedSubtitleIndex,
                      onChanged: (value) {
                        setState(() {
                          _selectedSubtitleIndex = value!;
                        });
                        Navigator.pop(context);
                      },
                      activeColor: Colors.red,
                    ),
                  );
                }),
            ],
          ),
        );
      },
    );
  }

  void _showAudioSettings() {
    setState(() {
      _showControls = true;
    });
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black87,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Audio Tracks',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              if (widget.audioTracks != null)
                ...widget.audioTracks!.asMap().entries.map((entry) {
                  final index = entry.key;
                  final audioTrack = entry.value;
                  return ListTile(
                    title: Text(
                      '${audioTrack.language} (${audioTrack.quality})',
                      style: const TextStyle(color: Colors.white),
                    ),
                    leading: Radio<int>(
                      value: index,
                      groupValue: _selectedAudioIndex,
                      onChanged: (value) {
                        setState(() {
                          _selectedAudioIndex = value!;
                        });
                        Navigator.pop(context);
                      },
                      activeColor: Colors.red,
                    ),
                  );
                }),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isFullScreen,
      onPopInvoked: (bool didPop) {
        if (!didPop && _isFullScreen) {
          _exitFullScreen();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: _isFullScreen
            ? null
            : AppBar(
                backgroundColor: Colors.black,
                title: Text(
                  widget.title,
                  style: const TextStyle(color: Colors.white),
                ),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.high_quality, color: Colors.white),
                    onPressed: _showQualitySettings,
                  ),
                  if (widget.subtitles != null && widget.subtitles!.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.subtitles, color: Colors.white),
                      onPressed: _showSubtitleSettings,
                    ),
                  if (widget.audioTracks != null &&
                      widget.audioTracks!.length > 1)
                    IconButton(
                      icon: const Icon(Icons.audiotrack, color: Colors.white),
                      onPressed: _showAudioSettings,
                    ),
                  IconButton(
                    icon: Icon(
                      _isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen,
                      color: Colors.white,
                    ),
                    onPressed: _toggleFullScreen,
                  ),
                ],
              ),
        body: GestureDetector(
          onTap: () {
            if (_isFullScreen) {
              _toggleControls();
            }
          },
          child: Stack(
            children: [
              _buildVideoPlayer(),
              // Fullscreen overlay controls - only show when _showControls is true
              if (_isFullScreen && _showControls) _buildFullscreenControls(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFullscreenControls() {
    return AnimatedOpacity(
      opacity: _showControls ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: Stack(
        children: [
          // Top controls bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.transparent,
                  ],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Back button
                      IconButton(
                        icon: const Icon(Icons.arrow_back,
                            color: Colors.white, size: 28),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      // Title
                      Expanded(
                        child: Text(
                          widget.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Control buttons
                      IconButton(
                        icon: const Icon(Icons.high_quality,
                            color: Colors.white, size: 28),
                        onPressed: _showQualitySettings,
                      ),
                      if (widget.subtitles != null &&
                          widget.subtitles!.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.subtitles,
                              color: Colors.white, size: 28),
                          onPressed: _showSubtitleSettings,
                        ),
                      if (widget.audioTracks != null &&
                          widget.audioTracks!.length > 1)
                        IconButton(
                          icon: const Icon(Icons.audiotrack,
                              color: Colors.white, size: 28),
                          onPressed: _showAudioSettings,
                        ),
                      IconButton(
                        icon: const Icon(Icons.fullscreen_exit,
                            color: Colors.white, size: 28),
                        onPressed: _toggleFullScreen,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoPlayer() {
    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 64,
            ),
            const SizedBox(height: 16),
            const Text(
              'Failed to load video',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Unknown error',
              style: const TextStyle(color: Colors.white70, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _retryInitialization,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (!_isInitialized || _chewieController == null) {
      return const Center(
        child: CircularProgressIndicator(
          color: Colors.red,
        ),
      );
    }

    return Center(
      child: AspectRatio(
        aspectRatio: _videoPlayerController.value.aspectRatio,
        child: Chewie(
          controller: _chewieController!,
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Save current position before disposing
    if (_isInitialized && !_hasError) {
      final position = _videoPlayerController.value.position;
      final duration = _videoPlayerController.value.duration;

      // Only save if video hasn't ended (not within last 5 seconds)
      if (duration.inSeconds > 0 &&
          (duration.inSeconds - position.inSeconds) > 5 &&
          position.inSeconds > 0) {
        _savePosition(position);
      }
    }

    _videoPlayerController.dispose();
    _chewieController?.dispose();
    WakelockPlus.disable();

    // Reset system UI when leaving video player
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    super.dispose();
  }
}

// Data classes for subtitle and audio tracks
class SubtitleTrack {
  final String language;
  final String url;
  final String format; // 'srt', 'vtt', etc.

  SubtitleTrack({
    required this.language,
    required this.url,
    required this.format,
  });
}

class AudioTrack {
  final String language;
  final String quality; // '128kbps', '320kbps', etc.
  final String url;

  AudioTrack({
    required this.language,
    required this.quality,
    required this.url,
  });
}
