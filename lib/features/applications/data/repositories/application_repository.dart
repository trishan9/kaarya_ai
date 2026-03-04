import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/core/error/failures.dart';
import 'package:kaarya/core/services/connectivity/network_info.dart';
import 'package:kaarya/features/applications/data/datasources/application_datasource.dart';
import 'package:kaarya/features/applications/data/datasources/local/application_local_datasource.dart';
import 'package:kaarya/features/applications/data/datasources/remote/application_remote_datasource.dart';
import 'package:kaarya/features/applications/data/models/application_hive_model.dart';
import 'package:kaarya/features/applications/data/models/resume_hive_model.dart';
import 'package:kaarya/features/applications/domain/entities/application_entity.dart';
import 'package:kaarya/features/applications/domain/entities/application_summary_entity.dart';
import 'package:kaarya/features/applications/domain/entities/resume_entity.dart';
import 'package:kaarya/features/applications/domain/repositories/application_repository.dart';

final applicationRepositoryProvider = Provider<IApplicationRepository>((ref) {
  return ApplicationRepository(
    remoteDatasource: ref.read(applicationRemoteDatasourceProvider),
    localDatasource: ref.read(applicationLocalDatasourceProvider),
    networkInfo: ref.read(networkInfoProvider),
  );
});

class ApplicationRepository implements IApplicationRepository {
  final IApplicationRemoteDataSource _remoteDatasource;
  final IApplicationLocalDataSource _localDatasource;
  final NetworkInfo _networkInfo;

  ApplicationRepository({
    required IApplicationRemoteDataSource remoteDatasource,
    required IApplicationLocalDataSource localDatasource,
    required NetworkInfo networkInfo,
  }) : _remoteDatasource = remoteDatasource,
       _localDatasource = localDatasource,
       _networkInfo = networkInfo;

