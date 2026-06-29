import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/portal_provider.dart';
import '../utils/app_theme.dart';

class CategoryTabs extends StatelessWidget {
  const CategoryTabs({super.key});

  static const _options = [
    (PortalFilter.all, 'All'),
    (PortalFilter.movies, 'Movies'),
    (PortalFilter.liveTv, 'Live TV'),
    (PortalFilter.favorites, 'Favorites'),
  ];

  @override
  Widget build(BuildContext context) {
    final active = context.watch<PortalProvider>().filter;

    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _options.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final (filter, label) = _options[i];
          final selected = filter == active;

          return GestureDetector(
            onTap: () => context.read<PortalProvider>().setFilter(filter),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                gradient: selected
                    ? const LinearGradient(
                        colors: KColors.brandGradient,
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      )
                    : null,
                color: selected ? null : KColors.surfaceVariant,
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                  color: selected ? Colors.white : KColors.textSecondary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
