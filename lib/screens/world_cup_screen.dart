import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/match.dart';
import '../providers/world_cup_provider.dart';
import '../widgets/match_card.dart';

class WorldCupScreen extends StatelessWidget {
  const WorldCupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (context, _) => [
            SliverAppBar(
              pinned: true,
              expandedHeight: 120,
              automaticallyImplyLeading: false,
              flexibleSpace: const _WcHeader(),
              bottom: const TabBar(
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                tabs: [
                  Tab(icon: Icon(Icons.sports_soccer_rounded), text: 'Live'),
                  Tab(icon: Icon(Icons.schedule_rounded), text: 'Upcoming'),
                  Tab(icon: Icon(Icons.check_circle_outline_rounded), text: 'Completed'),
                  Tab(icon: Icon(Icons.play_circle_outline_rounded), text: 'Highlights'),
                ],
              ),
            ),
          ],
          body: const TabBarView(
            children: [
              _MatchList(status: MatchStatus.live),
              _MatchList(status: MatchStatus.upcoming),
              _MatchList(status: MatchStatus.completed),
              _HighlightsTab(),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Header ──────────────────────────────────────────────────────────────────

class _WcHeader extends StatelessWidget {
  const _WcHeader();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WorldCupProvider>();
    final liveCount = provider.liveMatches.length;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0D1B4B), Color(0xFF1A3A8F), Color(0xFF0D4A3A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Row(
            children: [
              // Glowing gold trophy
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD700).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: const Color(0xFFFFD700).withValues(alpha: 0.4)),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFD700).withValues(alpha: 0.25),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Text('🏆', style: TextStyle(fontSize: 28)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('FIFA World Cup 2026',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.3)),
                    SizedBox(height: 2),
                    Text('USA · Canada · Mexico',
                        style: TextStyle(
                            color: Color(0xFFFFD700),
                            fontSize: 12,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              if (provider.loading)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
              else
                IconButton(
                  icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                  onPressed: provider.fetchMatches,
                  tooltip: 'Refresh',
                ),
              if (liveCount > 0) ...[
                const SizedBox(width: 4),
                _LiveBadge(count: liveCount),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _LiveBadge extends StatelessWidget {
  const _LiveBadge({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.red.withValues(alpha: 0.4),
              blurRadius: 8,
              spreadRadius: 1),
        ],
      ),
      child: Text(
        '$count LIVE',
        style: const TextStyle(
            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
      ),
    );
  }
}

// ─── Match list tab ───────────────────────────────────────────────────────────

class _MatchList extends StatelessWidget {
  const _MatchList({required this.status});
  final MatchStatus status;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WorldCupProvider>();

    // Show error banner if applicable
    final error = provider.error;

    final matches = switch (status) {
      MatchStatus.live => provider.liveMatches,
      MatchStatus.upcoming => provider.upcomingMatches,
      MatchStatus.completed => provider.completedMatches,
    };

    return RefreshIndicator(
      onRefresh: provider.fetchMatches,
      child: CustomScrollView(
        slivers: [
          if (error != null)
            SliverToBoxAdapter(
              child: _ErrorBanner(message: error),
            ),
          if (provider.loading && matches.isEmpty)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (matches.isEmpty)
            SliverFillRemaining(
              child: _EmptyState(status: status),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(14),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: MatchCard(
                      match: matches[i],
                      onTap: () => context.push('/match', extra: matches[i]),
                    ),
                  ),
                  childCount: matches.length,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Highlights tab ───────────────────────────────────────────────────────────

class _HighlightsTab extends StatelessWidget {
  const _HighlightsTab();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WorldCupProvider>();
    final featured = provider.completedMatches
        .where((m) => m.isFeatured)
        .toList();

    return RefreshIndicator(
      onRefresh: provider.fetchMatches,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Match Highlights',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text(
                    'Replay the best moments from featured matches.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
          ),
          if (featured.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.movie_outlined,
                          size: 52,
                          color: Theme.of(context).colorScheme.outline),
                      const SizedBox(height: 12),
                      Text(
                        'No highlights yet.\nCheck back after featured matches complete.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: MatchCard(
                      match: featured[i],
                      onTap: () =>
                          context.push('/match', extra: featured[i]),
                      showHighlightBadge: true,
                    ),
                  ),
                  childCount: featured.length,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Empty state ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.status});
  final MatchStatus status;

  @override
  Widget build(BuildContext context) {
    final (icon, label) = switch (status) {
      MatchStatus.live => (Icons.sports_soccer_rounded, 'No matches live right now'),
      MatchStatus.upcoming => (Icons.schedule_rounded, 'No upcoming matches scheduled'),
      MatchStatus.completed => (Icons.check_circle_outline_rounded, 'No completed matches yet'),
    };
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 52, color: Theme.of(context).colorScheme.outline),
            const SizedBox(height: 12),
            Text(label,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: context.read<WorldCupProvider>().fetchMatches,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Refresh'),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Error banner ─────────────────────────────────────────────────────────────

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 14, 14, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: cs.errorContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded,
              size: 16, color: cs.onErrorContainer),
          const SizedBox(width: 8),
          Expanded(
            child: Text(message,
                style: TextStyle(color: cs.onErrorContainer, fontSize: 12)),
          ),
        ],
      ),
    );
  }
}
