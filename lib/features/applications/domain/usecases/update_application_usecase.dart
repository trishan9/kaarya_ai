import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/core/error/failures.dart';
import 'package:kaarya/core/usecases/app_usecase.dart';
import 'package:kaarya/features/applications/data/repositories/application_repository.dart';
import 'package:kaarya/features/applications/domain/repositories/application_repository.dart';

final updateApplicationUseCaseProvider = Provider<UpdateApplicationUseCase>((
  ref,
) {
  final repository = ref.read(applicationRepositoryProvider);
  return UpdateApplicationUseCase(repository: repository);
});

class UpdateApplicationUseCaseParams extends Equatable {
  final String jobId;
  final String applicationId;
  final String? status;
  final DateTime? interviewScheduledAt;
  final String? interviewNote;

  const UpdateApplicationUseCaseParams({
    required this.jobId,
    required this.applicationId,
    this.status,
    this.interviewScheduledAt,
    this.interviewNote,
  });

  @override
  List<Object?> get props =>
      [jobId, applicationId, status, interviewScheduledAt, interviewNote];
}

class UpdateApplicationUseCase
    implements UseCaseWithParams<bool, UpdateApplicationUseCaseParams> {
  final IApplicationRepository _repository;

  UpdateApplicationUseCase({required IApplicationRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, bool>> call(UpdateApplicationUseCaseParams params) {
    return _repository.updateApplication(
      jobId: params.jobId,
      applicationId: params.applicationId,
      status: params.status,
      interviewScheduledAt: params.interviewScheduledAt,
      interviewNote: params.interviewNote,
    );
  }
}
