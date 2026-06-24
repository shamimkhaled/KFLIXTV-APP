import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/favorites_provider.dart';
import 'providers/portal_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/world_cup_provider.dart';
import 'services/connectivity_service.dart';
import 'services/match_service.dart';
import 'services/portal_status_service.dart';
import 'services/storage_service.dart';
import 'utils/app_router.dart';
import 'utils/app_theme.dart';

void main() {
  runApp(const KloudTvApp());
}

/// Root widget: wires up persistence-backed providers and the Material 3
/// theme, then hands off to [appRouter] for navigation.
class KloudTvApp extends StatelessWidget {
  const KloudTvApp({super.key});

  @override
  Widget build(BuildContext context) {
    final storageService = StorageService();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider(storageService)),
        ChangeNotifierProvider(create: (_) => FavoritesProvider(storageService)),
        ChangeNotifierProvider(create: (_) => ConnectivityService()),
        ChangeNotifierProvider(create: (_) => PortalProvider(PortalStatusService())),
        ChangeNotifierProvider(create: (_) => WorldCupProvider(PortalStatusService(), MatchService())),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp.router(
            title: 'KFLIX TV',
            debugShowCheckedModeBanner: false,
            themeMode: themeProvider.themeMode,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            routerConfig: appRouter,
          );
        },
      ),
    );
  }
}
