import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/core/error/failures.dart';
import 'package:kaarya/core/usecases/app_usecase.dart';
import 'package:kaarya/features/applications/data/repositories/application_repository.dart';
import 'package:kaarya/features/applications/domain/repositories/application_repository.dart';

final updateResumeActivityUseCaseProvider =
    Provider<UpdateResumeActivityUseCase>((ref) {
      final repository = ref.read(applicationRepositoryProvider);
      return UpdateResumeActivityUseCase(repository: repository);
    });

class UpdateResumeActivityUseCaseParams extends Equatable {
  final String jobId;
  final String applicationId;
  final String action;

  const UpdateResumeActivityUseCaseParams({
    required this.jobId,
    required this.applicationId,
    required this.action,
  });

  @override
  List<Object?> get props => [jobId, applicationId, action];
}

class UpdateResumeActivityUseCase
    implements UseCaseWithParams<bool, UpdateResumeActivityUseCaseParams> {
  final IApplicationRepository _repository;

  UpdateResumeActivityUseCase({required IApplicationRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, bool>> call(UpdateResumeActivityUseCaseParams params) {
    return _repository.updateResumeActivity(
      jobId: params.jobId,
      applicationId: params.applicationId,
      action: params.action,
    );
  }
}
