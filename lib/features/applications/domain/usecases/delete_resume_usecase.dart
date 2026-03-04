import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/core/error/failures.dart';
import 'package:kaarya/core/usecases/app_usecase.dart';
import 'package:kaarya/features/applications/data/repositories/application_repository.dart';
import 'package:kaarya/features/applications/domain/repositories/application_repository.dart';

final deleteResumeUseCaseProvider = Provider<DeleteResumeUseCase>((ref) {
  final repository = ref.read(applicationRepositoryProvider);
  return DeleteResumeUseCase(repository: repository);
});

class DeleteResumeUseCaseParams extends Equatable {
  final String resumeId;

  const DeleteResumeUseCaseParams({required this.resumeId});

  @override
  List<Object?> get props => [resumeId];
}

class DeleteResumeUseCase
    implements UseCaseWithParams<bool, DeleteResumeUseCaseParams> {
  final IApplicationRepository _repository;

  DeleteResumeUseCase({required IApplicationRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, bool>> call(DeleteResumeUseCaseParams params) {
    return _repository.deleteResume(resumeId: params.resumeId);
  }
}
