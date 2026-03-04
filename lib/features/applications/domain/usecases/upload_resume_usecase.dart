import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/core/error/failures.dart';
import 'package:kaarya/core/usecases/app_usecase.dart';
import 'package:kaarya/features/applications/data/repositories/application_repository.dart';
import 'package:kaarya/features/applications/domain/entities/resume_entity.dart';
import 'package:kaarya/features/applications/domain/repositories/application_repository.dart';

final uploadResumeUseCaseProvider = Provider<UploadResumeUseCase>((ref) {
  final repository = ref.read(applicationRepositoryProvider);
  return UploadResumeUseCase(repository: repository);
});

class UploadResumeUseCaseParams extends Equatable {
  final String filePath;

  const UploadResumeUseCaseParams({required this.filePath});

  @override
  List<Object?> get props => [filePath];
}

class UploadResumeUseCase
    implements UseCaseWithParams<ResumeEntity, UploadResumeUseCaseParams> {
  final IApplicationRepository _repository;

  UploadResumeUseCase({required IApplicationRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, ResumeEntity>> call(UploadResumeUseCaseParams params) {
    return _repository.uploadResume(filePath: params.filePath);
  }
}
