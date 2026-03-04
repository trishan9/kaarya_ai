import 'package:equatable/equatable.dart';

class InterviewFeedbackEntity extends Equatable {
  final String sessionId;
  final String interviewTitle;
  final double? totalScore;
  final String? finalAssessment;
  final List<InterviewCategoryScoreEntity> categoryScores;

  const InterviewFeedbackEntity({
    required this.sessionId,
    required this.interviewTitle,
    required this.totalScore,
    required this.finalAssessment,
    required this.categoryScores,
  });

  @override
  List<Object?> get props => [
    sessionId,
    interviewTitle,
    totalScore,
    finalAssessment,
    categoryScores,
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
