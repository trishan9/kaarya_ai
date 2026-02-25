import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/core/error/failures.dart';
import 'package:kaarya/core/usecases/app_usecase.dart';
import 'package:kaarya/features/interviews/data/repositories/interview_repository.dart';
import 'package:kaarya/features/interviews/domain/entities/interview_entity.dart';
import 'package:kaarya/features/interviews/domain/repositories/interview_repository.dart';

final createInterviewUseCaseProvider = Provider<CreateInterviewUseCase>((ref) {
  final repository = ref.read(interviewRepositoryProvider);
  return CreateInterviewUseCase(repository: repository);
});

class CreateInterviewUseCase
    implements
        UseCaseWithParams<InterviewEntity, CreateInterviewUseCaseParams> {
  final IInterviewRepository _repository;

  CreateInterviewUseCase({required IInterviewRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, InterviewEntity>> call(
    CreateInterviewUseCaseParams params,
  ) {
    return _repository.createInterview(
      title: params.title,
      description: params.description,
      interviewType: params.interviewType,
      role: params.role,
      level: params.level,
      techStack: params.techStack,
      questionCount: params.questionCount,
      durationMinutes: params.durationMinutes,
      visibility: params.visibility,
      status: params.status,
      tags: params.tags,
      instructions: params.instructions,
      generateQuestions: params.generateQuestions,
      companyId: params.companyId,
      collegeId: params.collegeId,
    );
  }
}

class CreateInterviewUseCaseParams {
  final String title;
  final String? description;
  final String interviewType;
  final String role;
  final String? level;
  final List<String>? techStack;
  final int? questionCount;
  final int? durationMinutes;
  final String? visibility;
  final String? status;
  final List<String>? tags;
  final String? instructions;
  final bool? generateQuestions;
  final String? companyId;
  final String? collegeId;

  const CreateInterviewUseCaseParams({
    required this.title,
    this.description,
    required this.interviewType,
    required this.role,
    this.level,
    this.techStack,
    this.questionCount,
    this.durationMinutes,
    this.visibility,
    this.status,
    this.tags,
    this.instructions,
    this.generateQuestions,
    this.companyId,
    this.collegeId,
  });
}
