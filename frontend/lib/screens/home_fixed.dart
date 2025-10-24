import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:namkeen_tv/bloc/netflix_bloc.dart';
import 'package:namkeen_tv/widgets/highlight_movie.dart';
import 'package:namkeen_tv/widgets/movie_box.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sliver_tools/sliver_tools.dart';

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
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Build shimmer effect for loading states
    final _shimmer = Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 10,
        itemBuilder: (_, __) => Container(
          width: 120.0,
          height: 180.0,
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
      ),
    );

    final state = GoRouterState.of(context);
    // Check if we're on a specific page
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
