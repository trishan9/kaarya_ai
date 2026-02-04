import 'package:kaarya/core/utils/json_parse_helpers.dart';
import 'package:kaarya/features/auth/domain/entities/profile_rating_entity.dart';

class ProfileRatingApiModel {
  final double overallScore;
  final String tier;
  final List<ProfileRatingSectionApiModel> sections;

  const ProfileRatingApiModel({
    required this.overallScore,
    required this.tier,
    required this.sections,
  });

  factory ProfileRatingApiModel.fromJson(Map<String, dynamic> json) {
    return ProfileRatingApiModel(
      overallScore: jsonDouble(json['overallScore']),
      tier: jsonString(json['tier']),
      sections: (json['sections'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(ProfileRatingSectionApiModel.fromJson)
          .toList(),
    );
  }

  ProfileRatingEntity toEntity() => ProfileRatingEntity(
    overallScore: overallScore,
    tier: tier,
    sections: sections.map((s) => s.toEntity()).toList(),
  );
}

class ProfileRatingSectionApiModel {
  final String name;
  final double score;
  final double maxScore;
  final List<ProfileRatingItemApiModel> items;

  const ProfileRatingSectionApiModel({
    required this.name,
    required this.score,
    required this.maxScore,
    required this.items,
  });

  factory ProfileRatingSectionApiModel.fromJson(Map<String, dynamic> json) {
    return ProfileRatingSectionApiModel(
      name: jsonString(json['name']),
      score: jsonDouble(json['score']),
      maxScore: jsonDouble(json['maxScore']),
      items: (json['items'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(ProfileRatingItemApiModel.fromJson)
          .toList(),
    );
  }

  ProfileRatingSectionEntity toEntity() => ProfileRatingSectionEntity(
    name: name,
    score: score,
    maxScore: maxScore,
    items: items.map((i) => i.toEntity()).toList(),
  );
}

class ProfileRatingItemApiModel {
  final String label;
  final double points;
  final double maxPoints;
  final bool isCompleted;

  const ProfileRatingItemApiModel({
    required this.label,
    required this.points,
    required this.maxPoints,
    required this.isCompleted,
  });

  factory ProfileRatingItemApiModel.fromJson(Map<String, dynamic> json) {
    return ProfileRatingItemApiModel(
      label: jsonString(json['label']),
      points: jsonDouble(json['points']),
      maxPoints: jsonDouble(json['maxPoints']),
      isCompleted: jsonBool(json['completed']),
    );
  }

  ProfileRatingItemEntity toEntity() => ProfileRatingItemEntity(
    label: label,
    points: points,
    maxPoints: maxPoints,
    isCompleted: isCompleted,
  );
}
