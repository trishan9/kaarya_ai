import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/core/error/failures.dart';
import 'package:kaarya/core/usecases/app_usecase.dart';
import 'package:kaarya/features/interviews/data/repositories/interview_repository.dart';
import 'package:kaarya/features/interviews/domain/entities/interview_entity.dart';
import 'package:kaarya/features/interviews/domain/repositories/interview_repository.dart';

final getInterviewByIdUseCaseProvider = Provider<GetInterviewByIdUseCase>((
  ref,
) {
  final repository = ref.read(interviewRepositoryProvider);
  return GetInterviewByIdUseCase(repository: repository);
});

class GetInterviewByIdUseCase
    implements
        UseCaseWithParams<InterviewEntity, GetInterviewByIdUseCaseParams> {
  final IInterviewRepository _repository;

  GetInterviewByIdUseCase({required IInterviewRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, InterviewEntity>> call(
    GetInterviewByIdUseCaseParams params,
  ) {
    return _repository.getInterviewById(params.id);
  }
}

class GetInterviewByIdUseCaseParams {
  final String id;

  const GetInterviewByIdUseCaseParams({required this.id});
}
