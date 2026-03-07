import 'package:dartz/dartz.dart';
import 'package:kaarya/core/error/failures.dart';
import 'package:kaarya/features/interviews/domain/entities/interview_analytics_entity.dart';
import 'package:kaarya/features/interviews/domain/entities/interview_entity.dart';
import 'package:kaarya/features/interviews/domain/entities/interview_feedback_entity.dart';
import 'package:kaarya/features/interviews/domain/entities/interview_section_entity.dart';
import 'package:kaarya/features/interviews/domain/entities/interview_session_entity.dart';

abstract interface class IInterviewRepository {
  Future<Either<Failure, InterviewsSectionEntity>> getInterviewsSection({
    String? searchQuery,
    String? interviewType,
    String? status,
    String? sortBy,
    String? attemptFilter,
  });

  Future<Either<Failure, InterviewEntity>> getInterviewById(String id);

  Future<Either<Failure, InterviewEntity>> createInterview({
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

  Future<Either<Failure, InterviewEntity>> updateInterview({
    required String id,
    required Map<String, dynamic> data,
  });

  Future<Either<Failure, bool>> deleteInterview(String id);

  Future<Either<Failure, InterviewSessionStartEntity>> startInterviewSession(
    String interviewId,
  );

  Future<Either<Failure, bool>> completeSession({
    required String interviewId,
    required String sessionId,
    required String status,
    List<Map<String, dynamic>>? transcript,
    String? recordingUrl,
    int? durationSeconds,
    String? vapiCallId,
    bool generateEvaluation = true,
  });

  Future<Either<Failure, List<InterviewSessionEntity>>> listMySessions(
    String interviewId,
  );

  Future<Either<Failure, InterviewFeedbackEntity>> getInterviewFeedback(
    String sessionId,
  );

  Future<Either<Failure, InterviewAnalyticsEntity>> getInterviewAnalytics(
    String interviewId,
  );

  Future<Either<Failure, bool>> setInterviewSaved({
    required String interviewId,
    required bool isSaved,
  });
}
