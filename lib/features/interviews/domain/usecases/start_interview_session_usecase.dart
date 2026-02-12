import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/core/error/failures.dart';
import 'package:kaarya/core/usecases/app_usecase.dart';
import 'package:kaarya/features/interviews/data/repositories/interview_repository.dart';
import 'package:kaarya/features/interviews/domain/entities/interview_session_entity.dart';
import 'package:kaarya/features/interviews/domain/repositories/interview_repository.dart';

final startInterviewSessionUseCaseProvider =
    Provider<StartInterviewSessionUseCase>((ref) {
      final repository = ref.read(interviewRepositoryProvider);
      return StartInterviewSessionUseCase(repository: repository);
    });

class StartInterviewSessionUseCase
    implements
        UseCaseWithParams<
          InterviewSessionStartEntity,
          StartInterviewSessionUseCaseParams
        > {
  final IInterviewRepository _repository;

  StartInterviewSessionUseCase({required IInterviewRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, InterviewSessionStartEntity>> call(
    StartInterviewSessionUseCaseParams params,
  ) {
    return _repository.startInterviewSession(params.interviewId);
  }
}

class StartInterviewSessionUseCaseParams {
  final String interviewId;

  const StartInterviewSessionUseCaseParams({required this.interviewId});
}
