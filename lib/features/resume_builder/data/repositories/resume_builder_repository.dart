import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/core/error/failures.dart';
import 'package:kaarya/core/services/connectivity/network_info.dart';
import 'package:kaarya/features/resume_builder/data/datasources/local/resume_builder_local_datasource.dart';
import 'package:kaarya/features/resume_builder/data/datasources/remote/resume_builder_remote_datasource.dart';
import 'package:kaarya/features/resume_builder/data/datasources/resume_builder_datasource.dart';
import 'package:kaarya/features/resume_builder/data/models/resume_draft_hive_model.dart';
import 'package:kaarya/features/resume_builder/domain/entities/ats_scan_result_entity.dart';
import 'package:kaarya/features/resume_builder/domain/entities/resume_draft_entity.dart';
import 'package:kaarya/features/resume_builder/domain/repositories/resume_builder_repository.dart';

final resumeBuilderRepositoryProvider = Provider<IResumeBuilderRepository>((
  ref,
) {
  return ResumeBuilderRepository(
    remoteDatasource: ref.read(resumeBuilderRemoteDatasourceProvider),
    localDatasource: ref.read(resumeBuilderLocalDatasourceProvider),
    networkInfo: ref.read(networkInfoProvider),
  );
});

class ResumeBuilderRepository implements IResumeBuilderRepository {
  final IResumeBuilderRemoteDataSource _remoteDatasource;
  final IResumeBuilderLocalDataSource _localDatasource;
  final NetworkInfo _networkInfo;

  ResumeBuilderRepository({
    required IResumeBuilderRemoteDataSource remoteDatasource,
    required IResumeBuilderLocalDataSource localDatasource,
    required NetworkInfo networkInfo,
  }) : _remoteDatasource = remoteDatasource,
       _localDatasource = localDatasource,
       _networkInfo = networkInfo;

