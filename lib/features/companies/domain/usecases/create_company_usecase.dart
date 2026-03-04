import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/core/error/failures.dart';
import 'package:kaarya/core/usecases/app_usecase.dart';
import 'package:kaarya/features/companies/data/repositories/company_repository.dart';
import 'package:kaarya/features/companies/domain/entities/company_entity.dart';
import 'package:kaarya/features/companies/domain/repositories/company_repository.dart';

final createCompanyUseCaseProvider = Provider<CreateCompanyUseCase>((ref) {
  return CreateCompanyUseCase(repository: ref.read(companyRepositoryProvider));
});

class CreateCompanyUseCaseParams extends Equatable {
  final String name;
  final String industry;
  final String location;
  final String? logoPath;
  final String designation;

  const CreateCompanyUseCaseParams({
    required this.name,
    required this.industry,
    required this.location,
    this.logoPath,
    required this.designation,
  });

  @override
  List<Object?> get props => [name, industry, location, logoPath, designation];
}

class CreateCompanyUseCase
    implements UseCaseWithParams<CompanyEntity, CreateCompanyUseCaseParams> {
  final ICompanyRepository _repository;

  CreateCompanyUseCase({required ICompanyRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, CompanyEntity>> call(
    CreateCompanyUseCaseParams params,
  ) {
    return _repository.createCompany(
      name: params.name,
      industry: params.industry,
      location: params.location,
      logoPath: params.logoPath,
      designation: params.designation,
    );
  }
}
