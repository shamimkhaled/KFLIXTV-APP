import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/portal.dart';
import '../providers/favorites_provider.dart';
import '../providers/portal_provider.dart';
import 'status_indicator.dart';

/// Modern portal card — clean Material 3 surface with subtle gradient border.
class PortalCard extends StatefulWidget {
  const PortalCard({super.key, required this.portal, required this.onOpen});

  final Portal portal;
  final VoidCallback onOpen;

  @override
  State<PortalCard> createState() => _PortalCardState();
}

class _PortalCardState extends State<PortalCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final portal = widget.portal;

    final isFavorite =
        context.watch<FavoritesProvider>().isFavorite(portal.url);
    final status = context.watch<PortalProvider>().statusFor(portal.url);

    return GestureDetector(
      onTap: widget.onOpen,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: cs.surfaceContainerHigh,
            border: Border.all(
              color: cs.outlineVariant.withValues(alpha: 0.2),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.07),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Top row: avatar + favourite ──────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Avatar(name: portal.name, category: portal.category),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => context
                        .read<FavoritesProvider>()
                        .toggleFavorite(portal.url),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        isFavorite
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        size: 20,
                        color: isFavorite
                            ? cs.error
                            : cs.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // ── Name ─────────────────────────────────────────────────
              Text(
                portal.name,
                style: tt.titleSmall
                    ?.copyWith(fontWeight: FontWeight.w700, height: 1.2),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),

              // ── Category + status ────────────────────────────────────
              Row(
                children: [
                  _CategoryBadge(category: portal.category),
                  const Spacer(),
                  StatusIndicator(status: status, compact: true),
                ],
              ),

              const Spacer(),

              // ── Open button ──────────────────────────────────────────
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: FilledButton.tonal(
                  onPressed: widget.onOpen,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Open',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.name, required this.category});
  final String name;
  final PortalCategory category;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isMovies = category == PortalCategory.movies;
    final letter = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: isMovies
              ? [cs.primary, cs.tertiary]
              : [const Color(0xFF003F8A), const Color(0xFF00897B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        letter,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  const _CategoryBadge({required this.category});
  final PortalCategory category;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isMovies = category == PortalCategory.movies;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: isMovies ? cs.secondaryContainer : cs.tertiaryContainer,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        isMovies ? '🎬 Movies' : '📺 Live TV',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: isMovies
              ? cs.onSecondaryContainer
              : cs.onTertiaryContainer,
        ),
      ),
    );
  }
}
