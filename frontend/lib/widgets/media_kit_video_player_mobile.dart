import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

/// HLS quality level parsed from a master playlist.
class _HlsQuality {
  final String label;  // e.g. "1080p"
  final String url;    // absolute variant-stream URL
  final int height;

  const _HlsQuality({required this.label, required this.url, required this.height});
}

/// Same public interface as before — all callers are unchanged.
class MediaKitVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final String? trailerUrl;
  final bool isTrailer;
  final String title;
  final String? videoId;
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
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _hasError = false;
  String? _errorMessage;
  bool _isFullScreen = false;
  bool _showControls = true;
  Timer? _hideControlsTimer;
  Timer? _savePositionTimer;
  bool _endedFired = false;

  // Slider drag state
  bool _isDraggingSlider = false;
  double _dragSliderValue = 0.0;

  // HLS quality levels (populated on first load of a master playlist)
  List<_HlsQuality> _qualities = [];
  // -1 = Auto (master playlist), otherwise index into _qualities
  int _selectedQualityIndex = -1;
  // The master playlist URL (always kept so Auto can restore it)
  String? _masterUrl;

  // ─── SharedPreferences helpers ───────────────────────────────────────────

  Future<Duration?> _getSavedPosition() async {
    if (widget.videoId == null) return null;
    try {
      final prefs = await SharedPreferences.getInstance();
      final s = prefs.getInt('video_position_${widget.videoId}');
      if (s != null && s > 0) return Duration(seconds: s);
    } catch (e) {
      debugPrint('Error loading saved position: $e');
    }
    return null;
  }

  Future<void> _savePosition(Duration position) async {
    if (widget.videoId == null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('video_position_${widget.videoId}', position.inSeconds);
    } catch (e) {
      debugPrint('Error saving position: $e');
    }
  }

  Future<void> _clearSavedPosition() async {
    if (widget.videoId == null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('video_position_${widget.videoId}');
    } catch (e) {
      debugPrint('Error clearing saved position: $e');
    }
  }

  String _formatDuration(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    return h > 0 ? '$h:${two(m)}:${two(s)}' : '${two(m)}:${two(s)}';
  }

  // ─── HLS manifest parser ─────────────────────────────────────────────────

  Future<List<_HlsQuality>> _parseHlsQualities(String masterUrl) async {
    try {
      final response = await http.get(Uri.parse(masterUrl))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) return [];

      final lines = response.body.split('\n');
      final List<_HlsQuality> results = [];

      for (int i = 0; i < lines.length; i++) {
        final line = lines[i].trim();
        if (!line.startsWith('#EXT-X-STREAM-INF:')) continue;

        final resMatch = RegExp(r'RESOLUTION=\d+x(\d+)').firstMatch(line);
        if (resMatch == null || i + 1 >= lines.length) continue;

        final height = int.parse(resMatch.group(1)!);
        final variantLine = lines[i + 1].trim();
        if (variantLine.isEmpty || variantLine.startsWith('#')) continue;

        final variantUrl = variantLine.startsWith('http')
            ? variantLine
            : '${masterUrl.substring(0, masterUrl.lastIndexOf('/') + 1)}$variantLine';

        results.add(_HlsQuality(
          label: '${height}p',
          url: variantUrl,
          height: height,
        ));
      }

      results.sort((a, b) => b.height.compareTo(a.height)); // highest first
      return results;
    } catch (e) {
      debugPrint('HLS parse error: $e');
      return [];
    }
  }

  // ─── Player lifecycle ─────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _isFullScreen = widget.autoFullScreen;
    WakelockPlus.enable();
    _initializePlayer();
    if (widget.autoFullScreen) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _enterFullScreen());
    }
  }

  /// [url] defaults to the widget's videoUrl.
  /// [resumeAt] overrides the saved/startAt position (used when switching quality).
  Future<void> _initializePlayer({String? url, Duration? resumeAt}) async {
    final videoUrl = url ??
        (widget.isTrailer && widget.trailerUrl != null
            ? widget.trailerUrl!
            : widget.videoUrl);

    try {
      // Tear down existing controller if any
      _savePositionTimer?.cancel();
      final oldController = _controller;
      if (oldController != null) {
        oldController.removeListener(_playerListener);
        await oldController.dispose();
        _controller = null;
      }

      // Parse HLS qualities once for the master playlist
      final bool isHls = videoUrl.toLowerCase().contains('.m3u8');
      if (isHls && _qualities.isEmpty) {
        _masterUrl = videoUrl;
        final parsed = await _parseHlsQualities(videoUrl);
        if (mounted) {
          setState(() => _qualities = parsed);
        }
      }

      // Determine start position
      Duration? startPos = resumeAt;
      if (startPos == null) {
        startPos = widget.startAt ?? await _getSavedPosition();
      }

      // Build controller
      final controller =
          VideoPlayerController.networkUrl(Uri.parse(videoUrl));

      // initialize() resolves only when ExoPlayer reaches READY —
      // seekTo() after this is guaranteed to be honoured.
      await controller.initialize();

      if (startPos != null && startPos.inSeconds > 0) {
        await controller.seekTo(startPos);
        if (mounted && startPos.inSeconds > 10 && resumeAt == null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Resuming from ${_formatDuration(startPos)}'),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.black87,
          ));
        }
      }

      controller.addListener(_playerListener);

      _savePositionTimer =
          Timer.periodic(const Duration(seconds: 5), (_) {
        if (_controller != null && !_hasError && !_endedFired) {
          _savePosition(_controller!.value.position);
        }
      });

      if (widget.autoPlay) await controller.play();

      if (mounted) {
        setState(() {
          _controller = controller;
          _isInitialized = true;
          _hasError = false;
          _endedFired = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = e.toString();
        });
      }
    }
  }

  void _playerListener() {
    if (!mounted || _controller == null) return;
    final value = _controller!.value;
    widget.onPositionChanged?.call(value.position);

    if (!_endedFired &&
        value.duration.inSeconds > 0 &&
        (value.duration.inSeconds - value.position.inSeconds) <= 2) {
      _endedFired = true;
      widget.onVideoEnded?.call();
      _clearSavedPosition();
    }
  }

  // ─── Quality switching ────────────────────────────────────────────────────

  Future<void> _switchQuality(int index) async {
    // Save current position before tearing down
    final currentPos = _controller?.value.position ?? Duration.zero;

    // -1 → Auto (master playlist), otherwise specific variant
    final newUrl = index == -1
        ? _masterUrl ?? widget.videoUrl
        : _qualities[index].url;

    setState(() {
      _selectedQualityIndex = index;
      _isInitialized = false;
    });

    await _initializePlayer(url: newUrl, resumeAt: currentPos);
  }

  // ─── Fullscreen / controls ────────────────────────────────────────────────

  void _enterFullScreen() async {
    if (_isFullScreen) return;
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    setState(() {
      _isFullScreen = true;
      _showControls = true;
    });
    _startHideControlsTimer();
  }

  void _exitFullScreen() async {
    if (!_isFullScreen) return;
    await SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp]);
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    setState(() => _isFullScreen = false);
    if (widget.autoFullScreen && mounted) Navigator.of(context).pop();
  }

  void _toggleFullScreen() =>
      _isFullScreen ? _exitFullScreen() : _enterFullScreen();

  void _toggleControls() {
    setState(() => _showControls = !_showControls);
    if (_showControls) _startHideControlsTimer();
  }

  void _startHideControlsTimer() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && _isFullScreen) setState(() => _showControls = false);
    });
  }

  // ─── Quality bottom sheet ─────────────────────────────────────────────────

  void _showQualityMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black87,
      isScrollControlled: true,
      builder: (_) => Container(
        constraints:
            BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.5),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Video Quality',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  // Auto
                  ListTile(
                    title: const Text('Auto',
                        style: TextStyle(color: Colors.white)),
                    subtitle: const Text('Adaptive (recommended)',
                        style:
                            TextStyle(color: Colors.white54, fontSize: 12)),
                    leading: Radio<int>(
                      value: -1,
                      groupValue: _selectedQualityIndex,
                      onChanged: (v) {
                        Navigator.pop(context);
                        _switchQuality(-1);
                      },
                      activeColor: Colors.red,
                    ),
                  ),
                  // Specific qualities (highest first)
                  ..._qualities.asMap().entries.map((e) => ListTile(
                        title: Text(e.value.label,
                            style: const TextStyle(color: Colors.white)),
                        leading: Radio<int>(
                          value: e.key,
                          groupValue: _selectedQualityIndex,
                          onChanged: (v) {
                            Navigator.pop(context);
                            _switchQuality(e.key);
                          },
                          activeColor: Colors.red,
                        ),
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isFullScreen,
      onPopInvokedWithResult: (bool didPop, _) {
        if (!didPop && _isFullScreen) _exitFullScreen();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: _isFullScreen
            ? null
            : AppBar(
                backgroundColor: Colors.black,
                title: Text(widget.title,
                    style: const TextStyle(color: Colors.white)),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                actions: [
                  if (_qualities.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.hd, color: Colors.white),
                      onPressed: _showQualityMenu,
                    ),
                  IconButton(
                    icon: Icon(
                      _isFullScreen
                          ? Icons.fullscreen_exit
                          : Icons.fullscreen,
                      color: Colors.white,
                    ),
                    onPressed: _toggleFullScreen,
                  ),
                ],
              ),
        body: GestureDetector(
          onTap: () {
            if (_isFullScreen) _toggleControls();
          },
          child: Stack(
            children: [
              _buildVideoSurface(),
              if (!_isFullScreen || _showControls) _buildControls(),
              if (_isFullScreen && _showControls) _buildFullscreenTopBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVideoSurface() {
    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 64),
            const SizedBox(height: 16),
            const Text('Failed to load video',
                style: TextStyle(color: Colors.white, fontSize: 18)),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(_errorMessage ?? 'Unknown error',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                  textAlign: TextAlign.center),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _hasError = false;
                  _isInitialized = false;
                });
                _initializePlayer();
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (!_isInitialized || _controller == null) {
      return const Center(
          child: CircularProgressIndicator(color: Colors.red));
    }

    return Center(
      child: AspectRatio(
        aspectRatio: _controller!.value.aspectRatio,
        child: VideoPlayer(_controller!),
      ),
    );
  }

  Widget _buildControls() {
    if (!_isInitialized || _controller == null) return const SizedBox.shrink();

    return ValueListenableBuilder<VideoPlayerValue>(
      valueListenable: _controller!,
      builder: (context, value, _) {
        final position = value.position;
        final duration = value.duration;
        final isPlaying = value.isPlaying;
        final isBuffering = value.isBuffering;
        final progress = duration.inMilliseconds > 0
            ? (position.inMilliseconds / duration.inMilliseconds)
                .clamp(0.0, 1.0)
            : 0.0;

        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Color(0xB3000000)],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Buffering spinner overlaid at center (doesn't block controls)
              if (isBuffering)
                const Expanded(
                  child: Center(
                      child: CircularProgressIndicator(
                          color: Colors.red, strokeWidth: 2)),
                )
              else
                const Spacer(),
              // Seek bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Text(_formatDuration(position),
                        style: const TextStyle(
                            color: Colors.white, fontSize: 12)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 2,
                          thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 6),
                          overlayShape: const RoundSliderOverlayShape(
                              overlayRadius: 14),
                        ),
                        child: Slider(
                          value: _isDraggingSlider
                              ? _dragSliderValue
                              : progress,
                          onChangeStart: (v) => setState(() {
                            _isDraggingSlider = true;
                            _dragSliderValue = v;
                          }),
                          onChanged: (v) =>
                              setState(() => _dragSliderValue = v),
                          onChangeEnd: (v) {
                            _controller!.seekTo(Duration(
                                milliseconds:
                                    (v * duration.inMilliseconds).round()));
                            setState(() => _isDraggingSlider = false);
                          },
                          activeColor: Colors.red,
                          inactiveColor: Colors.white38,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(_formatDuration(duration),
                        style: const TextStyle(
                            color: Colors.white, fontSize: 12)),
                  ],
                ),
              ),
              // Playback buttons row
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Quality button (bottom bar, visible in fullscreen too)
                    if (_qualities.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.hd,
                            color: Colors.white, size: 24),
                        onPressed: _showQualityMenu,
                      ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.replay_10,
                          color: Colors.white, size: 32),
                      onPressed: () {
                        final np = position - const Duration(seconds: 10);
                        _controller!.seekTo(
                            np < Duration.zero ? Duration.zero : np);
                      },
                    ),
                    const SizedBox(width: 16),
                    IconButton(
                      icon: Icon(
                          isPlaying ? Icons.pause : Icons.play_arrow,
                          color: Colors.white,
                          size: 48),
                      onPressed: () => isPlaying
                          ? _controller!.pause()
                          : _controller!.play(),
                    ),
                    const SizedBox(width: 16),
                    IconButton(
                      icon: const Icon(Icons.forward_10,
                          color: Colors.white, size: 32),
                      onPressed: () {
                        final np = position + const Duration(seconds: 10);
                        _controller!.seekTo(
                            np > duration ? duration : np);
                      },
                    ),
                    const Spacer(),
                    // Fullscreen toggle in bottom bar
                    IconButton(
                      icon: Icon(
                          _isFullScreen
                              ? Icons.fullscreen_exit
                              : Icons.fullscreen,
                          color: Colors.white,
                          size: 24),
                      onPressed: _toggleFullScreen,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFullscreenTopBar() {
    return AnimatedOpacity(
      opacity: _showControls ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: Align(
        alignment: Alignment.topCenter,
        child: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xB3000000), Colors.transparent],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back,
                        color: Colors.white, size: 28),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Expanded(
                    child: Text(widget.title,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─── Dispose ──────────────────────────────────────────────────────────────

  @override
  void dispose() {
    _hideControlsTimer?.cancel();
    _savePositionTimer?.cancel();
    if (_controller != null && !_hasError && !_endedFired) {
      final pos = _controller!.value.position;
      final dur = _controller!.value.duration;
      if (dur.inSeconds > 0 &&
          pos.inSeconds > 0 &&
          (dur.inSeconds - pos.inSeconds) > 5) {
        _savePosition(pos);
      }
    }
    _controller?.removeListener(_playerListener);
    _controller?.dispose();
    WakelockPlus.disable();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }
}
