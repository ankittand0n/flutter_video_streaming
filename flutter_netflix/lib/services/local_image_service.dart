class LocalImageService {
  static const List<String> movieImages = [
    'assets/images/movies/1.jpeg',
    'assets/images/movies/2.jpeg',
    'assets/images/movies/3.jpeg',
    'assets/images/movies/4.jpeg',
    'assets/images/movies/5.jpeg',
    'assets/images/movies/6.jpeg',
    'assets/images/movies/7.jpeg',
    'assets/images/movies/8.jpeg',
    'assets/images/movies/9.jpeg',
    'assets/images/movies/10.jpeg',
    'assets/images/movies/11.jpeg',
  ];

  static const List<String> tvSeriesImages = [
    'assets/images/tv_series/1.jpeg',
    'assets/images/tv_series/2.jpeg',
    'assets/images/tv_series/3.jpeg',
    'assets/images/tv_series/4.jpeg',
    'assets/images/tv_series/5.jpeg',
    'assets/images/tv_series/6.jpeg',
    'assets/images/tv_series/7.jpeg',
    'assets/images/tv_series/8.jpeg',
    'assets/images/tv_series/9.jpeg',
    'assets/images/tv_series/10.jpeg',
    'assets/images/tv_series/11.jpeg',
  ];

  // Get a movie image by index (with repetition)
  static String getMovieImage(int index) {
    return movieImages[index % movieImages.length];
  }

  // Get a TV series image by index (with repetition)
  static String getTvSeriesImage(int index) {
    return tvSeriesImages[index % tvSeriesImages.length];
  }

  // Get a random image from movies
  static String getRandomMovieImage() {
    final random = DateTime.now().millisecondsSinceEpoch;
    return movieImages[random % movieImages.length];
  }

  // Get a random image from TV series
  static String getRandomTvSeriesImage() {
    final random = DateTime.now().millisecondsSinceEpoch;
    return tvSeriesImages[random % tvSeriesImages.length];
  }

  // Get all movie images
  static List<String> getAllMovieImages() {
    return List.from(movieImages);
  }

  // Get all TV series images
  static List<String> getAllTvSeriesImages() {
    return List.from(tvSeriesImages);
  }
}
