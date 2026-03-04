import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/core/error/failures.dart';
import 'package:kaarya/core/services/connectivity/network_info.dart';
import 'package:kaarya/features/jobs/data/datasources/job_datasource.dart';
import 'package:kaarya/features/jobs/data/datasources/local/job_local_datasource.dart';
import 'package:kaarya/features/jobs/data/datasources/remote/job_remote_datasource.dart';
import 'package:kaarya/features/jobs/data/models/job_hive_model.dart';
import 'package:kaarya/features/jobs/domain/entities/job_entity.dart';
import 'package:kaarya/features/jobs/domain/entities/job_detail_entity.dart';
import 'package:kaarya/features/jobs/domain/entities/job_metrics_entity.dart';
import 'package:kaarya/features/jobs/domain/entities/jobs_section_entity.dart';
import 'package:kaarya/features/jobs/domain/repositories/job_repository.dart';

final jobRepositoryProvider = Provider<IJobRepository>((ref) {
  final remote = ref.read(jobRemoteDatasourceProvider);
  final local = ref.read(jobLocalDatasourceProvider);
  final networkInfo = ref.read(networkInfoProvider);
  return JobRepository(remote: remote, local: local, networkInfo: networkInfo);
});

class JobRepository implements IJobRepository {
  final IJobRemoteDataSource _remote;
  final IJobLocalDataSource _local;
  final NetworkInfo _networkInfo;

  JobRepository({
    required IJobRemoteDataSource remote,
    required IJobLocalDataSource local,
    required NetworkInfo networkInfo,
  }) : _remote = remote,
       _local = local,
       _networkInfo = networkInfo;

  @override
  Future<Either<Failure, JobsSectionEntity>> getJobsSection({
    String? searchQuery,
    String? locationQuery,
    String? status,
    String? employmentType,
    String? engagementType,
  }) async {
    if (await _networkInfo.isConnected) {
      try {
        final data = await _remote.getJobsSection(
          searchQuery: searchQuery,
          locationQuery: locationQuery,
          status: status,
          employmentType: employmentType,
          engagementType: engagementType,
        );
        await _local.saveJobsSection(JobsSectionHiveModel.fromApiModel(data));
        return Right(data.toEntity());
      } on DioException catch (e) {
        final cached = await _local.getJobsSection();
        if (cached != null) {
          return Right(cached.toApiModel().toEntity());
        }
        return Left(
          ApiFailure(
            statusCode: e.response?.statusCode,
            message: e.response?.data['message'] ?? 'Failed to load jobs',
          ),
        );
      } catch (e) {
        final cached = await _local.getJobsSection();
        if (cached != null) return Right(cached.toApiModel().toEntity());
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      final cached = await _local.getJobsSection();
      if (cached != null) return Right(cached.toApiModel().toEntity());
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, JobDetailEntity>> getJobDetail(String jobId) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      final data = await _remote.getJobDetail(jobId);
      final cached = await _local.getJobsSection();
      final cachedSection = cached?.toApiModel();
      final similarJobs = cachedSection != null
          ? cachedSection.jobs.forYou
                .where((j) => j.id != jobId)
                .take(5)
                .map((e) => e.toEntity())
                .toList()
          : <JobEntity>[];
      return Right(data.toEntity(similarJobs: similarJobs));
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          statusCode: e.response?.statusCode,
          message: e.response?.data['message'] ?? 'Failed to load job details',
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> recordJobView(String jobId) async {
    if (!await _networkInfo.isConnected) return const Right(null);
    try {
      await _remote.recordJobView(jobId);
      return const Right(null);
    } catch (_) {
      return const Right(null);
    }
  }

  @override
  Future<Either<Failure, JobEntity>> createJob(
    Map<String, dynamic> data,
  ) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      final model = await _remote.createJob(data);
      return Right(model.toEntity());
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          statusCode: e.response?.statusCode,
          message: e.response?.data['message'] ?? 'Failed to create job',
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, JobEntity>> updateJob(
    String jobId,
    Map<String, dynamic> data,
  ) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      final model = await _remote.updateJob(jobId, data);
      return Right(model.toEntity());
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          statusCode: e.response?.statusCode,
          message: e.response?.data['message'] ?? 'Failed to update job',
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteJob(String jobId) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      final ok = await _remote.deleteJob(jobId);
      return Right(ok);
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          statusCode: e.response?.statusCode,
          message: e.response?.data['message'] ?? 'Failed to delete job',
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, JobMetricsEntity>> getJobMetrics(String jobId) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      final model = await _remote.getJobMetrics(jobId);
      return Right(model.toEntity());
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          statusCode: e.response?.statusCode,
          message: e.response?.data['message'] ?? 'Failed to load job metrics',
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> applyToJob(
    String jobId, {
    String? resumeId,
    String? coverLetter,
    List<String>? portfolioLinks,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      final ok = await _remote.applyToJob(
        jobId,
        resumeId: resumeId,
        coverLetter: coverLetter,
        portfolioLinks: portfolioLinks,
      );
      return Right(ok);
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          statusCode: e.response?.statusCode,
          message: e.response?.data['message'] ?? 'Failed to apply',
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> toggleJobBookmark(
    String jobId,
    bool save,
  ) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      final ok = await _remote.toggleJobBookmark(jobId, save);
      return Right(ok);
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          statusCode: e.response?.statusCode,
          message: e.response?.data['message'] ?? 'Failed to update bookmark',
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }
}
