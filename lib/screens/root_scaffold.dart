import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/world_cup_provider.dart';
import '../utils/app_theme.dart';

class RootScaffold extends StatelessWidget {
  const RootScaffold({super.key, required this.navigationShell});
  final StatefulNavigationShell navigationShell;

  void _onTab(int index) => navigationShell.goBranch(
        index,
        initialLocation: index == navigationShell.currentIndex,
      );

  @override
  Widget build(BuildContext context) {
    final liveCount = context.watch<WorldCupProvider>().liveMatches.length;
    final width = MediaQuery.sizeOf(context).width;
    final useRail = width > 720;
    final extended = width > 1200;

    if (useRail) {
      return _RailScaffold(
        navigationShell: navigationShell,
        liveCount: liveCount,
        extended: extended,
        onTab: _onTab,
      );
    }

    return _BarScaffold(
      navigationShell: navigationShell,
      liveCount: liveCount,
      onTab: _onTab,
    );
  }
}

// ─── Bottom bar (mobile) ──────────────────────────────────────────────────────

class _BarScaffold extends StatelessWidget {
  const _BarScaffold({
    required this.navigationShell,
    required this.liveCount,
    required this.onTab,
  });

  final StatefulNavigationShell navigationShell;
  final int liveCount;
  final void Function(int) onTab;

  @override
  Widget build(BuildContext context) {
    final idx = navigationShell.currentIndex;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xF20D0C16)
              : Colors.white,
          border: Border(
            top: BorderSide(
              color: Theme.of(context).dividerColor.withValues(alpha: 0.5),
            ),
          ),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 62,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(icon: Icons.home_outlined, selectedIcon: Icons.home_rounded, label: 'Home', selected: idx == 0, onTap: () => onTab(0)),
                _WcNavItem(selected: idx == 1, liveCount: liveCount, onTap: () => onTab(1)),
                _NavItem(icon: Icons.favorite_border_rounded, selectedIcon: Icons.favorite_rounded, label: 'Favorites', selected: idx == 2, onTap: () => onTab(2)),
                _NavItem(icon: Icons.tune_rounded, selectedIcon: Icons.tune_rounded, label: 'Settings', selected: idx == 3, onTap: () => onTab(3)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = selected
        ? KColors.navSelected
        : (isDark ? KColors.navInactive : const Color(0xFF79747E));
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(selected ? selectedIcon : icon, color: color, size: 23),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WcNavItem extends StatelessWidget {
  const _WcNavItem({required this.selected, required this.liveCount, required this.onTap});
  final bool selected;
  final int liveCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = selected
        ? KColors.navSelected
        : (isDark ? KColors.navInactive : const Color(0xFF79747E));
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  selected ? Icons.emoji_events_rounded : Icons.emoji_events_outlined,
                  color: selected ? const Color(0xFFFFD700) : KColors.navInactive,
                  size: 23,
                ),
                if (liveCount > 0)
                  Positioned(
                    top: -4,
                    right: -8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: KColors.liveRed,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [BoxShadow(color: KColors.liveRed.withValues(alpha: 0.6), blurRadius: 6)],
                      ),
                      child: Text(
                        liveCount > 9 ? '9+' : '$liveCount',
                        style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'World Cup',
              style: TextStyle(
                fontSize: 10,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Navigation rail (tablet / TV) ───────────────────────────────────────────

class _RailScaffold extends StatelessWidget {
  const _RailScaffold({
    required this.navigationShell,
    required this.liveCount,
    required this.extended,
    required this.onTab,
  });

  final StatefulNavigationShell navigationShell;
  final int liveCount;
  final bool extended;
  final void Function(int) onTab;

  @override
  Widget build(BuildContext context) {
    final idx = navigationShell.currentIndex;

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            extended: extended,
            selectedIndex: idx,
            onDestinationSelected: onTab,
            backgroundColor: const Color(0xFF0D0C16),
            minWidth: 72,
            minExtendedWidth: 190,
            leading: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(children: [
                const Icon(Icons.live_tv_rounded, size: 26, color: KColors.navSelected),
                if (extended) ...[
                  const SizedBox(height: 4),
                  const Text('KFLIX TV', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: KColors.textPrimary)),
                ],
              ]),
            ),
            destinations: [
              const NavigationRailDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: Text('Home')),
              NavigationRailDestination(
                icon: Badge(
                  isLabelVisible: liveCount > 0,
                  label: Text('$liveCount', style: const TextStyle(fontSize: 9)),
                  backgroundColor: KColors.liveRed,
                  child: const Icon(Icons.emoji_events_outlined),
                ),
                selectedIcon: const Icon(Icons.emoji_events_rounded, color: Color(0xFFFFD700)),
                label: const Text('FIFA WC'),
              ),
              const NavigationRailDestination(icon: Icon(Icons.favorite_border_rounded), selectedIcon: Icon(Icons.favorite_rounded), label: Text('Favorites')),
              const NavigationRailDestination(icon: Icon(Icons.tune_rounded), selectedIcon: Icon(Icons.tune_rounded), label: Text('Settings')),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: navigationShell),
        ],
      ),
    );
  }
}
