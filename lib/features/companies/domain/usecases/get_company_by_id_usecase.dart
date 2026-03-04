import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/core/error/failures.dart';
import 'package:kaarya/core/usecases/app_usecase.dart';
import 'package:kaarya/features/companies/data/repositories/company_repository.dart';
import 'package:kaarya/features/companies/domain/entities/company_entity.dart';
import 'package:kaarya/features/companies/domain/repositories/company_repository.dart';

final getCompanyByIdUseCaseProvider = Provider<GetCompanyByIdUseCase>((ref) {
  return GetCompanyByIdUseCase(repository: ref.read(companyRepositoryProvider));
});

class GetCompanyByIdUseCaseParams extends Equatable {
  final String companyId;

  const GetCompanyByIdUseCaseParams({required this.companyId});

  @override
  List<Object?> get props => [companyId];
}

class GetCompanyByIdUseCase
    implements UseCaseWithParams<CompanyEntity, GetCompanyByIdUseCaseParams> {
  final ICompanyRepository _repository;

  GetCompanyByIdUseCase({required ICompanyRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, CompanyEntity>> call(
    GetCompanyByIdUseCaseParams params,
  ) {
    return _repository.getCompanyById(params.companyId);
  }
}
