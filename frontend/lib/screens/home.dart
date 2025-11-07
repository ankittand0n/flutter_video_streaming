import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:namkeen_tv/bloc/netflix_bloc.dart';
import 'package:namkeen_tv/widgets/highlight_movie.dart';
import 'package:namkeen_tv/widgets/movie_box.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:namkeen_tv/services/api_service.dart';
import 'package:namkeen_tv/services/auth_service.dart';
import 'package:namkeen_tv/model/movie.dart';

import '../widgets/netflix_app_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.name});

  final String? name;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double _scrollOffset = 0.0;
  // Key used to scroll to the Movies section
  final GlobalKey _moviesSectionKey = GlobalKey();
  late final ScrollController _scrollController = ScrollController()
    ..addListener(() {
      setState(() {
        _scrollOffset = _scrollController.offset;
      });
    });

  List<dynamic> _myList = [];

  @override
  void initState() {
    context
        .read<TrendingTvShowListWeeklyBloc>()
        .add(FetchTrendingTvShowListWeekly());

    context
        .read<TrendingTvShowListDailyBloc>()
        .add(FetchTrendingTvShowListDaily());

    context
        .read<TrendingMovieListWeeklyBloc>()
        .add(FetchTrendingMovieListWeekly());

    context
        .read<TrendingMovieListDailyBloc>()
        .add(FetchTrendingMovieListDaily());

    context.read<DiscoverMoviesBloc>().add(DiscoverMoviesEvent());
    _loadMyList();
    super.initState();
  }

  Future<void> _loadMyList() async {
    try {
      final authService = AuthService();
      final token = await authService.getToken();

      if (token != null) {
        final watchlist = await ApiService.getWatchlist(token);
        if (mounted) {
          setState(() {
            _myList = watchlist;
          });
        }
      }
    } catch (e) {
      print('Error loading my list: $e');
    }
  }

  @override
  void didChangeDependencies() {
    // Removed animation status management as we're using simpler navigation
    super.didChangeDependencies();
  }

  final _shimmer = Shimmer(
    gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[
          Colors.grey[900]!,
          Colors.grey[900]!,
          Colors.grey[800]!,
          Colors.grey[900]!,
          Colors.grey[900]!
        ],
        stops: const <double>[
          0.0,
          0.35,
          0.5,
          0.65,
          1.0
        ]),
    child: ListView(
      scrollDirection: Axis.horizontal,
      children: List.generate(
          6,
          (index) => Container(
                width: 110,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  color: Colors.red,
                ),
                margin:
                    const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
              )),
    ),
  );

  @override
  Widget build(BuildContext context) {
    // Keys for sections
    // padding is defined below and used for section spacing
    final state = GoRouterState.of(context);
    final isTvPage = state.location.contains('tvshows');
    final isMoviePage = state.location.contains('movies');
    const padding =
        EdgeInsets.only(top: 16.0, bottom: 4.0, left: 8.0, right: 8.0);

    // Make row height and text size responsive
    final screenWidth = MediaQuery.of(context).size.width;
    final rowHeight =
        screenWidth > 1200 ? 420.0 : (screenWidth > 800 ? 320.0 : 200.0);
    final titleFontSize =
        screenWidth > 1200 ? 28.0 : (screenWidth > 800 ? 22.0 : 18.0);

    return NestedScrollView(
      physics: const ClampingScrollPhysics(),
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          SliverOverlapAbsorber(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
              sliver: MultiSliver(children: [
                SliverPersistentHeader(
                  delegate: NetflixHeader(
                      scrollOffset: _scrollOffset, name: widget.name),
                  pinned: true,
                ),
              ])),
        ];
      },
      body: CustomScrollView(
        physics: const ClampingScrollPhysics(),
        controller: _scrollController,
        slivers: [
          // Build a simple children list to avoid complex inline collection-if parsing issues
          SliverList(
            delegate: SliverChildListDelegate.fixed(
              (() {
                final List<Widget> children = [];
                children.add(const HighlightMovie());

                // Add "My List" section if user has items
                if (_myList.isNotEmpty) {
                  children.add(Padding(
                    padding: padding,
                    child: Text(
                      'My List',
                      style: TextStyle(
                          fontSize: titleFontSize, fontWeight: FontWeight.bold),
                    ),
                  ));

                  children.add(SizedBox(
                    height: rowHeight,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      itemCount: _myList.length,
                      itemBuilder: (context, index) {
                        final item = _myList[index];
                        // Convert watchlist item to Movie object with minimal required fields
                        // Backend returns media_id and poster_path fields
                        final movie = Movie(
                          id: int.tryParse(item['media_id'] ?? '0') ?? 0,
                          title: item['title'] ?? '',
                          overview: '',
                          releaseDate: '',
                          voteAverage: 0.0,
                          posterPath: item['poster_path'] ?? '',
                          backdropPath: '',
                          genreIds: [],
                          originalLanguage: '',
                          createdAt: DateTime.now(),
                          updatedAt: DateTime.now(),
                          video: false,
                        );
                        return MovieBox(key: ValueKey(movie.id), movie: movie);
                      },
                    ),
                  ));
                }

                if (isTvPage) {
                  children.add(Padding(
                    padding: padding,
                    child: Text(
                      'Trending TV Shows This Week',
                      style: TextStyle(
                          fontSize: titleFontSize, fontWeight: FontWeight.bold),
                    ),
                  ));

                  children.add(SizedBox(
                    height: rowHeight,
                    child: Builder(builder: (context) {
                      final movies =
                          context.watch<TrendingTvShowListWeeklyBloc>().state;
                      if (movies is TrendingTvShowLisWeekly) {
                        return ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          itemCount: movies.list.length,
                          itemBuilder: (context, index) {
                            final movie = movies.list[index];
                            return MovieBox(
                                key: ValueKey(movie.id), movie: movie);
                          },
                        );
                      }
                      return _shimmer;
                    }),
                  ));

                  children.add(Padding(
                    padding: padding,
                    child: Text(
                      'Trending TV Shows Today',
                      style: TextStyle(
                          fontSize: titleFontSize, fontWeight: FontWeight.bold),
                    ),
                  ));

                  children.add(SizedBox(
                    height: rowHeight,
                    child: Builder(builder: (context) {
                      final movies =
                          context.watch<TrendingTvShowListDailyBloc>().state;
                      if (movies is TrendingTvShowListDaily) {
                        return ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          itemCount: movies.list.length,
                          itemBuilder: (context, index) {
                            final movie = movies.list[index];
                            return MovieBox(
                                key: ValueKey(movie.id), movie: movie);
                          },
                        );
                      }
                      return _shimmer;
                    }),
                  ));
                } else if (isMoviePage) {
                  children.add(Container(
                    key: _moviesSectionKey,
                    child: Padding(
                      padding: padding,
                      child: Text(
                        'Trending Movies This Week',
                        style: TextStyle(
                            fontSize: titleFontSize,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ));

                  children.add(SizedBox(
                    height: rowHeight,
                    child: Builder(builder: (context) {
                      final movies =
                          context.watch<TrendingMovieListWeeklyBloc>().state;
                      if (movies is TrendingMovieListWeekly) {
                        return ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          itemCount: movies.list.length,
                          itemBuilder: (context, index) {
                            final movie = movies.list[index];
                            return MovieBox(
                                key: ValueKey(movie.id), movie: movie);
                          },
                        );
                      }
                      return _shimmer;
                    }),
                  ));

                  children.add(Padding(
                    padding: padding,
                    child: Text(
                      'Trending Movies Today',
                      style: TextStyle(
                          fontSize: titleFontSize, fontWeight: FontWeight.bold),
                    ),
                  ));

                  children.add(SizedBox(
                    height: rowHeight,
                    child: Builder(builder: (context) {
                      final movies =
                          context.watch<TrendingMovieListDailyBloc>().state;
                      if (movies is TrendingMovieListDaily) {
                        return ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: movies.list.length,
                          itemBuilder: (context, index) {
                            final movie = movies.list[index];
                            return MovieBox(
                                key: ValueKey(movie.id), movie: movie);
                          },
                        );
                      }
                      return _shimmer;
                    }),
                  ));
                } else {
                  // Show both sections on the main home page
                  children.add(Padding(
                    padding: padding,
                    child: Text(
                      'Trending Movies This Week',
                      style: TextStyle(
                          fontSize: titleFontSize, fontWeight: FontWeight.bold),
                    ),
                  ));

                  children.add(SizedBox(
                    height: rowHeight,
                    child: Builder(builder: (context) {
                      final movies =
                          context.watch<TrendingMovieListWeeklyBloc>().state;
                      if (movies is TrendingMovieListWeekly) {
                        return ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: movies.list.length,
                          itemBuilder: (context, index) {
                            final movie = movies.list[index];
                            return MovieBox(
                                key: ValueKey(movie.id), movie: movie);
                          },
                        );
                      }
                      return _shimmer;
                    }),
                  ));

                  children.add(Padding(
                    padding: padding,
                    child: Text(
                      'Trending Movies Today',
                      style: TextStyle(
                          fontSize: titleFontSize, fontWeight: FontWeight.bold),
                    ),
                  ));

                  children.add(SizedBox(
                    height: rowHeight,
                    child: Builder(builder: (context) {
                      final movies =
                          context.watch<TrendingMovieListDailyBloc>().state;
                      if (movies is TrendingMovieListDaily) {
                        return ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: movies.list.length,
                          itemBuilder: (context, index) {
                            final movie = movies.list[index];
                            return MovieBox(
                                key: ValueKey(movie.id), movie: movie);
                          },
                        );
                      }
                      return _shimmer;
                    }),
                  ));

                  children.add(Padding(
                    padding: padding,
                    child: Text(
                      'Trending TV Shows This Week',
                      style: TextStyle(
                          fontSize: titleFontSize, fontWeight: FontWeight.bold),
                    ),
                  ));

                  children.add(SizedBox(
                    height: rowHeight,
                    child: Builder(builder: (context) {
                      final movies =
                          context.watch<TrendingTvShowListWeeklyBloc>().state;
                      if (movies is TrendingTvShowLisWeekly) {
                        return ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          itemCount: movies.list.length,
                          itemBuilder: (context, index) {
                            final movie = movies.list[index];
                            return MovieBox(
                                key: ValueKey(movie.id), movie: movie);
                          },
                        );
                      }
                      return _shimmer;
                    }),
                  ));

                  children.add(Padding(
                    padding: padding,
                    child: Text(
                      'Trending TV Shows Today',
                      style: TextStyle(
                          fontSize: titleFontSize, fontWeight: FontWeight.bold),
                    ),
                  ));

                  children.add(SizedBox(
                    height: rowHeight,
                    child: Builder(builder: (context) {
                      final movies =
                          context.watch<TrendingTvShowListDailyBloc>().state;
                      if (movies is TrendingTvShowListDaily) {
                        return ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: movies.list.length,
                          itemBuilder: (context, index) {
                            final movie = movies.list[index];
                            return MovieBox(
                                key: ValueKey(movie.id), movie: movie);
                          },
                        );
                      }
                      return _shimmer;
                    }),
                  ));
                }

                return children;
              })(),
            ),
          ),
        ],
      ),
    );
  }
}
