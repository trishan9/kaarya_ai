import 'package:equatable/equatable.dart';
import 'package:kaarya/features/interviews/domain/entities/interview_entity.dart';

class InterviewsSectionEntity extends Equatable {
  final List<InterviewEntity> forYou;
  final List<InterviewEntity> trending;
  final List<InterviewEntity> newThisWeek;
  final List<InterviewEntity> allTimePopular;
  final List<InterviewEntity> byYou;
  final List<InterviewEntity> all;
  final List<InterviewEntity> createdByMe;
  final List<InterviewEntity> takenByMe;
  final List<InterviewEntity> drafts;
  final double averageScore;
  final String? lastUpdatedAt;

  const InterviewsSectionEntity({
    required this.forYou,
    required this.trending,
    required this.newThisWeek,
    required this.allTimePopular,
    required this.byYou,
    required this.all,
    required this.createdByMe,
    required this.takenByMe,
    required this.drafts,
    required this.averageScore,
    required this.lastUpdatedAt,
  });

  @override
  List<Object?> get props => [
    forYou,
    trending,
    newThisWeek,
    allTimePopular,
    byYou,
    all,
    createdByMe,
    takenByMe,
    drafts,
    averageScore,
    lastUpdatedAt,
  ];
}
