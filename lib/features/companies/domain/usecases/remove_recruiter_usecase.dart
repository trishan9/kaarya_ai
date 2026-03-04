import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/core/error/failures.dart';
import 'package:kaarya/core/usecases/app_usecase.dart';
import 'package:kaarya/features/companies/data/repositories/company_repository.dart';
import 'package:kaarya/features/companies/domain/repositories/company_repository.dart';

final removeRecruiterUseCaseProvider = Provider<RemoveRecruiterUseCase>((ref) {
  return RemoveRecruiterUseCase(
    repository: ref.read(companyRepositoryProvider),
  );
});

class RemoveRecruiterUseCaseParams extends Equatable {
  final String companyId;
  final String recruiterId;

  const RemoveRecruiterUseCaseParams({
    required this.companyId,
    required this.recruiterId,
  });

  @override
  List<Object?> get props => [companyId, recruiterId];
}

class RemoveRecruiterUseCase
    implements UseCaseWithParams<bool, RemoveRecruiterUseCaseParams> {
  final ICompanyRepository _repository;

  RemoveRecruiterUseCase({required ICompanyRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, bool>> call(RemoveRecruiterUseCaseParams params) {
    return _repository.removeRecruiter(
      companyId: params.companyId,
      recruiterId: params.recruiterId,
    );
  }
}
