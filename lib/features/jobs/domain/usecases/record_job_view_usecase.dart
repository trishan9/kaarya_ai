import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/core/error/failures.dart';
import 'package:kaarya/core/usecases/app_usecase.dart';
import 'package:kaarya/features/jobs/data/repositories/job_repository.dart';
import 'package:kaarya/features/jobs/domain/repositories/job_repository.dart';

class RecordJobViewParams extends Equatable {
  final String jobId;
  const RecordJobViewParams({required this.jobId});
  @override
  List<Object?> get props => [jobId];
}

final recordJobViewUseCaseProvider = Provider<RecordJobViewUseCase>((ref) {
  return RecordJobViewUseCase(repository: ref.read(jobRepositoryProvider));
});

class RecordJobViewUseCase
    implements UseCaseWithParams<void, RecordJobViewParams> {
  final IJobRepository _repository;

  RecordJobViewUseCase({required IJobRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, void>> call(RecordJobViewParams params) {
    return _repository.recordJobView(params.jobId);
  }
}
