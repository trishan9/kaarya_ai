import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/core/error/failures.dart';
import 'package:kaarya/core/usecases/app_usecase.dart';
import 'package:kaarya/features/resume_builder/data/repositories/resume_builder_repository.dart';
import 'package:kaarya/features/resume_builder/domain/entities/resume_draft_entity.dart';
import 'package:kaarya/features/resume_builder/domain/repositories/resume_builder_repository.dart';

final generatePdfUseCaseProvider = Provider<GeneratePdfUseCase>((ref) {
  final repository = ref.read(resumeBuilderRepositoryProvider);
  return GeneratePdfUseCase(repository: repository);
});

class GeneratePdfUseCase
    implements
        UseCaseWithParams<GeneratePdfResultEntity, GeneratePdfUseCaseParams> {
  final IResumeBuilderRepository _repository;

  GeneratePdfUseCase({required IResumeBuilderRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, GeneratePdfResultEntity>> call(
    GeneratePdfUseCaseParams params,
  ) {
    return _repository.generatePdf(params.draftId);
  }
}

class GeneratePdfUseCaseParams {
  final String draftId;

  const GeneratePdfUseCaseParams({required this.draftId});
}
