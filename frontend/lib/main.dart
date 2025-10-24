import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:namkeen_tv/model/movie.dart';
import 'package:namkeen_tv/screens/home.dart';
import 'package:namkeen_tv/screens/movie_details.dart';
import 'package:namkeen_tv/screens/netflix_scaffold.dart';
import 'package:namkeen_tv/widgets/video_player_widget.dart';
import 'package:go_router/go_router.dart';

import 'bloc/blocs.dart';
import 'utils/utils.dart';

void main() => runApp(NamkeenTvApp());

class NamkeenTvApp extends StatelessWidget {
  NamkeenTvApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocWidget(
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        routeInformationProvider: _router.routeInformationProvider,
        routeInformationParser: _router.routeInformationParser,
        routerDelegate: _router.routerDelegate,
        title: 'Namkeen TV',
        theme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: backgroundColor,
            appBarTheme: const AppBarTheme(
              backgroundColor: backgroundColor,
              systemOverlayStyle: SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness: Brightness.light,
                statusBarBrightness: Brightness.light,
              ),
            )),
      ),
    );
  }

  final GlobalKey<NavigatorState> _navigatorState = GlobalKey<NavigatorState>();

  late final GoRouter _router = GoRouter(
    initialLocation: '/home',
    navigatorKey: _navigatorState,
    routes: [
      // Profile route removed
      ShellRoute(
        // observers: [_heroController],
        builder: (context, state, child) {
          return NetflixScaffold(child: child);
        },
        routes: <RouteBase>[
          GoRoute(
              name: 'Home',
              path: '/home',
              builder: (BuildContext context, GoRouterState state) {
                return const HomeScreen();
              },
              routes: [
                GoRoute(
                    name: 'Movies',
                    path: 'movies',
                    builder: (BuildContext context, GoRouterState state) {
                      return HomeScreen(name: state.name);
                    },
                    routes: [
                      GoRoute(
                        path: 'details',
                        builder: (BuildContext context, GoRouterState state) {
                          return MovieDetailsScreen(
                              movie: state.extra as Movie);
                        },
                      ),
                    ]),
                GoRoute(
                    name: 'TV Shows',
                    path: 'tvshows',
                    builder: (BuildContext context, GoRouterState state) {
                      return HomeScreen(name: state.name);
                    },
                    routes: [
                      GoRoute(
                        path: 'details',
                        builder: (BuildContext context, GoRouterState state) {
                          return MovieDetailsScreen(
                              movie: state.extra as Movie);
                        },
                      ),
                    ]),
                GoRoute(
                  path: 'details',
                  builder: (BuildContext context, GoRouterState state) {
                    return MovieDetailsScreen(movie: state.extra as Movie);
                  },
                ),
              ]),
        ],
      ),
      // Video player route outside shell - no bottom navigation
      GoRoute(
        path: '/video-player',
        builder: (context, state) {
          final params = state.extra as Map<String, dynamic>?;
          return VideoPlayerWidget(
            videoUrl: params?['videoUrl'] ?? '',
            trailerUrl: params?['trailerUrl'],
            isTrailer: params?['isTrailer'] ?? false,
            videoId: params?['videoId']?.toString(),
          );
        },
      ),
    ],
  );
}
