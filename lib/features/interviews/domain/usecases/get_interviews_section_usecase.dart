import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/core/error/failures.dart';
import 'package:kaarya/core/usecases/app_usecase.dart';
import 'package:kaarya/features/interviews/data/repositories/interview_repository.dart';
import 'package:kaarya/features/interviews/domain/entities/interview_section_entity.dart';
import 'package:kaarya/features/interviews/domain/repositories/interview_repository.dart';

final getInterviewsSectionUseCaseProvider =
    Provider<GetInterviewsSectionUseCase>((ref) {
      final repository = ref.read(interviewRepositoryProvider);
      return GetInterviewsSectionUseCase(repository: repository);
    });

class GetInterviewsSectionUseCase
    implements
        UseCaseWithParams<
          InterviewsSectionEntity,
          GetInterviewsSectionUseCaseParams
        > {
  final IInterviewRepository _repository;

  GetInterviewsSectionUseCase({required IInterviewRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, InterviewsSectionEntity>> call(
    GetInterviewsSectionUseCaseParams params,
  ) {
    return _repository.getInterviewsSection(
      searchQuery: params.searchQuery,
      interviewType: params.interviewType,
      status: params.status,
      sortBy: params.sortBy,
      attemptFilter: params.attemptFilter,
    );
  }
}

class GetInterviewsSectionUseCaseParams {
  final String? searchQuery;
  final String? interviewType;
  final String? status;
  final String? sortBy;
  final String? attemptFilter;

  const GetInterviewsSectionUseCaseParams({
    this.searchQuery,
    this.interviewType,
    this.status,
    this.sortBy,
    this.attemptFilter,
  });
}
