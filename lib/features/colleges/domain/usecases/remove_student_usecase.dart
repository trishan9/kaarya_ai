import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/core/error/failures.dart';
import 'package:kaarya/core/usecases/app_usecase.dart';
import 'package:kaarya/features/colleges/data/repositories/college_repository.dart';
import 'package:kaarya/features/colleges/domain/repositories/college_repository.dart';

final removeStudentUseCaseProvider = Provider<RemoveStudentUseCase>((ref) {
  return RemoveStudentUseCase(repository: ref.read(collegeRepositoryProvider));
});

class RemoveStudentUseCaseParams extends Equatable {
  final String collegeId;
  final String studentId;

  const RemoveStudentUseCaseParams({
    required this.collegeId,
    required this.studentId,
  });

  @override
  List<Object?> get props => [collegeId, studentId];
}

class RemoveStudentUseCase
    implements UseCaseWithParams<bool, RemoveStudentUseCaseParams> {
  final ICollegeRepository _repository;

  RemoveStudentUseCase({required ICollegeRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, bool>> call(RemoveStudentUseCaseParams params) {
    return _repository.removeStudent(
      collegeId: params.collegeId,
      studentId: params.studentId,
    );
  }
}
