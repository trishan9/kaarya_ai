import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/core/error/failures.dart';
import 'package:kaarya/core/usecases/app_usecase.dart';
import 'package:kaarya/features/resume_builder/data/repositories/resume_builder_repository.dart';
import 'package:kaarya/features/resume_builder/domain/entities/resume_draft_entity.dart';
import 'package:kaarya/features/resume_builder/domain/repositories/resume_builder_repository.dart';

final generateAiSummaryUseCaseProvider = Provider<GenerateAiSummaryUseCase>((
  ref,
) {
  final repository = ref.read(resumeBuilderRepositoryProvider);
  return GenerateAiSummaryUseCase(repository: repository);
});

class GenerateAiSummaryUseCase
    implements
        UseCaseWithParams<
          AiSummaryResultEntity,
          GenerateAiSummaryUseCaseParams
        > {
  final IResumeBuilderRepository _repository;

  GenerateAiSummaryUseCase({required IResumeBuilderRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, AiSummaryResultEntity>> call(
    GenerateAiSummaryUseCaseParams params,
  ) {
    return _repository.generateAiSummary(
      skills: params.skills,
      experience: params.experience,
      targetRole: params.targetRole,
    );
  }
}

class GenerateAiSummaryUseCaseParams {
  final List<String> skills;
  final List<String> experience;
  final String targetRole;

  const GenerateAiSummaryUseCaseParams({
    required this.skills,
    required this.experience,
    required this.targetRole,
  });
}
