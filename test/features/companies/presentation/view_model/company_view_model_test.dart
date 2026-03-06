import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaarya/core/error/failures.dart';
import 'package:kaarya/features/companies/domain/usecases/create_company_usecase.dart';
import 'package:kaarya/features/companies/domain/usecases/delete_company_usecase.dart';
import 'package:kaarya/features/companies/domain/usecases/get_company_by_id_usecase.dart';
import 'package:kaarya/features/companies/domain/usecases/invite_recruiter_usecase.dart';
import 'package:kaarya/features/companies/domain/usecases/join_by_code_usecase.dart';
import 'package:kaarya/features/companies/domain/usecases/list_companies_usecase.dart';
import 'package:kaarya/features/companies/domain/usecases/list_recruiters_usecase.dart';
import 'package:kaarya/features/companies/domain/usecases/list_recruiter_workspaces_usecase.dart';
import 'package:kaarya/features/companies/domain/usecases/remove_recruiter_usecase.dart';
import 'package:kaarya/features/companies/domain/usecases/reset_invite_code_usecase.dart';
import 'package:kaarya/features/companies/domain/usecases/update_company_usecase.dart';
import 'package:kaarya/features/companies/presentation/state/company_state.dart';
import 'package:kaarya/features/companies/presentation/view_model/company_view_model.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/test_fixtures.dart';

class MockListCompaniesUseCase extends Mock implements ListCompaniesUseCase {}

class MockGetCompanyByIdUseCase extends Mock implements GetCompanyByIdUseCase {}

class MockCreateCompanyUseCase extends Mock implements CreateCompanyUseCase {}

class MockUpdateCompanyUseCase extends Mock implements UpdateCompanyUseCase {}

class MockDeleteCompanyUseCase extends Mock implements DeleteCompanyUseCase {}

class MockJoinByCodeUseCase extends Mock implements JoinByCodeUseCase {}

class MockResetInviteCodeUseCase extends Mock implements ResetInviteCodeUseCase {}

class MockListRecruitersUseCase extends Mock implements ListRecruitersUseCase {}

class MockInviteRecruiterUseCase extends Mock implements InviteRecruiterUseCase {}

class MockRemoveRecruiterUseCase extends Mock implements RemoveRecruiterUseCase {}

class MockListRecruiterWorkspacesUseCase extends Mock
    implements ListRecruiterWorkspacesUseCase {}

