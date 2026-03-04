import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/core/error/failures.dart';
import 'package:kaarya/core/usecases/app_usecase.dart';
import 'package:kaarya/features/applications/data/repositories/application_repository.dart';
import 'package:kaarya/features/applications/domain/entities/application_entity.dart';
import 'package:kaarya/features/applications/domain/repositories/application_repository.dart';

final getJobApplicationsUseCaseProvider = Provider<GetJobApplicationsUseCase>((
  ref,
) {
  final repository = ref.read(applicationRepositoryProvider);
  return GetJobApplicationsUseCase(repository: repository);
});

class GetJobApplicationsUseCaseParams extends Equatable {
  final String jobId;
  final int page;
  final int size;
  final String? status;

  const GetJobApplicationsUseCaseParams({
    required this.jobId,
    this.page = 1,
    this.size = 50,
    this.status,
  });

  @override
  List<Object?> get props => [jobId, page, size, status];
}

class GetJobApplicationsUseCase
    implements
        UseCaseWithParams<
          ApplicationsListEntity,
          GetJobApplicationsUseCaseParams
        > {
  final IApplicationRepository _repository;

  GetJobApplicationsUseCase({required IApplicationRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, ApplicationsListEntity>> call(
    GetJobApplicationsUseCaseParams params,
  ) {
    return _repository.getJobApplications(
      jobId: params.jobId,
      page: params.page,
      size: params.size,
      status: params.status,
    );
  }
}
