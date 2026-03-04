import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/core/error/failures.dart';
import 'package:kaarya/core/usecases/app_usecase.dart';
import 'package:kaarya/features/interviews/data/repositories/interview_repository.dart';
import 'package:kaarya/features/interviews/domain/repositories/interview_repository.dart';

final setInterviewSavedUseCaseProvider = Provider<SetInterviewSavedUseCase>((
  ref,
) {
  final repository = ref.read(interviewRepositoryProvider);
  return SetInterviewSavedUseCase(repository: repository);
});

class SetInterviewSavedUseCase
    implements UseCaseWithParams<bool, SetInterviewSavedUseCaseParams> {
  final IInterviewRepository _repository;

  SetInterviewSavedUseCase({required IInterviewRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, bool>> call(SetInterviewSavedUseCaseParams params) {
    return _repository.setInterviewSaved(
      interviewId: params.interviewId,
      isSaved: params.isSaved,
    );
  }
}

class SetInterviewSavedUseCaseParams {
  final String interviewId;
  final bool isSaved;

  const SetInterviewSavedUseCaseParams({
    required this.interviewId,
    required this.isSaved,
  });
}
