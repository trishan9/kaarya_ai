import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/core/error/failures.dart';
import 'package:kaarya/core/usecases/app_usecase.dart';
import 'package:kaarya/features/interviews/data/repositories/interview_repository.dart';
import 'package:kaarya/features/interviews/domain/entities/interview_analytics_entity.dart';
import 'package:kaarya/features/interviews/domain/repositories/interview_repository.dart';

final getInterviewAnalyticsUseCaseProvider =
    Provider<GetInterviewAnalyticsUseCase>((ref) {
      final repository = ref.read(interviewRepositoryProvider);
      return GetInterviewAnalyticsUseCase(repository: repository);
    });

class GetInterviewAnalyticsUseCase
    implements
        UseCaseWithParams<
          InterviewAnalyticsEntity,
          GetInterviewAnalyticsUseCaseParams
        > {
  final IInterviewRepository _repository;

  GetInterviewAnalyticsUseCase({required IInterviewRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, InterviewAnalyticsEntity>> call(
    GetInterviewAnalyticsUseCaseParams params,
  ) {
    return _repository.getInterviewAnalytics(params.interviewId);
  }
}

class GetInterviewAnalyticsUseCaseParams {
  final String interviewId;

  const GetInterviewAnalyticsUseCaseParams({required this.interviewId});
}
