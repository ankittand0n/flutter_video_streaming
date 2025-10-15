
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:namkeen_tv/bloc/netflix_bloc.dart';

import '../widgets/new_and_hot_header_delegate.dart';
import '../widgets/new_and_hot_tile.dart';

class NewAndHotScreen extends StatefulWidget {
  const NewAndHotScreen({super.key});

  @override
  State<NewAndHotScreen> createState() => _NewAndHotScreenState();
}

class _NewAndHotScreenState extends State<NewAndHotScreen>
    with SingleTickerProviderStateMixin {
  late final ScrollController _scrollController = ScrollController();

  late final TabController _tabController =
      TabController(length: 3, vsync: this)
        // Removed automatic scroll-to-tab behavior to disable side-scrolling sync.
        ;

  @override
  void initState() {
    // Load both TV shows and movies for the New & Hot screen
    context.read<DiscoverTvShowsBloc>().add(DiscoverTvShowsEvent());
    context.read<DiscoverMoviesBloc>().add(DiscoverMoviesEvent());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverPersistentHeader(
            delegate: NewAndHotHeaderDelegate(tabController: _tabController),
            pinned: true,
          ),
          Builder(builder: (context) {
            final movies = context.watch<DiscoverTvShowsBloc>().state;
            if (movies is DiscoverTvShows) {
              return SliverList(
                  delegate: SliverChildBuilderDelegate(
                      (context, index) => NewAndHotTile(
                            movie: movies.list[index],
                          ),
                      childCount: movies.list.length));
            }
            return const SliverToBoxAdapter();
          }),
          Builder(builder: (context) {
            final movies = context.watch<DiscoverMoviesBloc>().state;
            if (movies is DiscoverMovies) {
              return SliverList(
                  delegate: SliverChildBuilderDelegate(
                      (context, index) => NewAndHotTile(
                            movie: movies.list[index],
                          ),
                      childCount: movies.list.length));
            }
            return const SliverToBoxAdapter();
          }),
        ],
      ),
    );
  }
}
