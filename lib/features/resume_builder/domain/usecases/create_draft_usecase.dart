import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/core/error/failures.dart';
import 'package:kaarya/core/usecases/app_usecase.dart';
import 'package:kaarya/features/resume_builder/data/repositories/resume_builder_repository.dart';
import 'package:kaarya/features/resume_builder/domain/entities/resume_draft_entity.dart';
import 'package:kaarya/features/resume_builder/domain/repositories/resume_builder_repository.dart';

final createDraftUseCaseProvider = Provider<CreateDraftUseCase>((ref) {
  final repository = ref.read(resumeBuilderRepositoryProvider);
  return CreateDraftUseCase(repository: repository);
});

class CreateDraftUseCase
    implements UseCaseWithParams<ResumeDraftEntity, CreateDraftUseCaseParams> {
  final IResumeBuilderRepository _repository;

  CreateDraftUseCase({required IResumeBuilderRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, ResumeDraftEntity>> call(
    CreateDraftUseCaseParams params,
  ) {
    return _repository.createDraft(
      title: params.title,
      template: params.template,
      personalInfo: params.personalInfo,
      sections: params.sections,
    );
  }
}

class CreateDraftUseCaseParams {
  final String title;
  final String template;
  final Map<String, dynamic>? personalInfo;
  final Map<String, dynamic>? sections;

  const CreateDraftUseCaseParams({
    required this.title,
    required this.template,
    this.personalInfo,
    this.sections,
  });
}
