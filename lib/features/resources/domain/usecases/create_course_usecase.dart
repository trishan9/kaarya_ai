import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/core/error/failures.dart';
import 'package:kaarya/core/usecases/app_usecase.dart';
import 'package:kaarya/features/resources/data/repositories/resource_repository.dart';
import 'package:kaarya/features/resources/domain/entities/resource_course_entity.dart';
import 'package:kaarya/features/resources/domain/repositories/resource_repository.dart';

final createCourseUseCaseProvider = Provider<CreateCourseUseCase>((ref) {
  final repository = ref.read(resourceRepositoryProvider);
  return CreateCourseUseCase(repository: repository);
});

class CreateCourseUseCase
    implements
        UseCaseWithParams<ResourceCourseEntity, CreateCourseUseCaseParams> {
  final IResourceRepository _repository;

  CreateCourseUseCase({required IResourceRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, ResourceCourseEntity>> call(
    CreateCourseUseCaseParams params,
  ) {
    return _repository.createCourse(
      title: params.title,
      description: params.description,
      category: params.category,
      generationMode: params.generationMode,
      difficulty: params.difficulty,
      targetRoles: params.targetRoles,
      chapterCount: params.chapterCount,
      visibility: params.visibility,
      includeVideoRecommendations: params.includeVideoRecommendations,
      promptContext: params.promptContext,
      jobDescriptionContext: params.jobDescriptionContext,
    );
  }
}

class CreateCourseUseCaseParams {
  final String title;
  final String? description;
  final String category;
  final String generationMode;
  final String difficulty;
  final List<String> targetRoles;
  final int? chapterCount;
  final String? visibility;
  final bool? includeVideoRecommendations;
  final String? promptContext;
  final String? jobDescriptionContext;

  const CreateCourseUseCaseParams({
    required this.title,
    this.description,
    required this.category,
    required this.generationMode,
    required this.difficulty,
    required this.targetRoles,
    this.chapterCount,
    this.visibility,
    this.includeVideoRecommendations,
    this.promptContext,
    this.jobDescriptionContext,
  });
}
