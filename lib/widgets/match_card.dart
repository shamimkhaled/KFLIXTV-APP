import 'package:flutter/material.dart';

import '../models/match.dart';

class MatchCard extends StatelessWidget {
  const MatchCard({
    super.key,
    required this.match,
    required this.onTap,
    this.showHighlightBadge = false,
  });

  final WorldCupMatch match;
  final VoidCallback onTap;
  final bool showHighlightBadge;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isLive = match.status == MatchStatus.live;

    return Material(
      color: cs.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isLive
                  ? Colors.red.withValues(alpha: 0.6)
                  : cs.outlineVariant.withValues(alpha: 0.25),
            ),
          ),
          child: Column(
            children: [
              // ── Top bar ─────────────────────────────────────────────
              _TopBar(match: match, showHighlightBadge: showHighlightBadge),

              // ── Scoreboard row ───────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: _TeamColumn(
                        flag: match.team1Flag,
                        name: match.team1,
                        align: CrossAxisAlignment.start,
                      ),
                    ),
                    _CenterScore(match: match),
                    Expanded(
                      child: _TeamColumn(
                        flag: match.team2Flag,
                        name: match.team2,
                        align: CrossAxisAlignment.end,
                      ),
                    ),
                  ],
                ),
              ),

              // ── Venue ────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
                child: Row(
                  children: [
                    Icon(Icons.location_on_outlined,
                        size: 13, color: cs.onSurfaceVariant),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        '${match.venue}, ${match.city}',
                        style: tt.labelSmall
                            ?.copyWith(color: cs.onSurfaceVariant),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

              // ── Action row ───────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                child: Row(
                  children: [
                    Icon(Icons.sensors_rounded,
                        size: 14, color: cs.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(
                      '${match.streamServers.length} streams',
                      style: tt.labelSmall
                          ?.copyWith(color: cs.onSurfaceVariant),
                    ),
                    const Spacer(),
                    _ActionButton(match: match, onTap: onTap),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Top bar (badges + round + venue) ────────────────────────────────────────

class _TopBar extends StatelessWidget {
  const _TopBar({required this.match, required this.showHighlightBadge});
  final WorldCupMatch match;
  final bool showHighlightBadge;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isLive = match.status == MatchStatus.live;

    // Live pulse + red strip
    Widget topBar = Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isLive
            ? Colors.red.withValues(alpha: 0.08)
            : cs.surfaceContainerHighest.withValues(alpha: 0.6),
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        children: [
          _StatusPill(match: match),
          const SizedBox(width: 8),
          Text(
            match.roundLabel,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: cs.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
          ),
          if (match.status == MatchStatus.live && match.minute != null) ...[
            const SizedBox(width: 6),
            Text(
              match.minute!,
              style: TextStyle(
                color: Colors.red.shade400,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
          const Spacer(),
          if (showHighlightBadge) _Pill(label: '▶ HIGHLIGHTS', color: Colors.orange),
        ],
      ),
    );

    return topBar;
  }
}

// ─── Centre score / kickoff ───────────────────────────────────────────────────

class _CenterScore extends StatelessWidget {
  const _CenterScore({required this.match});
  final WorldCupMatch match;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isUpcoming = match.status == MatchStatus.upcoming;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: cs.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: isUpcoming
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _timeStr(match.kickoff),
                  style: tt.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: cs.onPrimaryContainer,
                  ),
                ),
                Text(
                  _dateStr(match.kickoff),
                  style: tt.labelSmall?.copyWith(
                    color: cs.onPrimaryContainer.withValues(alpha: 0.7),
                  ),
                ),
              ],
            )
          : Text(
              match.scoreDisplay.isNotEmpty ? match.scoreDisplay : 'VS',
              style: tt.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: cs.onPrimaryContainer,
              ),
            ),
    );
  }

  String _timeStr(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  String _dateStr(DateTime dt) {
    const m = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${dt.day} ${m[dt.month]}';
  }
}

// ─── Team column ──────────────────────────────────────────────────────────────

class _TeamColumn extends StatelessWidget {
  const _TeamColumn({
    required this.flag,
    required this.name,
    required this.align,
  });

  final String flag;
  final String name;
  final CrossAxisAlignment align;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: align,
      children: [
        Text(flag, style: const TextStyle(fontSize: 40)),
        const SizedBox(height: 4),
        Text(
          name,
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(fontWeight: FontWeight.w700),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: align == CrossAxisAlignment.start
              ? TextAlign.left
              : TextAlign.right,
        ),
      ],
    );
  }
}

// ─── Action button ────────────────────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.match, required this.onTap});
  final WorldCupMatch match;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isLive = match.status == MatchStatus.live;
    final isUpcoming = match.status == MatchStatus.upcoming;

    return FilledButton.icon(
      onPressed: onTap,
      icon: Icon(
        isLive
            ? Icons.play_arrow_rounded
            : isUpcoming
                ? Icons.info_outline_rounded
                : Icons.replay_rounded,
        size: 16,
      ),
      label: Text(
        isLive ? 'Watch Live' : isUpcoming ? 'Details' : 'Replay',
        style: const TextStyle(fontSize: 12),
      ),
      style: FilledButton.styleFrom(
        backgroundColor: isLive ? Colors.red : null,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        visualDensity: VisualDensity.compact,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.match});
  final WorldCupMatch match;

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (match.status) {
      MatchStatus.live => (Colors.red, '● LIVE'),
      MatchStatus.upcoming => (Colors.blue, '⏰ UPCOMING'),
      MatchStatus.completed => (Colors.grey, '✓ FT'),
    };
    return _Pill(label: label, color: color);
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: TextStyle(
            color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
