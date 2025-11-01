import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:js_interop' as js;
import 'dart:js_interop_unsafe' as js_unsafe;

/// Service to handle Chromecast functionality on web
class CastService {
  static CastService? _instance;
  static CastService get instance => _instance ??= CastService._();

  CastService._();

  // Stream controllers for cast state
  final _castStateController = StreamController<CastState>.broadcast();
  final _mediaStateController = StreamController<MediaState>.broadcast();

  Stream<CastState> get castStateStream => _castStateController.stream;
  Stream<MediaState> get mediaStateStream => _mediaStateController.stream;

  bool _isInitialized = false;
  bool _isCasting = false;
  String? _currentMediaUrl;
  String? _currentMediaTitle;

  bool get isInitialized => _isInitialized;
  bool get isCasting => _isCasting;

  /// Initialize the Cast framework
  Future<void> initialize() async {
    if (!kIsWeb || _isInitialized) return;

    try {
      // Wait for Cast API to be available
      await _waitForCastApi();

      // Initialize with default media receiver app ID (for generic media content)
      _initializeCastApi();

      // Give the Cast SDK a moment to fully initialize
      await Future.delayed(const Duration(milliseconds: 500));

      _isInitialized = true;
      debugPrint('Cast service initialized successfully');
    } catch (e) {
      debugPrint('Failed to initialize Cast service: $e');
    }
  }

  Future<void> _waitForCastApi() async {
    // Wait up to 5 seconds for Cast API to load
    for (int i = 0; i < 50; i++) {
      if (_isCastApiAvailable()) {
        return;
      }
      await Future.delayed(const Duration(milliseconds: 100));
    }
    throw Exception('Cast API not available');
  }

  bool _isCastApiAvailable() {
    try {
      // Check if chrome.cast API and cast.framework are available
      final chrome = js.globalContext.getProperty('chrome'.toJS);
      if (chrome == null || chrome.isNull || chrome.isUndefined) return false;
      final castObj = (chrome as js.JSObject).getProperty('cast'.toJS);
      if (castObj == null || castObj.isNull || castObj.isUndefined)
        return false;

      // Also check for cast.framework
      final castGlobal = js.globalContext.getProperty('cast'.toJS);
      if (castGlobal == null || castGlobal.isNull || castGlobal.isUndefined)
        return false;
      final framework =
          (castGlobal as js.JSObject).getProperty('framework'.toJS);
      return framework != null && !framework.isNull && !framework.isUndefined;
    } catch (e) {
      return false;
    }
  }

  void _initializeCastApi() {
    try {
      // Initialize Cast API with default settings
      final initCode = '''
        (function() {
          if (window.chrome && window.chrome.cast && cast.framework) {
            try {
              const context = cast.framework.CastContext.getInstance();
              context.setOptions({
                receiverApplicationId: chrome.cast.media.DEFAULT_MEDIA_RECEIVER_APP_ID,
                autoJoinPolicy: chrome.cast.AutoJoinPolicy.ORIGIN_SCOPED
              });
              
              // Listen for session state changes
              context.addEventListener(
                cast.framework.CastContextEventType.SESSION_STATE_CHANGED,
                function(event) {
                  window.flutterCastStateChanged && window.flutterCastStateChanged(
                    event.sessionState === cast.framework.SessionState.SESSION_STARTED ||
                    event.sessionState === cast.framework.SessionState.SESSION_RESUMED
                  );
                }
              );
              
              console.log('[CastService] Cast API initialized successfully');
            } catch (err) {
              console.error('[CastService] Error initializing Cast API:', err);
            }
          }
        })();
      ''';

      // Execute initialization code
      js.globalContext.callMethod('eval'.toJS, initCode.toJS);

      // Set up Flutter callback
      js.globalContext.setProperty(
          'flutterCastStateChanged'.toJS,
          ((js.JSBoolean isCasting) {
            _isCasting = isCasting.toDart;
            _castStateController
                .add(_isCasting ? CastState.connected : CastState.notConnected);
            debugPrint('Cast state changed: $_isCasting');
          }).toJS);
    } catch (e) {
      debugPrint('Error initializing Cast API: $e');
    }
  }

  /// Show the cast device selection dialog
  Future<void> showCastDialog() async {
    if (!kIsWeb || !_isInitialized) return;

    try {
      final code = '''
        (function() {
          if (window.chrome && window.chrome.cast && cast.framework) {
            const context = cast.framework.CastContext.getInstance();
            context.requestSession();
          }
        })();
      ''';
      js.globalContext.callMethod('eval'.toJS, code.toJS);
    } catch (e) {
      debugPrint('Error showing cast dialog: $e');
    }
  }

