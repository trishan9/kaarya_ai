import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaarya/core/error/failures.dart';
import 'package:kaarya/features/companies/data/repositories/company_repository.dart';
import 'package:kaarya/features/companies/domain/repositories/company_repository.dart';
import 'package:kaarya/features/jobs/data/repositories/job_repository.dart';
import 'package:kaarya/features/jobs/domain/repositories/job_repository.dart';
import 'package:kaarya/features/recruiter/presentation/view_model/recruiter_view_model.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/test_fixtures.dart';

class MockCompanyRepository extends Mock implements ICompanyRepository {}

class MockJobRepository extends Mock implements IJobRepository {}

void main() {
  late MockCompanyRepository mockCompanyRepository;
  late MockJobRepository mockJobRepository;
  late ProviderContainer container;

  setUp(() {
    mockCompanyRepository = MockCompanyRepository();
    mockJobRepository = MockJobRepository();
    container = ProviderContainer(
      overrides: [
        companyRepositoryProvider.overrideWithValue(mockCompanyRepository),
        jobRepositoryProvider.overrideWithValue(mockJobRepository),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  test('RecruiterViewModel should load workspaces and select first one', () async {
    final workspace = buildRecruiterWorkspaceEntity();
    when(
      () => mockCompanyRepository.listRecruiterWorkspaces(
        page: any(named: 'page'),
        size: any(named: 'size'),
      ),
    ).thenAnswer((_) async => Right([workspace]));

    final viewModel = container.read(recruiterViewModelProvider.notifier);
    await viewModel.loadWorkspaces();

    final state = container.read(recruiterViewModelProvider);
    expect(state.workspacesStatus, RecruiterLoadStatus.loaded);
    expect(state.workspaces, [workspace]);
    expect(state.selectedWorkspace, workspace);
  });

  test('RecruiterViewModel should expose workspace error on failure', () async {
    const failure = ApiFailure(message: 'Workspace failed');
    when(
      () => mockCompanyRepository.listRecruiterWorkspaces(
        page: any(named: 'page'),
        size: any(named: 'size'),
      ),
    ).thenAnswer((_) async => const Left(failure));

    final viewModel = container.read(recruiterViewModelProvider.notifier);
    await viewModel.loadWorkspaces();

    final state = container.read(recruiterViewModelProvider);
    expect(state.workspacesStatus, RecruiterLoadStatus.error);
    expect(state.workspacesError, 'Workspace failed');
  });

  test('RecruiterViewModel should create workspace and select refreshed entry', () async {
    final company = buildCompanyEntity();
    final workspace = buildRecruiterWorkspaceEntity();
    when(
      () => mockCompanyRepository.createCompany(
        name: any(named: 'name'),
        industry: any(named: 'industry'),
        location: any(named: 'location'),
        logoPath: any(named: 'logoPath'),
        designation: any(named: 'designation'),
      ),
    ).thenAnswer((_) async => Right(company));
    when(
      () => mockCompanyRepository.listRecruiterWorkspaces(
        page: any(named: 'page'),
        size: any(named: 'size'),
      ),
    ).thenAnswer((_) async => Right([workspace]));

    final viewModel = container.read(recruiterViewModelProvider.notifier);
    final result = await viewModel.createWorkspace(
      name: 'Kaarya',
      industry: 'Software',
      location: 'Kathmandu',
      designation: 'HR',
    );

    final state = container.read(recruiterViewModelProvider);
    expect(result, isNull);
    expect(state.selectedWorkspace?.companyId, workspace.companyId);
  });

  test('RecruiterViewModel should load and filter company jobs', () async {
    final jobs = [
      buildJobEntity(id: 'job-1', companyName: 'Kaarya'),
      buildJobEntity(id: 'job-2', companyName: 'Other'),
    ];
    when(
      () => mockJobRepository.listCompanyJobs(
        companyId: any(named: 'companyId'),
        status: any(named: 'status'),
        search: any(named: 'search'),
        page: any(named: 'page'),
        size: any(named: 'size'),
      ),
    ).thenAnswer((_) async => Right(jobs));

    final viewModel = container.read(recruiterViewModelProvider.notifier);
    await viewModel.loadCompanyJobs(
      companyId: 'company-1',
      companyName: 'Kaarya',
    );

    final state = container.read(recruiterViewModelProvider);
    expect(state.companyJobsStatus, RecruiterLoadStatus.loaded);
    expect(state.companyJobs?.length, 1);
    expect(state.companyJobs?.first.companyName, 'Kaarya');
  });

  test('RecruiterViewModel should compute overview data from loaded jobs', () {
    final viewModel = container.read(recruiterViewModelProvider.notifier);
    viewModel.selectWorkspace(buildRecruiterWorkspaceEntity());
    container.read(recruiterViewModelProvider.notifier).state = RecruiterState(
      companyJobs: [
        buildJobEntity(status: 'open', workMode: 'remote'),
        buildJobEntity(id: 'job-2', status: 'draft', workMode: 'hybrid'),
      ],
    );

    final overview = viewModel.computeOverviewData();

    expect(overview.openJobsCount, 1);
    expect(overview.draftJobsCount, 1);
    expect(overview.workModeDistribution.first.count, 1);
  });
}
