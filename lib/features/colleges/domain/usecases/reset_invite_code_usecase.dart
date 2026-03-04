import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/core/error/failures.dart';
import 'package:kaarya/core/usecases/app_usecase.dart';
import 'package:kaarya/features/colleges/data/repositories/college_repository.dart';
import 'package:kaarya/features/colleges/domain/repositories/college_repository.dart';

final resetInviteCodeUseCaseProvider = Provider<ResetInviteCodeUseCase>((ref) {
  return ResetInviteCodeUseCase(
    repository: ref.read(collegeRepositoryProvider),
  );
});

class ResetInviteCodeUseCaseParams extends Equatable {
  final String collegeId;

  const ResetInviteCodeUseCaseParams({required this.collegeId});

  @override
  List<Object?> get props => [collegeId];
}

class ResetInviteCodeUseCase
    implements UseCaseWithParams<String, ResetInviteCodeUseCaseParams> {
  final ICollegeRepository _repository;

  ResetInviteCodeUseCase({required ICollegeRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, String>> call(ResetInviteCodeUseCaseParams params) {
    return _repository.resetInviteCode(params.collegeId);
  }
}
