import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/core/error/failures.dart';
import 'package:kaarya/core/usecases/app_usecase.dart';
import 'package:kaarya/features/resume_builder/data/repositories/resume_builder_repository.dart';
import 'package:kaarya/features/resume_builder/domain/entities/resume_draft_entity.dart';
import 'package:kaarya/features/resume_builder/domain/repositories/resume_builder_repository.dart';

final listDraftsUseCaseProvider = Provider<ListDraftsUseCase>((ref) {
  final repository = ref.read(resumeBuilderRepositoryProvider);
  return ListDraftsUseCase(repository: repository);
});

class ListDraftsUseCase
    implements
        UseCaseWithParams<ResumeDraftsListEntity, ListDraftsUseCaseParams> {
  final IResumeBuilderRepository _repository;

  ListDraftsUseCase({required IResumeBuilderRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, ResumeDraftsListEntity>> call(
    ListDraftsUseCaseParams params,
  ) {
    return _repository.listDrafts(page: params.page, size: params.size);
  }
}

class ListDraftsUseCaseParams {
  final int page;
  final int size;

  const ListDraftsUseCaseParams({this.page = 1, this.size = 20});
}
