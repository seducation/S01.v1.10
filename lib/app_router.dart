import 'package:go_router/go_router.dart';
import 'package:my_app/auth_service.dart';
import 'package:my_app/pps.dart';
import 'package:my_app/search_screen.dart';
import 'package:my_app/sign_in.dart';
import 'package:my_app/sign_up.dart';
import 'package:my_app/home_screen.dart';

class AppRouter {
  final AuthService authService;

  AppRouter({required this.authService});

  late final GoRouter router = GoRouter(
    refreshListenable: authService,
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/signin',
        builder: (context, state) => const SignInScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: '/search',
        builder: (context, state) => const SearchScreen(),
        routes: [
          GoRoute(
            path: ':query',
            builder: (context, state) =>
                SearchScreen(query: state.pathParameters['query']!),
          ),
        ],
      ),
      GoRoute(
        path: '/profile/:id',
        builder: (context, state) =>
            ProfilePageScreen(profileId: state.pathParameters['id']!),
      ),
    ],
    redirect: (context, state) {
      final loggedIn = authService.isLoggedIn;
      final loggingIn =
          state.matchedLocation == '/signin' || state.matchedLocation == '/signup';

      if (!loggedIn) {
        return loggingIn ? null : '/signin';
      }

      if (loggingIn) {
        return '/';
      }

      return null;
    },
  );
}
