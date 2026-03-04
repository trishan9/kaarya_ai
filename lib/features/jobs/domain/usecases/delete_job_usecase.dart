import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/core/error/failures.dart';
import 'package:kaarya/core/usecases/app_usecase.dart';
import 'package:kaarya/features/jobs/data/repositories/job_repository.dart';
import 'package:kaarya/features/jobs/domain/repositories/job_repository.dart';

class DeleteJobParams extends Equatable {
  final String jobId;
  const DeleteJobParams({required this.jobId});
  @override
  List<Object?> get props => [jobId];
}

final deleteJobUseCaseProvider = Provider<DeleteJobUseCase>((ref) {
  return DeleteJobUseCase(repository: ref.read(jobRepositoryProvider));
});

class DeleteJobUseCase implements UseCaseWithParams<bool, DeleteJobParams> {
  final IJobRepository _repository;

  DeleteJobUseCase({required IJobRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, bool>> call(DeleteJobParams params) {
    return _repository.deleteJob(params.jobId);
  }
}
