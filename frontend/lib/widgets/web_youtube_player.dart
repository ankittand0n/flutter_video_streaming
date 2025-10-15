import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

class WebYouTubePlayer extends StatefulWidget {
  final String youtubeUrl;
  final VoidCallback? onClose;

  const WebYouTubePlayer({
    super.key,
    required this.youtubeUrl,
    this.onClose,
  });

  @override
  State<WebYouTubePlayer> createState() => _WebYouTubePlayerState();
}

class _WebYouTubePlayerState extends State<WebYouTubePlayer> {
  late String viewId;
  String? embedUrl;

  @override
  void initState() {
    super.initState();
    viewId = 'youtube-player-${DateTime.now().millisecondsSinceEpoch}';
    embedUrl = _convertToEmbedUrl(widget.youtubeUrl);
    
    if (embedUrl != null) {
      // Register the view factory
      // ignore: undefined_prefixed_name
      ui_web.platformViewRegistry.registerViewFactory(viewId, (int viewId) {
        final iframeElement = html.IFrameElement()
          ..src = embedUrl!
          ..style.border = 'none'
          ..style.width = '100%'
          ..style.height = '100%'
          ..allow = 'accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture'
          ..allowFullscreen = true;
        
        return iframeElement;
      });
    }
  }

  String? _convertToEmbedUrl(String url) {
    // Extract video ID from various YouTube URL formats
    final patterns = [
      RegExp(r'youtube\.com/watch\?v=([^&]+)'),
      RegExp(r'youtu\.be/([^?]+)'),
      RegExp(r'youtube\.com/embed/([^?]+)'),
    ];

    for (var pattern in patterns) {
      final match = pattern.firstMatch(url);
      if (match != null && match.groupCount > 0) {
        final videoId = match.group(1);
        return 'https://www.youtube.com/embed/$videoId?autoplay=1&rel=0';
      }
    }
    
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (embedUrl == null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 64),
              const SizedBox(height: 16),
              const Text(
                'Invalid YouTube URL',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // YouTube player
          Center(
            child: HtmlElementView(viewType: viewId),
          ),
          
          // Close button
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
        ],
      ),
    );
  }
}
