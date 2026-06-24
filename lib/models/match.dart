import 'package:flutter/foundation.dart';

enum MatchStatus { live, upcoming, completed }

enum MatchRound { groupStage, roundOf32, quarterFinal, semiFinal, final_ }

@immutable
class WorldCupMatch {
  const WorldCupMatch({
    required this.id,
    required this.team1,
    required this.team1Flag,
    required this.team2,
    required this.team2Flag,
    required this.kickoff,
    required this.status,
    required this.round,
    required this.group,
    required this.venue,
    required this.city,
    required this.streamServers,
    this.team1Score,
    this.team2Score,
    this.isFeatured = false,
    this.minute, // live clock string, e.g. "67'" or "HT"
  });

  final String id;
  final String team1;
  final String team1Flag;
  final String team2;
  final String team2Flag;
  final DateTime kickoff;
  final MatchStatus status;
  final MatchRound round;
  final String group;
  final String venue;
  final String city;
  final List<String> streamServers;
  final int? team1Score;
  final int? team2Score;
  final bool isFeatured;
  final String? minute;

  String get scoreDisplay =>
      (team1Score != null && team2Score != null) ? '$team1Score - $team2Score' : '';

  String get roundLabel {
    switch (round) {
      case MatchRound.groupStage:
        return group.isNotEmpty ? 'Group $group' : 'Group Stage';
      case MatchRound.roundOf32:
        return 'Round of 32';
      case MatchRound.quarterFinal:
        return 'Quarter Final';
      case MatchRound.semiFinal:
        return 'Semi Final';
      case MatchRound.final_:
        return 'Final';
    }
  }
}
