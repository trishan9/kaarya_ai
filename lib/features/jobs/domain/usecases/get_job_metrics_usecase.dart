import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/core/error/failures.dart';
import 'package:kaarya/core/usecases/app_usecase.dart';
import 'package:kaarya/features/jobs/data/repositories/job_repository.dart';
import 'package:kaarya/features/jobs/domain/entities/job_metrics_entity.dart';
import 'package:kaarya/features/jobs/domain/repositories/job_repository.dart';

class GetJobMetricsParams extends Equatable {
  final String jobId;
  const GetJobMetricsParams({required this.jobId});
  @override
  List<Object?> get props => [jobId];
}

final getJobMetricsUseCaseProvider = Provider<GetJobMetricsUseCase>((ref) {
  return GetJobMetricsUseCase(repository: ref.read(jobRepositoryProvider));
});

class GetJobMetricsUseCase
    implements UseCaseWithParams<JobMetricsEntity, GetJobMetricsParams> {
  final IJobRepository _repository;

  GetJobMetricsUseCase({required IJobRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, JobMetricsEntity>> call(GetJobMetricsParams params) {
    return _repository.getJobMetrics(params.jobId);
  }
}