  @override
  Future<Either<Failure, ApplicationsListEntity>> getMyApplications({
    int page = 1,
    int size = 50,
    String? status,
  }) async {
    try {
      final isOnline = await _networkInfo.isConnected;
      if (isOnline) {
        final data = await _remoteDatasource.getMyApplications(
          page: page,
          size: size,
          status: status,
        );
        await _localDatasource.saveMyApplications(
          data.map(ApplicationHiveModel.fromApiModel).toList(),
        );
        final entities = data.map((e) => e.toEntity()).toList();
        return Right(_buildApplicationsList(entities));
      } else {
        final cached = await _localDatasource.getMyApplications();
        if (cached.isNotEmpty) {
          final entities = cached
              .map((e) => e.toApiModel().toEntity())
              .toList();
          return Right(_buildApplicationsList(entities));
        }
        return const Left(NetworkFailure(message: 'No internet connection'));
      }
    } on DioException catch (e) {
      final cached = await _localDatasource.getMyApplications();
      if (cached.isNotEmpty) {
        final entities = cached.map((e) => e.toApiModel().toEntity()).toList();
        return Right(_buildApplicationsList(entities));
      }
      return Left(
        _mapDioException(e, fallbackMessage: 'Failed to load applications'),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ApplicationSummaryEntity>> getApplicationsSummary({
    String? month,
    String? statuses,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      final data = await _remoteDatasource.getApplicationsSummary(
        month: month,
        statuses: statuses,
      );
      return Right(data.toEntity());
    } on DioException catch (e) {
      return Left(
        _mapDioException(e, fallbackMessage: 'Failed to load summary'),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ApplicationEntity>> getApplicationForJob({
    required String jobId,
  }) async {
    try {
      final data = await _remoteDatasource.getApplicationForJob(jobId: jobId);
      return Right(data.toEntity());
    } on DioException catch (e) {
      return Left(
        _mapDioException(
          e,
          fallbackMessage: 'Failed to load application for this job',
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> applyToJob({
    required String jobId,
    String? resumeId,
    String? resumeFilePath,
    List<int>? resumeBytes,
    String? resumeFilename,
    String? coverLetter,
    List<String>? portfolioLinks,
  }) async {
    try {
      final result = await _remoteDatasource.applyToJob(
        jobId,
        resumeId: resumeId,
        resumeFilePath: resumeFilePath,
        resumeBytes: resumeBytes,
        resumeFilename: resumeFilename,
        coverLetter: coverLetter,
        portfolioLinks: portfolioLinks,
      );
      return Right(result);
    } on DioException catch (e) {
      return Left(
        _mapDioException(e, fallbackMessage: 'Failed to apply to job'),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ApplicationsListEntity>> getJobApplications({
    required String jobId,
    int page = 1,
    int size = 50,
    String? status,
  }) async {
    try {
      final data = await _remoteDatasource.getJobApplications(
        jobId: jobId,
        page: page,
        size: size,
        status: status,
      );
      final entities = data.map((e) => e.toEntity()).toList();
      return Right(_buildApplicationsList(entities));
    } on DioException catch (e) {
      return Left(
        _mapDioException(e, fallbackMessage: 'Failed to load job applications'),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> updateApplication({
    required String jobId,
    required String applicationId,
    required String status,
    Map<String, dynamic>? interviewMetadata,
  }) async {
    try {
      final result = await _remoteDatasource.updateApplication(
        jobId: jobId,
        applicationId: applicationId,
        status: status,
        interviewMetadata: interviewMetadata,
      );
      return Right(result);
    } on DioException catch (e) {
      return Left(
        _mapDioException(e, fallbackMessage: 'Failed to update application'),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ResumeEntity>>> listMyResumes({
    int page = 1,
    int size = 50,
  }) async {
    try {
      final isOnline = await _networkInfo.isConnected;
      if (isOnline) {
        final data = await _remoteDatasource.listMyResumes(
          page: page,
          size: size,
        );
        await _localDatasource.saveResumes(
          data.map(ResumeHiveModel.fromApiModel).toList(),
        );
        return Right(data.map((e) => e.toEntity()).toList());
      } else {
        final cached = await _localDatasource.listMyResumes();
        if (cached.isNotEmpty) {
          return Right(cached.map((e) => e.toApiModel().toEntity()).toList());
        }
        return const Left(NetworkFailure(message: 'No internet connection'));
      }
    } on DioException catch (e) {
      final cached = await _localDatasource.listMyResumes();
      if (cached.isNotEmpty) {
        return Right(cached.map((e) => e.toApiModel().toEntity()).toList());
      }
      return Left(
        _mapDioException(e, fallbackMessage: 'Failed to load resumes'),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ResumeEntity>> uploadResume({
    required String filePath,
  }) async {
    try {
      final data = await _remoteDatasource.uploadResume(filePath: filePath);
      return Right(data.toEntity());
    } on DioException catch (e) {
      return Left(
        _mapDioException(e, fallbackMessage: 'Failed to upload resume'),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteResume({required String resumeId}) async {
    try {
      final result = await _remoteDatasource.deleteResume(resumeId: resumeId);
      return Right(result);
    } on DioException catch (e) {
      return Left(
        _mapDioException(e, fallbackMessage: 'Failed to delete resume'),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> updateResumeActivity({
    required String jobId,
    required String applicationId,
    required String action,
  }) async {
    try {
      final result = await _remoteDatasource.updateResumeActivity(
        jobId: jobId,
        applicationId: applicationId,
        action: action,
      );
      return Right(result);
    } on DioException catch (e) {
      return Left(
        _mapDioException(
          e,
          fallbackMessage: 'Failed to update resume activity',
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  ApplicationsListEntity _buildApplicationsList(List<ApplicationEntity> apps) {
    final inProgress = apps
        .where(
          (a) =>
              a.status == 'applied' ||
              a.status == 'reviewing' ||
              a.status == 'shortlisted',
        )
        .length;
    final interviews = apps
        .where(
          (a) => a.status == 'interview_scheduled' || a.status == 'interview',
        )
        .length;
    final accepted = apps.where((a) => a.status == 'accepted').length;

    return ApplicationsListEntity(
      applications: apps,
      totalSubmissions: apps.length,
      inProgressCount: inProgress,
      interviewCount: interviews,
      acceptedCount: accepted,
    );
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
