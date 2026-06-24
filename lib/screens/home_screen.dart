import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/portals.dart';
import '../models/portal.dart';
import '../providers/favorites_provider.dart';
import '../providers/portal_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/category_tabs.dart';
import '../widgets/hero_banner.dart';
import '../widgets/offline_banner.dart';
import '../widgets/portal_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _openPortal(BuildContext context, Portal portal) =>
      context.push('/player', extra: portal);

  @override
  Widget build(BuildContext context) {
    final portalProvider = context.watch<PortalProvider>();
    final favorites = context.watch<FavoritesProvider>();
    final filtered = portalProvider.filteredPortals(favorites.favoriteUrls);
    final screenW = MediaQuery.sizeOf(context).width;

    final showExtras = portalProvider.filter == PortalFilter.all &&
        portalProvider.searchQuery.isEmpty;

    final recentPortals = favorites.recentUrls
        .map(_findPortalByUrl)
        .whereType<Portal>()
        .toList(growable: false);

    // Responsive grid columns
    final crossAxisCount = screenW > 900
        ? 4
        : screenW > 600
            ? 3
            : 2;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            // ── Offline banner ───────────────────────────────────────
            const SliverToBoxAdapter(child: OfflineBanner()),

            // ── App bar ──────────────────────────────────────────────
            _GradientHeader(onSearchTap: () => context.push('/search')),

            // ── Hero banner (featured portals) ───────────────────────
            if (showExtras && portalProvider.featuredPortals.isNotEmpty)
              SliverToBoxAdapter(
                child: HeroBanner(
                  portals: portalProvider.featuredPortals,
                  onOpen: (p) => _openPortal(context, p),
                ),
              ),

            // ── Category filter tabs ─────────────────────────────────
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: CategoryTabs(),
              ),
            ),

            // ── Recently opened rail ─────────────────────────────────
            if (showExtras && recentPortals.isNotEmpty)
              SliverToBoxAdapter(
                child: _Rail(
                  title: 'Recently Opened',
                  portals: recentPortals,
                  onOpen: (p) => _openPortal(context, p),
                ),
              ),

            // ── Section title ────────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              sliver: SliverToBoxAdapter(
                child: Row(
                  children: [
                    Text(
                      _sectionTitle(portalProvider.filter),
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    Text(
                      '${filtered.length} portals',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Portal grid ──────────────────────────────────────────
            if (filtered.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _EmptyState(filter: portalProvider.filter),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 100),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 0.75,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final portal = filtered[index];
                      return PortalCard(
                        portal: portal,
                        onOpen: () => _openPortal(context, portal),
                      );
                    },
                    childCount: filtered.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Portal? _findPortalByUrl(String url) {
    for (final p in kPortals) {
      if (p.url == url) return p;
    }
    return null;
  }

  String _sectionTitle(PortalFilter filter) => switch (filter) {
        PortalFilter.all => 'All Portals',
        PortalFilter.movies => 'Movies',
        PortalFilter.liveTv => 'Live TV',
        PortalFilter.favorites => 'Favorites',
      };
}

// ─── Gradient SliverAppBar ────────────────────────────────────────────────────

class _GradientHeader extends StatelessWidget {
  const _GradientHeader({required this.onSearchTap});
  final VoidCallback onSearchTap;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      stretch: true,
      expandedHeight: 90,
      automaticallyImplyLeading: false,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: AppColors.brandGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.live_tv_rounded,
                      color: Colors.white, size: 22),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'KFLIX TV',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.search_rounded, color: Colors.white),
                  onPressed: onSearchTap,
                  tooltip: 'Search',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Horizontal rail ──────────────────────────────────────────────────────────

class _Rail extends StatelessWidget {
  const _Rail({
    required this.title,
    required this.portals,
    required this.onOpen,
  });

  final String title;
  final List<Portal> portals;
  final void Function(Portal) onOpen;

  @override
  Widget build(BuildContext context) {
    final itemH = MediaQuery.sizeOf(context).height * 0.24;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
          child: Text(
            title,
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: itemH.clamp(150, 220),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: portals.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, i) {
              final portal = portals[i];
              return SizedBox(
                width: 150,
                child:
                    PortalCard(portal: portal, onOpen: () => onOpen(portal)),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ─── Empty state ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.filter});
  final PortalFilter filter;

  @override
  Widget build(BuildContext context) {
    final isFav = filter == PortalFilter.favorites;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isFav
                  ? Icons.favorite_border_rounded
                  : Icons.search_off_rounded,
              size: 56,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 12),
            Text(
              isFav
                  ? 'No favorites yet.\nTap ♡ on any portal to save it here.'
                  : 'No portals found.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
