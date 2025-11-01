import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:js_interop' as js;

// Web fullscreen API bindings
@js.JS('document.documentElement')
external js.JSObject get _documentElement;

@js.JS('document.fullscreenElement')
external js.JSObject? get _fullscreenElement;

@js.JS('document')
external js.JSObject get _document;

extension on js.JSObject {
  external void requestFullscreen();
  external void addEventListener(String type, js.JSFunction listener);
  external void removeEventListener(String type, js.JSFunction listener);
}

@js.JS('document.exitFullscreen')
external void _exitFullscreen();

class MediaKitVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final String? trailerUrl;
  final bool isTrailer;
  final String title;
  final String? videoId; // Unique identifier for saving progress
  final bool autoPlay;
  final bool autoFullScreen;
  final Duration? startAt;
  final VoidCallback? onVideoEnded;
  final Function(Duration)? onPositionChanged;

  const MediaKitVideoPlayer({
    super.key,
    required this.videoUrl,
    this.trailerUrl,
    this.isTrailer = false,
    required this.title,
    this.videoId,
    this.autoPlay = false,
    this.autoFullScreen = true,
    this.startAt,
    this.onVideoEnded,
    this.onPositionChanged,
  });

  @override
  State<MediaKitVideoPlayer> createState() => _MediaKitVideoPlayerState();
}

class _MediaKitVideoPlayerState extends State<MediaKitVideoPlayer> {
  late final Player _player;
  late final VideoController _videoController;
  bool _isInitialized = false;
  bool _hasError = false;
  String? _errorMessage;
  late bool
      _isFullScreen; // Will be initialized in initState based on autoFullScreen
  bool _showControls = true;
  List<VideoTrack> _videoTracks = [];
  VideoTrack _currentVideoTrack = VideoTrack.auto();
  js.JSFunction? _fullscreenChangeListener;

