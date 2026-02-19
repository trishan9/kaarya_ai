// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leaderboard_api_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LeaderboardEntryApiModel _$LeaderboardEntryApiModelFromJson(
        Map<String, dynamic> json) =>
    LeaderboardEntryApiModel(
      rank: json['rank'] as String,
      userId: json['userId'] as String,
      name: json['name'] as String,
      photo: json['photo'] as String?,
      xp: (json['xp'] as num).toInt(),
      score: (json['score'] as num?)?.toInt() ?? 0,
      kRank: (json['kRank'] as num?)?.toInt() ?? 0,
      level: json['level'] as String,
      college: json['college'] as String?,
      isCurrentUser: json['isCurrentUser'] as bool,
    );

Map<String, dynamic> _$LeaderboardEntryApiModelToJson(
        LeaderboardEntryApiModel instance) =>
    <String, dynamic>{
      'rank': instance.rank,
      'userId': instance.userId,
      'name': instance.name,
      'photo': instance.photo,
      'xp': instance.xp,
      'score': instance.score,
      'kRank': instance.kRank,
      'level': instance.level,
      'college': instance.college,
      'isCurrentUser': instance.isCurrentUser,
    };

LeaderboardApiModel _$LeaderboardApiModelFromJson(Map<String, dynamic> json) =>
    LeaderboardApiModel(
      entries: (json['entries'] as List<dynamic>)
          .map((e) =>
              LeaderboardEntryApiModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalEntries: (json['totalEntries'] as num).toInt(),
    );

Map<String, dynamic> _$LeaderboardApiModelToJson(
        LeaderboardApiModel instance) =>
    <String, dynamic>{
      'entries': instance.entries,
      'totalEntries': instance.totalEntries,
    };
