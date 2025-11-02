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
      try {
        // Check if chrome.cast API is available
        final chrome = js.globalContext.getProperty('chrome'.toJS);
        if (chrome != null) {
          final castObj = (chrome as js.JSObject).getProperty('cast'.toJS);
          if (castObj != null) {
            debugPrint('Cast API found');
            return;
          }
        }
        // Fallback: check for cast global
        final castGlobal = js.globalContext.getProperty('cast'.toJS);
        if (castGlobal != null) {
          final framework =
              (castGlobal as js.JSObject).getProperty('framework'.toJS);
          if (framework != null) {
            debugPrint('Cast framework found');
            return;
          }
        }
      } catch (e) {
        debugPrint('Error checking Cast API: $e');
      }

      await Future.delayed(const Duration(milliseconds: 100));
    }

    throw Exception('Cast API not available');
  }

  void _initializeCastApi() {
    // Create initialization code for Cast
    const initCode = '''
      (function() {
        if (typeof cast === 'undefined' || !cast.framework) {
          console.error('Cast framework not loaded');
          return;
        }

        try {
          const context = cast.framework.CastContext.getInstance();
          
          // Set up receiver application ID (default media receiver)
          context.setOptions({
            receiverApplicationId: chrome.cast.media.DEFAULT_MEDIA_RECEIVER_APP_ID,
            autoJoinPolicy: chrome.cast.AutoJoinPolicy.ORIGIN_SCOPED
          });

          // Listen for cast state changes
          context.addEventListener(
            cast.framework.CastContextEventType.CAST_STATE_CHANGED,
            function(event) {
              console.log('Cast state changed:', event.castState);
              if (typeof flutterCastStateChanged !== 'undefined') {
                flutterCastStateChanged(event.castState === 'CONNECTED');
              }
            }
          );

          console.log('Cast framework initialized');
        } catch (e) {
          console.error('Error initializing Cast:', e);
        }
      })();
    ''';

    try {
      js.globalContext.callMethod('eval'.toJS, initCode.toJS);

      // Set up Flutter callback for cast state changes
      js.globalContext.setProperty(
          'flutterCastStateChanged'.toJS,
          ((js.JSBoolean isCasting) {
            final casting = isCasting.toDart;
            _isCasting = casting;
            _castStateController
                .add(casting ? CastState.connected : CastState.notConnected);
            debugPrint('Cast state changed from JS: $casting');
          }).toJS);

      debugPrint('Cast callbacks set up');
    } catch (e) {
      debugPrint('Error setting up Cast callbacks: $e');
    }
  }

  /// Start casting a media URL
  Future<void> loadMedia(String mediaUrl, String title,
      {String? imageUrl}) async {
    if (!kIsWeb || !_isInitialized) return;

    _currentMediaUrl = mediaUrl;
    _currentMediaTitle = title;

    const code = '''
      (function() {
        try {
          const context = cast.framework.CastContext.getInstance();
          const session = context.getCurrentSession();
          
          if (!session) {
            console.error('No cast session available');
            return;
          }

          const mediaInfo = new chrome.cast.media.MediaInfo(arguments[0], 'video/mp4');
          mediaInfo.metadata = new chrome.cast.media.GenericMediaMetadata();
          mediaInfo.metadata.title = arguments[1];
          
          if (arguments[2]) {
            mediaInfo.metadata.images = [new chrome.cast.Image(arguments[2])];
          }

          const request = new chrome.cast.media.LoadRequest(mediaInfo);
          
          session.loadMedia(request).then(
            function() {
              console.log('Media loaded successfully');
            },
            function(error) {
              console.error('Error loading media:', error);
            }
          );
        } catch (e) {
          console.error('Error in loadMedia:', e);
        }
      })();
    ''';

    try {
      js.globalContext.callMethod('eval'.toJS, code.toJS);
      _mediaStateController.add(MediaState.loading);

      // Set up callbacks for media events
      js.globalContext.setProperty(
          'flutterMediaLoaded'.toJS,
          (() {
            _mediaStateController.add(MediaState.loaded);
            debugPrint('Media loaded on Cast device');
          }).toJS);

      js.globalContext.setProperty(
          'flutterMediaError'.toJS,
          ((js.JSString error) {
            _mediaStateController.add(MediaState.error);
            debugPrint('Media error on Cast device: ${error.toDart}');
          }).toJS);

      js.globalContext.callMethod('eval'.toJS, code.toJS);
    } catch (e) {
      debugPrint('Error loading media: $e');
      _mediaStateController.add(MediaState.error);
    }
  }

  /// Play the current media
  Future<void> play() async {
    if (!kIsWeb || !_isInitialized || !_isCasting) return;

    const code = '''
      (function() {
        try {
          const context = cast.framework.CastContext.getInstance();
          const session = context.getCurrentSession();
          const media = session ? session.getMediaSession() : null;
          
          if (media) {
            media.play(new chrome.cast.media.PlayRequest());
          }
        } catch (e) {
          console.error('Error playing media:', e);
        }
      })();
    ''';

    try {
      js.globalContext.callMethod('eval'.toJS, code.toJS);
    } catch (e) {
      debugPrint('Error playing media: $e');
    }
  }

  /// Pause the current media
  Future<void> pause() async {
    if (!kIsWeb || !_isInitialized || !_isCasting) return;

    const code = '''
      (function() {
        try {
          const context = cast.framework.CastContext.getInstance();
          const session = context.getCurrentSession();
          const media = session ? session.getMediaSession() : null;
          
          if (media) {
            media.pause(new chrome.cast.media.PauseRequest());
          }
        } catch (e) {
          console.error('Error pausing media:', e);
        }
      })();
    ''';

    try {
      js.globalContext.callMethod('eval'.toJS, code.toJS);
    } catch (e) {
      debugPrint('Error pausing media: $e');
    }
  }

  /// Stop casting
  Future<void> stopCasting() async {
    if (!kIsWeb || !_isInitialized || !_isCasting) return;

    const code = '''
      (function() {
        try {
          const context = cast.framework.CastContext.getInstance();
          const session = context.getCurrentSession();
          
          if (session) {
            session.endSession(true);
          }
        } catch (e) {
          console.error('Error stopping cast:', e);
        }
      })();
    ''';

    try {
      js.globalContext.callMethod('eval'.toJS, code.toJS);
      _isCasting = false;
      _currentMediaUrl = null;
      _currentMediaTitle = null;
      _castStateController.add(CastState.notConnected);
    } catch (e) {
      debugPrint('Error stopping cast: $e');
    }
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

void debugPrint(String message) {
  print('[CastService] $message');
}
