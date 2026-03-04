import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/core/error/failures.dart';
import 'package:kaarya/core/usecases/app_usecase.dart';
import 'package:kaarya/features/companies/data/repositories/company_repository.dart';
import 'package:kaarya/features/companies/domain/repositories/company_repository.dart';

final inviteRecruiterUseCaseProvider = Provider<InviteRecruiterUseCase>((ref) {
  return InviteRecruiterUseCase(
    repository: ref.read(companyRepositoryProvider),
  );
});

class InviteRecruiterUseCaseParams extends Equatable {
  final String companyId;
  final String email;
  final String designation;

  const InviteRecruiterUseCaseParams({
    required this.companyId,
    required this.email,
    required this.designation,
  });

  @override
  List<Object?> get props => [companyId, email, designation];
}

class InviteRecruiterUseCase
    implements UseCaseWithParams<bool, InviteRecruiterUseCaseParams> {
  final ICompanyRepository _repository;

  InviteRecruiterUseCase({required ICompanyRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, bool>> call(InviteRecruiterUseCaseParams params) {
    return _repository.inviteRecruiter(
      companyId: params.companyId,
      email: params.email,
      designation: params.designation,
    );
  }
}
