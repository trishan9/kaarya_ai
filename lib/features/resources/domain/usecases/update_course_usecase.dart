import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/core/error/failures.dart';
import 'package:kaarya/core/usecases/app_usecase.dart';
import 'package:kaarya/features/resources/data/repositories/resource_repository.dart';
import 'package:kaarya/features/resources/domain/entities/resource_course_entity.dart';
import 'package:kaarya/features/resources/domain/repositories/resource_repository.dart';

final updateCourseUseCaseProvider = Provider<UpdateCourseUseCase>((ref) {
  final repository = ref.read(resourceRepositoryProvider);
  return UpdateCourseUseCase(repository: repository);
});

class UpdateCourseUseCase
    implements
        UseCaseWithParams<ResourceCourseEntity, UpdateCourseUseCaseParams> {
  final IResourceRepository _repository;

  UpdateCourseUseCase({required IResourceRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, ResourceCourseEntity>> call(
    UpdateCourseUseCaseParams params,
  ) {
    return _repository.updateCourse(
      courseId: params.courseId,
      fields: params.fields,
    );
  }
}

class UpdateCourseUseCaseParams {
  final String courseId;
  final Map<String, dynamic> fields;

  const UpdateCourseUseCaseParams({
    required this.courseId,
    required this.fields,
  });
}
