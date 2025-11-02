import 'dart:async';

/// Stub implementation for non-web platforms (mobile)
/// Chromecast is not supported on mobile in this implementation
class CastService {
  static CastService? _instance;
  static CastService get instance => _instance ??= CastService._();

  CastService._();

  // Stream controllers for cast state
  final _castStateController = StreamController<CastState>.broadcast();
  final _mediaStateController = StreamController<MediaState>.broadcast();

  Stream<CastState> get castStateStream => _castStateController.stream;
  Stream<MediaState> get mediaStateStream => _mediaStateController.stream;

  bool get isInitialized => false;
  bool get isCasting => false;

  /// No-op on mobile
  Future<void> initialize() async {
    // Cast is not supported on mobile
  }

  /// No-op on mobile
  Future<void> showCastDialog() async {
    // Cast is not supported on mobile
  }

  /// No-op on mobile
  Future<void> castMedia({
    required String mediaUrl,
    required String title,
    String? description,
    String? imageUrl,
    String? contentType,
  }) async {
    // Cast is not supported on mobile
  }

  /// No-op on mobile
  Future<void> loadMedia(String mediaUrl, String title,
      {String? imageUrl}) async {
    // Cast is not supported on mobile
  }

  /// No-op on mobile
  Future<void> play() async {
    // Cast is not supported on mobile
  }

  /// No-op on mobile
  Future<void> pause() async {
    // Cast is not supported on mobile
  }

  /// No-op on mobile
  Future<void> togglePlayPause() async {
    // Cast is not supported on mobile
  }

  /// No-op on mobile
  Future<void> stopCasting() async {
    // Cast is not supported on mobile
  }

  void dispose() {
    _castStateController.close();
    _mediaStateController.close();
  }
}

enum CastState {
  noDevicesAvailable,
  notConnected,
  connecting,
  connected,
}

enum MediaState {
  idle,
  loading,
  loaded,
  playing,
  paused,
  error,
}
