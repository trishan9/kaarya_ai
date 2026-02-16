import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/core/error/failures.dart';
import 'package:kaarya/core/usecases/app_usecase.dart';
import 'package:kaarya/features/resume_builder/data/repositories/resume_builder_repository.dart';
import 'package:kaarya/features/resume_builder/domain/entities/resume_draft_entity.dart';
import 'package:kaarya/features/resume_builder/domain/repositories/resume_builder_repository.dart';

final updateDraftUseCaseProvider = Provider<UpdateDraftUseCase>((ref) {
  final repository = ref.read(resumeBuilderRepositoryProvider);
  return UpdateDraftUseCase(repository: repository);
});

class UpdateDraftUseCase
    implements UseCaseWithParams<ResumeDraftEntity, UpdateDraftUseCaseParams> {
  final IResumeBuilderRepository _repository;

  UpdateDraftUseCase({required IResumeBuilderRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, ResumeDraftEntity>> call(
    UpdateDraftUseCaseParams params,
  ) {
    return _repository.updateDraft(
      draftId: params.draftId,
      fields: params.fields,
    );
  }
}

class UpdateDraftUseCaseParams {
  final String draftId;
  final Map<String, dynamic> fields;

  const UpdateDraftUseCaseParams({required this.draftId, required this.fields});
}
