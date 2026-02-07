import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/core/error/failures.dart';
import 'package:kaarya/core/usecases/app_usecase.dart';
import 'package:kaarya/features/colleges/data/repositories/college_repository.dart';
import 'package:kaarya/features/colleges/domain/entities/student_member_entity.dart';
import 'package:kaarya/features/colleges/domain/repositories/college_repository.dart';

final listStudentsUseCaseProvider = Provider<ListStudentsUseCase>((ref) {
  return ListStudentsUseCase(repository: ref.read(collegeRepositoryProvider));
});

class ListStudentsUseCaseParams extends Equatable {
  final String collegeId;
  final int page;
  final int size;

  const ListStudentsUseCaseParams({
    required this.collegeId,
    this.page = 1,
    this.size = 20,
  });

  @override
  List<Object?> get props => [collegeId, page, size];
}

class ListStudentsUseCase
    implements
        UseCaseWithParams<
          List<StudentMemberEntity>,
          ListStudentsUseCaseParams
        > {
  final ICollegeRepository _repository;

  ListStudentsUseCase({required ICollegeRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, List<StudentMemberEntity>>> call(
    ListStudentsUseCaseParams params,
  ) {
    return _repository.listStudents(
      collegeId: params.collegeId,
      page: params.page,
      size: params.size,
    );
  }
}
