import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/core/error/failures.dart';
import 'package:kaarya/core/usecases/app_usecase.dart';
import 'package:kaarya/features/jobs/data/repositories/job_repository.dart';
import 'package:kaarya/features/jobs/domain/entities/job_entity.dart';
import 'package:kaarya/features/jobs/domain/repositories/job_repository.dart';

class CreateJobParams {
  final Map<String, dynamic> data;
  const CreateJobParams({required this.data});
}

final createJobUseCaseProvider = Provider<CreateJobUseCase>((ref) {
  return CreateJobUseCase(repository: ref.read(jobRepositoryProvider));
});

class CreateJobUseCase
    implements UseCaseWithParams<JobEntity, CreateJobParams> {
  final IJobRepository _repository;

  CreateJobUseCase({required IJobRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, JobEntity>> call(CreateJobParams params) {
    return _repository.createJob(params.data);
  }
}