  @override
  Future<Either<Failure, ResumeDraftEntity>> createDraft({
    required String title,
    required String template,
    Map<String, dynamic>? personalInfo,
    Map<String, dynamic>? sections,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(
        NetworkFailure(message: 'No internet connection to create draft.'),
      );
    }

    try {
      final remote = await _remoteDatasource.createDraft(
        title: title,
        template: template,
        personalInfo: personalInfo,
        sections: sections,
      );
      return Right(remote.toEntity());
    } on DioException catch (e) {
      return Left(
        _mapDioException(e, fallbackMessage: 'Failed to create draft.'),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ResumeDraftsListEntity>> listDrafts({
    int page = 1,
    int size = 20,
  }) async {
    if (await _networkInfo.isConnected) {
      try {
        final remote = await _remoteDatasource.listDrafts(
          page: page,
          size: size,
        );
        await _localDatasource.saveDraftsList(
          remote.drafts.map(ResumeDraftHiveModel.fromApiModel).toList(),
        );
        return Right(
          ResumeDraftsListEntity(
            drafts: remote.drafts.map((e) => e.toEntity()).toList(),
            totalCount: remote.totalCount,
            page: remote.page,
            size: remote.size,
          ),
        );
      } on DioException catch (e) {
        final cached = await _localDatasource.listDrafts();
        if (cached.isNotEmpty) {
          return Right(
            ResumeDraftsListEntity(
              drafts: cached.map((e) => e.toApiModel().toEntity()).toList(),
              totalCount: cached.length,
              page: 1,
              size: cached.length,
            ),
          );
        }
        return Left(
          _mapDioException(e, fallbackMessage: 'Failed to load drafts.'),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    }

    final cached = await _localDatasource.listDrafts();
    if (cached.isNotEmpty) {
      return Right(
        ResumeDraftsListEntity(
          drafts: cached.map((e) => e.toApiModel().toEntity()).toList(),
          totalCount: cached.length,
          page: 1,
          size: cached.length,
        ),
      );
    }

    return const Left(
      NetworkFailure(
        message: 'No internet connection and no cached drafts data.',
      ),
    );
  }

  @override
  Future<Either<Failure, ResumeDraftEntity>> getDraftById(
    String draftId,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        final remote = await _remoteDatasource.getDraftById(draftId);
        await _localDatasource.saveDraft(
          ResumeDraftHiveModel.fromApiModel(remote),
        );
        return Right(remote.toEntity());
      } on DioException catch (e) {
        final cached = await _localDatasource.getDraftById(draftId);
        if (cached != null) {
          return Right(cached.toApiModel().toEntity());
        }
        return Left(
          _mapDioException(e, fallbackMessage: 'Failed to load draft details.'),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    }

    final cached = await _localDatasource.getDraftById(draftId);
    if (cached != null) {
      return Right(cached.toApiModel().toEntity());
    }

    return const Left(
      NetworkFailure(
        message: 'No internet connection and no cached draft data.',
      ),
    );
  }

  @override
  Future<Either<Failure, ResumeDraftEntity>> updateDraft({
    required String draftId,
    required Map<String, dynamic> fields,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(
        NetworkFailure(message: 'No internet connection to update draft.'),
      );
    }

    try {
      final remote = await _remoteDatasource.updateDraft(
        draftId: draftId,
        fields: fields,
      );
      await _localDatasource.saveDraft(
        ResumeDraftHiveModel.fromApiModel(remote),
      );
      return Right(remote.toEntity());
    } on DioException catch (e) {
      return Left(
        _mapDioException(e, fallbackMessage: 'Failed to update draft.'),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteDraft(String draftId) async {
    if (!await _networkInfo.isConnected) {
      return const Left(
        NetworkFailure(message: 'No internet connection to delete draft.'),
      );
    }

    try {
      final result = await _remoteDatasource.deleteDraft(draftId);
      if (!result) {
        return const Left(ApiFailure(message: 'Unable to delete draft.'));
      }
      return Right(result);
    } on DioException catch (e) {
      return Left(
        _mapDioException(e, fallbackMessage: 'Failed to delete draft.'),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, GeneratePdfResultEntity>> generatePdf(
    String draftId,
  ) async {
    if (!await _networkInfo.isConnected) {
      return const Left(
        NetworkFailure(message: 'No internet connection to generate PDF.'),
      );
    }

    try {
      final pdfUrl = await _remoteDatasource.generatePdf(draftId);
      return Right(GeneratePdfResultEntity(pdfUrl: pdfUrl));
    } on DioException catch (e) {
      return Left(
        _mapDioException(e, fallbackMessage: 'Failed to generate PDF.'),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> saveAsResume(String draftId) async {
    if (!await _networkInfo.isConnected) {
      return const Left(
        NetworkFailure(message: 'No internet connection to save resume.'),
      );
    }

    try {
      final result = await _remoteDatasource.saveAsResume(draftId);
      return Right(result);
    } on DioException catch (e) {
      return Left(
        _mapDioException(e, fallbackMessage: 'Failed to save resume.'),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AiSummaryResultEntity>> generateAiSummary({
    required List<String> skills,
    required List<String> experience,
    required String targetRole,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(
        NetworkFailure(
          message: 'No internet connection to generate AI summary.',
        ),
      );
    }

    try {
      final summary = await _remoteDatasource.generateAiSummary(
        skills: skills,
        experience: experience,
        targetRole: targetRole,
      );
      return Right(AiSummaryResultEntity(summary: summary));
    } on DioException catch (e) {
      return Left(
        _mapDioException(e, fallbackMessage: 'Failed to generate AI summary.'),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ExperienceBulletsResultEntity>>
  generateExperienceBullets({
    required String jobTitle,
    required String responsibilities,
    required List<String> techStack,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(
        NetworkFailure(
          message: 'No internet connection to generate experience bullets.',
        ),
      );
    }

    try {
      final bullets = await _remoteDatasource.generateExperienceBullets(
        jobTitle: jobTitle,
        responsibilities: responsibilities,
        techStack: techStack,
      );
      return Right(ExperienceBulletsResultEntity(bullets: bullets));
    } on DioException catch (e) {
      return Left(
        _mapDioException(
          e,
          fallbackMessage: 'Failed to generate experience bullets.',
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AiSuggestionsResultEntity>> generateAiSuggestions({
    required String step,
    required Map<String, dynamic> resumeData,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(
        NetworkFailure(
          message: 'No internet connection to generate AI suggestions.',
        ),
      );
    }

    try {
      final suggestions = await _remoteDatasource.generateAiSuggestions(
        step: step,
        resumeData: resumeData,
      );
      return Right(AiSuggestionsResultEntity(suggestions: suggestions));
    } on DioException catch (e) {
      return Left(
        _mapDioException(
          e,
          fallbackMessage: 'Failed to generate AI suggestions.',
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AtsScanResultEntity>> atsScan({
    required String filePath,
    String? targetRole,
    String? experienceLevel,
    String? jobDescription,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(
        NetworkFailure(message: 'No internet connection to perform ATS scan.'),
      );
    }

    try {
      final result = await _remoteDatasource.atsScan(
        filePath: filePath,
        targetRole: targetRole,
        experienceLevel: experienceLevel,
        jobDescription: jobDescription,
      );
      return Right(result.toEntity());
    } on DioException catch (e) {
      return Left(
        _mapDioException(e, fallbackMessage: 'Failed to perform ATS scan.'),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  Failure _mapDioException(DioException e, {required String fallbackMessage}) {
    final data = e.response?.data;
    String? message;
    if (data is Map && data['message'] is String) {
      message = data['message'] as String;
    }
    return ApiFailure(
      statusCode: e.response?.statusCode,
      message: message ?? e.message ?? fallbackMessage,
    );
  }
}
