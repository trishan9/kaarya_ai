import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/core/error/failures.dart';
import 'package:kaarya/core/usecases/app_usecase.dart';
import 'package:kaarya/features/resources/data/repositories/resource_repository.dart';
import 'package:kaarya/features/resources/domain/entities/resource_course_entity.dart';
import 'package:kaarya/features/resources/domain/repositories/resource_repository.dart';

final getCourseByIdUseCaseProvider = Provider<GetCourseByIdUseCase>((ref) {
  final repository = ref.read(resourceRepositoryProvider);
  return GetCourseByIdUseCase(repository: repository);
});

class GetCourseByIdUseCase
    implements
        UseCaseWithParams<ResourceCourseEntity, GetCourseByIdUseCaseParams> {
  final IResourceRepository _repository;

  GetCourseByIdUseCase({required IResourceRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, ResourceCourseEntity>> call(
    GetCourseByIdUseCaseParams params,
  ) {
    return _repository.getCourseById(params.courseId);
  }
}

class GetCourseByIdUseCaseParams {
  final String courseId;

  const GetCourseByIdUseCaseParams({required this.courseId});
}
