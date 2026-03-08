import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaarya/core/error/failures.dart';
import 'package:kaarya/features/companies/data/repositories/company_repository.dart';
import 'package:kaarya/features/companies/domain/repositories/company_repository.dart';
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
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/test_fixtures.dart';

class MockCompanyRepository extends Mock implements ICompanyRepository {}

void main() {
  late MockCompanyRepository mockRepository;
  late ProviderContainer container;

  setUp(() {
    mockRepository = MockCompanyRepository();
    container = ProviderContainer(
      overrides: [companyRepositoryProvider.overrideWithValue(mockRepository)],
    );
  });

  tearDown(() {
    container.dispose();
  });

  test('company usecase providers should resolve', () {
    expect(
      container.read(listCompaniesUseCaseProvider),
      isA<ListCompaniesUseCase>(),
    );
    expect(
      container.read(getCompanyByIdUseCaseProvider),
      isA<GetCompanyByIdUseCase>(),
    );
    expect(
      container.read(createCompanyUseCaseProvider),
      isA<CreateCompanyUseCase>(),
    );
    expect(
      container.read(updateCompanyUseCaseProvider),
      isA<UpdateCompanyUseCase>(),
    );
    expect(
      container.read(deleteCompanyUseCaseProvider),
      isA<DeleteCompanyUseCase>(),
    );
    expect(container.read(joinByCodeUseCaseProvider), isA<JoinByCodeUseCase>());
    expect(
      container.read(resetInviteCodeUseCaseProvider),
      isA<ResetInviteCodeUseCase>(),
    );
    expect(
      container.read(listRecruitersUseCaseProvider),
      isA<ListRecruitersUseCase>(),
    );
    expect(
      container.read(inviteRecruiterUseCaseProvider),
      isA<InviteRecruiterUseCase>(),
    );
    expect(
      container.read(removeRecruiterUseCaseProvider),
      isA<RemoveRecruiterUseCase>(),
    );
    expect(
      container.read(listRecruiterWorkspacesUseCaseProvider),
      isA<ListRecruiterWorkspacesUseCase>(),
    );
  });

  test('ListCompaniesUseCase should pass filters to repository', () async {
    final expected = [buildCompanyEntity()];
    when(
      () => mockRepository.listCompanies(
        page: any(named: 'page'),
        size: any(named: 'size'),
        search: any(named: 'search'),
      ),
    ).thenAnswer((_) async => Right(expected));

    final usecase = ListCompaniesUseCase(repository: mockRepository);
    final result = await usecase(
      const ListCompaniesUseCaseParams(page: 2, size: 25, search: 'Kaarya'),
    );

    expect(result, Right(expected));
    verify(
      () => mockRepository.listCompanies(page: 2, size: 25, search: 'Kaarya'),
    ).called(1);
  });

  test('GetCompanyByIdUseCase should pass company id', () async {
    final expected = buildCompanyEntity();
    when(
      () => mockRepository.getCompanyById(any()),
    ).thenAnswer((_) async => Right(expected));

    final usecase = GetCompanyByIdUseCase(repository: mockRepository);
    final result = await usecase(
      const GetCompanyByIdUseCaseParams(companyId: 'company-1'),
    );

    expect(result, Right(expected));
    verify(() => mockRepository.getCompanyById('company-1')).called(1);
  });

  test('CreateCompanyUseCase should pass creation payload', () async {
    final expected = buildCompanyEntity();
    when(
      () => mockRepository.createCompany(
        name: any(named: 'name'),
        industry: any(named: 'industry'),
        location: any(named: 'location'),
        logoPath: any(named: 'logoPath'),
        designation: any(named: 'designation'),
      ),
    ).thenAnswer((_) async => Right(expected));

    final usecase = CreateCompanyUseCase(repository: mockRepository);
    final result = await usecase(
      const CreateCompanyUseCaseParams(
        name: 'Kaarya',
        industry: 'Software',
        location: 'Kathmandu',
        logoPath: '/tmp/logo.png',
        designation: 'HR',
      ),
    );

    expect(result, Right(expected));
    verify(
      () => mockRepository.createCompany(
        name: 'Kaarya',
        industry: 'Software',
        location: 'Kathmandu',
        logoPath: '/tmp/logo.png',
        designation: 'HR',
      ),
    ).called(1);
  });

  test('UpdateCompanyUseCase should pass update payload', () async {
    final expected = buildCompanyEntity();
    when(
      () => mockRepository.updateCompany(
        companyId: any(named: 'companyId'),
        fields: any(named: 'fields'),
      ),
    ).thenAnswer((_) async => Right(expected));

    final usecase = UpdateCompanyUseCase(repository: mockRepository);
    final result = await usecase(
      const UpdateCompanyUseCaseParams(
        companyId: 'company-1',
        fields: {'name': 'Kaarya AI'},
      ),
    );

    expect(result, Right(expected));
    verify(
      () => mockRepository.updateCompany(
        companyId: 'company-1',
        fields: {'name': 'Kaarya AI'},
      ),
    ).called(1);
  });

  test('DeleteCompanyUseCase should return repository result', () async {
    when(
      () => mockRepository.deleteCompany(any()),
    ).thenAnswer((_) async => const Right(true));

    final usecase = DeleteCompanyUseCase(repository: mockRepository);
    final result = await usecase(
      const DeleteCompanyUseCaseParams(companyId: 'company-1'),
    );

    expect(result, const Right(true));
    verify(() => mockRepository.deleteCompany('company-1')).called(1);
  });

  test('JoinByCodeUseCase should pass join payload', () async {
    final expected = buildCompanyEntity();
    when(
      () => mockRepository.joinByCode(
        inviteCode: any(named: 'inviteCode'),
        designation: any(named: 'designation'),
      ),
    ).thenAnswer((_) async => Right(expected));

    final usecase = JoinByCodeUseCase(repository: mockRepository);
    final result = await usecase(
      const JoinByCodeUseCaseParams(
        inviteCode: 'JOIN123',
        designation: 'Recruiter',
      ),
    );

    expect(result, Right(expected));
    verify(
      () => mockRepository.joinByCode(
        inviteCode: 'JOIN123',
        designation: 'Recruiter',
      ),
    ).called(1);
  });

  test('ResetInviteCodeUseCase should call repository', () async {
    final expected = buildCompanyEntity();
    when(
      () => mockRepository.resetInviteCode(any()),
    ).thenAnswer((_) async => Right(expected));

    final usecase = ResetInviteCodeUseCase(repository: mockRepository);
    final result = await usecase(
      const ResetInviteCodeUseCaseParams(companyId: 'company-1'),
    );

    expect(result, Right(expected));
    verify(() => mockRepository.resetInviteCode('company-1')).called(1);
  });

  test('ListRecruitersUseCase should pass paging values', () async {
    final expected = [buildWorkspaceMemberEntity()];
    when(
      () => mockRepository.listRecruiters(
        companyId: any(named: 'companyId'),
        page: any(named: 'page'),
        size: any(named: 'size'),
      ),
    ).thenAnswer((_) async => Right(expected));

    final usecase = ListRecruitersUseCase(repository: mockRepository);
    final result = await usecase(
      const ListRecruitersUseCaseParams(
        companyId: 'company-1',
        page: 2,
        size: 30,
      ),
    );

    expect(result, Right(expected));
    verify(
      () => mockRepository.listRecruiters(
        companyId: 'company-1',
        page: 2,
        size: 30,
      ),
    ).called(1);
  });

  test('InviteRecruiterUseCase should pass invite payload', () async {
    when(
      () => mockRepository.inviteRecruiter(
        companyId: any(named: 'companyId'),
        email: any(named: 'email'),
        designation: any(named: 'designation'),
      ),
    ).thenAnswer((_) async => const Right(true));

    final usecase = InviteRecruiterUseCase(repository: mockRepository);
    final result = await usecase(
      const InviteRecruiterUseCaseParams(
        companyId: 'company-1',
        email: 'recruiter@example.com',
        designation: 'HR',
      ),
    );

    expect(result, const Right(true));
    verify(
      () => mockRepository.inviteRecruiter(
        companyId: 'company-1',
        email: 'recruiter@example.com',
        designation: 'HR',
      ),
    ).called(1);
  });

  test('RemoveRecruiterUseCase should return repository failure', () async {
    const failure = ApiFailure(message: 'Remove failed');
    when(
      () => mockRepository.removeRecruiter(
        companyId: any(named: 'companyId'),
        recruiterId: any(named: 'recruiterId'),
      ),
    ).thenAnswer((_) async => const Left(failure));

    final usecase = RemoveRecruiterUseCase(repository: mockRepository);
    final result = await usecase(
      const RemoveRecruiterUseCaseParams(
        companyId: 'company-1',
        recruiterId: 'user-1',
      ),
    );

    expect(result, const Left(failure));
    verify(
      () => mockRepository.removeRecruiter(
        companyId: 'company-1',
        recruiterId: 'user-1',
      ),
    ).called(1);
  });

  test('ListRecruiterWorkspacesUseCase should pass paging values', () async {
    final expected = [buildRecruiterWorkspaceEntity()];
    when(
      () => mockRepository.listRecruiterWorkspaces(
        page: any(named: 'page'),
        size: any(named: 'size'),
      ),
    ).thenAnswer((_) async => Right(expected));

    final usecase = ListRecruiterWorkspacesUseCase(repository: mockRepository);
    final result = await usecase(
      const ListRecruiterWorkspacesUseCaseParams(page: 2, size: 50),
    );

    expect(result, Right(expected));
    verify(
      () => mockRepository.listRecruiterWorkspaces(page: 2, size: 50),
    ).called(1);
  });
}
