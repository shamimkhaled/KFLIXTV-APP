import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/portal.dart';
import '../utils/app_theme.dart';

/// Auto-rotating hero banner matching the KFLIX TV mockup.
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
        duration: const Duration(milliseconds: 350), curve: Curves.easeInOut);
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
    final h = (MediaQuery.sizeOf(context).height * 0.26).clamp(160.0, 260.0);

    return SizedBox(
      height: h,
      child: Stack(
        children: [
          // Pages
          PageView.builder(
            controller: _controller,
            itemCount: widget.portals.length,
            onPageChanged: (i) => setState(() => _current = i),
            itemBuilder: (_, i) => _BannerPage(
              portal: widget.portals[i],
              onOpen: () {
                _timer?.cancel();
                widget.onOpen(widget.portals[i]);
              },
            ),
          ),

          // Left arrow
          Positioned(
            left: 6,
            top: 0,
            bottom: 22,
            child: Center(
              child: _Arrow(
                icon: Icons.chevron_left_rounded,
                onTap: _current > 0
                    ? () {
                        _timer?.cancel();
                        _goTo(_current - 1);
                        _startTimer();
                      }
                    : null,
              ),
            ),
          ),

          // Right arrow
          Positioned(
            right: 6,
            top: 0,
            bottom: 22,
            child: Center(
              child: _Arrow(
                icon: Icons.chevron_right_rounded,
                onTap: _current < widget.portals.length - 1
                    ? () {
                        _timer?.cancel();
                        _goTo(_current + 1);
                        _startTimer();
                      }
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
                  duration: const Duration(milliseconds: 260),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: _current == i ? 20 : 6,
                  height: 5,
                  decoration: BoxDecoration(
                    color: _current == i
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.35),
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
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 22),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: isMovies
                ? const [Color(0xFF4A1E96), Color(0xFF00B4D8)]
                : const [Color(0xFF003F8A), Color(0xFF00897B)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Grid overlay
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: CustomPaint(painter: _GridPainter()),
              ),
            ),
            // LIVE badge top-right
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: isMovies ? KColors.primary : KColors.liveRed,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                          color: Colors.white, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      isMovies ? 'MOVIES' : 'LIVE TV',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ),
            // Content bottom
            Positioned(
              left: 16,
              right: 60,
              bottom: 14,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    portal.name,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 21,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    portal.url,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withValues(alpha: 0.65),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 36,
                    child: FilledButton.icon(
                      onPressed: onOpen,
                      icon: const Icon(Icons.play_arrow_rounded, size: 16),
                      label: const Text('Play', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black87,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
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
        opacity: onTap != null ? 1 : 0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.35),
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
    final p = Paint()
      ..color = Colors.white.withValues(alpha: 0.04)
      ..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 30) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
    }
    for (double y = 0; y < size.height; y += 30) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}
