import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/core/error/failures.dart';
import 'package:kaarya/core/usecases/app_usecase.dart';
import 'package:kaarya/features/resume_builder/data/repositories/resume_builder_repository.dart';
import 'package:kaarya/features/resume_builder/domain/entities/resume_draft_entity.dart';
import 'package:kaarya/features/resume_builder/domain/repositories/resume_builder_repository.dart';

final generateAiSuggestionsUseCaseProvider =
    Provider<GenerateAiSuggestionsUseCase>((ref) {
      final repository = ref.read(resumeBuilderRepositoryProvider);
      return GenerateAiSuggestionsUseCase(repository: repository);
    });

class GenerateAiSuggestionsUseCase
    implements
        UseCaseWithParams<
          AiSuggestionsResultEntity,
          GenerateAiSuggestionsUseCaseParams
        > {
  final IResumeBuilderRepository _repository;

  GenerateAiSuggestionsUseCase({required IResumeBuilderRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, AiSuggestionsResultEntity>> call(
    GenerateAiSuggestionsUseCaseParams params,
  ) {
    return _repository.generateAiSuggestions(
      step: params.step,
      resumeData: params.resumeData,
    );
  }
}

class GenerateAiSuggestionsUseCaseParams {
  final String step;
  final Map<String, dynamic> resumeData;

  const GenerateAiSuggestionsUseCaseParams({
    required this.step,
    required this.resumeData,
  });
}
