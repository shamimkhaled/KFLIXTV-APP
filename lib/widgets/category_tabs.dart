import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/portal_provider.dart';

/// Horizontal row of filter chips: All, Movies, Live TV, Favorites.
class CategoryTabs extends StatelessWidget {
  const CategoryTabs({super.key});

  static const _options = [
    (PortalFilter.all, 'All', Icons.apps_rounded),
    (PortalFilter.movies, 'Movies', Icons.movie_rounded),
    (PortalFilter.liveTv, 'Live TV', Icons.live_tv_rounded),
    (PortalFilter.favorites, 'Favorites', Icons.favorite_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    final activeFilter = context.watch<PortalProvider>().filter;

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _options.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final (filter, label, icon) = _options[index];
          final selected = filter == activeFilter;

          return ChoiceChip(
            selected: selected,
            avatar: Icon(
              icon,
              size: 18,
              color: selected
                  ? Theme.of(context).colorScheme.onPrimary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            label: Text(label),
            onSelected: (_) =>
                context.read<PortalProvider>().setFilter(filter),
          );
        },
      ),
    );
  }
}
