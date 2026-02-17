import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/core/error/failures.dart';
import 'package:kaarya/core/services/connectivity/network_info.dart';
import 'package:kaarya/features/interviews/data/datasources/interview_datasource.dart';
import 'package:kaarya/features/interviews/data/datasources/local/interview_local_datasource.dart';
import 'package:kaarya/features/interviews/data/datasources/remote/interview_remote_datasource.dart';
import 'package:kaarya/features/interviews/data/models/interview_hive_model.dart';
import 'package:kaarya/features/interviews/domain/entities/interview_analytics_entity.dart';
import 'package:kaarya/features/interviews/domain/entities/interview_entity.dart';
import 'package:kaarya/features/interviews/domain/entities/interview_feedback_entity.dart';
import 'package:kaarya/features/interviews/domain/entities/interview_section_entity.dart';
import 'package:kaarya/features/interviews/domain/entities/interview_session_entity.dart';
import 'package:kaarya/features/interviews/domain/repositories/interview_repository.dart';

final interviewRepositoryProvider = Provider<IInterviewRepository>((ref) {
  final remote = ref.read(interviewRemoteDatasourceProvider);
  final local = ref.read(interviewLocalDatasourceProvider);
  final networkInfo = ref.read(networkInfoProvider);
  return InterviewRepository(
    remote: remote,
    local: local,
    networkInfo: networkInfo,
  );
});

class InterviewRepository implements IInterviewRepository {
  final IInterviewRemoteDataSource _remote;
  final IInterviewLocalDataSource _local;
  final NetworkInfo _networkInfo;

  InterviewRepository({
    required IInterviewRemoteDataSource remote,
    required IInterviewLocalDataSource local,
    required NetworkInfo networkInfo,
  }) : _remote = remote,
       _local = local,
       _networkInfo = networkInfo;

  @override
  Future<Either<Failure, InterviewsSectionEntity>> getInterviewsSection({
    String? searchQuery,
    String? interviewType,
    String? status,
    String? sortBy,
    String? attemptFilter,
  }) async {
    if (await _networkInfo.isConnected) {
      try {
        final data = await _remote.getInterviewsSection(
          searchQuery: searchQuery,
          interviewType: interviewType,
          status: status,
          sortBy: sortBy,
          attemptFilter: attemptFilter,
        );
        await _local.saveInterviewsSection(
          InterviewsSectionHiveModel.fromApiModel(data),
        );
        return Right(data.toEntity());
      } on DioException catch (e) {
        final cached = await _local.getInterviewsSection();
        if (cached != null) return Right(cached.toApiModel().toEntity());
        return Left(
          ApiFailure(
            statusCode: e.response?.statusCode,
            message: e.response?.data['message'] ?? 'Failed to load interviews',
          ),
        );
      } catch (e) {
        final cached = await _local.getInterviewsSection();
        if (cached != null) return Right(cached.toApiModel().toEntity());
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      final cached = await _local.getInterviewsSection();
      if (cached != null) return Right(cached.toApiModel().toEntity());
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, InterviewEntity>> getInterviewById(String id) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      final data = await _remote.getInterviewById(id);
      return Right(data.toEntity());
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          statusCode: e.response?.statusCode,
          message: e.response?.data['message'] ?? 'Failed to load interview',
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
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
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      final data = await _remote.createInterview(
        title: title,
        description: description,
        interviewType: interviewType,
        role: role,
        level: level,
        techStack: techStack,
        questionCount: questionCount,
        durationMinutes: durationMinutes,
        visibility: visibility,
        status: status,
        tags: tags,
        instructions: instructions,
        generateQuestions: generateQuestions,
      );
      return Right(data.toEntity());
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          statusCode: e.response?.statusCode,
          message: e.response?.data['message'] ?? 'Failed to create interview',
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, InterviewEntity>> updateInterview({
    required String id,
    required Map<String, dynamic> data,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      final model = await _remote.updateInterview(id: id, data: data);
      return Right(model.toEntity());
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          statusCode: e.response?.statusCode,
          message: e.response?.data['message'] ?? 'Failed to update interview',
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteInterview(String id) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      final ok = await _remote.deleteInterview(id);
      return Right(ok);
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          statusCode: e.response?.statusCode,
          message: e.response?.data['message'] ?? 'Failed to delete interview',
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, InterviewSessionStartEntity>> startInterviewSession(
    String interviewId,
  ) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      final data = await _remote.startInterviewSession(interviewId);
      return Right(data.toEntity());
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          statusCode: e.response?.statusCode,
          message:
              e.response?.data['message'] ??
              'Failed to start interview session',
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> completeSession({
    required String interviewId,
    required String sessionId,
    required String status,
    List<Map<String, dynamic>>? transcript,
    String? recordingUrl,
    int? durationSeconds,
    String? vapiCallId,
    bool generateEvaluation = true,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      final ok = await _remote.completeSession(
        interviewId: interviewId,
        sessionId: sessionId,
        status: status,
        transcript: transcript,
        recordingUrl: recordingUrl,
        durationSeconds: durationSeconds,
        vapiCallId: vapiCallId,
        generateEvaluation: generateEvaluation,
      );
      return Right(ok);
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          statusCode: e.response?.statusCode,
          message: e.response?.data['message'] ?? 'Failed to complete session',
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<InterviewSessionEntity>>> listMySessions(
    String interviewId,
  ) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      final sessions = await _remote.listMySessions(interviewId);
      return Right(sessions.map((s) => s.toEntity()).toList());
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          statusCode: e.response?.statusCode,
          message: e.response?.data['message'] ?? 'Failed to load sessions',
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, InterviewFeedbackEntity>> getInterviewFeedback(
    String sessionId,
  ) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      final data = await _remote.getInterviewFeedback(sessionId);
      return Right(data.toEntity());
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          statusCode: e.response?.statusCode,
          message:
              e.response?.data['message'] ??
              'Failed to load interview feedback',
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, InterviewAnalyticsEntity>> getInterviewAnalytics(
    String interviewId,
  ) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      final data = await _remote.getInterviewAnalytics(interviewId);
      return Right(data.toEntity());
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          statusCode: e.response?.statusCode,
          message:
              e.response?.data['message'] ??
              'Failed to load interview analytics',
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> setInterviewSaved({
    required String interviewId,
    required bool isSaved,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      final ok = await _remote.setInterviewSaved(
        interviewId: interviewId,
        isSaved: isSaved,
      );
      return Right(ok);
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          statusCode: e.response?.statusCode,
          message:
              e.response?.data['message'] ?? 'Failed to update saved status',
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }
}
