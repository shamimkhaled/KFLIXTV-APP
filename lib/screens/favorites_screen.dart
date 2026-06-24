import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/portals.dart';
import '../models/portal.dart';
import '../providers/favorites_provider.dart';
import '../widgets/portal_card.dart';

/// Grid of all portals the user has favorited.
class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favoriteUrls = context.watch<FavoritesProvider>().favoriteUrls;
    final favoritePortals = kPortals
        .where((p) => favoriteUrls.contains(p.url))
        .toList(growable: false);

    return Scaffold(
      appBar: AppBar(title: const Text('Favorites')),
      body: favoritePortals.isEmpty
          ? const _NoFavorites()
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.78,
              ),
              itemCount: favoritePortals.length,
              itemBuilder: (context, index) {
                final portal = favoritePortals[index];
                return PortalCard(
                  portal: portal,
                  onOpen: () => _open(context, portal),
                );
              },
            ),
    );
  }

  void _open(BuildContext context, Portal portal) {
    context.push('/player', extra: portal);
  }
}

class _NoFavorites extends StatelessWidget {
  const _NoFavorites();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.favorite_border_rounded,
              size: 56,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 12),
            Text(
              'No favorites yet.\nTap the heart icon on any portal to save it here.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
