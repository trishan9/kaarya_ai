import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/core/error/failures.dart';
import 'package:kaarya/core/usecases/app_usecase.dart';
import 'package:kaarya/features/applications/data/repositories/application_repository.dart';
import 'package:kaarya/features/applications/domain/entities/application_entity.dart';
import 'package:kaarya/features/applications/domain/repositories/application_repository.dart';

final getMyApplicationsUseCaseProvider = Provider<GetMyApplicationsUseCase>((
  ref,
) {
  final repository = ref.read(applicationRepositoryProvider);
  return GetMyApplicationsUseCase(repository: repository);
});

class GetMyApplicationsUseCaseParams extends Equatable {
  final int page;
  final int size;
  final String? status;

  const GetMyApplicationsUseCaseParams({
    this.page = 1,
    this.size = 50,
    this.status,
  });

  @override
  List<Object?> get props => [page, size, status];
}

class GetMyApplicationsUseCase
    implements
        UseCaseWithParams<
          ApplicationsListEntity,
          GetMyApplicationsUseCaseParams
        > {
  final IApplicationRepository _repository;

  GetMyApplicationsUseCase({required IApplicationRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, ApplicationsListEntity>> call(
    GetMyApplicationsUseCaseParams params,
  ) {
    return _repository.getMyApplications(
      page: params.page,
      size: params.size,
      status: params.status,
    );
  }
}
