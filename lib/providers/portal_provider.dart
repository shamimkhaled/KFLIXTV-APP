import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/portals.dart';
import '../models/portal.dart';
import '../services/portal_status_service.dart';

/// Category filter values shown as chips/tabs across the app.
enum PortalFilter {
  all,
  movies,
  liveTv,
  favorites,
}

/// Central source of truth for the portal catalogue: search query, category
/// filter, and live reachability status for each portal.
///
/// Favorites are intentionally *not* stored here - see [FavoritesProvider] -
/// but [filteredPortals] accepts the current favorite set so it can apply the
/// "Favorites" filter without a circular dependency.
class PortalProvider extends ChangeNotifier {
  PortalProvider(this._statusService) {
    _statusSubscription = _statusService.statusStream.listen((_) {
      notifyListeners();
    });
    refreshStatuses();
  }

  final PortalStatusService _statusService;
  late final StreamSubscription<Map<String, PortalReachability>>
      _statusSubscription;

  String _searchQuery = '';
  PortalFilter _filter = PortalFilter.all;

  String get searchQuery => _searchQuery;
  PortalFilter get filter => _filter;

  List<Portal> get allPortals => kPortals;

  List<Portal> get featuredPortals =>
      kPortals.where((p) => p.isFeatured).toList(growable: false);

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setFilter(PortalFilter filter) {
    if (filter == _filter) return;
    _filter = filter;
    notifyListeners();
  }

  PortalReachability statusFor(String url) => _statusService.statusFor(url);

  /// Returns the portals matching the current search query and category
  /// filter. [favoriteUrls] is required to evaluate [PortalFilter.favorites].
  List<Portal> filteredPortals(Set<String> favoriteUrls) {
    final query = _searchQuery.trim().toLowerCase();

    return kPortals.where((portal) {
      switch (_filter) {
        case PortalFilter.all:
          break;
        case PortalFilter.movies:
          if (portal.category != PortalCategory.movies) return false;
          break;
        case PortalFilter.liveTv:
          if (portal.category != PortalCategory.liveTv) return false;
          break;
        case PortalFilter.favorites:
          if (!favoriteUrls.contains(portal.url)) return false;
          break;
      }

      if (query.isEmpty) return true;

      return portal.name.toLowerCase().contains(query) ||
          portal.category.label.toLowerCase().contains(query);
    }).toList(growable: true)
      ..sort(_byStatus);
  }

  /// Searches across the *entire* catalogue regardless of the active
  /// category filter - used by the dedicated Search screen.
  List<Portal> search(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return const [];
    return kPortals
        .where((p) =>
            p.name.toLowerCase().contains(q) ||
            p.category.label.toLowerCase().contains(q))
        .toList(growable: true)
      ..sort(_byStatus);
  }

  // Online → Checking → Offline
  int _byStatus(Portal a, Portal b) =>
      _statusRank(_statusService.statusFor(a.url))
          .compareTo(_statusRank(_statusService.statusFor(b.url)));

  static int _statusRank(PortalReachability r) => switch (r) {
        PortalReachability.online => 0,
        PortalReachability.checking => 1,
        PortalReachability.offline => 2,
      };

  Future<void> refreshStatuses() => _statusService.checkAll(kPortals);

  Future<void> refreshStatus(Portal portal) =>
      _statusService.checkPortal(portal);

  @override
  void dispose() {
    _statusSubscription.cancel();
    super.dispose();
  }
}
