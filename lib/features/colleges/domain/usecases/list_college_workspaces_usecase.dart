import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/core/error/failures.dart';
import 'package:kaarya/core/usecases/app_usecase.dart';
import 'package:kaarya/features/colleges/data/repositories/college_repository.dart';
import 'package:kaarya/features/colleges/domain/entities/college_workspace_entity.dart';
import 'package:kaarya/features/colleges/domain/repositories/college_repository.dart';

final listCollegeWorkspacesUseCaseProvider =
    Provider<ListCollegeWorkspacesUseCase>((ref) {
      return ListCollegeWorkspacesUseCase(
        repository: ref.read(collegeRepositoryProvider),
      );
    });

class ListCollegeWorkspacesUseCaseParams extends Equatable {
  final int page;
  final int size;

  const ListCollegeWorkspacesUseCaseParams({this.page = 1, this.size = 20});

  @override
  List<Object?> get props => [page, size];
}

class ListCollegeWorkspacesUseCase
    implements
        UseCaseWithParams<
          List<CollegeWorkspaceEntity>,
          ListCollegeWorkspacesUseCaseParams
        > {
  final ICollegeRepository _repository;

  ListCollegeWorkspacesUseCase({required ICollegeRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, List<CollegeWorkspaceEntity>>> call(
    ListCollegeWorkspacesUseCaseParams params,
  ) {
    return _repository.listCollegeWorkspaces(
      page: params.page,
      size: params.size,
    );
  }
}