  /// Cast media to the connected device
  Future<void> castMedia({
    required String mediaUrl,
    required String title,
    String? description,
    String? imageUrl,
    String? contentType,
  }) async {
    if (!kIsWeb || !_isInitialized || !_isCasting) return;

    try {
      _currentMediaUrl = mediaUrl;
      _currentMediaTitle = title;

      final code = '''
        (function() {
          if (window.chrome && window.chrome.cast && cast.framework) {
            const context = cast.framework.CastContext.getInstance();
            const session = context.getCurrentSession();
            
            if (session) {
              const mediaInfo = new chrome.cast.media.MediaInfo(
                '${mediaUrl.replaceAll("'", "\\'")}',
                '${contentType ?? 'application/x-mpegURL'}'
              );
              
              const metadata = new chrome.cast.media.GenericMediaMetadata();
              metadata.title = '${title.replaceAll("'", "\\'")}';
              ${description != null ? "metadata.subtitle = '${description.replaceAll("'", "\\'")}';'" : ""}
              ${imageUrl != null ? "metadata.images = [new chrome.cast.Image('${imageUrl.replaceAll("'", "\\'")}')];" : ""}
              
              mediaInfo.metadata = metadata;
              
              const request = new chrome.cast.media.LoadRequest(mediaInfo);
              request.autoplay = true;
              
              session.loadMedia(request).then(
                function() {
                  console.log('Media loaded successfully');
                  window.flutterMediaLoaded && window.flutterMediaLoaded();
                },
                function(error) {
                  console.error('Error loading media:', error);
                  window.flutterMediaError && window.flutterMediaError(error.toString());
                }
              );
            }
          }
        })();
      ''';

      // Set up callbacks
      js.globalContext.setProperty(
          'flutterMediaLoaded'.toJS,
          (() {
            _mediaStateController.add(MediaState.playing);
            debugPrint('Media loaded on cast device');
          }).toJS);

      js.globalContext.setProperty(
          'flutterMediaError'.toJS,
          ((js.JSString error) {
            debugPrint('Cast media error: ${error.toDart}');
          }).toJS);

      js.globalContext.callMethod('eval'.toJS, code.toJS);
    } catch (e) {
      debugPrint('Error casting media: $e');
    }
  }

  /// Stop casting and disconnect from the cast device
  Future<void> stopCasting() async {
    if (!kIsWeb || !_isInitialized) return;

    try {
      final code = '''
        (function() {
          if (window.chrome && window.chrome.cast && cast.framework) {
            const context = cast.framework.CastContext.getInstance();
            const session = context.getCurrentSession();
            if (session) {
              session.endSession(true);
            }
          }
        })();
      ''';
      js.globalContext.callMethod('eval'.toJS, code.toJS);

      _isCasting = false;
      _currentMediaUrl = null;
      _currentMediaTitle = null;
      _castStateController.add(CastState.notConnected);
    } catch (e) {
      debugPrint('Error stopping cast: $e');
    }
  }

  /// Play/pause the currently casting media
  Future<void> togglePlayPause() async {
    if (!kIsWeb || !_isInitialized || !_isCasting) return;

    try {
      final code = '''
        (function() {
          if (window.chrome && window.chrome.cast && cast.framework) {
            const context = cast.framework.CastContext.getInstance();
            const session = context.getCurrentSession();
            if (session) {
              const media = session.getMediaSession();
              if (media) {
                const controller = new chrome.cast.media.RemotePlayerController(
                  new chrome.cast.media.RemotePlayer()
                );
                if (media.playerState === chrome.cast.media.PlayerState.PLAYING) {
                  controller.playOrPause();
                } else {
                  controller.playOrPause();
                }
              }
            }
          }
        })();
      ''';
      js.globalContext.callMethod('eval'.toJS, code.toJS);
    } catch (e) {
      debugPrint('Error toggling play/pause: $e');
    }
  }

  void dispose() {
    _castStateController.close();
    _mediaStateController.close();
  }
}

enum CastState {
  notConnected,
  connecting,
  connected,
}

enum MediaState {
  idle,
  loading,
  playing,
  paused,
  stopped,
}

void debugPrint(String message) {
  print('[CastService] $message');
}
