import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/world_cup_provider.dart';

/// Responsive shell:
/// - Mobile / portrait (≤720 px) → [NavigationBar] at bottom.
/// - Tablet / TV (>720 px)       → [NavigationRail] on left.
class RootScaffold extends StatelessWidget {
  const RootScaffold({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _onTab(int index) => navigationShell.goBranch(
        index,
        initialLocation: index == navigationShell.currentIndex,
      );

  @override
  Widget build(BuildContext context) {
    final liveCount =
        context.watch<WorldCupProvider>().liveMatches.length;
    final width = MediaQuery.sizeOf(context).width;
    final useRail = width > 720;
    final extended = width > 1200;

    if (useRail) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              extended: extended,
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: _onTab,
              minWidth: 72,
              minExtendedWidth: 190,
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  children: [
                    const Icon(Icons.live_tv_rounded, size: 28),
                    if (extended) ...[
                      const SizedBox(height: 4),
                      const Text('KFLIX TV',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 13)),
                    ],
                  ],
                ),
              ),
              destinations: [
                const NavigationRailDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home_rounded),
                  label: Text('Home'),
                ),
                NavigationRailDestination(
                  icon: _WcIcon(liveCount: liveCount, selected: false),
                  selectedIcon: _WcIcon(liveCount: liveCount, selected: true),
                  label: const Text('FIFA WC'),
                ),
                const NavigationRailDestination(
                  icon: Icon(Icons.favorite_border_rounded),
                  selectedIcon: Icon(Icons.favorite_rounded),
                  label: Text('Favorites'),
                ),
                const NavigationRailDestination(
                  icon: Icon(Icons.settings_outlined),
                  selectedIcon: Icon(Icons.settings_rounded),
                  label: Text('Settings'),
                ),
              ],
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(child: navigationShell),
          ],
        ),
      );
    }

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _onTab,
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: _WcIcon(liveCount: liveCount, selected: false),
            selectedIcon: _WcIcon(liveCount: liveCount, selected: true),
            label: 'FIFA WC',
          ),
          const NavigationDestination(
            icon: Icon(Icons.favorite_border_rounded),
            selectedIcon: Icon(Icons.favorite_rounded),
            label: 'Favorites',
          ),
          const NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings_rounded),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

/// Trophy icon with an animated red LIVE badge when matches are in progress.
class _WcIcon extends StatelessWidget {
  const _WcIcon({required this.liveCount, required this.selected});
  final int liveCount;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final icon = Icon(
      selected ? Icons.emoji_events_rounded : Icons.emoji_events_outlined,
      color: selected
          ? const Color(0xFFFFD700) // gold when active
          : null,
    );

    if (liveCount == 0) return icon;

    return Badge(
      label: Text(
        liveCount > 9 ? '9+' : '$liveCount',
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
      ),
      backgroundColor: Colors.red,
      child: icon,
    );
  }
}
