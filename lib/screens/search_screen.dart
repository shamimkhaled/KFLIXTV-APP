import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/portal.dart';
import '../providers/favorites_provider.dart';
import '../providers/portal_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/portal_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _ctrl.text.trim();
    final results = context.watch<PortalProvider>().search(query);
    final recents = context.watch<FavoritesProvider>().recentUrls;

    return Scaffold(
      backgroundColor: KColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Search bar ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: KColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.arrow_back_rounded,
                          color: KColors.textSecondary, size: 20),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      height: 46,
                      decoration: BoxDecoration(
                        color: KColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: _ctrl.text.isNotEmpty
                              ? KColors.primary
                              : KColors.borderSubtle,
                        ),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 12),
                          const Icon(Icons.search_rounded,
                              color: KColors.navSelected, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _ctrl,
                              autofocus: true,
                              style: const TextStyle(
                                  fontSize: 15, color: KColors.textPrimary),
                              decoration: const InputDecoration(
                                hintText: 'Search portals…',
                                hintStyle:
                                    TextStyle(color: KColors.textMuted),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                              ),
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                          if (_ctrl.text.isNotEmpty)
                            GestureDetector(
                              onTap: () => setState(_ctrl.clear),
                              child: const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                child: Icon(Icons.close_rounded,
                                    color: KColors.textMuted, size: 18),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            Expanded(
              child: query.isEmpty
                  ? _Hint(recentUrls: recents)
                  : results.isEmpty
                      ? const _NoResults()
                      : _Results(
                          results: results,
                          onOpen: (p) => context.push('/player', extra: p),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Hint (empty query) ───────────────────────────────────────────────────────

class _Hint extends StatelessWidget {
  const _Hint({required this.recentUrls});
  final List<String> recentUrls;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (recentUrls.isNotEmpty) ...[
            const Text('RECENT',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: KColors.textMuted,
                    letterSpacing: 0.5)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: recentUrls.take(6).map((url) {
                final name = url.split('/').where((s) => s.isNotEmpty).last;
                return GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 13, vertical: 7),
                    decoration: BoxDecoration(
                      color: KColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.history_rounded,
                            size: 13, color: KColors.textMuted),
                        const SizedBox(width: 5),
                        Text(name,
                            style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: KColors.textSecondary)),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ] else
            const Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.search_rounded,
                        size: 56, color: KColors.textMuted),
                    SizedBox(height: 12),
                    Text('Search by portal name or category',
                        style: TextStyle(color: KColors.textMuted)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Results ─────────────────────────────────────────────────────────────────

class _Results extends StatelessWidget {
  const _Results({required this.results, required this.onOpen});
  final List<Portal> results;
  final void Function(Portal) onOpen;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 11,
        crossAxisSpacing: 11,
        childAspectRatio: 0.75,
      ),
      itemCount: results.length,
      itemBuilder: (context, i) {
        final p = results[i];
        return PortalCard(portal: p, onOpen: () => onOpen(p));
      },
    );
  }
}

// ─── No results ───────────────────────────────────────────────────────────────

class _NoResults extends StatelessWidget {
  const _NoResults();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off_rounded, size: 56, color: KColors.textMuted),
          SizedBox(height: 12),
          Text('No portals match your search.',
              style: TextStyle(color: KColors.textMuted)),
        ],
      ),
    );
  }
}
