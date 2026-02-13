import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/core/error/failures.dart';
import 'package:kaarya/core/usecases/app_usecase.dart';
import 'package:kaarya/features/jobs/data/repositories/job_repository.dart';
import 'package:kaarya/features/jobs/domain/entities/job_detail_entity.dart';
import 'package:kaarya/features/jobs/domain/repositories/job_repository.dart';

class GetJobDetailParams extends Equatable {
  final String jobId;
  const GetJobDetailParams({required this.jobId});
  @override
  List<Object?> get props => [jobId];
}

final getJobDetailUseCaseProvider = Provider<GetJobDetailUseCase>((ref) {
  return GetJobDetailUseCase(repository: ref.read(jobRepositoryProvider));
});

class GetJobDetailUseCase
    implements UseCaseWithParams<JobDetailEntity, GetJobDetailParams> {
  final IJobRepository _repository;

  GetJobDetailUseCase({required IJobRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, JobDetailEntity>> call(GetJobDetailParams params) {
    return _repository.getJobDetail(params.jobId);
  }
}
