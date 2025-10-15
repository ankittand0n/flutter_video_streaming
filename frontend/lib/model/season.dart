import 'package:namkeen_tv/model/episode.dart';

class Season {
  final int id;
  final String name;
  final int seasonNumber;
  final String? overview;
  final String? posterPath;
  final DateTime? airDate;
  final List<Episode> episodes;
  final List<String> starring;
  final List<String> creators;

  factory Season.fromJson(Map<String, dynamic> json) {
    final List<String> starring = [];
    final List<String> creators = [];
    final List<Episode> episodes = [];

    final rawEpisodes = json['episodes'];
    if (rawEpisodes is Iterable) {
      for (final episode in rawEpisodes) {
        if (episode is Map<String, dynamic>) {
          // collect crew writers
          final crewList = episode['crew'];
          if (crewList is Iterable) {
            for (final crew in crewList) {
              try {
                final job = crew['job']?.toString() ?? '';
                final name = crew['name']?.toString() ?? '';
                if (job.toLowerCase().contains('writer') && name.isNotEmpty && !creators.contains(name)) {
                  creators.add(name);
                }
              } catch (_) {}
            }
          }

          // collect guest stars
          final guestStars = episode['guest_stars'];
          if (guestStars is Iterable) {
            for (final actor in guestStars) {
              try {
                final actorName = actor['name']?.toString() ?? '';
                if (actorName.isNotEmpty && !starring.contains(actorName)) {
                  starring.add(actorName);
                }
              } catch (_) {}
            }
          }

          try {
            episodes.add(Episode.fromJson(Map<String, dynamic>.from(episode)));
          } catch (_) {}
        }
      }
    }

    return Season(
        json['id'] ?? 0,
        json['name'] ?? '',
        json['season_number'] ?? 0,
        json['overview'],
        json['poster_path'],
        DateTime.tryParse(json['air_date']?.toString() ?? ''),
        episodes,
        starring,
        creators);
  }

  Season(this.id, this.name, this.seasonNumber, this.overview, this.posterPath,
      this.airDate, this.episodes, this.starring, this.creators);
}