  @override
  void initState() {
    super.initState();

    // Initialize fullscreen state immediately if autoFullScreen is enabled
    // This prevents the AppBar from showing on first build
    _isFullScreen = widget.autoFullScreen;

    _initializePlayer();
    WakelockPlus.enable(); // Keep screen awake during video playback

    // Listen for fullscreen changes (e.g., user presses ESC)
    if (kIsWeb) {
      _fullscreenChangeListener = (() {
        if (_fullscreenElement == null && _isFullScreen) {
          // User exited fullscreen via ESC or browser button
          if (mounted) {
            setState(() {
              _isFullScreen = false;
            });
            // Close the dialog if in auto-fullscreen mode
            if (widget.autoFullScreen) {
              Navigator.of(context).pop();
            }
          }
        }
      }).toJS;
      _document.addEventListener(
          'fullscreenchange', _fullscreenChangeListener!);
    }

    // Auto enter fullscreen if enabled
    // Must be called synchronously from initState to preserve user gesture context
    if (widget.autoFullScreen && kIsWeb) {
      // Call immediately for web to preserve user gesture
      try {
        debugPrint('Requesting immediate fullscreen in initState...');
        _documentElement.requestFullscreen();
      } catch (e) {
        debugPrint('Failed to request fullscreen in initState: $e');
        // Fallback: try again in postFrameCallback
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _enterFullScreen();
        });
      }
    } else if (widget.autoFullScreen) {
      // For mobile, use postFrameCallback
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
    return '$minutes:${twoDigits(seconds)}';
  }

  Future<void> _initializePlayer() async {
    try {
      final videoUrl = widget.isTrailer && widget.trailerUrl != null
          ? widget.trailerUrl!
          : widget.videoUrl;

      // Create Player instance
      _player = Player();

      // Create VideoController
      _videoController = VideoController(
        _player,
        configuration: const VideoControllerConfiguration(
          enableHardwareAcceleration: true,
        ),
      );

      // Open media (without unsafe headers for web compatibility)
      await _player.open(
        Media(videoUrl),
        play: widget.autoPlay,
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
        await _player.seek(resumePosition);

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

      // Listen for position changes
      _player.stream.position.listen((position) {
        final duration = _player.state.duration;

        // Check if video ended (within 5 seconds of the end)
        if (duration.inSeconds > 0 &&
            (duration.inSeconds - position.inSeconds) <= 5) {
          widget.onVideoEnded?.call();
          _clearSavedPosition(); // Clear saved position when video ends
        } else {
          // Save position every 5 seconds
          if (position.inSeconds % 5 == 0 && position.inSeconds > 0) {
            _savePosition(position);
          }
        }

        // Report position changes
        widget.onPositionChanged?.call(position);
      });

      // Listen for errors
      _player.stream.error.listen((error) {
        if (mounted) {
          setState(() {
            _hasError = true;
            _errorMessage = error;
          });
        }
      });

      // Listen for available video tracks (for quality selection)
      _player.stream.tracks.listen((tracks) {
        if (mounted) {
          setState(() {
            _videoTracks = tracks.video;
          });
        }
      });

      // Listen for current video track changes
      _player.stream.track.listen((track) {
        if (mounted) {
          setState(() {
            _currentVideoTrack = track.video;
          });
        }
      });

      setState(() {
        _isInitialized = true;
        _hasError = false;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _retryInitialization() async {
    setState(() {
      _isInitialized = false;
      _hasError = false;
      _errorMessage = null;
    });
    await _initializePlayer();
  }

  void _enterFullScreen() async {
    if (!_isFullScreen) {
      setState(() {
        _isFullScreen = true;
        _showControls = true;
      });

      // Use native browser fullscreen API on web
      if (kIsWeb) {
        try {
          // Request fullscreen on the document element (entire page, F11-style)
          debugPrint('Requesting browser fullscreen...');
          _documentElement.requestFullscreen();
          debugPrint('Fullscreen requested successfully');
        } catch (e) {
          debugPrint('Failed to enter native fullscreen: $e');
        }
      } else {
        // Mobile fullscreen
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);
      }

      _startHideControlsTimer();
    }
  }

  void _exitFullScreen() async {
    if (_isFullScreen) {
      setState(() {
        _isFullScreen = false;
      });

      // Exit native browser fullscreen on web
      if (kIsWeb) {
        try {
          // Only exit if currently in fullscreen
          if (_fullscreenElement != null) {
            _exitFullscreen();
          }
        } catch (e) {
          debugPrint('Failed to exit native fullscreen: $e');
        }
      } else {
        // Mobile fullscreen
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
        ]);
      }

      // If we were auto-fullscreen (dialog mode), close the dialog when exiting fullscreen
      if (widget.autoFullScreen && mounted) {
        Navigator.of(context).pop();
      }
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
              // Auto quality option
              ListTile(
                title: const Text(
                  'Auto',
                  style: TextStyle(color: Colors.white),
                ),
                subtitle: const Text(
                  'Automatic quality selection',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                leading: Radio<String>(
                  value: 'auto',
                  groupValue: _currentVideoTrack.id,
                  onChanged: (value) {
                    _player.setVideoTrack(VideoTrack.auto());
                    Navigator.pop(context);
                  },
                  activeColor: Colors.red,
                ),
              ),
              // Available video tracks
              if (_videoTracks.isNotEmpty)
                ..._videoTracks.map((track) {
                  // Extract quality info from track id or title
                  String label = track.title ?? track.id;

                  // Try to extract resolution from track info
                  if (track.w != null && track.h != null) {
                    label = '${track.h}p';
                    if (track.fps != null) {
                      label += ' (${track.fps?.round()} fps)';
                    }
                  }

                  return ListTile(
                    title: Text(
                      label,
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: track.w != null && track.h != null
                        ? Text(
                            '${track.w}x${track.h}',
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 12),
                          )
                        : null,
                    leading: Radio<String>(
                      value: track.id,
                      groupValue: _currentVideoTrack.id,
                      onChanged: (value) {
                        _player.setVideoTrack(track);
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
                  // Quality settings button
                  IconButton(
                    icon: const Icon(Icons.settings, color: Colors.white),
                    onPressed: _showQualitySettings,
                  ),
                  // Fullscreen button
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
              // Custom controls overlay (always show in normal mode, toggle in fullscreen)
              if (!_isFullScreen || _showControls)
                _buildCustomControlsOverlay(),
              // Fullscreen top bar
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
                      // Quality settings button
                      IconButton(
                        icon: const Icon(Icons.settings,
                            color: Colors.white, size: 28),
                        onPressed: _showQualitySettings,
                      ),
                      // Fullscreen button
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

    if (!_isInitialized) {
      return const Center(
        child: CircularProgressIndicator(
          color: Colors.red,
        ),
      );
    }

    return Center(
      child: Video(
        controller: _videoController,
        // Use NoVideoControls since we have custom controls
        controls: NoVideoControls,
      ),
    );
  }

  Widget _buildCustomControlsOverlay() {
    return StreamBuilder<bool>(
      stream: _player.stream.playing,
      builder: (context, playingSnapshot) {
        final isPlaying = playingSnapshot.data ?? false;

        return StreamBuilder<Duration>(
          stream: _player.stream.position,
          builder: (context, positionSnapshot) {
            final position = positionSnapshot.data ?? Duration.zero;

            return StreamBuilder<Duration>(
              stream: _player.stream.duration,
              builder: (context, durationSnapshot) {
                final duration = durationSnapshot.data ?? Duration.zero;
                final progress = duration.inMilliseconds > 0
                    ? position.inMilliseconds / duration.inMilliseconds
                    : 0.0;

                return Container(
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
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Progress bar
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          children: [
                            Text(
                              _formatDuration(position),
                              style: const TextStyle(color: Colors.white),
                            ),
                            Expanded(
                              child: Slider(
                                value: progress.clamp(0.0, 1.0),
                                onChanged: (value) {
                                  final newPosition = Duration(
                                    milliseconds:
                                        (value * duration.inMilliseconds)
                                            .round(),
                                  );
                                  _player.seek(newPosition);
                                },
                                activeColor: Colors.red,
                                inactiveColor: Colors.grey,
                              ),
                            ),
                            Text(
                              _formatDuration(duration),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      // Control buttons
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Rewind 10s
                            IconButton(
                              icon: const Icon(Icons.replay_10,
                                  color: Colors.white, size: 32),
                              onPressed: () {
                                final newPosition =
                                    position - const Duration(seconds: 10);
                                _player.seek(newPosition < Duration.zero
                                    ? Duration.zero
                                    : newPosition);
                              },
                            ),
                            const SizedBox(width: 24),
                            // Play/Pause
                            IconButton(
                              icon: Icon(
                                isPlaying ? Icons.pause : Icons.play_arrow,
                                color: Colors.white,
                                size: 48,
                              ),
                              onPressed: () {
                                _player.playOrPause();
                              },
                            ),
                            const SizedBox(width: 24),
                            // Forward 10s
                            IconButton(
                              icon: const Icon(Icons.forward_10,
                                  color: Colors.white, size: 32),
                              onPressed: () {
                                final newPosition =
                                    position + const Duration(seconds: 10);
                                _player.seek(newPosition > duration
                                    ? duration
                                    : newPosition);
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    // Save current position before disposing
    if (_isInitialized && !_hasError) {
      final position = _player.state.position;
      final duration = _player.state.duration;

      // Only save if video hasn't ended (not within last 5 seconds)
      if (duration.inSeconds > 0 &&
          (duration.inSeconds - position.inSeconds) > 5 &&
          position.inSeconds > 0) {
        _savePosition(position);
      }
    }

    // Remove fullscreen change listener on web
    if (kIsWeb && _fullscreenChangeListener != null) {
      _document.removeEventListener(
          'fullscreenchange', _fullscreenChangeListener!);
    }

    _player.dispose();
    WakelockPlus.disable();

    // Reset system UI when leaving video player
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    super.dispose();
  }
}
