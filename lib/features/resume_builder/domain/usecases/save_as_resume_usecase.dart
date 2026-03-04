import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/core/error/failures.dart';
import 'package:kaarya/core/usecases/app_usecase.dart';
import 'package:kaarya/features/resume_builder/data/repositories/resume_builder_repository.dart';
import 'package:kaarya/features/resume_builder/domain/repositories/resume_builder_repository.dart';

final saveAsResumeUseCaseProvider = Provider<SaveAsResumeUseCase>((ref) {
  final repository = ref.read(resumeBuilderRepositoryProvider);
  return SaveAsResumeUseCase(repository: repository);
});

class SaveAsResumeUseCase
    implements UseCaseWithParams<bool, SaveAsResumeUseCaseParams> {
  final IResumeBuilderRepository _repository;

  SaveAsResumeUseCase({required IResumeBuilderRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, bool>> call(SaveAsResumeUseCaseParams params) {
    return _repository.saveAsResume(params.draftId);
  }
}

class SaveAsResumeUseCaseParams {
  final String draftId;

  const SaveAsResumeUseCaseParams({required this.draftId});
}
