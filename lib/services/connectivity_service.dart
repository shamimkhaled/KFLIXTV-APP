import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

/// Tracks whether the device currently has *any* network connection
/// (Wi-Fi, mobile data, ethernet, etc.) so the UI can show a global
/// online/offline banner.
///
/// This does not guarantee a portal is reachable - it only reflects the
/// device's own network state.
class ConnectivityService extends ChangeNotifier {
  ConnectivityService({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity() {
    _init();
  }

  final Connectivity _connectivity;
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  bool _isOnline = true;
  bool get isOnline => _isOnline;

  Future<void> _init() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _applyResults(results);
    } catch (_) {
      // If the platform check fails, assume online so we don't block the UI.
    }

    _subscription = _connectivity.onConnectivityChanged.listen(_applyResults);
  }

  void _applyResults(List<ConnectivityResult> results) {
    final online = results.any((r) => r != ConnectivityResult.none);
    if (online != _isOnline) {
      _isOnline = online;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
