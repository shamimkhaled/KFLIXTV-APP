import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
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

  void _open(BuildContext context, Portal portal) =>
      context.push('/player', extra: portal);

  @override
  Widget build(BuildContext context) {
    final portalProvider = context.watch<PortalProvider>();
    final favorites = context.watch<FavoritesProvider>();
    final filtered = portalProvider.filteredPortals(favorites.favoriteUrls);
    final width = MediaQuery.sizeOf(context).width;
    final cols = width > 900 ? 4 : 2;

    final showExtras = portalProvider.filter == PortalFilter.all &&
        portalProvider.searchQuery.isEmpty;

    final recentPortals = favorites.recentUrls
        .map(_findPortalByUrl)
        .whereType<Portal>()
        .toList(growable: false);

    return Scaffold(
      backgroundColor: KColors.background,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(child: OfflineBanner()),
            _GradientHeader(onSearchTap: () => context.push('/search')),

            if (showExtras && portalProvider.featuredPortals.isNotEmpty)
              SliverToBoxAdapter(
                child: HeroBanner(
                  portals: portalProvider.featuredPortals,
                  onOpen: (p) => _open(context, p),
                ),
              ),

            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: CategoryTabs(),
              ),
            ),

            if (showExtras && recentPortals.isNotEmpty)
              SliverToBoxAdapter(
                child: _Rail(
                  title: 'Recently Opened',
                  portals: recentPortals,
                  onOpen: (p) => _open(context, p),
                ),
              ),

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
              sliver: SliverToBoxAdapter(
                child: Row(
                  children: [
                    Text(
                      _sectionTitle(portalProvider.filter),
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: KColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${filtered.length} portals',
                      style: const TextStyle(
                          fontSize: 12, color: KColors.textMuted),
                    ),
                  ],
                ),
              ),
            ),

            if (filtered.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: _EmptyState(),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: cols,
                    mainAxisSpacing: 11,
                    crossAxisSpacing: 11,
                    childAspectRatio: 0.75,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, i) {
                      final p = filtered[i];
                      return PortalCard(portal: p, onOpen: () => _open(context, p));
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

  String _sectionTitle(PortalFilter f) => switch (f) {
        PortalFilter.all => 'All Portals',
        PortalFilter.movies => 'Movies',
        PortalFilter.liveTv => 'Live TV',
        PortalFilter.favorites => 'Favorites',
      };
}

// ─── Gradient header ──────────────────────────────────────────────────────────

class _GradientHeader extends StatelessWidget {
  const _GradientHeader({required this.onSearchTap});
  final VoidCallback onSearchTap;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      stretch: true,
      expandedHeight: 88,
      automaticallyImplyLeading: false,
      backgroundColor: KColors.background,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: KColors.brandGradient,
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SafeArea(
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
                      color: Colors.white, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'KFLIX TV',
                    style: GoogleFonts.spaceGrotesk(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.search_rounded, color: Colors.white),
                  onPressed: onSearchTap,
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
  const _Rail({required this.title, required this.portals, required this.onOpen});
  final String title;
  final List<Portal> portals;
  final void Function(Portal) onOpen;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Text(title,
              style: GoogleFonts.spaceGrotesk(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: KColors.textPrimary)),
        ),
        SizedBox(
          height: 200,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: portals.length,
            separatorBuilder: (_, __) => const SizedBox(width: 11),
            itemBuilder: (context, i) {
              final p = portals[i];
              return SizedBox(
                width: 148,
                child: PortalCard(portal: p, onOpen: () => onOpen(p)),
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
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off_rounded,
                size: 56, color: KColors.textMuted.withValues(alpha: 0.5)),
            const SizedBox(height: 12),
            const Text('No portals found.',
                textAlign: TextAlign.center,
                style: TextStyle(color: KColors.textMuted)),
          ],
        ),
      ),
    );
  }
}
