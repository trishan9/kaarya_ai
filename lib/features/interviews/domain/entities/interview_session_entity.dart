import 'package:equatable/equatable.dart';

class InterviewSessionStartEntity extends Equatable {
  final String sessionId;
  final String? interviewId;

  const InterviewSessionStartEntity({
    required this.sessionId,
    required this.interviewId,
  });

  @override
  List<Object?> get props => [sessionId, interviewId];
}

class InterviewSessionEntity extends Equatable {
  final String id;
  final String interviewId;
  final String userId;
  final String status;
  final int durationSeconds;
  final double? totalScore;
  final String createdAt;

  const InterviewSessionEntity({
    required this.id,
    required this.interviewId,
    required this.userId,
    required this.status,
    required this.durationSeconds,
    required this.totalScore,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    interviewId,
    userId,
    status,
    durationSeconds,
    totalScore,
    createdAt,
  ];
}
