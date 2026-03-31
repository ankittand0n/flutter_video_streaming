import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:namkeen_tv/config/app_config.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  List<_PolicySection> _sections = [];

  @override
  void initState() {
    super.initState();
    _loadPrivacyPolicy();
  }

  Future<void> _loadPrivacyPolicy() async {
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.imageBaseUrl}/privacy-policy'),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final sections = _parseHtmlToSections(response.body);
        if (mounted) {
          setState(() {
            _sections = sections;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _errorMessage = 'Failed to load privacy policy (${response.statusCode})';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Could not load privacy policy. Please check your connection.';
          _isLoading = false;
        });
      }
    }
  }

  /// Simple HTML parser that extracts headings, paragraphs, and list items
  List<_PolicySection> _parseHtmlToSections(String html) {
    final sections = <_PolicySection>[];
    // Extract content inside <main>...</main>
    final mainMatch = RegExp(r'<main[^>]*>([\s\S]*?)</main>').firstMatch(html);
    final content = mainMatch?.group(1) ?? html;

    // Match h2, p, ul blocks in order
    final blockPattern = RegExp(
      r'<h2[^>]*>([\s\S]*?)</h2>|<p>([\s\S]*?)</p>|<ul>([\s\S]*?)</ul>',
      caseSensitive: false,
    );

    for (final match in blockPattern.allMatches(content)) {
      if (match.group(1) != null) {
        sections.add(_PolicySection(type: _SectionType.heading, text: _stripTags(match.group(1)!)));
      } else if (match.group(2) != null) {
        sections.add(_PolicySection(type: _SectionType.paragraph, text: _stripTags(match.group(2)!)));
      } else if (match.group(3) != null) {
        final items = RegExp(r'<li>([\s\S]*?)</li>', caseSensitive: false)
            .allMatches(match.group(3)!)
            .map((m) => _stripTags(m.group(1)!).trim())
            .toList();
        sections.add(_PolicySection(type: _SectionType.list, items: items));
      }
    }
    return sections;
  }

  String _stripTags(String html) {
    return html
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .trim();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF141414),
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          'Privacy Policy',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.red))
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 48),
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.white70, fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                          onPressed: () {
                            setState(() {
                              _isLoading = true;
                              _errorMessage = null;
                            });
                            _loadPrivacyPolicy();
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _sections.map((section) {
                          switch (section.type) {
                            case _SectionType.heading:
                              return Padding(
                                padding: const EdgeInsets.only(top: 28.0, bottom: 8.0),
                                child: Text(
                                  section.text ?? '',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            case _SectionType.paragraph:
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: Text(
                                  section.text ?? '',
                                  style: const TextStyle(color: Color(0xFFB3B3B3), fontSize: 15, height: 1.7),
                                ),
                              );
                            case _SectionType.list:
                              return Padding(
                                padding: const EdgeInsets.only(left: 16.0, bottom: 12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: (section.items ?? []).map((item) {
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 6.0),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text('• ', style: TextStyle(color: Color(0xFFB3B3B3), fontSize: 15)),
                                          Expanded(
                                            child: Text(
                                              item,
                                              style: const TextStyle(color: Color(0xFFB3B3B3), fontSize: 15, height: 1.7),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                              );
                          }
                        }).toList(),
                      ),
                    ),
                  ),
                ),
    );
  }
}

enum _SectionType { heading, paragraph, list }

class _PolicySection {
  final _SectionType type;
  final String? text;
  final List<String>? items;

  _PolicySection({required this.type, this.text, this.items});
}
