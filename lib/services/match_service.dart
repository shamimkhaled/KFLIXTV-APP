import 'dart:convert';

import 'package:http/http.dart' as http;

import '../data/world_cup_data.dart';
import '../models/match.dart';
import '../utils/country_flags.dart';

/// Fetches FIFA World Cup 2026 match data from the ESPN public API.
/// No API key required. Falls back to static data on any error.
class MatchService {
  MatchService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const _timeout = Duration(seconds: 12);

  // ESPN public soccer API — no auth needed
  static const _baseUrl =
      'https://site.api.espn.com/apis/site/v2/sports/soccer/fifa.world';

  // Teams whose matches are always featured
  static const _featuredTeams = {
    'Argentina', 'Brazil', 'France', 'England',
    'Spain', 'Germany', 'Portugal', 'Netherlands',
  };

  /// Returns all WC 2026 matches (group stage through final).
  /// Falls back to [kWorldCupMatches] if the network request fails.
  Future<List<WorldCupMatch>> fetchMatches() async {
    try {
      // Fetch the full tournament window in one request
      const start = '20260611';
      const end = '20260719';
      final uri = Uri.parse('$_baseUrl/scoreboard?dates=$start-$end&limit=200');

      final response = await _client
          .get(uri, headers: {'Accept': 'application/json'})
          .timeout(_timeout);

      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}');
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final events = body['events'] as List<dynamic>? ?? [];

      if (events.isEmpty) return kWorldCupMatches;

      final parsed = events
          .map((e) => _parseEvent(e as Map<String, dynamic>))
          .whereType<WorldCupMatch>()
          .toList();

      return parsed.isNotEmpty ? parsed : kWorldCupMatches;
    } catch (_) {
      // Network unavailable or unexpected response — use bundled data
      return kWorldCupMatches;
    }
  }

  WorldCupMatch? _parseEvent(Map<String, dynamic> event) {
    try {
      final competitions = event['competitions'] as List?;
      if (competitions == null || competitions.isEmpty) return null;

      final comp = competitions[0] as Map<String, dynamic>;
      final competitors = (comp['competitors'] as List<dynamic>)
          .cast<Map<String, dynamic>>();
      final statusMap = comp['status'] as Map<String, dynamic>;
      final statusType = statusMap['type'] as Map<String, dynamic>;

      // Sort by 'order' so team1=home, team2=away
      final sorted = [...competitors]
        ..sort((a, b) =>
            ((a['order'] as num?) ?? 0)
                .compareTo((b['order'] as num?) ?? 0));

      final t1 = sorted[0];
      final t2 = sorted[1];
      final t1Team = t1['team'] as Map<String, dynamic>;
      final t2Team = t2['team'] as Map<String, dynamic>;

      final team1Name = t1Team['displayName'] as String? ?? '';
      final team2Name = t2Team['displayName'] as String? ?? '';

      // Status
      final state = (statusType['state'] as String?)?.toLowerCase() ?? 'pre';
      final matchStatus = switch (state) {
        'in' => MatchStatus.live,
        'post' => MatchStatus.completed,
        _ => MatchStatus.upcoming,
      };

      // Scores (only meaningful when not upcoming)
      int? team1Score, team2Score;
      if (matchStatus != MatchStatus.upcoming) {
        team1Score = int.tryParse(t1['score']?.toString() ?? '');
        team2Score = int.tryParse(t2['score']?.toString() ?? '');
      }

      // Live clock display ("45'", "67'", "HT", etc.)
      final minute = matchStatus == MatchStatus.live
          ? statusMap['displayClock'] as String?
          : null;

      // Venue
      final venue = comp['venue'] as Map<String, dynamic>?;
      final venueName = venue?['fullName'] as String? ?? '';
      final address = venue?['address'] as Map<String, dynamic>?;
      final city = address?['city'] as String? ?? '';

      // Kickoff (UTC → local)
      final dateStr =
          (comp['date'] ?? event['date']) as String? ?? '';
      final kickoff =
          dateStr.isNotEmpty ? DateTime.parse(dateStr).toLocal() : DateTime.now();

      // Round / group from competition notes
      final notes = (comp['notes'] as List<dynamic>?)
          ?.cast<Map<String, dynamic>>();
      String group = '';
      MatchRound round = MatchRound.groupStage;

      if (notes != null && notes.isNotEmpty) {
        final headline =
            (notes[0]['headline'] as String?)?.toLowerCase() ?? '';
        final groupMatch = RegExp(r'group ([a-z])').firstMatch(headline);
        if (groupMatch != null) {
          group = groupMatch.group(1)!.toUpperCase();
          round = MatchRound.groupStage;
        } else if (headline.contains('round of 32')) {
          round = MatchRound.roundOf32;
        } else if (headline.contains('quarter')) {
          round = MatchRound.quarterFinal;
        } else if (headline.contains('semi')) {
          round = MatchRound.semiFinal;
        } else if (headline.contains('final')) {
          round = MatchRound.final_;
        }
      }

      final isFeatured = _featuredTeams.contains(team1Name) ||
          _featuredTeams.contains(team2Name);

      return WorldCupMatch(
        id: event['id']?.toString() ??
            '${team1Name}_${team2Name}_${kickoff.millisecondsSinceEpoch}',
        team1: team1Name,
        team1Flag: flagFor(team1Name),
        team2: team2Name,
        team2Flag: flagFor(team2Name),
        kickoff: kickoff,
        status: matchStatus,
        round: round,
        group: group,
        venue: venueName,
        city: city,
        streamServers: kWcServers,
        team1Score: team1Score,
        team2Score: team2Score,
        isFeatured: isFeatured,
        minute: minute,
      );
    } catch (_) {
      return null;
    }
  }
}
