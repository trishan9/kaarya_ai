import 'package:equatable/equatable.dart';

class LeaderboardEntryEntity extends Equatable {
  final String rank;
  final String userId;
  final String name;
  final String? photo;
  final int xp;
  final int score;
  final int kRank;
  final String level;
  final String? college;
  final bool isCurrentUser;

  const LeaderboardEntryEntity({
    required this.rank,
    required this.userId,
    required this.name,
    this.photo,
    required this.xp,
    this.score = 0,
    this.kRank = 0,
    required this.level,
    this.college,
    required this.isCurrentUser,
  });

  @override
  List<Object?> get props => [rank, userId, xp, score, kRank];
}

class LeaderboardEntity extends Equatable {
  final List<LeaderboardEntryEntity> entries;
  final int totalEntries;
  final LeaderboardEntryEntity? currentUserEntry;

  const LeaderboardEntity({
    required this.entries,
    required this.totalEntries,
    this.currentUserEntry,
  });

  @override
  List<Object?> get props => [entries, totalEntries];
}
