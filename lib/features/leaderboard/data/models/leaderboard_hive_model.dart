import 'package:hive/hive.dart';
import 'package:kaarya/core/constants/hive_table_constant.dart';
import 'package:kaarya/features/leaderboard/data/models/leaderboard_api_model.dart';

part 'leaderboard_hive_model.g.dart';

@HiveType(typeId: HiveTableConstant.leaderboardEntryHiveTypeId)
class LeaderboardEntryHiveModel extends HiveObject {
  @HiveField(0)
  final String rank;

  @HiveField(1)
  final String userId;

  @HiveField(2)
  final String name;

  @HiveField(3)
  final String? photo;

  @HiveField(4)
  final int xp;

  @HiveField(5)
  final String level;

  @HiveField(6)
  final String? college;

  @HiveField(7)
  final bool isCurrentUser;

  @HiveField(8)
  final int score;

  @HiveField(9)
  final int kRank;

  LeaderboardEntryHiveModel({
    required this.rank,
    required this.userId,
    required this.name,
    this.photo,
    required this.xp,
    required this.level,
    this.college,
    required this.isCurrentUser,
    this.score = 0,
    this.kRank = 0,
  });

  factory LeaderboardEntryHiveModel.fromApiModel(
    LeaderboardEntryApiModel model,
  ) => LeaderboardEntryHiveModel(
    rank: model.rank,
    userId: model.userId,
    name: model.name,
    photo: model.photo,
    xp: model.xp,
    level: model.level,
    college: model.college,
    isCurrentUser: model.isCurrentUser,
    score: model.score,
    kRank: model.kRank,
  );

  LeaderboardEntryApiModel toApiModel() => LeaderboardEntryApiModel(
    rank: rank,
    userId: userId,
    name: name,
    photo: photo,
    xp: xp,
    score: score,
    kRank: kRank,
    level: level,
    college: college,
    isCurrentUser: isCurrentUser,
  );
}

@HiveType(typeId: HiveTableConstant.leaderboardHiveTypeId)
class LeaderboardHiveModel extends HiveObject {
  @HiveField(0)
  final List<LeaderboardEntryHiveModel> entries;

  @HiveField(1)
  final int totalEntries;

  LeaderboardHiveModel({required this.entries, required this.totalEntries});

  factory LeaderboardHiveModel.fromApiModel(LeaderboardApiModel model) =>
      LeaderboardHiveModel(
        entries: model.entries
            .map(LeaderboardEntryHiveModel.fromApiModel)
            .toList(),
        totalEntries: model.totalEntries,
      );

  LeaderboardApiModel toApiModel() => LeaderboardApiModel(
    entries: entries.map((e) => e.toApiModel()).toList(),
    totalEntries: totalEntries,
  );
}
