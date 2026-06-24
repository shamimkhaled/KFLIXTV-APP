import 'package:flutter/material.dart';

import '../services/storage_service.dart';

/// Holds the app's current [ThemeMode] and persists changes via
/// [StorageService]. Defaults to dark mode until a saved preference loads.
class ThemeProvider extends ChangeNotifier {
  ThemeProvider(this._storage) {
    _load();
  }

  final StorageService _storage;

  ThemeMode _themeMode = ThemeMode.dark;
  ThemeMode get themeMode => _themeMode;

  Future<void> _load() async {
    _themeMode = await _storage.loadThemeMode();
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (mode == _themeMode) return;
    _themeMode = mode;
    notifyListeners();
    await _storage.saveThemeMode(mode);
  }
}
