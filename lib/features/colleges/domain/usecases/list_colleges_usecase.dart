import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/core/error/failures.dart';
import 'package:kaarya/core/usecases/app_usecase.dart';
import 'package:kaarya/features/colleges/data/repositories/college_repository.dart';
import 'package:kaarya/features/colleges/domain/entities/college_entity.dart';
import 'package:kaarya/features/colleges/domain/repositories/college_repository.dart';

final listCollegesUseCaseProvider = Provider<ListCollegesUseCase>((ref) {
  return ListCollegesUseCase(repository: ref.read(collegeRepositoryProvider));
});

class ListCollegesUseCaseParams extends Equatable {
  final int page;
  final int size;
  final String? search;

  const ListCollegesUseCaseParams({this.page = 1, this.size = 20, this.search});

  @override
  List<Object?> get props => [page, size, search];
}

class ListCollegesUseCase
    implements
        UseCaseWithParams<List<CollegeEntity>, ListCollegesUseCaseParams> {
  final ICollegeRepository _repository;

  ListCollegesUseCase({required ICollegeRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, List<CollegeEntity>>> call(
    ListCollegesUseCaseParams params,
  ) {
    return _repository.listColleges(
      page: params.page,
      size: params.size,
      search: params.search,
    );
  }
}
