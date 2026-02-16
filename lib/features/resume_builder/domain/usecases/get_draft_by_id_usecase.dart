import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/core/error/failures.dart';
import 'package:kaarya/core/usecases/app_usecase.dart';
import 'package:kaarya/features/resume_builder/data/repositories/resume_builder_repository.dart';
import 'package:kaarya/features/resume_builder/domain/entities/resume_draft_entity.dart';
import 'package:kaarya/features/resume_builder/domain/repositories/resume_builder_repository.dart';

final getDraftByIdUseCaseProvider = Provider<GetDraftByIdUseCase>((ref) {
  final repository = ref.read(resumeBuilderRepositoryProvider);
  return GetDraftByIdUseCase(repository: repository);
});

class GetDraftByIdUseCase
    implements UseCaseWithParams<ResumeDraftEntity, GetDraftByIdUseCaseParams> {
  final IResumeBuilderRepository _repository;

  GetDraftByIdUseCase({required IResumeBuilderRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, ResumeDraftEntity>> call(
    GetDraftByIdUseCaseParams params,
  ) {
    return _repository.getDraftById(params.draftId);
  }
}

class GetDraftByIdUseCaseParams {
  final String draftId;

  const GetDraftByIdUseCaseParams({required this.draftId});
}
