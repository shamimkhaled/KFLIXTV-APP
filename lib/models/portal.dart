import 'package:flutter/foundation.dart';

/// Top-level categories used for filtering and grouping portals.
enum PortalCategory {
  movies,
  liveTv,
}

extension PortalCategoryLabel on PortalCategory {
  String get label {
    switch (this) {
      case PortalCategory.movies:
        return 'Movies';
      case PortalCategory.liveTv:
        return 'Live TV';
    }
  }
}

/// Reachability state for a portal, refreshed asynchronously in the background.
enum PortalReachability {
  checking,
  online,
  offline,
}

/// Static description of a single ISP/FTP/IPTV portal.
@immutable
class Portal {
  final String name;
  final String url;
  final PortalCategory category;

  /// Featured portals are highlighted in the "Featured" section on Home.
  final bool isFeatured;

  const Portal({
    required this.name,
    required this.url,
    required this.category,
    this.isFeatured = false,
  });

  /// Stable identity used for favorites/recents persistence.
  String get id => url;

  @override
  bool operator ==(Object other) =>
      other is Portal && other.url == url && other.name == name;

  @override
  int get hashCode => Object.hash(name, url);
}
