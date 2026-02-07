import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/core/error/failures.dart';
import 'package:kaarya/core/usecases/app_usecase.dart';
import 'package:kaarya/features/colleges/data/repositories/college_repository.dart';
import 'package:kaarya/features/colleges/domain/entities/college_entity.dart';
import 'package:kaarya/features/colleges/domain/repositories/college_repository.dart';

final joinByCodeUseCaseProvider = Provider<JoinByCodeUseCase>((ref) {
  return JoinByCodeUseCase(repository: ref.read(collegeRepositoryProvider));
});

class JoinByCodeUseCaseParams extends Equatable {
  final String inviteCode;

  const JoinByCodeUseCaseParams({required this.inviteCode});

  @override
  List<Object?> get props => [inviteCode];
}

class JoinByCodeUseCase
    implements UseCaseWithParams<CollegeEntity, JoinByCodeUseCaseParams> {
  final ICollegeRepository _repository;

  JoinByCodeUseCase({required ICollegeRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, CollegeEntity>> call(JoinByCodeUseCaseParams params) {
    return _repository.joinByCode(params.inviteCode);
  }
}
