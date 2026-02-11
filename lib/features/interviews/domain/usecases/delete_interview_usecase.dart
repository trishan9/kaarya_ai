import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/core/error/failures.dart';
import 'package:kaarya/core/usecases/app_usecase.dart';
import 'package:kaarya/features/interviews/data/repositories/interview_repository.dart';
import 'package:kaarya/features/interviews/domain/repositories/interview_repository.dart';

final deleteInterviewUseCaseProvider = Provider<DeleteInterviewUseCase>((ref) {
  final repository = ref.read(interviewRepositoryProvider);
  return DeleteInterviewUseCase(repository: repository);
});

class DeleteInterviewUseCase
    implements UseCaseWithParams<bool, DeleteInterviewUseCaseParams> {
  final IInterviewRepository _repository;

  DeleteInterviewUseCase({required IInterviewRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, bool>> call(DeleteInterviewUseCaseParams params) {
    return _repository.deleteInterview(params.id);
  }
}

class DeleteInterviewUseCaseParams {
  final String id;

  const DeleteInterviewUseCaseParams({required this.id});
}
