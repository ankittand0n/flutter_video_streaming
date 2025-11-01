import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:namkeen_tv/model/movie.dart';
import 'package:namkeen_tv/screens/home.dart';
import 'package:namkeen_tv/screens/movie_details.dart';
import 'package:namkeen_tv/screens/netflix_scaffold.dart';
import 'package:namkeen_tv/screens/login_screen.dart';
import 'package:namkeen_tv/screens/register_screen.dart';
import 'package:namkeen_tv/screens/profile_screen.dart';
import 'package:namkeen_tv/widgets/video_player_widget.dart';
import 'package:namkeen_tv/services/auth_service.dart';
import 'package:go_router/go_router.dart';

import 'bloc/blocs.dart';
import 'utils/utils.dart';
import 'config/app_config.dart';

void main() {
  // Print runtime configuration for debugging
  AppConfig.printConfig();
  runApp(NamkeenTvApp());
}

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
    initialLocation: '/login',
    navigatorKey: _navigatorState,
    redirect: (context, state) async {
      final authService = AuthService();
      final isLoggedIn = await authService.isLoggedIn();
      final currentPath = state.location;
      final isLoginRoute = currentPath == '/login';
      final isRegisterRoute = currentPath == '/register';

      // If not logged in and trying to access protected routes, redirect to login
      if (!isLoggedIn && !isLoginRoute && !isRegisterRoute) {
        return '/login';
      }

      // If logged in and trying to access login/register, redirect to home
      if (isLoggedIn && (isLoginRoute || isRegisterRoute)) {
        return '/home';
      }

      // Allow navigation
      return null;
    },
    routes: [
      // Login route
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      // Register route
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
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
          GoRoute(
            name: 'Profile',
            path: '/profile',
            builder: (BuildContext context, GoRouterState state) {
              return const ProfileScreen();
            },
          ),
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
