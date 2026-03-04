import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/core/error/failures.dart';
import 'package:kaarya/core/usecases/app_usecase.dart';
import 'package:kaarya/features/colleges/data/repositories/college_repository.dart';
import 'package:kaarya/features/colleges/domain/entities/college_entity.dart';
import 'package:kaarya/features/colleges/domain/repositories/college_repository.dart';

final getCollegeByIdUseCaseProvider = Provider<GetCollegeByIdUseCase>((ref) {
  return GetCollegeByIdUseCase(repository: ref.read(collegeRepositoryProvider));
});

class GetCollegeByIdUseCaseParams extends Equatable {
  final String collegeId;

  const GetCollegeByIdUseCaseParams({required this.collegeId});

  @override
  List<Object?> get props => [collegeId];
}

class GetCollegeByIdUseCase
    implements UseCaseWithParams<CollegeEntity, GetCollegeByIdUseCaseParams> {
  final ICollegeRepository _repository;

  GetCollegeByIdUseCase({required ICollegeRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, CollegeEntity>> call(
    GetCollegeByIdUseCaseParams params,
  ) {
    return _repository.getCollegeById(params.collegeId);
  }
}
