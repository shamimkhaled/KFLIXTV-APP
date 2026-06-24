import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/match.dart';
import '../models/portal.dart';
import '../providers/world_cup_provider.dart';
import '../widgets/status_indicator.dart';

class MatchDetailScreen extends StatelessWidget {
  const MatchDetailScreen({super.key, required this.match});
  final WorldCupMatch match;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WorldCupProvider>();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _AppBar(match: match),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _ScoreBoard(match: match),
                const SizedBox(height: 24),
                _ServerSection(match: match, provider: provider),
                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── App bar ──────────────────────────────────────────────────────────────────

class _AppBar extends StatelessWidget {
  const _AppBar({required this.match});
  final WorldCupMatch match;

  @override
  Widget build(BuildContext context) {
    final isLive = match.status == MatchStatus.live;
    return SliverAppBar(
      pinned: true,
      expandedHeight: 64,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isLive
                  ? [const Color(0xFF7B0000), const Color(0xFFC62828)]
                  : [const Color(0xFF003F8A), const Color(0xFF1565C0)],
            ),
          ),
        ),
        titlePadding: const EdgeInsets.only(left: 56, bottom: 12),
        title: Text(
          '${match.team1} vs ${match.team2}',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

// ─── Scoreboard ───────────────────────────────────────────────────────────────

class _ScoreBoard extends StatelessWidget {
  const _ScoreBoard({required this.match});
  final WorldCupMatch match;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isLive = match.status == MatchStatus.live;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: isLive
              ? [
                  Colors.red.withValues(alpha: 0.12),
                  cs.surfaceContainerHigh,
                ]
              : [cs.surfaceContainerHigh, cs.surfaceContainerHigh],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        border: Border.all(
          color: isLive
              ? Colors.red.withValues(alpha: 0.4)
              : cs.outlineVariant,
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Status badges
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _Pill(label: match.roundLabel, color: cs.primary),
              if (isLive) ...[
                const SizedBox(width: 8),
                _Pill(
                  label: match.minute != null
                      ? '● ${match.minute}'
                      : '● LIVE',
                  color: Colors.red,
                ),
              ] else if (match.status == MatchStatus.completed) ...[
                const SizedBox(width: 8),
                const _Pill(label: 'FULL TIME', color: Colors.grey),
              ],
            ],
          ),
          const SizedBox(height: 20),

          // Teams + score
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text(match.team1Flag,
                          style: const TextStyle(fontSize: 52)),
                      const SizedBox(height: 6),
                      Text(match.team1,
                          style: tt.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: cs.primaryContainer,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    match.status == MatchStatus.upcoming
                        ? 'VS'
                        : match.scoreDisplay,
                    style: tt.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: cs.onPrimaryContainer,
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(match.team2Flag,
                          style: const TextStyle(fontSize: 52)),
                      const SizedBox(height: 6),
                      Text(match.team2,
                          style: tt.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Venue
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.stadium_outlined,
                  size: 14, color: cs.onSurfaceVariant),
              const SizedBox(width: 4),
              Text('${match.venue}, ${match.city}',
                  style:
                      tt.labelMedium?.copyWith(color: cs.onSurfaceVariant)),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Server section ───────────────────────────────────────────────────────────

class _ServerSection extends StatelessWidget {
  const _ServerSection(
      {required this.match, required this.provider});
  final WorldCupMatch match;
  final WorldCupProvider provider;

  @override
  Widget build(BuildContext context) {
    final selectedIdx = provider.selectedServerIndex(match.id);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text('Choose Stream',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
            ),
            TextButton.icon(
              onPressed: provider.refreshServerStatuses,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Check status'),
              style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ...match.streamServers.asMap().entries.map((e) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _ServerTile(
              index: e.key,
              url: e.value,
              isSelected: e.key == selectedIdx,
              status: provider.serverStatus(e.value),
              onSelect: () => provider.selectServer(match.id, e.key),
            ),
          );
        }),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            icon: const Icon(Icons.play_arrow_rounded),
            label: Text('Watch on Server ${selectedIdx + 1}'),
            onPressed: () => _openStream(context),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            'Tip: switch servers if the stream buffers or fails',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
        ),
      ],
    );
  }

  void _openStream(BuildContext context) {
    final url = provider.selectedServerUrl(match);
    if (url.isEmpty) return;
    context.push('/player',
        extra: Portal(
          name: '${match.team1} vs ${match.team2}',
          url: url,
          category: PortalCategory.liveTv,
        ));
  }
}

class _ServerTile extends StatelessWidget {
  const _ServerTile({
    required this.index,
    required this.url,
    required this.isSelected,
    required this.status,
    required this.onSelect,
  });

  final int index;
  final String url;
  final bool isSelected;
  final PortalReachability status;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: isSelected ? cs.primaryContainer : cs.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onSelect,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? cs.primary
                  : cs.outlineVariant.withValues(alpha: 0.3),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor:
                    isSelected ? cs.primary : cs.surfaceContainerHighest,
                foregroundColor:
                    isSelected ? cs.onPrimary : cs.onSurface,
                child: Text('S${index + 1}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 12)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Server ${index + 1}',
                        style: TextStyle(
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          fontSize: 14,
                        )),
                    Text(url,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: cs.onSurfaceVariant),
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              StatusIndicator(status: status, compact: true),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }
}
