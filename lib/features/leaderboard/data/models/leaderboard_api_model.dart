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
  @JsonKey(defaultValue: 0)
  final int score;
  @JsonKey(defaultValue: 0)
  final int kRank;
  final String level;
  final String? college;
  final bool isCurrentUser;

  const LeaderboardEntryApiModel({
    required this.rank,
    required this.userId,
    required this.name,
    required this.photo,
    required this.xp,
    this.score = 0,
    this.kRank = 0,
    required this.level,
    required this.college,
    required this.isCurrentUser,
  });

  factory LeaderboardEntryApiModel.fromJson(Map<String, dynamic> json) =>
      _$LeaderboardEntryApiModelFromJson(json);

  factory LeaderboardEntryApiModel.fromApiResponse(
    Map<String, dynamic> json, {
    bool isCurrentUser = false,
  }) {
    final student = jsonAsMap(json['student']) ?? const <String, dynamic>{};
    final xp = jsonInt(json['xp']);
    final apiLevelRaw = json['level'];
    final apiLevel = apiLevelRaw != null ? jsonInt(apiLevelRaw) : 0;
    final levelStr = apiLevel > 0 ? '$apiLevel' : '${(xp ~/ 250) + 1}';

    return LeaderboardEntryApiModel(
      rank: jsonString(json['rank']?.toString()),
      userId: jsonString(student['id']),
      name: jsonString(student['name'], fallback: 'Unknown'),
      photo: jsonNullableString(student['photo']),
      xp: xp,
      score: jsonInt(json['score']),
      kRank: jsonInt(json['total']),
      level: levelStr,
      college: null,
      isCurrentUser: isCurrentUser || jsonBool(json['isCurrentUser']),
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
      score: score,
      kRank: kRank,
      level: level,
      college: college,
      isCurrentUser: isCurrentUser,
    );
  }

  static List<LeaderboardEntryApiModel> fromApiList(
    dynamic items, {
    String currentUserId = '',
  }) {
    if (items is! List) return const <LeaderboardEntryApiModel>[];
    return items.whereType<Map>().map((item) {
      final map = jsonCastMap(item);
      final student = jsonAsMap(map['student']) ?? const <String, dynamic>{};
      final studentId = jsonString(student['id']);
      return LeaderboardEntryApiModel.fromApiResponse(
        map,
        isCurrentUser:
            currentUserId.isNotEmpty && studentId == currentUserId,
      );
    }).toList();
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
    // Extract current user ID from 'me' to mark the matching row
    final meMap = jsonAsMap(data['me']);
    String currentUserId = '';

    if (meMap != null) {
      final meStudent =
          jsonAsMap(meMap['student']) ?? const <String, dynamic>{};
      currentUserId = jsonString(meStudent['id']);
    }

    final entries = LeaderboardEntryApiModel.fromApiList(
      data['rows'],
      currentUserId: currentUserId,
    );

    final meta = jsonAsMap(data['meta']) ?? const <String, dynamic>{};
    return LeaderboardApiModel(
      entries: entries,
      totalEntries: jsonInt(meta['totalItems']),
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
