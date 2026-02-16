import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/core/error/failures.dart';
import 'package:kaarya/core/usecases/app_usecase.dart';
import 'package:kaarya/features/resume_builder/data/repositories/resume_builder_repository.dart';
import 'package:kaarya/features/resume_builder/domain/entities/resume_draft_entity.dart';
import 'package:kaarya/features/resume_builder/domain/repositories/resume_builder_repository.dart';

final generateExperienceBulletsUseCaseProvider =
    Provider<GenerateExperienceBulletsUseCase>((ref) {
      final repository = ref.read(resumeBuilderRepositoryProvider);
      return GenerateExperienceBulletsUseCase(repository: repository);
    });

class GenerateExperienceBulletsUseCase
    implements
        UseCaseWithParams<
          ExperienceBulletsResultEntity,
          GenerateExperienceBulletsUseCaseParams
        > {
  final IResumeBuilderRepository _repository;

  GenerateExperienceBulletsUseCase({
    required IResumeBuilderRepository repository,
  }) : _repository = repository;

  @override
  Future<Either<Failure, ExperienceBulletsResultEntity>> call(
    GenerateExperienceBulletsUseCaseParams params,
  ) {
    return _repository.generateExperienceBullets(
      jobTitle: params.jobTitle,
      responsibilities: params.responsibilities,
      techStack: params.techStack,
    );
  }
}

class GenerateExperienceBulletsUseCaseParams {
  final String jobTitle;
  final String responsibilities;
  final List<String> techStack;

  const GenerateExperienceBulletsUseCaseParams({
    required this.jobTitle,
    required this.responsibilities,
    required this.techStack,
  });
}
