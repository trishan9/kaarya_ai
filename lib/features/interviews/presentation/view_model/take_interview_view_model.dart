import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/core/services/vapi/vapi_interview_service.dart';
import 'package:kaarya/features/interviews/domain/usecases/complete_session_usecase.dart';
import 'package:kaarya/features/interviews/domain/usecases/get_interview_by_id_usecase.dart';
import 'package:kaarya/features/interviews/domain/usecases/get_interview_feedback_usecase.dart';
import 'package:kaarya/features/interviews/domain/usecases/start_interview_session_usecase.dart';
import 'package:kaarya/features/interviews/presentation/state/take_interview_state.dart';

final takeInterviewViewModelProvider =
    NotifierProvider<TakeInterviewViewModel, TakeInterviewState>(
      TakeInterviewViewModel.new,
    );

class TakeInterviewViewModel extends Notifier<TakeInterviewState> {
  late final GetInterviewByIdUseCase _getInterviewById;
  late final StartInterviewSessionUseCase _startSession;
  late final CompleteSessionUseCase _completeSession;
  late final GetInterviewFeedbackUseCase _getFeedback;
  late final VapiInterviewService _vapiService;

  StreamSubscription? _vapiEventSub;
  Timer? _elapsedTimer;
  DateTime? _callStartedAt;
  bool _finalizeInProgress = false;
  final Set<int> _askedQuestionIndexes = {};
  List<String> _normalizedQuestionBank = [];

  @override
  TakeInterviewState build() {
    _getInterviewById = ref.read(getInterviewByIdUseCaseProvider);
    _startSession = ref.read(startInterviewSessionUseCaseProvider);
    _completeSession = ref.read(completeSessionUseCaseProvider);
    _getFeedback = ref.read(getInterviewFeedbackUseCaseProvider);
    _vapiService = ref.read(vapiInterviewServiceProvider);

    ref.onDispose(_cleanup);

    return const TakeInterviewState();
  }

  /// Load interview details by ID.
  Future<void> loadInterview(String interviewId) async {
    state = state.copyWith(
      phase: TakeInterviewPhase.loading,
      interviewId: interviewId,
      error: null,
    );

    final result = await _getInterviewById(
      GetInterviewByIdUseCaseParams(id: interviewId),
    );

    result.fold(
      (failure) => state = state.copyWith(
        phase: TakeInterviewPhase.error,
        error: failure.message,
      ),
      (interview) => state = state.copyWith(
        phase: TakeInterviewPhase.ready,
        interview: interview,
        interviewId: interview.id,
      ),
    );
  }

  /// Start a new interview session — calls the backend and captures VAPI config.
  Future<void> startSession() async {
    final interviewId = state.interviewId;
    if (interviewId == null || interviewId.isEmpty) {
      state = state.copyWith(
        phase: TakeInterviewPhase.error,
        error: 'No interview ID',
      );
      return;
    }

    state = state.copyWith(
      phase: TakeInterviewPhase.connecting,
      error: null,
      transcript: const [],
      elapsedSeconds: 0,
      askedQuestionCount: 0,
    );

    _finalizeInProgress = false;
    _askedQuestionIndexes.clear();
    _callStartedAt = null;

    final result = await _startSession(
      StartInterviewSessionUseCaseParams(interviewId: interviewId),
    );

    result.fold(
      (failure) => state = state.copyWith(
        phase: TakeInterviewPhase.error,
        error: failure.message,
      ),
      (sessionStart) {
        if (sessionStart.vapiWebToken == null ||
            sessionStart.vapiWebToken!.isEmpty) {
          state = state.copyWith(
            phase: TakeInterviewPhase.error,
            error: 'VAPI web token is missing in backend configuration.',
          );
          return;
        }

        // Extract question strings from the questions list
        final questions = sessionStart.questions
            .map((q) => (q['question'] ?? '').toString().trim())
            .where((q) => q.isNotEmpty)
            .toList();

        _normalizedQuestionBank =
            questions.map(_normalizeForMatch).where((q) => q.isNotEmpty).toList();

        state = state.copyWith(
          sessionId: sessionStart.sessionId,
          vapiWebToken: sessionStart.vapiWebToken,
          vapiAssistantId: sessionStart.vapiAssistantId,
          vapiAssistantConfig: sessionStart.vapiAssistantConfig,
          vapiWorkflowId: sessionStart.vapiWorkflowId,
          vapiVariableValues: sessionStart.vapiVariableValues,
          questionBank: questions,
          totalQuestions: questions.length,
        );

        // Initialize VAPI and start call
        _initVapiCall();
      },
    );
  }

  /// End the interview call.
  void endInterview() {
    if (state.phase != TakeInterviewPhase.active) return;
    state = state.copyWith(phase: TakeInterviewPhase.finishing);
    _vapiService.endCall();
  }

  /// Load feedback for a completed session.
  Future<void> loadFeedback(String sessionId) async {
    state = state.copyWith(isFeedbackLoading: true);

    final result = await _getFeedback(
      GetInterviewFeedbackUseCaseParams(sessionId: sessionId),
    );

    result.fold(
      (failure) => state = state.copyWith(
        isFeedbackLoading: false,
        error: failure.message,
      ),
      (feedback) => state = state.copyWith(
        isFeedbackLoading: false,
        feedback: feedback,
      ),
    );
  }

  /// Reset state for a new interview.
  void reset() {
    _cleanup();
    state = const TakeInterviewState();
  }

  // ─── Private helpers ───

