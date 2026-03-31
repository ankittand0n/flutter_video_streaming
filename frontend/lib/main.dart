import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:namkeen_tv/model/movie.dart';
import 'package:namkeen_tv/screens/home.dart';
import 'package:namkeen_tv/screens/movie_details.dart';
import 'package:namkeen_tv/screens/netflix_scaffold.dart';
import 'package:namkeen_tv/screens/login_screen.dart';
import 'package:namkeen_tv/screens/register_screen.dart';
import 'package:namkeen_tv/screens/profile_screen.dart';
import 'package:namkeen_tv/screens/privacy_policy_screen.dart';
import 'package:namkeen_tv/screens/search_screen.dart';
import 'package:namkeen_tv/services/auth_service.dart';
import 'package:namkeen_tv/services/cast_service.dart';
import 'package:go_router/go_router.dart';
import 'package:media_kit/media_kit.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_web_plugins/url_strategy.dart';

import 'bloc/blocs.dart';
import 'utils/utils.dart';
import 'config/app_config.dart';

void main() async {
  // Use path-based URLs (no # in URLs) for clean web routing
  usePathUrlStrategy();

  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize media_kit for video/audio playback (not supported on web)
  if (!kIsWeb) {
    try {
      MediaKit.ensureInitialized();
    } catch (e) {
      print('MediaKit initialization failed: $e');
    }
  }

  // Initialize Cast service on web (non-blocking, don't delay app render)
  if (kIsWeb) {
    CastService.instance.initialize().catchError((e) {
      print('Cast service initialization failed: $e');
    });
  }

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
              elevation: 0,
              scrolledUnderElevation: 0,
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

  final AuthService _authService = AuthService();

  late final GoRouter _router = GoRouter(
    initialLocation: '/login',
    navigatorKey: _navigatorState,
    redirect: (context, state) async {
      try {
        final isLoggedIn = await _authService.isLoggedIn().timeout(
          const Duration(seconds: 5),
          onTimeout: () => false,
        );
        final currentPath = state.location;
        final isLoginRoute = currentPath == '/login';
        final isRegisterRoute = currentPath == '/register';
        final isPrivacyPolicyRoute = currentPath.startsWith('/privacy-policy');

        // If not logged in and trying to access protected routes, redirect to login
        if (!isLoggedIn && !isLoginRoute && !isRegisterRoute && !isPrivacyPolicyRoute) {
          return '/login';
        }

        // If logged in and trying to access login/register, redirect to home
        if (isLoggedIn && (isLoginRoute || isRegisterRoute)) {
          return '/home';
        }

        return null;
      } catch (e) {
        print('Redirect error: $e');
        return null; // Allow navigation to proceed
      }
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
      // Privacy Policy route - public access
      GoRoute(
        name: 'PrivacyPolicy',
        path: '/privacy-policy',
        builder: (BuildContext context, GoRouterState state) {
          return const PrivacyPolicyScreen();
        },
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
                GoRoute(
                  name: 'Search',
                  path: 'search',
                  builder: (BuildContext context, GoRouterState state) {
                    return const SearchScreen();
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
    ],
  );
}
