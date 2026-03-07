import 'package:equatable/equatable.dart';

class InterviewFeedbackEntity extends Equatable {
  final String sessionId;
  final String interviewTitle;
  final double? totalScore;
  final String? finalAssessment;
  final List<InterviewCategoryScoreEntity> categoryScores;
  final List<String> strengths;
  final List<String> areasForImprovement;
  final String? interviewId;
  final String? interviewLevel;
  final int? durationSeconds;

  const InterviewFeedbackEntity({
    required this.sessionId,
    required this.interviewTitle,
    required this.totalScore,
    required this.finalAssessment,
    required this.categoryScores,
    this.strengths = const [],
    this.areasForImprovement = const [],
    this.interviewId,
    this.interviewLevel,
    this.durationSeconds,
  });

  @override
  List<Object?> get props => [
    sessionId,
    interviewTitle,
    totalScore,
    finalAssessment,
    categoryScores,
    strengths,
    areasForImprovement,
    interviewId,
    interviewLevel,
    durationSeconds,
  ];
}

class InterviewCategoryScoreEntity extends Equatable {
  final String category;
  final double score;
  final String? feedback;

  const InterviewCategoryScoreEntity({
    required this.category,
    required this.score,
    required this.feedback,
  });

  @override
  List<Object?> get props => [category, score, feedback];
}
