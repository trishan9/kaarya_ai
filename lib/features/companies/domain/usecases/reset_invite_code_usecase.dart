import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/core/error/failures.dart';
import 'package:kaarya/core/usecases/app_usecase.dart';
import 'package:kaarya/features/companies/data/repositories/company_repository.dart';
import 'package:kaarya/features/companies/domain/entities/company_entity.dart';
import 'package:kaarya/features/companies/domain/repositories/company_repository.dart';

final resetInviteCodeUseCaseProvider = Provider<ResetInviteCodeUseCase>((ref) {
  return ResetInviteCodeUseCase(
    repository: ref.read(companyRepositoryProvider),
  );
});

class ResetInviteCodeUseCaseParams extends Equatable {
  final String companyId;

  const ResetInviteCodeUseCaseParams({required this.companyId});

  @override
  List<Object?> get props => [companyId];
}

class ResetInviteCodeUseCase
    implements UseCaseWithParams<CompanyEntity, ResetInviteCodeUseCaseParams> {
  final ICompanyRepository _repository;

  ResetInviteCodeUseCase({required ICompanyRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, CompanyEntity>> call(
    ResetInviteCodeUseCaseParams params,
  ) {
    return _repository.resetInviteCode(params.companyId);
  }
}
