import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/core/error/failures.dart';
import 'package:kaarya/core/usecases/app_usecase.dart';
import 'package:kaarya/features/applications/data/repositories/application_repository.dart';
import 'package:kaarya/features/applications/domain/entities/application_entity.dart';
import 'package:kaarya/features/applications/domain/repositories/application_repository.dart';

final getApplicationForJobUseCaseProvider =
    Provider<GetApplicationForJobUseCase>((ref) {
      final repository = ref.read(applicationRepositoryProvider);
      return GetApplicationForJobUseCase(repository: repository);
    });

class GetApplicationForJobUseCaseParams extends Equatable {
  final String jobId;

  const GetApplicationForJobUseCaseParams({required this.jobId});

  @override
  List<Object?> get props => [jobId];
}

class GetApplicationForJobUseCase
    implements
        UseCaseWithParams<
          ApplicationEntity,
          GetApplicationForJobUseCaseParams
        > {
  final IApplicationRepository _repository;

  GetApplicationForJobUseCase({required IApplicationRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, ApplicationEntity>> call(
    GetApplicationForJobUseCaseParams params,
  ) {
    return _repository.getApplicationForJob(jobId: params.jobId);
  }
}
