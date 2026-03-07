import 'package:equatable/equatable.dart';
import 'package:kaarya/features/interviews/domain/entities/interview_entity.dart';
import 'package:kaarya/features/interviews/domain/entities/interview_feedback_entity.dart';

enum TakeInterviewPhase {
  idle,
  loading,
  ready,
  connecting,
  active,
  finishing,
  completed,
  error,
}

class TranscriptMessage extends Equatable {
  final String role; // 'assistant', 'user', 'system'
  final String content;
  final DateTime timestamp;

  const TranscriptMessage({
    required this.role,
    required this.content,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'role': role,
    'content': content,
    'timestamp': timestamp.toIso8601String(),
  };

  @override
  List<Object?> get props => [role, content, timestamp];
}

class TakeInterviewState extends Equatable {
  static const Object _unset = Object();

  final TakeInterviewPhase phase;
  final String? error;

  // Interview info
  final InterviewEntity? interview;
  final String? sessionId;
  final String? interviewId;

  // VAPI config from startSession response
  final String? vapiWebToken;
  final String? vapiAssistantId;
  final Map<String, dynamic>? vapiAssistantConfig;
  final String? vapiWorkflowId;
  final Map<String, dynamic>? vapiVariableValues;

  // Question bank from session
  final List<String> questionBank;

  // Live call state
  final String? vapiCallId;
  final bool isSpeaking; // AI is speaking
  final String? activeSpeaker; // 'assistant', 'user', or null
  final List<TranscriptMessage> transcript;
  final String? partialMessage; // in-progress speech, shown as live preview
  final String? partialRole;
  final int askedQuestionCount;
  final int totalQuestions;
  final int elapsedSeconds;

  // Post-interview feedback
  final InterviewFeedbackEntity? feedback;
  final bool isFeedbackLoading;

  const TakeInterviewState({
    this.phase = TakeInterviewPhase.idle,
    this.error,
    this.interview,
    this.sessionId,
    this.interviewId,
    this.vapiWebToken,
    this.vapiAssistantId,
    this.vapiAssistantConfig,
    this.vapiWorkflowId,
    this.vapiVariableValues,
    this.questionBank = const [],
    this.vapiCallId,
    this.isSpeaking = false,
    this.activeSpeaker,
    this.transcript = const [],
    this.partialMessage,
    this.partialRole,
    this.askedQuestionCount = 0,
    this.totalQuestions = 0,
    this.elapsedSeconds = 0,
    this.feedback,
    this.isFeedbackLoading = false,
  });

  TakeInterviewState copyWith({
    TakeInterviewPhase? phase,
    Object? error = _unset,
    Object? interview = _unset,
    Object? sessionId = _unset,
    Object? interviewId = _unset,
    Object? vapiWebToken = _unset,
    Object? vapiAssistantId = _unset,
    Object? vapiAssistantConfig = _unset,
    Object? vapiWorkflowId = _unset,
    Object? vapiVariableValues = _unset,
    List<String>? questionBank,
    Object? vapiCallId = _unset,
    bool? isSpeaking,
    Object? activeSpeaker = _unset,
    List<TranscriptMessage>? transcript,
    Object? partialMessage = _unset,
    Object? partialRole = _unset,
    int? askedQuestionCount,
    int? totalQuestions,
    int? elapsedSeconds,
    Object? feedback = _unset,
    bool? isFeedbackLoading,
  }) {
    return TakeInterviewState(
      phase: phase ?? this.phase,
      error: error == _unset ? this.error : error as String?,
      interview: interview == _unset
          ? this.interview
          : interview as InterviewEntity?,
      sessionId: sessionId == _unset ? this.sessionId : sessionId as String?,
      interviewId:
          interviewId == _unset ? this.interviewId : interviewId as String?,
      vapiWebToken: vapiWebToken == _unset
          ? this.vapiWebToken
          : vapiWebToken as String?,
      vapiAssistantId: vapiAssistantId == _unset
          ? this.vapiAssistantId
          : vapiAssistantId as String?,
      vapiAssistantConfig: vapiAssistantConfig == _unset
          ? this.vapiAssistantConfig
          : vapiAssistantConfig as Map<String, dynamic>?,
      vapiWorkflowId: vapiWorkflowId == _unset
          ? this.vapiWorkflowId
          : vapiWorkflowId as String?,
      vapiVariableValues: vapiVariableValues == _unset
          ? this.vapiVariableValues
          : vapiVariableValues as Map<String, dynamic>?,
      questionBank: questionBank ?? this.questionBank,
      vapiCallId:
          vapiCallId == _unset ? this.vapiCallId : vapiCallId as String?,
      isSpeaking: isSpeaking ?? this.isSpeaking,
      activeSpeaker: activeSpeaker == _unset
          ? this.activeSpeaker
          : activeSpeaker as String?,
      transcript: transcript ?? this.transcript,
      partialMessage: partialMessage == _unset
          ? this.partialMessage
          : partialMessage as String?,
      partialRole:
          partialRole == _unset ? this.partialRole : partialRole as String?,
      askedQuestionCount: askedQuestionCount ?? this.askedQuestionCount,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      feedback: feedback == _unset
          ? this.feedback
          : feedback as InterviewFeedbackEntity?,
      isFeedbackLoading: isFeedbackLoading ?? this.isFeedbackLoading,
    );
  }

  @override
  List<Object?> get props => [
    phase,
    error,
    interview,
    sessionId,
    interviewId,
    vapiWebToken,
    vapiAssistantId,
    vapiAssistantConfig,
    vapiWorkflowId,
    vapiVariableValues,
    questionBank,
    vapiCallId,
    isSpeaking,
    activeSpeaker,
    transcript,
    partialMessage,
    partialRole,
    askedQuestionCount,
    totalQuestions,
    elapsedSeconds,
    feedback,
    isFeedbackLoading,
  ];
}
