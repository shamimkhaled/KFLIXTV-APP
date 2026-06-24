import 'dart:async';

import 'package:flutter/material.dart';

import '../models/portal.dart';

/// Auto-rotating hero banner for featured portals.
/// Rotates every 5 s with animated dots and nav arrows.
class HeroBanner extends StatefulWidget {
  const HeroBanner({
    super.key,
    required this.portals,
    required this.onOpen,
  });

  final List<Portal> portals;
  final void Function(Portal) onOpen;

  @override
  State<HeroBanner> createState() => _HeroBannerState();
}

class _HeroBannerState extends State<HeroBanner> {
  late final PageController _controller;
  int _current = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted || widget.portals.isEmpty) return;
      _goTo((_current + 1) % widget.portals.length);
    });
  }

  void _goTo(int idx) {
    if (!mounted) return;
    _controller.animateToPage(idx,
        duration: const Duration(milliseconds: 380), curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.portals.isEmpty) return const SizedBox.shrink();
    final screenH = MediaQuery.sizeOf(context).height;
    final bannerH = (screenH * 0.26).clamp(170.0, 280.0);

    return SizedBox(
      height: bannerH,
      child: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: widget.portals.length,
            onPageChanged: (i) => setState(() => _current = i),
            itemBuilder: (_, i) => _BannerPage(
              portal: widget.portals[i],
              onOpen: () => widget.onOpen(widget.portals[i]),
            ),
          ),

          // Left arrow
          Positioned(
            left: 4,
            top: 0,
            bottom: 24,
            child: Center(
              child: _Arrow(
                icon: Icons.chevron_left_rounded,
                onTap: _current > 0
                    ? () { _timer?.cancel(); _goTo(_current - 1); _startTimer(); }
                    : null,
              ),
            ),
          ),

          // Right arrow
          Positioned(
            right: 4,
            top: 0,
            bottom: 24,
            child: Center(
              child: _Arrow(
                icon: Icons.chevron_right_rounded,
                onTap: _current < widget.portals.length - 1
                    ? () { _timer?.cancel(); _goTo(_current + 1); _startTimer(); }
                    : null,
              ),
            ),
          ),

          // Dot indicators
          Positioned(
            bottom: 8,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.portals.length, (i) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 280),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: _current == i ? 20 : 6,
                  height: 5,
                  decoration: BoxDecoration(
                    color: _current == i
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Single page ──────────────────────────────────────────────────────────────

class _BannerPage extends StatelessWidget {
  const _BannerPage({required this.portal, required this.onOpen});
  final Portal portal;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final isMovies = portal.category == PortalCategory.movies;

    return GestureDetector(
      onTap: onOpen,
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 6, 12, 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            colors: isMovies
                ? [const Color(0xFF4A00E0), const Color(0xFF00D2D3)]
                : [const Color(0xFF003F8A), const Color(0xFF00897B)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.22),
              blurRadius: 14,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: Stack(
          children: [
            // Subtle grid pattern
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: CustomPaint(painter: _GridPainter()),
              ),
            ),
            // Content pinned to bottom-left
            Positioned(
              left: 18,
              right: 60,
              bottom: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _CategoryChip(isMovies: isMovies),
                  const SizedBox(height: 5),
                  Text(
                    portal.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    portal.url,
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.65),
                        fontSize: 11),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  _OpenButton(onTap: onOpen),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.isMovies});
  final bool isMovies;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        isMovies ? '🎬 Movies' : '📺 Live TV',
        style: const TextStyle(
            color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _OpenButton extends StatelessWidget {
  const _OpenButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      child: FilledButton.icon(
        onPressed: onTap,
        icon: const Icon(Icons.play_arrow_rounded, size: 16),
        label: const Text('Open', style: TextStyle(fontSize: 12)),
        style: FilledButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}

class _Arrow extends StatelessWidget {
  const _Arrow({required this.icon, this.onTap});
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        opacity: onTap != null ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.32),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.04)
      ..strokeWidth = 1;
    const step = 30.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}
