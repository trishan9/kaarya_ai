import 'package:equatable/equatable.dart';

class InterviewAnalyticsEntity extends Equatable {
  final int totalSessions;
  final double completionRate;
  final double averageScore;
  final List<InterviewScoreDistributionEntity> scoreDistribution;

  const InterviewAnalyticsEntity({
    required this.totalSessions,
    required this.completionRate,
    required this.averageScore,
    required this.scoreDistribution,
  });

  @override
  List<Object?> get props => [
    totalSessions,
    completionRate,
    averageScore,
    scoreDistribution,
  ];
}

class InterviewScoreDistributionEntity extends Equatable {
  final String range;
  final int count;

  const InterviewScoreDistributionEntity({
    required this.range,
    required this.count,
  });

  @override
  List<Object?> get props => [range, count];
}
