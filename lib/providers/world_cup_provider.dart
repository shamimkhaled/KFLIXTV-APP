import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/world_cup_data.dart';
import '../models/match.dart';
import '../models/portal.dart';
import '../services/match_service.dart';
import '../services/portal_status_service.dart';

class WorldCupProvider extends ChangeNotifier {
  WorldCupProvider(this._statusService, this._matchService) {
    _statusSub = _statusService.statusStream.listen((_) => notifyListeners());
    fetchMatches();
    _checkServerStatuses();
  }

  final PortalStatusService _statusService;
  final MatchService _matchService;
  late final StreamSubscription<dynamic> _statusSub;
  Timer? _liveRefreshTimer;

  List<WorldCupMatch> _matches = kWorldCupMatches;
  bool _loading = false;
  String? _error;
  final Map<String, int> _selectedServerIndex = {};

  bool get loading => _loading;
  String? get error => _error;

  List<WorldCupMatch> get liveMatches =>
      _matches.where((m) => m.status == MatchStatus.live).toList();

  List<WorldCupMatch> get upcomingMatches =>
      _matches.where((m) => m.status == MatchStatus.upcoming).toList();

  List<WorldCupMatch> get completedMatches =>
      _matches.where((m) => m.status == MatchStatus.completed).toList();

  List<WorldCupMatch> get featuredMatches =>
      _matches.where((m) => m.isFeatured).toList();

  // ── Fetch ────────────────────────────────────────────────────────────────

  Future<void> fetchMatches() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final fetched = await _matchService.fetchMatches();
      _matches = fetched;
      _error = null;
    } catch (e) {
      _error = 'Could not load live data — showing cached matches.';
    } finally {
      _loading = false;
      notifyListeners();
    }

    _scheduleLiveRefresh();
  }

  // Auto-refresh every 60 s while there are live matches
  void _scheduleLiveRefresh() {
    _liveRefreshTimer?.cancel();
    if (liveMatches.isNotEmpty) {
      _liveRefreshTimer =
          Timer(const Duration(seconds: 60), fetchMatches);
    }
  }

  // ── Server selection ─────────────────────────────────────────────────────

  int selectedServerIndex(String matchId) =>
      _selectedServerIndex[matchId] ?? 0;

  String selectedServerUrl(WorldCupMatch match) {
    if (match.streamServers.isEmpty) return '';
    final idx = selectedServerIndex(match.id)
        .clamp(0, match.streamServers.length - 1);
    return match.streamServers[idx];
  }

  void selectServer(String matchId, int index) {
    _selectedServerIndex[matchId] = index;
    notifyListeners();
  }

  // ── Server status ─────────────────────────────────────────────────────────

  PortalReachability serverStatus(String url) =>
      _statusService.statusFor(url);

  void refreshServerStatuses() => _checkServerStatuses();

  void _checkServerStatuses() {
    final portals = kWcServers
        .map((url) => Portal(
              name: url,
              url: url,
              category: PortalCategory.liveTv,
            ))
        .toList();
    _statusService.checkAll(portals);
  }

  @override
  void dispose() {
    _statusSub.cancel();
    _liveRefreshTimer?.cancel();
    super.dispose();
  }
}
