class Episode {
  final int id;
  final String name;
  final String? overview;
  final int episodeNumber;
  final String? stillPath;
  final DateTime? airDate;

  Episode.fromJson(Map<String, dynamic> json)
      : id = json['id'] ?? 0,
        name = (json['name'] ?? '').toString(),
        overview = json['overview']?.toString(),
        episodeNumber = json['episode_number'] ?? 0,
        stillPath = json['still_path']?.toString(),
        airDate = (() {
          final dateStr = json['air_date'];
          if (dateStr == null) return null;
          return DateTime.tryParse(dateStr.toString());
        })();
}
