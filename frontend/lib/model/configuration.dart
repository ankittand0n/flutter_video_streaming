class Configuration {
  final ImageConfiguration images;
  final List<String> changeKeys;

  Configuration.fromJson(Map<String, dynamic> json)
      : images = ImageConfiguration.fromJson(json['images'] ?? {}),
        changeKeys = json['change_keys'] != null
            ? List<String>.from(json['change_keys'])
            : [];
}

class ImageConfiguration {
  final String baseUrl;
  final String secureBaseUrl;
  final List<String> backdropSizes;
  final List<String> logoSizes;
  final List<String> posterSizes;
  final List<String> profileSizes;
  final List<String> stillSizes;

  ImageConfiguration.fromJson(Map<String, dynamic> json)
      : baseUrl = json['base_url'] ?? '',
        secureBaseUrl = json['secure_base_url'] ?? '',
        backdropSizes = json['backdrop_sizes'] != null
            ? List<String>.from(json['backdrop_sizes'])
            : [],
        logoSizes = json['logo_sizes'] != null
            ? List<String>.from(json['logo_sizes'])
            : [],
        posterSizes = json['poster_sizes'] != null
            ? List<String>.from(json['poster_sizes'])
            : [],
        profileSizes = json['profile_sizes'] != null
            ? List<String>.from(json['profile_sizes'])
            : [],
        stillSizes = json['still_sizes'] != null
            ? List<String>.from(json['still_sizes'])
            : [];
}
