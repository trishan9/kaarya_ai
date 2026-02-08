import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/core/error/failures.dart';
import 'package:kaarya/core/usecases/app_usecase.dart';
import 'package:kaarya/features/companies/data/repositories/company_repository.dart';
import 'package:kaarya/features/companies/domain/entities/recruiter_workspace_entity.dart';
import 'package:kaarya/features/companies/domain/repositories/company_repository.dart';

final listRecruiterWorkspacesUseCaseProvider =
    Provider<ListRecruiterWorkspacesUseCase>((ref) {
      return ListRecruiterWorkspacesUseCase(
        repository: ref.read(companyRepositoryProvider),
      );
    });

class ListRecruiterWorkspacesUseCaseParams extends Equatable {
  final int page;
  final int size;

  const ListRecruiterWorkspacesUseCaseParams({this.page = 1, this.size = 20});

  @override
  List<Object?> get props => [page, size];
}

class ListRecruiterWorkspacesUseCase
    implements
        UseCaseWithParams<
          List<RecruiterWorkspaceEntity>,
          ListRecruiterWorkspacesUseCaseParams
        > {
  final ICompanyRepository _repository;

  ListRecruiterWorkspacesUseCase({required ICompanyRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, List<RecruiterWorkspaceEntity>>> call(
    ListRecruiterWorkspacesUseCaseParams params,
  ) {
    return _repository.listRecruiterWorkspaces(
      page: params.page,
      size: params.size,
    );
  }
}
