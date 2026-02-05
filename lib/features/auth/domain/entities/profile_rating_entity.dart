import 'package:equatable/equatable.dart';

class ProfileRatingEntity extends Equatable {
  final double overallScore;
  final String tier;
  final List<ProfileRatingSectionEntity> sections;

  const ProfileRatingEntity({
    required this.overallScore,
    required this.tier,
    this.sections = const [],
  });

  @override
  List<Object?> get props => [overallScore, tier, sections];
}

class ProfileRatingSectionEntity extends Equatable {
  final String name;
  final double score;
  final double maxScore;
  final List<ProfileRatingItemEntity> items;

  const ProfileRatingSectionEntity({
    required this.name,
    required this.score,
    required this.maxScore,
    this.items = const [],
  });

  @override
  List<Object?> get props => [name, score, maxScore];
}

class ProfileRatingItemEntity extends Equatable {
  final String label;
  final double points;
  final double maxPoints;
  final bool isCompleted;

  const ProfileRatingItemEntity({
    required this.label,
    required this.points,
    required this.maxPoints,
    required this.isCompleted,
  });

  @override
  List<Object?> get props => [label, points, isCompleted];
}
