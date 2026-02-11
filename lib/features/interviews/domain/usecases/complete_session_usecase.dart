import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/core/error/failures.dart';
import 'package:kaarya/core/usecases/app_usecase.dart';
import 'package:kaarya/features/interviews/data/repositories/interview_repository.dart';
import 'package:kaarya/features/interviews/domain/repositories/interview_repository.dart';

final completeSessionUseCaseProvider = Provider<CompleteSessionUseCase>((ref) {
  final repository = ref.read(interviewRepositoryProvider);
  return CompleteSessionUseCase(repository: repository);
});

class CompleteSessionUseCase
    implements UseCaseWithParams<bool, CompleteSessionUseCaseParams> {
  final IInterviewRepository _repository;

  CompleteSessionUseCase({required IInterviewRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, bool>> call(CompleteSessionUseCaseParams params) {
    return _repository.completeSession(
      interviewId: params.interviewId,
      sessionId: params.sessionId,
      status: params.status,
      transcript: params.transcript,
      recordingUrl: params.recordingUrl,
      durationSeconds: params.durationSeconds,
    );
  }
}

class CompleteSessionUseCaseParams {
  final String interviewId;
  final String sessionId;
  final String status;
  final String? transcript;
  final String? recordingUrl;
  final int? durationSeconds;

  const CompleteSessionUseCaseParams({
    required this.interviewId,
    required this.sessionId,
    required this.status,
    this.transcript,
    this.recordingUrl,
    this.durationSeconds,
  });
}
