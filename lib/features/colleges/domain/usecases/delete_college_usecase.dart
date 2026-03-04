import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/core/error/failures.dart';
import 'package:kaarya/core/usecases/app_usecase.dart';
import 'package:kaarya/features/colleges/data/repositories/college_repository.dart';
import 'package:kaarya/features/colleges/domain/repositories/college_repository.dart';

final deleteCollegeUseCaseProvider = Provider<DeleteCollegeUseCase>((ref) {
  return DeleteCollegeUseCase(repository: ref.read(collegeRepositoryProvider));
});

class DeleteCollegeUseCaseParams extends Equatable {
  final String collegeId;

  const DeleteCollegeUseCaseParams({required this.collegeId});

  @override
  List<Object?> get props => [collegeId];
}

class DeleteCollegeUseCase
    implements UseCaseWithParams<bool, DeleteCollegeUseCaseParams> {
  final ICollegeRepository _repository;

  DeleteCollegeUseCase({required ICollegeRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, bool>> call(DeleteCollegeUseCaseParams params) {
    return _repository.deleteCollege(params.collegeId);
  }
}
