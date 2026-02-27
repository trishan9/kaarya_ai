import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/core/error/failures.dart';
import 'package:kaarya/core/usecases/app_usecase.dart';
import 'package:kaarya/features/colleges/data/repositories/college_repository.dart';
import 'package:kaarya/features/colleges/domain/repositories/college_repository.dart';

final inviteStudentUseCaseProvider = Provider<InviteStudentUseCase>((ref) {
  return InviteStudentUseCase(repository: ref.read(collegeRepositoryProvider));
});

class InviteStudentUseCaseParams extends Equatable {
  final String collegeId;
  final String email;
  final String? program;
  final int? year;

  const InviteStudentUseCaseParams({
    required this.collegeId,
    required this.email,
    this.program,
    this.year,
  });

  @override
  List<Object?> get props => [collegeId, email, program, year];
}

class InviteStudentUseCase
    implements UseCaseWithParams<bool, InviteStudentUseCaseParams> {
  final ICollegeRepository _repository;

  InviteStudentUseCase({required ICollegeRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, bool>> call(InviteStudentUseCaseParams params) {
    return _repository.inviteStudent(
      collegeId: params.collegeId,
      email: params.email,
      program: params.program,
      year: params.year,
    );
  }
}
