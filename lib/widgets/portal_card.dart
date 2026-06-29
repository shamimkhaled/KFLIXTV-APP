import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../data/portals.dart';
import '../models/portal.dart';
import '../providers/favorites_provider.dart';
import '../providers/portal_provider.dart';
import '../utils/app_theme.dart';

/// Portal card matching the KFLIX TV dark UI mockup:
/// gradient-accent header · 2-letter avatar · status badge · heart icon.
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
    final portal = widget.portal;
    final isFavorite =
        context.watch<FavoritesProvider>().isFavorite(portal.url);
    final status = context.watch<PortalProvider>().statusFor(portal.url);

    // Accent colour for header gradient based on portal position in list
    final idx = kPortals.indexOf(portal);
    final accent = KColors.accentFor(idx < 0 ? 0 : idx);

    final initials = _initials(portal.name);

    return GestureDetector(
      onTap: widget.onOpen,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Theme.of(context).colorScheme.surface,
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant
                  .withValues(alpha: 0.5),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ───────────────────────────────────────────────
              Expanded(
                flex: 3,
                child: Stack(
                  children: [
                    // Accent gradient background
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(16)),
                          gradient: RadialGradient(
                            center: const Alignment(-0.6, -0.7),
                            radius: 1.3,
                            colors: accent,
                          ),
                        ),
                      ),
                    ),
                    // Letter avatar
                    Center(
                      child: Text(
                        initials,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: Colors.white.withValues(alpha: 0.92),
                        ),
                      ),
                    ),
                    // Heart icon – top right
                    Positioned(
                      top: 6,
                      right: 6,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => context
                            .read<FavoritesProvider>()
                            .toggleFavorite(portal.url),
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.45),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isFavorite
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            size: 15,
                            color: isFavorite
                                ? KColors.liveRed
                                : Colors.white,
                          ),
                        ),
                      ),
                    ),
                    // Status badge – bottom left
                    Positioned(
                      bottom: 7,
                      left: 7,
                      child: _StatusBadge(status: status),
                    ),
                  ],
                ),
              ),

              // ── Footer ───────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(11, 8, 11, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      portal.name,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      portal.category.label,
                      style: TextStyle(
                        fontSize: 11,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    return name.length >= 2
        ? name.substring(0, 2).toUpperCase()
        : name.toUpperCase();
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final PortalReachability status;

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (status) {
      PortalReachability.online => (KColors.online, 'ONLINE'),
      PortalReachability.offline => (KColors.offline, 'OFFLINE'),
      PortalReachability.checking => (KColors.checking, 'CHECKING'),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: color.withValues(alpha: 0.9),
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}