  void _initVapiCall() {
    _vapiService.init(state.vapiWebToken!);
    _listenToVapiEvents();

    final assistant = state.vapiAssistantConfig;
    final assistantId = state.vapiAssistantId;
    final overrides = state.vapiVariableValues != null
        ? {'variableValues': state.vapiVariableValues!}
        : null;

    _vapiService.startCall(
      assistant: assistant,
      assistantId: assistantId,
      assistantOverrides: overrides,
    );
  }

  void _listenToVapiEvents() {
    _vapiEventSub?.cancel();
    _vapiEventSub = _vapiService.events.listen((event) {
      switch (event.type) {
        case VapiEventType.callStart:
          _onCallStart(event.data);
          break;
        case VapiEventType.callEnd:
          _onCallEnd();
          break;
        case VapiEventType.transcript:
          _onTranscript(event.data);
          break;
        case VapiEventType.partialTranscript:
          state = state.copyWith(
            partialMessage: event.data['content']?.toString(),
            partialRole: event.data['role']?.toString(),
          );
          break;
        case VapiEventType.speechStart:
          state = state.copyWith(isSpeaking: true, activeSpeaker: 'assistant');
          break;
        case VapiEventType.speechEnd:
          state = state.copyWith(
            isSpeaking: false,
            activeSpeaker:
                state.activeSpeaker == 'assistant' ? null : state.activeSpeaker,
          );
          break;
        case VapiEventType.error:
          final msg = event.data['message']?.toString() ?? 'Interview call failed.';
          state = state.copyWith(
            phase: TakeInterviewPhase.error,
            error: msg,
          );
          break;
      }
    });
  }

  void _onCallStart(Map<String, dynamic> data) {
    final callId = data['callId']?.toString();
    _callStartedAt = DateTime.now();

    state = state.copyWith(
      phase: TakeInterviewPhase.active,
      vapiCallId: callId,
      error: null,
      elapsedSeconds: 0,
    );

    _startElapsedTimer();
  }

  void _onCallEnd() {
    state = state.copyWith(phase: TakeInterviewPhase.finishing);
    _stopElapsedTimer();

    // Delay to let the final transcript flush before finalizing
    Future.delayed(const Duration(milliseconds: 800), () {
      _finalizeSession();
    });
  }

  void _onTranscript(Map<String, dynamic> data) {
    final role = data['role']?.toString() ?? 'user';
    final content = data['content']?.toString() ?? '';
    final timestampStr = data['timestamp']?.toString();
    final timestamp = timestampStr != null
        ? DateTime.tryParse(timestampStr) ?? DateTime.now()
        : DateTime.now();

    if (content.isEmpty) return;

    final message = TranscriptMessage(
      role: role,
      content: content,
      timestamp: timestamp,
    );

    final updatedTranscript = [...state.transcript, message];
    // Clear partial preview now that we have the final version
    state = state.copyWith(
      transcript: updatedTranscript,
      partialMessage: null,
      partialRole: null,
    );

    // Track user speaking
    if (role == 'user') {
      state = state.copyWith(activeSpeaker: 'user');
      // Reset after a delay
      Future.delayed(const Duration(milliseconds: 1400), () {
        if (state.activeSpeaker == 'user') {
          state = state.copyWith(activeSpeaker: null);
        }
      });
    }

    // Question tracking for assistant messages
    if (role == 'assistant' && _normalizedQuestionBank.isNotEmpty) {
      final normalizedContent = _normalizeForMatch(content);
      for (int i = 0; i < _normalizedQuestionBank.length; i++) {
        if (_normalizedQuestionBank[i].isNotEmpty &&
            normalizedContent.contains(_normalizedQuestionBank[i]) &&
            !_askedQuestionIndexes.contains(i)) {
          _askedQuestionIndexes.add(i);
        }
      }
      state = state.copyWith(askedQuestionCount: _askedQuestionIndexes.length);
    }

  }

  Future<void> _finalizeSession() async {
    if (_finalizeInProgress) return;
    final sessionId = state.sessionId;
    final interviewId = state.interviewId;
    if (sessionId == null || interviewId == null) {
      state = state.copyWith(phase: TakeInterviewPhase.error);
      return;
    }

    _finalizeInProgress = true;

    final durationSeconds = _callStartedAt != null
        ? DateTime.now().difference(_callStartedAt!).inSeconds
        : state.elapsedSeconds;

    final transcriptJson = state.transcript.map((m) => m.toJson()).toList();

    final result = await _completeSession(
      CompleteSessionUseCaseParams(
        interviewId: interviewId,
        sessionId: sessionId,
        status: 'completed',
        transcript: transcriptJson,
        vapiCallId: _vapiService.vapiCallId ?? state.vapiCallId,
        durationSeconds: durationSeconds,
        generateEvaluation: true,
      ),
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          phase: TakeInterviewPhase.error,
          error: 'Session finished but feedback failed: ${failure.message}',
        );
      },
      (_) {
        state = state.copyWith(phase: TakeInterviewPhase.completed);
      },
    );

    _finalizeInProgress = false;
  }

  void _startElapsedTimer() {
    _stopElapsedTimer();
    _elapsedTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_callStartedAt == null) return;
      final elapsed = DateTime.now().difference(_callStartedAt!).inSeconds;
      state = state.copyWith(elapsedSeconds: elapsed);
    });
  }

  void _stopElapsedTimer() {
    _elapsedTimer?.cancel();
    _elapsedTimer = null;
  }

  String _normalizeForMatch(String value) {
    return value
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  void _cleanup() {
    _vapiEventSub?.cancel();
    _vapiEventSub = null;
    _stopElapsedTimer();
    _vapiService.endCall();
    _askedQuestionIndexes.clear();
    _normalizedQuestionBank = [];
    _callStartedAt = null;
    _finalizeInProgress = false;
  }
}
