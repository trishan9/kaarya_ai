import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/core/error/failures.dart';
import 'package:kaarya/core/usecases/app_usecase.dart';
import 'package:kaarya/features/applications/data/repositories/application_repository.dart';
import 'package:kaarya/features/applications/domain/entities/application_summary_entity.dart';
import 'package:kaarya/features/applications/domain/repositories/application_repository.dart';

final getApplicationsSummaryUseCaseProvider =
    Provider<GetApplicationsSummaryUseCase>((ref) {
      final repository = ref.read(applicationRepositoryProvider);
      return GetApplicationsSummaryUseCase(repository: repository);
    });

class GetApplicationsSummaryUseCaseParams extends Equatable {
  final String? month;
  final String? statuses;

  const GetApplicationsSummaryUseCaseParams({this.month, this.statuses});

  @override
  List<Object?> get props => [month, statuses];
}

class GetApplicationsSummaryUseCase
    implements
        UseCaseWithParams<
          ApplicationSummaryEntity,
          GetApplicationsSummaryUseCaseParams
        > {
  final IApplicationRepository _repository;

  GetApplicationsSummaryUseCase({required IApplicationRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, ApplicationSummaryEntity>> call(
    GetApplicationsSummaryUseCaseParams params,
  ) {
    return _repository.getApplicationsSummary(
      month: params.month,
      statuses: params.statuses,
    );
  }
}
