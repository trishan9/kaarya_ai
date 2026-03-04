import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/core/error/failures.dart';
import 'package:kaarya/features/companies/domain/usecases/create_company_usecase.dart';
import 'package:kaarya/features/companies/domain/usecases/delete_company_usecase.dart';
import 'package:kaarya/features/companies/domain/usecases/get_company_by_id_usecase.dart';
import 'package:kaarya/features/companies/domain/usecases/invite_recruiter_usecase.dart';
import 'package:kaarya/features/companies/domain/usecases/join_by_code_usecase.dart';
import 'package:kaarya/features/companies/domain/usecases/list_companies_usecase.dart';
import 'package:kaarya/features/companies/domain/usecases/list_recruiter_workspaces_usecase.dart';
import 'package:kaarya/features/companies/domain/usecases/list_recruiters_usecase.dart';
import 'package:kaarya/features/companies/domain/usecases/remove_recruiter_usecase.dart';
import 'package:kaarya/features/companies/domain/usecases/reset_invite_code_usecase.dart';
import 'package:kaarya/features/companies/domain/usecases/update_company_usecase.dart';
import 'package:kaarya/features/companies/presentation/state/company_state.dart';

final companyViewModelProvider =
    NotifierProvider<CompanyViewModel, CompanyState>(CompanyViewModel.new);

class CompanyViewModel extends Notifier<CompanyState> {
  late final ListCompaniesUseCase _listCompaniesUseCase;
  late final GetCompanyByIdUseCase _getCompanyByIdUseCase;
  late final CreateCompanyUseCase _createCompanyUseCase;
  late final UpdateCompanyUseCase _updateCompanyUseCase;
  late final DeleteCompanyUseCase _deleteCompanyUseCase;
  late final JoinByCodeUseCase _joinByCodeUseCase;
  late final ResetInviteCodeUseCase _resetInviteCodeUseCase;
  late final ListRecruitersUseCase _listRecruitersUseCase;
  late final InviteRecruiterUseCase _inviteRecruiterUseCase;
  late final RemoveRecruiterUseCase _removeRecruiterUseCase;
  late final ListRecruiterWorkspacesUseCase _listRecruiterWorkspacesUseCase;

  @override
  CompanyState build() {
    _listCompaniesUseCase = ref.read(listCompaniesUseCaseProvider);
    _getCompanyByIdUseCase = ref.read(getCompanyByIdUseCaseProvider);
    _createCompanyUseCase = ref.read(createCompanyUseCaseProvider);
    _updateCompanyUseCase = ref.read(updateCompanyUseCaseProvider);
    _deleteCompanyUseCase = ref.read(deleteCompanyUseCaseProvider);
    _joinByCodeUseCase = ref.read(joinByCodeUseCaseProvider);
    _resetInviteCodeUseCase = ref.read(resetInviteCodeUseCaseProvider);
    _listRecruitersUseCase = ref.read(listRecruitersUseCaseProvider);
    _inviteRecruiterUseCase = ref.read(inviteRecruiterUseCaseProvider);
    _removeRecruiterUseCase = ref.read(removeRecruiterUseCaseProvider);
    _listRecruiterWorkspacesUseCase = ref.read(
      listRecruiterWorkspacesUseCaseProvider,
    );
    return const CompanyState();
  }

  void resetState() {
    state = const CompanyState();
  }

  Future<void> loadCompanies({
    int page = 1,
    int size = 20,
    String? search,
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh &&
        state.companiesStatus == CompanyLoadStatus.loaded &&
        state.companies != null) {
      return;
    }

    state = state.copyWith(
      companiesStatus: CompanyLoadStatus.loading,
      companiesErrorMessage: null,
    );

    final result = await _listCompaniesUseCase(
      ListCompaniesUseCaseParams(page: page, size: size, search: search),
    );

    result.fold(
      (failure) => state = state.copyWith(
        companiesStatus: CompanyLoadStatus.error,
        companiesErrorMessage: failure.message,
      ),
      (companies) => state = state.copyWith(
        companiesStatus: CompanyLoadStatus.loaded,
        companies: companies,
        companiesErrorMessage: null,
      ),
    );
  }

  Future<void> loadCompanyDetail(String companyId) async {
    state = state.copyWith(
      companyDetailStatus: CompanyLoadStatus.loading,
      companyDetail: null,
      companyDetailErrorMessage: null,
    );

    final result = await _getCompanyByIdUseCase(
      GetCompanyByIdUseCaseParams(companyId: companyId),
    );

    result.fold(
      (failure) => state = state.copyWith(
        companyDetailStatus: CompanyLoadStatus.error,
        companyDetailErrorMessage: failure.message,
      ),
      (company) => state = state.copyWith(
        companyDetailStatus: CompanyLoadStatus.loaded,
        companyDetail: company,
        companyDetailErrorMessage: null,
      ),
    );
  }

