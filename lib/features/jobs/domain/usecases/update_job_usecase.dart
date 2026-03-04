import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/core/error/failures.dart';
import 'package:kaarya/core/usecases/app_usecase.dart';
import 'package:kaarya/features/jobs/data/repositories/job_repository.dart';
import 'package:kaarya/features/jobs/domain/entities/job_entity.dart';
import 'package:kaarya/features/jobs/domain/repositories/job_repository.dart';

class UpdateJobParams extends Equatable {
  final String jobId;
  final Map<String, dynamic> data;
  const UpdateJobParams({required this.jobId, required this.data});
  @override
  List<Object?> get props => [jobId, data];
}

final updateJobUseCaseProvider = Provider<UpdateJobUseCase>((ref) {
  return UpdateJobUseCase(repository: ref.read(jobRepositoryProvider));
});

class UpdateJobUseCase
    implements UseCaseWithParams<JobEntity, UpdateJobParams> {
  final IJobRepository _repository;

  UpdateJobUseCase({required IJobRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, JobEntity>> call(UpdateJobParams params) {
    return _repository.updateJob(params.jobId, params.data);
  }
}
