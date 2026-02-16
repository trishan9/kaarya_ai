import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/core/error/failures.dart';
import 'package:kaarya/core/usecases/app_usecase.dart';
import 'package:kaarya/features/resume_builder/data/repositories/resume_builder_repository.dart';
import 'package:kaarya/features/resume_builder/domain/repositories/resume_builder_repository.dart';

final deleteDraftUseCaseProvider = Provider<DeleteDraftUseCase>((ref) {
  final repository = ref.read(resumeBuilderRepositoryProvider);
  return DeleteDraftUseCase(repository: repository);
});

class DeleteDraftUseCase
    implements UseCaseWithParams<bool, DeleteDraftUseCaseParams> {
  final IResumeBuilderRepository _repository;

  DeleteDraftUseCase({required IResumeBuilderRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, bool>> call(DeleteDraftUseCaseParams params) {
    return _repository.deleteDraft(params.draftId);
  }
}

class DeleteDraftUseCaseParams {
  final String draftId;

  const DeleteDraftUseCaseParams({required this.draftId});
}
