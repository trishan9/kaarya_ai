import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/core/error/failures.dart';
import 'package:kaarya/core/usecases/app_usecase.dart';
import 'package:kaarya/features/companies/data/repositories/company_repository.dart';
import 'package:kaarya/features/companies/domain/repositories/company_repository.dart';

final deleteCompanyUseCaseProvider = Provider<DeleteCompanyUseCase>((ref) {
  return DeleteCompanyUseCase(repository: ref.read(companyRepositoryProvider));
});

class DeleteCompanyUseCaseParams extends Equatable {
  final String companyId;

  const DeleteCompanyUseCaseParams({required this.companyId});

  @override
  List<Object?> get props => [companyId];
}

class DeleteCompanyUseCase
    implements UseCaseWithParams<bool, DeleteCompanyUseCaseParams> {
  final ICompanyRepository _repository;

  DeleteCompanyUseCase({required ICompanyRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, bool>> call(DeleteCompanyUseCaseParams params) {
    return _repository.deleteCompany(params.companyId);
  }
}
