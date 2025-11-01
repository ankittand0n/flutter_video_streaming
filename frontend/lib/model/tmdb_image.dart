class TMDBImage {
  final int width;
  final int height;
  final String filePath;
  final double aspectRatio;
  final String? iso;

  TMDBImage.fromJson(Map<String, dynamic> json)
      : width = json['width'] ?? 0,
        height = json['height'] ?? 0,
        filePath = (json['file_path'] ?? '').toString(),
        aspectRatio = (() {
          final val = json['aspect_ratio'];
          if (val == null) return 1.0;
          if (val is double) return val;
          if (val is int) return val.toDouble();
          return double.tryParse(val.toString()) ?? 1.0;
        })(),
        iso = json['iso_639_1'];
}

class TMDBImages {
  final int id;
  final List<TMDBImage> posters;
  final List<TMDBImage> backdrops;
  final List<TMDBImage> logos;

  TMDBImages.fromJson(Map<String, dynamic> json)
      : id = json['id'] ?? 0,
        posters = (() {
          try {
            final postersJson = json['posters'];
            if (postersJson == null) return <TMDBImage>[];
            if (postersJson is! List) return <TMDBImage>[];
            return postersJson
                .whereType<Map<String, dynamic>>()
                .map((e) => TMDBImage.fromJson(e as Map<String, dynamic>))
                .toList();
          } catch (e) {
            return <TMDBImage>[];
          }
        })(),
        backdrops = (() {
          try {
            final backdropsJson = json['backdrops'];
            if (backdropsJson == null) return <TMDBImage>[];
            if (backdropsJson is! List) return <TMDBImage>[];
            return backdropsJson
                .whereType<Map<String, dynamic>>()
                .map((e) => TMDBImage.fromJson(e as Map<String, dynamic>))
                .toList();
          } catch (e) {
            return <TMDBImage>[];
          }
        })(),
        logos = (() {
          try {
            final logosJson = json['logos'];
            if (logosJson == null) return <TMDBImage>[];
            if (logosJson is! List) return <TMDBImage>[];
            return logosJson
                .whereType<Map<String, dynamic>>()
                .map((e) => TMDBImage.fromJson(e as Map<String, dynamic>))
                .where((image) =>
                    image.iso == 'en' && !image.filePath.endsWith('.svg'))
                .toList();
          } catch (e) {
            return <TMDBImage>[];
          }
        })();
}
