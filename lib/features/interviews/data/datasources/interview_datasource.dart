import 'package:kaarya/features/interviews/data/models/interview_api_model.dart';
import 'package:kaarya/features/interviews/data/models/interview_hive_model.dart';

abstract interface class IInterviewRemoteDataSource {
  Future<InterviewsSectionApiModel> getInterviewsSection({
    String? searchQuery,
    String? interviewType,
    String? status,
    String? sortBy,
    String? attemptFilter,
  });

  Future<InterviewApiModel> getInterviewById(String id);

  Future<InterviewApiModel> createInterview({
    required String title,
    String? description,
    required String interviewType,
    required String role,
    String? level,
    List<String>? techStack,
    int? questionCount,
    int? durationMinutes,
    String? visibility,
    String? status,
    List<String>? tags,
    String? instructions,
    bool? generateQuestions,
    String? companyId,
    String? collegeId,
  });

  Future<InterviewApiModel> updateInterview({
    required String id,
    required Map<String, dynamic> data,
  });

  Future<bool> deleteInterview(String id);

  Future<InterviewSessionStartApiModel> startInterviewSession(
    String interviewId,
  );

  Future<bool> completeSession({
    required String interviewId,
    required String sessionId,
    required String status,
    List<Map<String, dynamic>>? transcript,
    String? recordingUrl,
    int? durationSeconds,
    String? vapiCallId,
    bool generateEvaluation = true,
  });

  Future<List<InterviewSessionApiModel>> listMySessions(String interviewId);

  Future<InterviewFeedbackApiModel> getInterviewFeedback(String sessionId);

  Future<InterviewAnalyticsApiModel> getInterviewAnalytics(String interviewId);

  Future<bool> setInterviewSaved({
    required String interviewId,
    required bool isSaved,
  });
}

abstract interface class IInterviewLocalDataSource {
  Future<void> saveInterviewsSection(InterviewsSectionHiveModel data);
  Future<InterviewsSectionHiveModel?> getInterviewsSection();
}
