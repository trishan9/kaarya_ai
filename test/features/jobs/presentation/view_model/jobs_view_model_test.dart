import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaarya/core/error/failures.dart';
import 'package:kaarya/features/jobs/data/repositories/job_repository.dart';
import 'package:kaarya/features/jobs/domain/repositories/job_repository.dart';
import 'package:kaarya/features/jobs/presentation/view_model/jobs_view_model.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/test_fixtures.dart';

class MockJobRepository extends Mock implements IJobRepository {}

void main() {
  late MockJobRepository mockRepository;
  late ProviderContainer container;

  setUp(() {
    mockRepository = MockJobRepository();
    container = ProviderContainer(
      overrides: [
        jobRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('JobsViewModel', () {
    test('should load jobs section successfully', () async {
      final section = buildJobsSectionEntity();
      when(
        () => mockRepository.getJobsSection(
          searchQuery: any(named: 'searchQuery'),
          locationQuery: any(named: 'locationQuery'),
          status: any(named: 'status'),
          employmentType: any(named: 'employmentType'),
          engagementType: any(named: 'engagementType'),
        ),
      ).thenAnswer((_) async => Right(section));

      final viewModel = container.read(jobsViewModelProvider.notifier);
      await viewModel.loadJobsSection(searchQuery: 'flutter');

      final state = container.read(jobsViewModelProvider);
      expect(state.isLoading, isFalse);
      expect(state.section, section);
      expect(state.error, isNull);
    });

    test('should keep current section on refresh failure', () async {
      final section = buildJobsSectionEntity();
      when(
        () => mockRepository.getJobsSection(
          searchQuery: any(named: 'searchQuery'),
          locationQuery: any(named: 'locationQuery'),
          status: any(named: 'status'),
          employmentType: any(named: 'employmentType'),
          engagementType: any(named: 'engagementType'),
        ),
      ).thenAnswer((_) async => Right(section));

      final viewModel = container.read(jobsViewModelProvider.notifier);
      await viewModel.loadJobsSection();

      when(
        () => mockRepository.getJobsSection(
          searchQuery: any(named: 'searchQuery'),
          locationQuery: any(named: 'locationQuery'),
          status: any(named: 'status'),
          employmentType: any(named: 'employmentType'),
          engagementType: any(named: 'engagementType'),
        ),
      ).thenAnswer((_) async => const Left(ApiFailure(message: 'Failed')));

      await viewModel.loadJobsSection(searchQuery: 'other');

      expect(container.read(jobsViewModelProvider).section, section);
    });

    test('should load job detail successfully', () async {
      final detail = buildJobDetailEntity();
      when(() => mockRepository.getJobDetail(any())).thenAnswer(
        (_) async => Right(detail),
      );

      final viewModel = container.read(jobsViewModelProvider.notifier);
      await viewModel.loadJobDetail('job-1');

      final state = container.read(jobsViewModelProvider);
      expect(state.jobDetail, detail);
      expect(state.jobDetailError, isNull);
    });

    test('should clear job detail on detail failure', () async {
      when(() => mockRepository.getJobDetail(any())).thenAnswer(
        (_) async => const Left(ApiFailure(message: 'Not found')),
      );

      final viewModel = container.read(jobsViewModelProvider.notifier);
      await viewModel.loadJobDetail('job-1');

      expect(container.read(jobsViewModelProvider).jobDetail, isNull);
      expect(container.read(jobsViewModelProvider).jobDetailError, 'Not found');
    });

    test('should update bookmark state optimistically', () {
      final viewModel = container.read(jobsViewModelProvider.notifier);
      viewModel.state = viewModel.state.copyWith(section: buildJobsSectionEntity());

      viewModel.updateJobBookmarkState('job-1', true);

      expect(
        container.read(jobsViewModelProvider).section?.jobs.forYou.first.isSaved,
        isTrue,
      );
    });

    test('should return null when apply fails', () async {
      when(
        () => mockRepository.applyToJob(
          any(),
          resumeId: any(named: 'resumeId'),
          coverLetter: any(named: 'coverLetter'),
          portfolioLinks: any(named: 'portfolioLinks'),
        ),
      ).thenAnswer((_) async => const Left(ApiFailure(message: 'Apply failed')));

      final viewModel = container.read(jobsViewModelProvider.notifier);
      final result = await viewModel.applyToJob('job-1');

      expect(result, isNull);
    });

    test('should load job metrics successfully', () async {
      final metrics = buildJobMetricsEntity();
      when(() => mockRepository.getJobMetrics(any())).thenAnswer(
        (_) async => Right(metrics),
      );

      final viewModel = container.read(jobsViewModelProvider.notifier);
      await viewModel.loadJobMetrics('job-1');

      expect(container.read(jobsViewModelProvider).jobMetrics, metrics);
    });

    test('should clear list error', () {
      final viewModel = container.read(jobsViewModelProvider.notifier);
      viewModel.state = viewModel.state.copyWith(error: 'Error');

      viewModel.clearError();

      expect(container.read(jobsViewModelProvider).error, isNull);
    });
  });
}
