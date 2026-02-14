import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/core/error/failures.dart';
import 'package:kaarya/core/usecases/app_usecase.dart';
import 'package:kaarya/features/resources/data/repositories/resource_repository.dart';
import 'package:kaarya/features/resources/domain/entities/resource_course_entity.dart';
import 'package:kaarya/features/resources/domain/repositories/resource_repository.dart';

final listCoursesUseCaseProvider = Provider<ListCoursesUseCase>((ref) {
  final repository = ref.read(resourceRepositoryProvider);
  return ListCoursesUseCase(repository: repository);
});

class ListCoursesUseCase
    implements
        UseCaseWithParams<ResourceCoursesListEntity, ListCoursesUseCaseParams> {
  final IResourceRepository _repository;

  ListCoursesUseCase({required IResourceRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, ResourceCoursesListEntity>> call(
    ListCoursesUseCaseParams params,
  ) {
    return _repository.listCourses(
      page: params.page,
      size: params.size,
      search: params.search,
      difficulty: params.difficulty,
      category: params.category,
    );
  }
}

class ListCoursesUseCaseParams {
  final int page;
  final int size;
  final String? search;
  final String? difficulty;
  final String? category;

  const ListCoursesUseCaseParams({
    this.page = 1,
    this.size = 20,
    this.search,
    this.difficulty,
    this.category,
  });
}
