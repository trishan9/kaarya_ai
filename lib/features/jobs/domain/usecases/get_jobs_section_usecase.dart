import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/core/error/failures.dart';
import 'package:kaarya/core/usecases/app_usecase.dart';
import 'package:kaarya/features/jobs/data/repositories/job_repository.dart';
import 'package:kaarya/features/jobs/domain/entities/jobs_section_entity.dart';
import 'package:kaarya/features/jobs/domain/repositories/job_repository.dart';

class GetJobsSectionParams extends Equatable {
  final String? searchQuery;
  final String? locationQuery;
  final String? status;
  final String? employmentType;
  final String? engagementType;

  const GetJobsSectionParams({
    this.searchQuery,
    this.locationQuery,
    this.status,
    this.employmentType,
    this.engagementType,
  });

  @override
  List<Object?> get props => [
    searchQuery,
    locationQuery,
    status,
    employmentType,
    engagementType,
  ];
}

final getJobsSectionUseCaseProvider = Provider<GetJobsSectionUseCase>((ref) {
  return GetJobsSectionUseCase(repository: ref.read(jobRepositoryProvider));
});

class GetJobsSectionUseCase
    implements UseCaseWithParams<JobsSectionEntity, GetJobsSectionParams> {
  final IJobRepository _repository;

  GetJobsSectionUseCase({required IJobRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, JobsSectionEntity>> call(GetJobsSectionParams params) {
    return _repository.getJobsSection(
      searchQuery: params.searchQuery,
      locationQuery: params.locationQuery,
      status: params.status,
      employmentType: params.employmentType,
      engagementType: params.engagementType,
    );
  }
}
