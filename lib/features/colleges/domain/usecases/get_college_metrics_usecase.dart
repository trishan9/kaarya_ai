import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/core/error/failures.dart';
import 'package:kaarya/core/usecases/app_usecase.dart';
import 'package:kaarya/features/colleges/data/repositories/college_repository.dart';
import 'package:kaarya/features/colleges/domain/entities/college_metrics_entity.dart';
import 'package:kaarya/features/colleges/domain/repositories/college_repository.dart';

final getCollegeMetricsUseCaseProvider = Provider<GetCollegeMetricsUseCase>((
  ref,
) {
  return GetCollegeMetricsUseCase(
    repository: ref.read(collegeRepositoryProvider),
  );
});

class GetCollegeMetricsUseCaseParams extends Equatable {
  final String collegeId;

  const GetCollegeMetricsUseCaseParams({required this.collegeId});

  @override
  List<Object?> get props => [collegeId];
}

class GetCollegeMetricsUseCase
    implements
        UseCaseWithParams<
          CollegeMetricsEntity,
          GetCollegeMetricsUseCaseParams
        > {
  final ICollegeRepository _repository;

  GetCollegeMetricsUseCase({required ICollegeRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, CollegeMetricsEntity>> call(
    GetCollegeMetricsUseCaseParams params,
  ) {
    return _repository.getCollegeMetrics(params.collegeId);
  }
}
