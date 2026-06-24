import 'package:flutter/foundation.dart';

import '../services/storage_service.dart';

/// Tracks favorite portals and recently opened portals (by URL), persisting
/// both to local storage via [StorageService].
class FavoritesProvider extends ChangeNotifier {
  FavoritesProvider(this._storage) {
    _load();
  }

  final StorageService _storage;

  final Set<String> _favoriteUrls = {};
  final List<String> _recentUrls = [];

  bool _loaded = false;
  bool get isLoaded => _loaded;

  Set<String> get favoriteUrls => Set.unmodifiable(_favoriteUrls);
  List<String> get recentUrls => List.unmodifiable(_recentUrls);

  bool isFavorite(String url) => _favoriteUrls.contains(url);

  Future<void> _load() async {
    final favorites = await _storage.loadFavorites();
    final recent = await _storage.loadRecent();
    _favoriteUrls.addAll(favorites);
    _recentUrls.addAll(recent);
    _loaded = true;
    notifyListeners();
  }

  Future<void> toggleFavorite(String url) async {
    if (_favoriteUrls.contains(url)) {
      _favoriteUrls.remove(url);
    } else {
      _favoriteUrls.add(url);
    }
    notifyListeners();
    await _storage.saveFavorites(_favoriteUrls);
  }

  Future<void> clearFavorites() async {
    if (_favoriteUrls.isEmpty) return;
    _favoriteUrls.clear();
    notifyListeners();
    await _storage.saveFavorites(_favoriteUrls);
  }

  Future<void> addRecent(String url) async {
    _recentUrls.remove(url);
    _recentUrls.insert(0, url);
    if (_recentUrls.length > StorageService.maxRecent) {
      _recentUrls.removeRange(StorageService.maxRecent, _recentUrls.length);
    }
    notifyListeners();
    await _storage.saveRecent(_recentUrls);
  }

  Future<void> clearRecent() async {
    if (_recentUrls.isEmpty) return;
    _recentUrls.clear();
    notifyListeners();
    await _storage.saveRecent(_recentUrls);
  }
}
