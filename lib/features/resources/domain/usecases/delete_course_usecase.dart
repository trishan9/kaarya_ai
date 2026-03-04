import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/core/error/failures.dart';
import 'package:kaarya/core/usecases/app_usecase.dart';
import 'package:kaarya/features/resources/data/repositories/resource_repository.dart';
import 'package:kaarya/features/resources/domain/repositories/resource_repository.dart';

final deleteCourseUseCaseProvider = Provider<DeleteCourseUseCase>((ref) {
  final repository = ref.read(resourceRepositoryProvider);
  return DeleteCourseUseCase(repository: repository);
});

class DeleteCourseUseCase
    implements UseCaseWithParams<bool, DeleteCourseUseCaseParams> {
  final IResourceRepository _repository;

  DeleteCourseUseCase({required IResourceRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, bool>> call(DeleteCourseUseCaseParams params) {
    return _repository.deleteCourse(params.courseId);
  }
}

class DeleteCourseUseCaseParams {
  final String courseId;

  const DeleteCourseUseCaseParams({required this.courseId});
}
