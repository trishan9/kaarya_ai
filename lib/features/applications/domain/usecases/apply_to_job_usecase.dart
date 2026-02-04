import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/core/error/failures.dart';
import 'package:kaarya/core/usecases/app_usecase.dart';
import 'package:kaarya/features/applications/data/repositories/application_repository.dart';
import 'package:kaarya/features/applications/domain/repositories/application_repository.dart';

final applyToJobUseCaseProvider = Provider<ApplyToJobUseCase>((ref) {
  final repository = ref.read(applicationRepositoryProvider);
  return ApplyToJobUseCase(repository: repository);
});

class ApplyToJobUseCaseParams extends Equatable {
  final String jobId;
  final String? resumeId;
  final String? resumeFilePath;
  final List<int>? resumeBytes;
  final String? resumeFilename;
  final String? coverLetter;
  final List<String>? portfolioLinks;

  const ApplyToJobUseCaseParams({
    required this.jobId,
    this.resumeId,
    this.resumeFilePath,
    this.resumeBytes,
    this.resumeFilename,
    this.coverLetter,
    this.portfolioLinks,
  });

  @override
  List<Object?> get props => [
        jobId,
        resumeId,
        resumeFilePath,
        resumeBytes,
        resumeFilename,
        coverLetter,
        portfolioLinks,
      ];
}

class ApplyToJobUseCase
    implements UseCaseWithParams<bool, ApplyToJobUseCaseParams> {
  final IApplicationRepository _repository;

  ApplyToJobUseCase({required IApplicationRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, bool>> call(ApplyToJobUseCaseParams params) {
    return _repository.applyToJob(
      jobId: params.jobId,
      resumeId: params.resumeId,
      resumeFilePath: params.resumeFilePath,
      resumeBytes: params.resumeBytes,
      resumeFilename: params.resumeFilename,
      coverLetter: params.coverLetter,
      portfolioLinks: params.portfolioLinks,
    );
  }
}
