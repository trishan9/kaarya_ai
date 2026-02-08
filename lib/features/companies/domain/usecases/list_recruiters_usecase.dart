import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/core/error/failures.dart';
import 'package:kaarya/core/usecases/app_usecase.dart';
import 'package:kaarya/features/companies/data/repositories/company_repository.dart';
import 'package:kaarya/features/companies/domain/entities/workspace_member_entity.dart';
import 'package:kaarya/features/companies/domain/repositories/company_repository.dart';

final listRecruitersUseCaseProvider = Provider<ListRecruitersUseCase>((ref) {
  return ListRecruitersUseCase(repository: ref.read(companyRepositoryProvider));
});

class ListRecruitersUseCaseParams extends Equatable {
  final String companyId;
  final int page;
  final int size;

  const ListRecruitersUseCaseParams({
    required this.companyId,
    this.page = 1,
    this.size = 20,
  });

  @override
  List<Object?> get props => [companyId, page, size];
}

class ListRecruitersUseCase
    implements
        UseCaseWithParams<
          List<WorkspaceMemberEntity>,
          ListRecruitersUseCaseParams
        > {
  final ICompanyRepository _repository;

  ListRecruitersUseCase({required ICompanyRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, List<WorkspaceMemberEntity>>> call(
    ListRecruitersUseCaseParams params,
  ) {
    return _repository.listRecruiters(
      companyId: params.companyId,
      page: params.page,
      size: params.size,
    );
  }
}
