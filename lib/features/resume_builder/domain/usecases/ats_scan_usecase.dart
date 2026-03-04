import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/core/error/failures.dart';
import 'package:kaarya/core/usecases/app_usecase.dart';
import 'package:kaarya/features/resume_builder/data/repositories/resume_builder_repository.dart';
import 'package:kaarya/features/resume_builder/domain/entities/ats_scan_result_entity.dart';
import 'package:kaarya/features/resume_builder/domain/repositories/resume_builder_repository.dart';

final atsScanUseCaseProvider = Provider<AtsScanUseCase>((ref) {
  final repository = ref.read(resumeBuilderRepositoryProvider);
  return AtsScanUseCase(repository: repository);
});

class AtsScanUseCase
    implements UseCaseWithParams<AtsScanResultEntity, AtsScanUseCaseParams> {
  final IResumeBuilderRepository _repository;

  AtsScanUseCase({required IResumeBuilderRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, AtsScanResultEntity>> call(
    AtsScanUseCaseParams params,
  ) {
    return _repository.atsScan(
      filePath: params.filePath,
      targetRole: params.targetRole,
      experienceLevel: params.experienceLevel,
      jobDescription: params.jobDescription,
    );
  }
}

class AtsScanUseCaseParams {
  final String filePath;
  final String? targetRole;
  final String? experienceLevel;
  final String? jobDescription;

  const AtsScanUseCaseParams({
    required this.filePath,
    this.targetRole,
    this.experienceLevel,
    this.jobDescription,
  });
}
