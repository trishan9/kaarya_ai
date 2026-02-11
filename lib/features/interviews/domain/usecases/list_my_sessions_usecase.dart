import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/core/error/failures.dart';
import 'package:kaarya/core/usecases/app_usecase.dart';
import 'package:kaarya/features/interviews/data/repositories/interview_repository.dart';
import 'package:kaarya/features/interviews/domain/entities/interview_session_entity.dart';
import 'package:kaarya/features/interviews/domain/repositories/interview_repository.dart';

final listMySessionsUseCaseProvider = Provider<ListMySessionsUseCase>((ref) {
  final repository = ref.read(interviewRepositoryProvider);
  return ListMySessionsUseCase(repository: repository);
});

class ListMySessionsUseCase
    implements
        UseCaseWithParams<
          List<InterviewSessionEntity>,
          ListMySessionsUseCaseParams
        > {
  final IInterviewRepository _repository;

  ListMySessionsUseCase({required IInterviewRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, List<InterviewSessionEntity>>> call(
    ListMySessionsUseCaseParams params,
  ) {
    return _repository.listMySessions(params.interviewId);
  }
}

class ListMySessionsUseCaseParams {
  final String interviewId;

  const ListMySessionsUseCaseParams({required this.interviewId});
}
