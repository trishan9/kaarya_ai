import 'package:json_annotation/json_annotation.dart';
import 'package:kaarya/core/utils/json_parse_helpers.dart';
import 'package:kaarya/features/leaderboard/domain/entities/leaderboard_entity.dart';

part 'leaderboard_api_model.g.dart';

@JsonSerializable()
class LeaderboardEntryApiModel {
  final String rank;
  final String userId;
  final String name;
  final String? photo;
  final int xp;
  final String level;
  final String? college;
  final bool isCurrentUser;

  const LeaderboardEntryApiModel({
    required this.rank,
    required this.userId,
    required this.name,
    required this.photo,
    required this.xp,
    required this.level,
    required this.college,
    required this.isCurrentUser,
  });

  factory LeaderboardEntryApiModel.fromJson(Map<String, dynamic> json) =>
      _$LeaderboardEntryApiModelFromJson(json);

  factory LeaderboardEntryApiModel.fromApiResponse(Map<String, dynamic> json) {
    final user = jsonAsMap(json['user']) ?? const <String, dynamic>{};
    final gamification =
        jsonAsMap(json['gamification']) ?? const <String, dynamic>{};
    final collegeData = jsonAsMap(json['college']);

    return LeaderboardEntryApiModel(
      rank: jsonString(json['rank']?.toString()),
      userId: jsonString(user['id']),
      name: jsonString(user['name'], fallback: 'Unknown'),
      photo: jsonNullableString(user['photo']),
      xp: jsonInt(gamification['xp']),
      level: jsonString(gamification['level'], fallback: 'Beginner'),
      college: jsonNullableString(collegeData?['name']),
      isCurrentUser: jsonBool(json['isCurrentUser']),
    );
  }

  Map<String, dynamic> toJson() => _$LeaderboardEntryApiModelToJson(this);

  LeaderboardEntryEntity toEntity() {
    return LeaderboardEntryEntity(
      rank: rank,
      userId: userId,
      name: name,
      photo: photo,
      xp: xp,
      level: level,
      college: college,
      isCurrentUser: isCurrentUser,
    );
  }

  static List<LeaderboardEntryApiModel> fromApiList(dynamic items) {
    if (items is! List) return const <LeaderboardEntryApiModel>[];
    return items
        .whereType<Map>()
        .map(
          (item) => LeaderboardEntryApiModel.fromApiResponse(jsonCastMap(item)),
        )
        .toList();
  }

  static List<LeaderboardEntryApiModel> fromCacheList(dynamic items) {
    if (items is! List) return const <LeaderboardEntryApiModel>[];
    return items
        .whereType<Map>()
        .map((item) => LeaderboardEntryApiModel.fromJson(jsonCastMap(item)))
        .toList();
  }
}

@JsonSerializable()
class LeaderboardApiModel {
  final List<LeaderboardEntryApiModel> entries;
  final int totalEntries;

  const LeaderboardApiModel({
    required this.entries,
    required this.totalEntries,
  });

  factory LeaderboardApiModel.fromJson(Map<String, dynamic> json) =>
      _$LeaderboardApiModelFromJson(json);

  factory LeaderboardApiModel.fromApiResponse(Map<String, dynamic> data) {
    final entries = LeaderboardEntryApiModel.fromApiList(data['data']);
    final meta = jsonAsMap(data['meta']) ?? const <String, dynamic>{};
    return LeaderboardApiModel(
      entries: entries,
      totalEntries: jsonInt(meta['total']),
    );
  }

  Map<String, dynamic> toJson() => _$LeaderboardApiModelToJson(this);

  LeaderboardEntity toEntity() {
    final entityEntries = entries.map((e) => e.toEntity()).toList();
    final currentUser = entityEntries
        .cast<LeaderboardEntryEntity?>()
        .firstWhere((e) => e!.isCurrentUser, orElse: () => null);

    return LeaderboardEntity(
      entries: entityEntries,
      totalEntries: totalEntries,
      currentUserEntry: currentUser,
    );
  }
}
