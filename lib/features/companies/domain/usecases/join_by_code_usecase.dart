import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/core/error/failures.dart';
import 'package:kaarya/core/usecases/app_usecase.dart';
import 'package:kaarya/features/companies/data/repositories/company_repository.dart';
import 'package:kaarya/features/companies/domain/entities/company_entity.dart';
import 'package:kaarya/features/companies/domain/repositories/company_repository.dart';

final joinByCodeUseCaseProvider = Provider<JoinByCodeUseCase>((ref) {
  return JoinByCodeUseCase(repository: ref.read(companyRepositoryProvider));
});

class JoinByCodeUseCaseParams extends Equatable {
  final String inviteCode;
  final String designation;

  const JoinByCodeUseCaseParams({
    required this.inviteCode,
    required this.designation,
  });

  @override
  List<Object?> get props => [inviteCode, designation];
}

class JoinByCodeUseCase
    implements UseCaseWithParams<CompanyEntity, JoinByCodeUseCaseParams> {
  final ICompanyRepository _repository;

  JoinByCodeUseCase({required ICompanyRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, CompanyEntity>> call(JoinByCodeUseCaseParams params) {
    return _repository.joinByCode(
      inviteCode: params.inviteCode,
      designation: params.designation,
    );
  }
}
