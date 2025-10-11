import 'package:flutter/material.dart';
import 'package:namkeen_tv/models/movie.dart';
import 'package:namkeen_tv/services/api_service.dart';
import 'package:namkeen_tv/widgets/poster_image.dart';
import 'package:namkeen_tv/screens/movie_details_screen.dart';
import 'package:shimmer/shimmer.dart';

class HomeApiScreen extends StatefulWidget {
  const HomeApiScreen({Key? key}) : super(key: key);

  @override
  State<HomeApiScreen> createState() => _HomeApiScreenState();
}

class _HomeApiScreenState extends State<HomeApiScreen> {
  List<Movie> _movies = [];
  List<Movie> _popularMovies = [];
  List<Movie> _topRatedMovies = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final results = await Future.wait([
        ApiService.getMovies(),
        ApiService.getPopularMovies(),
        ApiService.getTopRatedMovies(),
      ]);

      setState(() {
        _movies = results[0].map((json) => Movie.fromJson(json)).toList();
        _popularMovies = results[1].map((json) => Movie.fromJson(json)).toList();
        _topRatedMovies = results[2].map((json) => Movie.fromJson(json)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Namkeen TV',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_error != null) {
      return _buildErrorState();
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      color: Colors.red,
      child: CustomScrollView(
        slivers: [
          // Featured movie
          if (_movies.isNotEmpty) _buildFeaturedMovie(_movies.first),
          
          // Movies section
          _buildSection('Movies', _movies),
          
          // Popular movies section
          if (_popularMovies.isNotEmpty)
            _buildSection('Popular Movies', _popularMovies),
          
          // Top rated movies section
          if (_topRatedMovies.isNotEmpty)
            _buildSection('Top Rated Movies', _topRatedMovies),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.red),
          SizedBox(height: 16),
          Text(
            'Loading movies...',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 64,
          ),
          const SizedBox(height: 16),
          const Text(
            'Failed to load movies',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            _error ?? 'Unknown error',
            style: const TextStyle(color: Colors.white70, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadData,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedMovie(Movie movie) {
    return SliverToBoxAdapter(
      child: Container(
        height: 400,
        child: Stack(
          fit: StackFit.expand,
          children: [
            PosterImage(
              movie: movie,
              backdrop: true,
              width: double.infinity,
              height: 400,
            ),
            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
            // Movie info
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    movie.overview,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      if (movie.hasVideo)
                        ElevatedButton.icon(
                          onPressed: () => _navigateToMovieDetails(movie),
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('Play'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      const SizedBox(width: 12),
                      OutlinedButton.icon(
                        onPressed: () => _navigateToMovieDetails(movie),
                        icon: const Icon(Icons.info_outline),
                        label: const Text('More Info'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Movie> movies) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: movies.length,
              itemBuilder: (context, index) {
                final movie = movies[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: GestureDetector(
                    onTap: () => _navigateToMovieDetails(movie),
                    child: PosterImage(
                      movie: movie,
                      width: 120,
                      height: 180,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _navigateToMovieDetails(Movie movie) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MovieDetailsScreen(movie: movie),
        fullscreenDialog: true,
      ),
    );
  }
}