void main() {
  late MockListCompaniesUseCase mockListCompaniesUseCase;
  late MockGetCompanyByIdUseCase mockGetCompanyByIdUseCase;
  late MockCreateCompanyUseCase mockCreateCompanyUseCase;
  late MockUpdateCompanyUseCase mockUpdateCompanyUseCase;
  late MockDeleteCompanyUseCase mockDeleteCompanyUseCase;
  late MockJoinByCodeUseCase mockJoinByCodeUseCase;
  late MockResetInviteCodeUseCase mockResetInviteCodeUseCase;
  late MockListRecruitersUseCase mockListRecruitersUseCase;
  late MockInviteRecruiterUseCase mockInviteRecruiterUseCase;
  late MockRemoveRecruiterUseCase mockRemoveRecruiterUseCase;
  late MockListRecruiterWorkspacesUseCase mockListRecruiterWorkspacesUseCase;
  late ProviderContainer container;

  setUpAll(() {
    registerFallbackValue(const ListCompaniesUseCaseParams());
    registerFallbackValue(
      const GetCompanyByIdUseCaseParams(companyId: 'company-1'),
    );
    registerFallbackValue(
      const CreateCompanyUseCaseParams(
        name: 'Kaarya',
        industry: 'Software',
        location: 'Kathmandu',
        designation: 'HR',
      ),
    );
    registerFallbackValue(
      const UpdateCompanyUseCaseParams(
        companyId: 'company-1',
        fields: {'name': 'Kaarya AI'},
      ),
    );
    registerFallbackValue(
      const DeleteCompanyUseCaseParams(companyId: 'company-1'),
    );
    registerFallbackValue(
      const JoinByCodeUseCaseParams(
        inviteCode: 'JOIN123',
        designation: 'HR',
      ),
    );
    registerFallbackValue(
      const ResetInviteCodeUseCaseParams(companyId: 'company-1'),
    );
    registerFallbackValue(
      const ListRecruitersUseCaseParams(companyId: 'company-1'),
    );
    registerFallbackValue(
      const InviteRecruiterUseCaseParams(
        companyId: 'company-1',
        email: 'recruiter@example.com',
        designation: 'HR',
      ),
    );
    registerFallbackValue(
      const RemoveRecruiterUseCaseParams(
        companyId: 'company-1',
        recruiterId: 'user-1',
      ),
    );
    registerFallbackValue(const ListRecruiterWorkspacesUseCaseParams());
  });

  setUp(() {
    mockListCompaniesUseCase = MockListCompaniesUseCase();
    mockGetCompanyByIdUseCase = MockGetCompanyByIdUseCase();
    mockCreateCompanyUseCase = MockCreateCompanyUseCase();
    mockUpdateCompanyUseCase = MockUpdateCompanyUseCase();
    mockDeleteCompanyUseCase = MockDeleteCompanyUseCase();
    mockJoinByCodeUseCase = MockJoinByCodeUseCase();
    mockResetInviteCodeUseCase = MockResetInviteCodeUseCase();
    mockListRecruitersUseCase = MockListRecruitersUseCase();
    mockInviteRecruiterUseCase = MockInviteRecruiterUseCase();
    mockRemoveRecruiterUseCase = MockRemoveRecruiterUseCase();
    mockListRecruiterWorkspacesUseCase = MockListRecruiterWorkspacesUseCase();

    container = ProviderContainer(
      overrides: [
        listCompaniesUseCaseProvider.overrideWithValue(mockListCompaniesUseCase),
        getCompanyByIdUseCaseProvider.overrideWithValue(
          mockGetCompanyByIdUseCase,
        ),
        createCompanyUseCaseProvider.overrideWithValue(mockCreateCompanyUseCase),
        updateCompanyUseCaseProvider.overrideWithValue(mockUpdateCompanyUseCase),
        deleteCompanyUseCaseProvider.overrideWithValue(mockDeleteCompanyUseCase),
        joinByCodeUseCaseProvider.overrideWithValue(mockJoinByCodeUseCase),
        resetInviteCodeUseCaseProvider.overrideWithValue(
          mockResetInviteCodeUseCase,
        ),
        listRecruitersUseCaseProvider.overrideWithValue(
          mockListRecruitersUseCase,
        ),
        inviteRecruiterUseCaseProvider.overrideWithValue(
          mockInviteRecruiterUseCase,
        ),
        removeRecruiterUseCaseProvider.overrideWithValue(
          mockRemoveRecruiterUseCase,
        ),
        listRecruiterWorkspacesUseCaseProvider.overrideWithValue(
          mockListRecruiterWorkspacesUseCase,
        ),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  test('CompanyViewModel should load companies successfully', () async {
    final companies = [buildCompanyEntity()];
    when(
      () => mockListCompaniesUseCase(any()),
    ).thenAnswer((_) async => Right(companies));

    final viewModel = container.read(companyViewModelProvider.notifier);
    await viewModel.loadCompanies(search: 'Kaarya');

    final state = container.read(companyViewModelProvider);
    expect(state.companiesStatus, CompanyLoadStatus.loaded);
    expect(state.companies, companies);
  });

  test('CompanyViewModel should load company detail successfully', () async {
    final company = buildCompanyEntity();
    when(
      () => mockGetCompanyByIdUseCase(any()),
    ).thenAnswer((_) async => Right(company));

    final viewModel = container.read(companyViewModelProvider.notifier);
    await viewModel.loadCompanyDetail('company-1');

    final state = container.read(companyViewModelProvider);
    expect(state.companyDetailStatus, CompanyLoadStatus.loaded);
    expect(state.companyDetail, company);
  });

  test('CompanyViewModel should set company detail on create success', () async {
    final company = buildCompanyEntity();
    when(
      () => mockCreateCompanyUseCase(any()),
    ).thenAnswer((_) async => Right(company));

    final viewModel = container.read(companyViewModelProvider.notifier);
    final result = await viewModel.createCompany(
      name: 'Kaarya',
      industry: 'Software',
      location: 'Kathmandu',
      designation: 'HR',
    );

    expect(result, isNull);
    expect(container.read(companyViewModelProvider).companyDetail, company);
  });

  test('CompanyViewModel should update recruiter list on remove success', () async {
    when(
      () => mockRemoveRecruiterUseCase(any()),
    ).thenAnswer((_) async => const Right(true));

    final viewModel = container.read(companyViewModelProvider.notifier);
    viewModel.state = CompanyState(
      recruiters: [
        buildWorkspaceMemberEntity(userId: 'user-1'),
        buildWorkspaceMemberEntity(userId: 'user-2'),
      ],
    );

    final result = await viewModel.removeRecruiter(
      companyId: 'company-1',
      recruiterId: 'user-1',
    );

    expect(result, isNull);
    expect(container.read(companyViewModelProvider).recruiters?.length, 1);
  });

  test('CompanyViewModel should load workspaces successfully', () async {
    final workspaces = [buildRecruiterWorkspaceEntity()];
    when(
      () => mockListRecruiterWorkspacesUseCase(any()),
    ).thenAnswer((_) async => Right(workspaces));

    final viewModel = container.read(companyViewModelProvider.notifier);
    await viewModel.loadWorkspaces();

    final state = container.read(companyViewModelProvider);
    expect(state.workspacesStatus, CompanyLoadStatus.loaded);
    expect(state.workspaces, workspaces);
  });

  test('CompanyViewModel should reset state', () {
    final viewModel = container.read(companyViewModelProvider.notifier);
    viewModel.resetState();

    expect(container.read(companyViewModelProvider), const CompanyState());
  });
}
