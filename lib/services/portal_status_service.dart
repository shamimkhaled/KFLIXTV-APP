import 'dart:async';

import 'package:http/http.dart' as http;

import '../models/portal.dart';

/// Performs best-effort, non-blocking reachability checks for each portal.
///
/// Results are cached in memory and broadcast via [statusStream] so that any
/// number of widgets (grid cards, favorites, etc.) can reflect the latest
/// known status without re-triggering network calls themselves.
class PortalStatusService {
  PortalStatusService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  static const Duration _timeout = Duration(seconds: 5);

  final Map<String, PortalReachability> _statuses = {};
  final StreamController<Map<String, PortalReachability>> _controller =
      StreamController<Map<String, PortalReachability>>.broadcast();

  /// Snapshot of the latest known status for every portal checked so far.
  Map<String, PortalReachability> get statuses => Map.unmodifiable(_statuses);

  /// Emits a full snapshot of [statuses] whenever any portal's status changes.
  Stream<Map<String, PortalReachability>> get statusStream => _controller.stream;

  PortalReachability statusFor(String url) =>
      _statuses[url] ?? PortalReachability.checking;

  /// Kicks off reachability checks for every portal, in parallel.
  Future<void> checkAll(List<Portal> portals) async {
    await Future.wait(portals.map(checkPortal));
  }

  /// Checks a single portal and updates [statuses] + [statusStream].
  Future<void> checkPortal(Portal portal) async {
    _update(portal.url, PortalReachability.checking);

    var reachable = false;
    try {
      final uri = Uri.parse(portal.url);
      final response = await _client.get(uri).timeout(_timeout);
      // Treat anything below 500 (including redirects, 401, 403 etc.) as
      // "the server is alive" - we only care about reachability, not auth.
      reachable = response.statusCode < 500;
    } catch (_) {
      reachable = false;
    }

    _update(
      portal.url,
      reachable ? PortalReachability.online : PortalReachability.offline,
    );
  }

  void _update(String url, PortalReachability status) {
    _statuses[url] = status;
    if (!_controller.isClosed) {
      _controller.add(statuses);
    }
  }

  void dispose() {
    _controller.close();
    _client.close();
  }
}
