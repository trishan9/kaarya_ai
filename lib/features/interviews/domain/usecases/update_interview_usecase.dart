import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/core/error/failures.dart';
import 'package:kaarya/core/usecases/app_usecase.dart';
import 'package:kaarya/features/interviews/data/repositories/interview_repository.dart';
import 'package:kaarya/features/interviews/domain/entities/interview_entity.dart';
import 'package:kaarya/features/interviews/domain/repositories/interview_repository.dart';

final updateInterviewUseCaseProvider = Provider<UpdateInterviewUseCase>((ref) {
  final repository = ref.read(interviewRepositoryProvider);
  return UpdateInterviewUseCase(repository: repository);
});

class UpdateInterviewUseCase
    implements
        UseCaseWithParams<InterviewEntity, UpdateInterviewUseCaseParams> {
  final IInterviewRepository _repository;

  UpdateInterviewUseCase({required IInterviewRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, InterviewEntity>> call(
    UpdateInterviewUseCaseParams params,
  ) {
    return _repository.updateInterview(id: params.id, data: params.data);
  }
}

class UpdateInterviewUseCaseParams {
  final String id;
  final Map<String, dynamic> data;

  const UpdateInterviewUseCaseParams({required this.id, required this.data});
}
