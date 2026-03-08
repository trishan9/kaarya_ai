import 'package:equatable/equatable.dart';

class InterviewSessionStartEntity extends Equatable {
  final String sessionId;
  final String? interviewId;

  final String? vapiWebToken;
  final String? vapiAssistantId;
  final Map<String, dynamic>? vapiAssistantConfig;
  final String? vapiWorkflowId;
  final Map<String, dynamic>? vapiVariableValues;

  final String? interviewTitle;
  final String? interviewRole;
  final List<Map<String, dynamic>> questions;

  const InterviewSessionStartEntity({
    required this.sessionId,
    required this.interviewId,
    this.vapiWebToken,
    this.vapiAssistantId,
    this.vapiAssistantConfig,
    this.vapiWorkflowId,
    this.vapiVariableValues,
    this.interviewTitle,
    this.interviewRole,
    this.questions = const [],
  });

  @override
  List<Object?> get props => [
    sessionId,
    interviewId,
    vapiWebToken,
    vapiAssistantId,
    vapiAssistantConfig,
    vapiWorkflowId,
    vapiVariableValues,
    interviewTitle,
    interviewRole,
    questions,
  ];
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
