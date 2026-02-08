import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/core/error/failures.dart';
import 'package:kaarya/core/usecases/app_usecase.dart';
import 'package:kaarya/features/companies/data/repositories/company_repository.dart';
import 'package:kaarya/features/companies/domain/entities/company_entity.dart';
import 'package:kaarya/features/companies/domain/repositories/company_repository.dart';

final updateCompanyUseCaseProvider = Provider<UpdateCompanyUseCase>((ref) {
  return UpdateCompanyUseCase(repository: ref.read(companyRepositoryProvider));
});

class UpdateCompanyUseCaseParams extends Equatable {
  final String companyId;
  final Map<String, dynamic> fields;

  const UpdateCompanyUseCaseParams({
    required this.companyId,
    required this.fields,
  });

  @override
  List<Object?> get props => [companyId, fields];
}

class UpdateCompanyUseCase
    implements UseCaseWithParams<CompanyEntity, UpdateCompanyUseCaseParams> {
  final ICompanyRepository _repository;

  UpdateCompanyUseCase({required ICompanyRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, CompanyEntity>> call(
    UpdateCompanyUseCaseParams params,
  ) {
    return _repository.updateCompany(
      companyId: params.companyId,
      fields: params.fields,
    );
  }
}
