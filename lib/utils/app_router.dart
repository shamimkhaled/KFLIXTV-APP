import 'package:go_router/go_router.dart';

import '../models/match.dart';
import '../models/portal.dart';
import '../screens/favorites_screen.dart';
import '../screens/home_screen.dart';
import '../screens/match_detail_screen.dart';
import '../screens/root_scaffold.dart';
import '../screens/search_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/webview_screen.dart';
import '../screens/world_cup_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          RootScaffold(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/world-cup',
              builder: (context, state) => const WorldCupScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/favorites',
              builder: (context, state) => const FavoritesScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/settings',
              builder: (context, state) => const SettingsScreen(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/search',
      builder: (context, state) => const SearchScreen(),
    ),
    GoRoute(
      path: '/player',
      builder: (context, state) =>
          WebViewScreen(portal: state.extra as Portal),
    ),
    GoRoute(
      path: '/match',
      builder: (context, state) =>
          MatchDetailScreen(match: state.extra as WorldCupMatch),
    ),
  ],
);
