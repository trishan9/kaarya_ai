import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaarya/core/error/failures.dart';
import 'package:kaarya/features/colleges/data/repositories/college_repository.dart';
import 'package:kaarya/features/colleges/domain/repositories/college_repository.dart';
import 'package:kaarya/features/jobs/data/repositories/job_repository.dart';
import 'package:kaarya/features/jobs/domain/repositories/job_repository.dart';
import 'package:kaarya/features/colleges/presentation/view_model/college_dashboard_view_model.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/test_fixtures.dart';

class MockCollegeRepository extends Mock implements ICollegeRepository {}

class MockJobRepository extends Mock implements IJobRepository {}

void main() {
  late MockCollegeRepository mockCollegeRepository;
  late MockJobRepository mockJobRepository;
  late ProviderContainer container;

  setUp(() {
    mockCollegeRepository = MockCollegeRepository();
    mockJobRepository = MockJobRepository();
    container = ProviderContainer(
      overrides: [
        collegeRepositoryProvider.overrideWithValue(mockCollegeRepository),
        jobRepositoryProvider.overrideWithValue(mockJobRepository),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  test('CollegeDashboardViewModel should load workspaces and select first one', () async {
    final workspace = buildCollegeWorkspaceEntity();
    when(
      () => mockCollegeRepository.listCollegeWorkspaces(
        page: any(named: 'page'),
        size: any(named: 'size'),
      ),
    ).thenAnswer((_) async => Right([workspace]));

    final viewModel = container.read(collegeDashboardViewModelProvider.notifier);
    await viewModel.loadWorkspaces();

    final state = container.read(collegeDashboardViewModelProvider);
    expect(state.workspacesStatus, CollegeDashboardLoadStatus.loaded);
    expect(state.selectedWorkspace, workspace);
  });

  test('CollegeDashboardViewModel should join workspace and select refreshed college', () async {
    final college = buildCollegeEntity();
    final workspace = buildCollegeWorkspaceEntity();
    when(() => mockCollegeRepository.joinByCode(any())).thenAnswer(
      (_) async => Right(college),
    );
    when(
      () => mockCollegeRepository.listCollegeWorkspaces(
        page: any(named: 'page'),
        size: any(named: 'size'),
      ),
    ).thenAnswer((_) async => Right([workspace]));

    final viewModel = container.read(collegeDashboardViewModelProvider.notifier);
    final result = await viewModel.joinWorkspace(inviteCode: 'COLLEGE123');

    expect(result, isNull);
    expect(
      container.read(collegeDashboardViewModelProvider).selectedWorkspace?.collegeId,
      workspace.collegeId,
    );
  });

  test('CollegeDashboardViewModel should load college jobs', () async {
    final jobs = [buildJobEntity(), buildJobEntity(id: 'job-2')];
    when(
      () => mockJobRepository.listCollegeJobs(
        collegeId: any(named: 'collegeId'),
        status: any(named: 'status'),
        search: any(named: 'search'),
        page: any(named: 'page'),
        size: any(named: 'size'),
      ),
    ).thenAnswer((_) async => Right(jobs));

    final viewModel = container.read(collegeDashboardViewModelProvider.notifier);
    await viewModel.loadCollegeJobs(collegeId: 'college-1');

    final state = container.read(collegeDashboardViewModelProvider);
    expect(state.collegeJobsStatus, CollegeDashboardLoadStatus.loaded);
    expect(state.collegeJobs, jobs);
  });

  test('CollegeDashboardViewModel should compute overview data from jobs', () {
    final viewModel = container.read(collegeDashboardViewModelProvider.notifier);
    container.read(collegeDashboardViewModelProvider.notifier).state =
        CollegeDashboardState(
          collegeJobs: [
            buildJobEntity(status: 'open', workMode: 'remote'),
            buildJobEntity(id: 'job-2', status: 'draft', workMode: 'onsite'),
          ],
        );

    final overview = viewModel.computeOverviewData();

    expect(overview.openJobsCount, 1);
    expect(overview.draftJobsCount, 1);
    expect(overview.totalApplicants, greaterThan(0));
  });

  test('CollegeDashboardViewModel should clear jobs and reset state', () {
    final viewModel = container.read(collegeDashboardViewModelProvider.notifier);
    viewModel.clearCollegeJobs();
    viewModel.resetState();

    expect(
      container.read(collegeDashboardViewModelProvider),
      const CollegeDashboardState(),
    );
  });
}