  Future<Failure?> createCompany({
    required String name,
    required String industry,
    required String location,
    String? logoPath,
    required String designation,
  }) async {
    final result = await _createCompanyUseCase(
      CreateCompanyUseCaseParams(
        name: name,
        industry: industry,
        location: location,
        logoPath: logoPath,
        designation: designation,
      ),
    );

    return result.fold((failure) => failure, (company) {
      state = state.copyWith(
        companyDetailStatus: CompanyLoadStatus.loaded,
        companyDetail: company,
      );
      return null;
    });
  }

  Future<Failure?> updateCompany({
    required String companyId,
    required Map<String, dynamic> fields,
  }) async {
    final result = await _updateCompanyUseCase(
      UpdateCompanyUseCaseParams(companyId: companyId, fields: fields),
    );

    return result.fold((failure) => failure, (company) {
      state = state.copyWith(
        companyDetailStatus: CompanyLoadStatus.loaded,
        companyDetail: company,
      );
      return null;
    });
  }

  Future<Failure?> deleteCompany(String companyId) async {
    final result = await _deleteCompanyUseCase(
      DeleteCompanyUseCaseParams(companyId: companyId),
    );

    return result.fold((failure) => failure, (_) {
      state = state.copyWith(
        companyDetail: null,
        companyDetailStatus: CompanyLoadStatus.initial,
      );
      return null;
    });
  }

  Future<Failure?> joinByCode({
    required String inviteCode,
    required String designation,
  }) async {
    final result = await _joinByCodeUseCase(
      JoinByCodeUseCaseParams(inviteCode: inviteCode, designation: designation),
    );

    return result.fold((failure) => failure, (company) {
      state = state.copyWith(
        companyDetailStatus: CompanyLoadStatus.loaded,
        companyDetail: company,
      );
      return null;
    });
  }

  Future<Failure?> resetInviteCode(String companyId) async {
    final result = await _resetInviteCodeUseCase(
      ResetInviteCodeUseCaseParams(companyId: companyId),
    );

    return result.fold((failure) => failure, (company) {
      state = state.copyWith(
        companyDetailStatus: CompanyLoadStatus.loaded,
        companyDetail: company,
      );
      return null;
    });
  }

  Future<void> loadRecruiters({
    required String companyId,
    int page = 1,
    int size = 20,
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh &&
        state.recruitersStatus == CompanyLoadStatus.loaded &&
        state.recruiters != null) {
      return;
    }

    state = state.copyWith(
      recruitersStatus: CompanyLoadStatus.loading,
      recruitersErrorMessage: null,
    );

    final result = await _listRecruitersUseCase(
      ListRecruitersUseCaseParams(companyId: companyId, page: page, size: size),
    );

    result.fold(
      (failure) => state = state.copyWith(
        recruitersStatus: CompanyLoadStatus.error,
        recruitersErrorMessage: failure.message,
      ),
      (recruiters) => state = state.copyWith(
        recruitersStatus: CompanyLoadStatus.loaded,
        recruiters: recruiters,
        recruitersErrorMessage: null,
      ),
    );
  }

  Future<Failure?> inviteRecruiter({
    required String companyId,
    required String email,
    required String designation,
  }) async {
    final result = await _inviteRecruiterUseCase(
      InviteRecruiterUseCaseParams(
        companyId: companyId,
        email: email,
        designation: designation,
      ),
    );

    return result.fold((failure) => failure, (_) => null);
  }

  Future<Failure?> removeRecruiter({
    required String companyId,
    required String recruiterId,
  }) async {
    final result = await _removeRecruiterUseCase(
      RemoveRecruiterUseCaseParams(
        companyId: companyId,
        recruiterId: recruiterId,
      ),
    );

    return result.fold((failure) => failure, (_) {
      final current = state.recruiters;
      if (current != null) {
        final updated = current.where((m) => m.userId != recruiterId).toList();
        state = state.copyWith(recruiters: updated);
      }
      return null;
    });
  }

  Future<void> loadWorkspaces({
    int page = 1,
    int size = 20,
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh &&
        state.workspacesStatus == CompanyLoadStatus.loaded &&
        state.workspaces != null) {
      return;
    }

    state = state.copyWith(
      workspacesStatus: CompanyLoadStatus.loading,
      workspacesErrorMessage: null,
    );

    final result = await _listRecruiterWorkspacesUseCase(
      ListRecruiterWorkspacesUseCaseParams(page: page, size: size),
    );

    result.fold(
      (failure) => state = state.copyWith(
        workspacesStatus: CompanyLoadStatus.error,
        workspacesErrorMessage: failure.message,
      ),
      (workspaces) => state = state.copyWith(
        workspacesStatus: CompanyLoadStatus.loaded,
        workspaces: workspaces,
        workspacesErrorMessage: null,
      ),
    );
  }
}
