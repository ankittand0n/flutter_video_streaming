import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:namkeen_tv/cubit/movie_details_tab_cubit.dart';
import 'package:namkeen_tv/widgets/episode_box.dart';
import 'package:namkeen_tv/widgets/netflix_dropdown.dart';
import 'package:namkeen_tv/widgets/poster_image.dart';
import 'package:namkeen_tv/widgets/inline_trailer_player.dart';
import 'package:namkeen_tv/widgets/media_kit_video_player.dart';
import 'package:namkeen_tv/services/cast_service.dart';
import 'package:namkeen_tv/services/auth_service.dart';
import 'package:namkeen_tv/services/api_service.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../bloc/netflix_bloc.dart';
import '../model/movie.dart';
import '../repository/repository.dart';
import '../utils/utils.dart';
import '../widgets/movie_box.dart';
import '../widgets/movie_trailer.dart';

class MovieDetailsScreen extends StatefulWidget {
  const MovieDetailsScreen({super.key, required this.movie});

  final Movie movie;

  @override
  State<MovieDetailsScreen> createState() => _MovieDetailsScreenState();
}

class _MovieDetailsScreenState extends State<MovieDetailsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController =
      TabController(length: widget.movie.type == 'tv' ? 3 : 2, vsync: this)
        ..addListener(() {
          context.read<MovieDetailsTabCubit>().setTab(_tabController.index);
        });

  bool _showTrailerPlayer = false;
  bool _isInWatchlist = false;
  double? _userRating;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.movie.type == 'tv') {
      context
          .read<TvShowSeasonSelectorBloc>()
          .add(SelectTvShowSeason(widget.movie.id, 1));
    }
    context.read<MovieDetailsTabCubit>().setTab(_tabController.index);
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final authService = AuthService();
    final token = await authService.getToken();
    if (token != null) {
      try {
        // Check if current movie is in watchlist
        final watchlistItems = await ApiService.getWatchlist(token);
        print('Watchlist items: $watchlistItems');
        print('Looking for movie ID: ${widget.movie.id}');

        // Try both contentId and contentid (lowercase) as the backend might use either
        final isInList = watchlistItems.any((item) {
          final itemId =
              (item['contentId'] ?? item['contentid'] ?? item['id']).toString();
          print('Comparing $itemId with ${widget.movie.id}');
          return itemId == widget.movie.id.toString();
        });

        print('Is in watchlist: $isInList');

        if (mounted) {
          setState(() {
            _isInWatchlist = isInList;
            _userRating = null; // TODO: Load actual user rating
          });
        }
      } catch (e) {
        print('Error loading user data: $e');
        if (mounted) {
          setState(() {
            _isInWatchlist = false;
            _userRating = null;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final configuration = context.watch<ConfigurationBloc>().state;

    if (widget.movie.details) {
      return _buildDetails(widget.movie, configuration);
    }
    return FutureBuilder(
        future: context
            .watch<TMDBRepository>()
            .getDetails(widget.movie.id, widget.movie.type),
        builder: (context, AsyncSnapshot<Movie> snapshoot) {
          if (snapshoot.hasError || !snapshoot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          return _buildDetails(snapshoot.data!, configuration);
        });
  }

  Widget _buildDetails(Movie movie, ConfigurationState configuration) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          leading: IconButton(
            icon: const Icon(LucideIcons.arrowLeft),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          actions: [
            if (kIsWeb)
              StreamBuilder<CastState>(
                stream: CastService.instance.castStateStream,
                initialData: CastState.notConnected,
                builder: (context, snapshot) {
                  final isCasting = snapshot.data == CastState.connected;
                  return IconButton(
                    icon: Icon(
                      LucideIcons.cast,
                      color: isCasting ? Colors.blue : null,
                    ),
                    onPressed: () async {
                      if (isCasting) {
                        // Show options: stop casting or cast media
                        _showCastOptions();
                      } else {
                        // Show cast device picker
                        await CastService.instance.showCastDialog();
                      }
                    },
                  );
                },
              ),
          ],
          pinned: true,
        ),
        SliverList(
            delegate: SliverChildListDelegate.fixed([
          // Poster image or inline trailer player
          _showTrailerPlayer &&
                  movie.trailerUrl != null &&
                  movie.trailerUrl!.isNotEmpty
              ? InlineTrailerPlayer(
                  trailerUrl: movie.trailerUrl!,
                  fullVideoUrl: movie.videoUrl,
                  title: movie.name,
                )
              : PosterImage(
                  movie: movie,
                  backdrop: true,
                  borderRadius: BorderRadius.zero,
                ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              movie.name,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold, fontSize: 32.0),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Text(
                  movie.year.isNotEmpty ? movie.year : 'N/A',
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(
                  width: 8.0,
                ),
                Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6.0, vertical: 2.0),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4.0),
                        color: Colors.grey.shade700),
                    child: const Text(
                      '16+',
                      style: TextStyle(letterSpacing: 1.0),
                    )),
                const SizedBox(
                  width: 8.0,
                ),
                Text(
                  movie.getRuntime(),
                  style: TextStyle(color: Colors.grey.shade400),
                ),
                const SizedBox(
                  width: 8.0,
                ),
                Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6.0, vertical: 2.0),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2.0),
                        color: Colors.grey.shade300),
                    child: const Text(
                      'HD',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 12.0,
                          fontWeight: FontWeight.w400),
                    ))
              ],
            ),
          ),
          // Button Row 1: Play Trailer and Play Movie
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                // Play Trailer Button
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16.0),
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      disabledBackgroundColor: Colors.grey.shade800,
                      disabledForegroundColor: Colors.grey.shade600,
                    ),
                    onPressed: (movie.trailerUrl != null &&
                            movie.trailerUrl!.isNotEmpty)
                        ? () {
                            setState(() {
                              _showTrailerPlayer = !_showTrailerPlayer;
                            });
                            // Scroll to top to see the trailer
                            if (_showTrailerPlayer) {
                              Scrollable.ensureVisible(
                                context,
                                duration: const Duration(milliseconds: 300),
                                alignment: 0.0,
                              );
                            }
                          }
                        : null,
                    icon: Icon(_showTrailerPlayer
                        ? Icons.stop
                        : Icons.play_circle_outline),
                    label: Text(
                        _showTrailerPlayer ? 'Stop Trailer' : 'Play Trailer'),
                  ),
                ),
                const SizedBox(width: 12),
                // Play Movie Button
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16.0),
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey.shade800,
                      disabledForegroundColor: Colors.grey.shade600,
                    ),
                    onPressed: (movie.videoUrl != null &&
                            movie.videoUrl!.isNotEmpty)
                        ? () {
                            Navigator.of(context, rootNavigator: true).push(
                              PageRouteBuilder(
                                opaque: true,
                                pageBuilder:
                                    (context, animation, secondaryAnimation) =>
                                        MediaKitVideoPlayer(
                                  videoUrl: movie.videoUrl!,
                                  trailerUrl: movie.trailerUrl,
                                  isTrailer: false,
                                  title: movie.name,
                                  videoId: movie.id.toString(),
                                  autoPlay: true,
                                  autoFullScreen: true,
                                  onVideoEnded: () =>
                                      Navigator.of(context, rootNavigator: true)
                                          .pop(),
                                ),
                                transitionDuration: Duration.zero,
                                reverseTransitionDuration: Duration.zero,
                              ),
                            );
                          }
                        : null,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Play Movie'),
                  ),
                ),
              ],
            ),
          ),
          // Button Row 2: Download
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(16.0),
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Download feature coming soon for "${movie.name}"'),
                      backgroundColor: Colors.blue,
                      action: SnackBarAction(
                        label: 'OK',
                        textColor: Colors.white,
                        onPressed: () {},
                      ),
                    ),
                  );
                },
                icon: const Icon(LucideIcons.download),
                label: const Text('Download'),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(movie.overview),
                const SizedBox(
                  height: 8.0,
                ),
                const Text(
                    'Starring: Bob Odenkirk, Jonathan Banks, Rhea Seehorn...'),
                const SizedBox(
                  height: 8.0,
                ),
                const Text('Creators: Vince Gilligan, Peter Gould'),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildActionButton(
                  icon: _isInWatchlist ? LucideIcons.check : LucideIcons.plus,
                  label: _isInWatchlist ? 'Remove' : 'My List',
                  onPressed: () => _toggleWatchlist(movie),
                ),
                _buildActionButton(
                  icon: _userRating != null
                      ? LucideIcons.thumbsUp
                      : LucideIcons.thumbsUp,
                  label: _userRating != null
                      ? 'Rated ${_userRating!.toStringAsFixed(1)}'
                      : 'Rate',
                  onPressed: () => _showRatingDialog(movie),
                ),
                _buildActionButton(
                  icon: LucideIcons.share2,
                  label: 'Share',
                  onPressed: () => _shareMovie(movie),
                ),
              ],
            ),
          ),
          const Text(
            'Fast Laughs',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
          ),
          SizedBox(
            height: 180.0,
            child: Builder(builder: (context) {
              final movies =
                  context.watch<TrendingTvShowListWeeklyBloc>().state;

              if (movies is TrendingTvShowLisWeekly) {
                return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: movies.list.length,
                    itemBuilder: (context, index) {
                      final movie = movies.list[index];
                      return MovieBox(
                        key: ValueKey(movie.id),
                        movie: movie,
                        laughs: 100,
                      );
                    });
              }
              return Container();
            }),
          ),
          const Divider(
            height: 1.0,
          ),
          TabBar(
              controller: _tabController,
              indicator: const BoxDecoration(
                border: Border(
                    top: BorderSide(
                  color: redColor,
                  width: 4.0,
                )),
              ),
              tabs: [
                if (movie.type == 'tv')
                  const Tab(
                    text: 'Episodes',
                  ),
                const Tab(
                  text: 'Trailers & More',
                ),
                const Tab(
                  text: 'More Like This',
                ),
              ]),
        ])),
        Builder(builder: (context) {
          final tabIndex = context.watch<MovieDetailsTabCubit>().state;
          if (tabIndex == 0 && movie.type == 'tv') {
            final state = context.watch<TvShowSeasonSelectorBloc>().state;
            if (state is SelectedTvShowSeason) {
              return SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  if (index == 0) {
                    return _seasonDropdown(movie, state.season.seasonNumber);
                  }

                  return EpisodeBox(
                      episode: state.season.episodes[index - 1],
                      fill: true,
                      padding: EdgeInsets.zero);
                }, childCount: state.season.episodes.length + 1),
              );
            }
          } else if (tabIndex == 1 && movie.type == 'tv' ||
              tabIndex == 0 && movie.type == 'movie') {
            final movies = context.watch<TrendingMovieListDailyBloc>().state;

            if (movies is TrendingMovieListDaily) {
              return SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final movie = movies.list[index];
                  return MovieTrailer(
                      key: ValueKey(movie.id),
                      movie: movie,
                      fill: true,
                      padding: EdgeInsets.zero);
                }, childCount: movies.list.length),
              );
            }
          } else {
            final movies = context.watch<TrendingTvShowListDailyBloc>().state;
            if (movies is TrendingTvShowListDaily) {
              return SliverGrid(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final movie = movies.list[index];
                  return MovieBox(
                      key: ValueKey(movie.id),
                      movie: movie,
                      fill: true,
                      padding: EdgeInsets.zero);
                }, childCount: min(12, movies.list.length)),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 2 / 3,
                    mainAxisSpacing: 8.0,
                    crossAxisSpacing: 8.0),
              );
            }
          }
          return const SliverToBoxAdapter();
        })
      ],
    );
  }

  void _openSeasonSelector(Movie movie) {
    OverlayEntry? overlay;
    overlay = OverlayEntry(
      builder: (context) {
        return NetflixDropDownScreen(
            movie: movie,
            selected: (context.read<TvShowSeasonSelectorBloc>().state
                    as SelectedTvShowSeason)
                .season
                .seasonNumber,
            onPop: () {
              overlay?.remove();
            });
      },
    );

    Overlay.of(context, rootOverlay: true).insert(overlay);
  }

  Widget _seasonDropdown(Movie movie, int seasonNumber) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ElevatedButton(
            style:
                ElevatedButton.styleFrom(backgroundColor: Colors.grey.shade900),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Season $seasonNumber',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  width: 8.0,
                ),
                const Icon(
                  LucideIcons.chevronDown,
                  size: 14.0,
                )
              ],
            ),
            onPressed: () {
              _openSeasonSelector(movie);
            }),
        const SizedBox(
          height: 8.0,
        )
      ],
    );
  }

  void _showCastOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black87,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(LucideIcons.cast, color: Colors.white),
                title: const Text('Cast Movie',
                    style: TextStyle(color: Colors.white)),
                onTap: () async {
                  Navigator.pop(context);
                  final movie = widget.movie;
                  if (movie.videoUrl != null && movie.videoUrl!.isNotEmpty) {
                    await CastService.instance.castMedia(
                      mediaUrl: movie.videoUrl!,
                      title: movie.name,
                      description: movie.overview,
                      imageUrl: movie.backdropPath.isNotEmpty
                          ? 'https://image.tmdb.org/t/p/w500${movie.backdropPath}'
                          : null,
                    );
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Casting to device...')),
                      );
                    }
                  }
                },
              ),
              ListTile(
                leading: const Icon(LucideIcons.x, color: Colors.white),
                title: const Text('Stop Casting',
                    style: TextStyle(color: Colors.white)),
                onTap: () async {
                  Navigator.pop(context);
                  await CastService.instance.stopCasting();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Disconnected from cast device')),
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: _isLoading ? null : onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleWatchlist(Movie movie) async {
    setState(() => _isLoading = true);

    final authService = AuthService();
    final token = await authService.getToken();

    if (token == null) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please login to use watchlist')),
        );
      }
      return;
    }

    final result = _isInWatchlist
        ? await ApiService.removeFromWatchlist(token, movie.id.toString())
        : await ApiService.addToWatchlist(
            token,
            movie.id.toString(),
            movie.type,
            movie.name,
            overview: movie.overview,
            posterPath: movie.posterPath,
            backdropPath: movie.backdropPath,
          );

    setState(() {
      _isLoading = false;
      if (result['success']) {
        _isInWatchlist = !_isInWatchlist;
      }
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: result['success'] ? Colors.green : Colors.red,
        ),
      );
    }
  }

  Future<void> _showRatingDialog(Movie movie) async {
    double rating = _userRating ?? 5.0;

    final result = await showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Rate this content',
            style: TextStyle(color: Colors.white)),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${rating.toStringAsFixed(1)} / 10',
                style: const TextStyle(color: Colors.white, fontSize: 24),
              ),
              Slider(
                value: rating,
                min: 1,
                max: 10,
                divisions: 18,
                activeColor: Colors.red,
                label: rating.toStringAsFixed(1),
                onChanged: (value) => setState(() => rating = value),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
                const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, rating),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Submit'),
          ),
        ],
      ),
    );

    if (result != null) {
      await _submitRating(movie, result);
    }
  }

  Future<void> _submitRating(Movie movie, double rating) async {
    setState(() => _isLoading = true);

    final authService = AuthService();
    final token = await authService.getToken();

    if (token == null) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please login to rate content')),
        );
      }
      return;
    }

    final result = await ApiService.rateContent(
      token,
      movie.id.toString(),
      movie.type,
      rating,
      title: movie.name,
    );

    setState(() {
      _isLoading = false;
      if (result['success']) {
        _userRating = rating;
      }
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: result['success'] ? Colors.green : Colors.red,
        ),
      );
    }
  }

  Future<void> _shareMovie(Movie movie) async {
    final shareUrl = 'https://namkeen-tv.app/movie/${movie.id}';
    final shareText = 'Check out ${movie.name} on Namkeen TV!\n$shareUrl';

    try {
      final uri = Uri.parse(
          'https://api.whatsapp.com/send?text=${Uri.encodeComponent(shareText)}');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        // Fallback: just show the share text
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: Colors.grey[900],
              title: const Text('Share', style: TextStyle(color: Colors.white)),
              content: SelectableText(
                shareText,
                style: const TextStyle(color: Colors.white),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close',
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sharing: $e')),
        );
      }
    }
  }
}
