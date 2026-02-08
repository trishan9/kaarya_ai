import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/core/error/failures.dart';
import 'package:kaarya/core/usecases/app_usecase.dart';
import 'package:kaarya/features/companies/data/repositories/company_repository.dart';
import 'package:kaarya/features/companies/domain/entities/company_entity.dart';
import 'package:kaarya/features/companies/domain/repositories/company_repository.dart';

final listCompaniesUseCaseProvider = Provider<ListCompaniesUseCase>((ref) {
  return ListCompaniesUseCase(repository: ref.read(companyRepositoryProvider));
});

class ListCompaniesUseCaseParams extends Equatable {
  final int page;
  final int size;
  final String? search;

  const ListCompaniesUseCaseParams({
    this.page = 1,
    this.size = 20,
    this.search,
  });

  @override
  List<Object?> get props => [page, size, search];
}

class ListCompaniesUseCase
    implements
        UseCaseWithParams<List<CompanyEntity>, ListCompaniesUseCaseParams> {
  final ICompanyRepository _repository;

  ListCompaniesUseCase({required ICompanyRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, List<CompanyEntity>>> call(
    ListCompaniesUseCaseParams params,
  ) {
    return _repository.listCompanies(
      page: params.page,
      size: params.size,
      search: params.search,
    );
  }
}
