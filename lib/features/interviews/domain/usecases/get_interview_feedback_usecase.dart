import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/core/error/failures.dart';
import 'package:kaarya/core/usecases/app_usecase.dart';
import 'package:kaarya/features/interviews/data/repositories/interview_repository.dart';
import 'package:kaarya/features/interviews/domain/entities/interview_feedback_entity.dart';
import 'package:kaarya/features/interviews/domain/repositories/interview_repository.dart';

final getInterviewFeedbackUseCaseProvider =
    Provider<GetInterviewFeedbackUseCase>((ref) {
      final repository = ref.read(interviewRepositoryProvider);
      return GetInterviewFeedbackUseCase(repository: repository);
    });

class GetInterviewFeedbackUseCase
    implements
        UseCaseWithParams<
          InterviewFeedbackEntity,
          GetInterviewFeedbackUseCaseParams
        > {
  final IInterviewRepository _repository;

  GetInterviewFeedbackUseCase({required IInterviewRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, InterviewFeedbackEntity>> call(
    GetInterviewFeedbackUseCaseParams params,
  ) {
    return _repository.getInterviewFeedback(params.sessionId);
  }
}

class GetInterviewFeedbackUseCaseParams {
  final String sessionId;

  const GetInterviewFeedbackUseCaseParams({required this.sessionId});
}
