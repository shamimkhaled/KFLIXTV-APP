import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Thin wrapper around [SharedPreferences] used to persist user
/// preferences (theme, favorites, recently opened portals) on-device.
///
/// There is no backend or database involved - everything lives in the
/// app's local key/value store.
class StorageService {
  static const _favoritesKey = 'kloud_tv.favorites';
  static const _recentKey = 'kloud_tv.recent_portals';
  static const _themeModeKey = 'kloud_tv.theme_mode';

  static const int maxRecent = 10;

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  // ---------------------------------------------------------------------
  // Favorites
  // ---------------------------------------------------------------------

  Future<Set<String>> loadFavorites() async {
    final prefs = await _prefs;
    return (prefs.getStringList(_favoritesKey) ?? const []).toSet();
  }

  Future<void> saveFavorites(Set<String> portalUrls) async {
    final prefs = await _prefs;
    await prefs.setStringList(_favoritesKey, portalUrls.toList());
  }

  // ---------------------------------------------------------------------
  // Recently opened
  // ---------------------------------------------------------------------

  Future<List<String>> loadRecent() async {
    final prefs = await _prefs;
    return prefs.getStringList(_recentKey) ?? const [];
  }

  Future<void> saveRecent(List<String> portalUrls) async {
    final prefs = await _prefs;
    final trimmed = portalUrls.take(maxRecent).toList();
    await prefs.setStringList(_recentKey, trimmed);
  }

  // ---------------------------------------------------------------------
  // Theme
  // ---------------------------------------------------------------------

  Future<ThemeMode> loadThemeMode() async {
    final prefs = await _prefs;
    final value = prefs.getString(_themeModeKey);
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'system':
        return ThemeMode.system;
      case 'dark':
      default:
        return ThemeMode.dark;
    }
  }

  Future<void> saveThemeMode(ThemeMode mode) async {
    final prefs = await _prefs;
    await prefs.setString(_themeModeKey, mode.name);
  }
}
