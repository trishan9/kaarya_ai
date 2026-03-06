import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaarya/core/error/failures.dart';
import 'package:kaarya/features/applications/domain/usecases/apply_to_job_usecase.dart';
import 'package:kaarya/features/applications/domain/usecases/get_my_applications_usecase.dart';
import 'package:kaarya/features/applications/domain/usecases/list_my_resumes_usecase.dart';
import 'package:kaarya/features/bookmarks/domain/usecases/get_my_bookmarks_usecase.dart';
import 'package:kaarya/features/bookmarks/domain/usecases/save_job_bookmark_usecase.dart';
import 'package:kaarya/features/bookmarks/domain/usecases/unsave_job_bookmark_usecase.dart';
import 'package:kaarya/features/dashboard/data/repositories/dashboard_repository.dart';
import 'package:kaarya/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:kaarya/features/dashboard/domain/usecases/get_overview_usecase.dart';
import 'package:kaarya/features/dashboard/presentation/state/dashboard_state.dart';
import 'package:kaarya/features/dashboard/presentation/view_model/dashboard_view_model.dart';
import 'package:kaarya/features/interviews/domain/usecases/get_interview_feedback_usecase.dart';
import 'package:kaarya/features/interviews/domain/usecases/get_interviews_section_usecase.dart';
import 'package:kaarya/features/interviews/domain/usecases/set_interview_saved_usecase.dart';
import 'package:kaarya/features/interviews/domain/usecases/start_interview_session_usecase.dart';
import 'package:kaarya/features/jobs/domain/usecases/get_job_detail_usecase.dart';
import 'package:kaarya/features/jobs/domain/usecases/get_jobs_section_usecase.dart';
import 'package:kaarya/features/leaderboard/domain/usecases/get_leaderboard_usecase.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/test_fixtures.dart';

class MockGetOverviewUseCase extends Mock implements GetOverviewUseCase {}

class MockGetJobsSectionUseCase extends Mock implements GetJobsSectionUseCase {}

class MockGetInterviewsSectionUseCase extends Mock
    implements GetInterviewsSectionUseCase {}

class MockSetInterviewSavedUseCase extends Mock
    implements SetInterviewSavedUseCase {}

class MockStartInterviewSessionUseCase extends Mock
    implements StartInterviewSessionUseCase {}

class MockGetInterviewFeedbackUseCase extends Mock
    implements GetInterviewFeedbackUseCase {}

class MockGetJobDetailUseCase extends Mock implements GetJobDetailUseCase {}

class MockGetMyApplicationsUseCase extends Mock
    implements GetMyApplicationsUseCase {}

class MockApplyToJobUseCase extends Mock implements ApplyToJobUseCase {}

class MockGetMyBookmarksUseCase extends Mock implements GetMyBookmarksUseCase {}

class MockSaveJobBookmarkUseCase extends Mock
    implements SaveJobBookmarkUseCase {}

class MockUnsaveJobBookmarkUseCase extends Mock
    implements UnsaveJobBookmarkUseCase {}

class MockGetLeaderboardUseCase extends Mock implements GetLeaderboardUseCase {}

class MockListMyResumesUseCase extends Mock implements ListMyResumesUseCase {}

class MockDashboardRepository extends Mock implements IDashboardRepository {}

void main() {
  late MockGetOverviewUseCase mockGetOverviewUseCase;
  late MockGetJobsSectionUseCase mockGetJobsSectionUseCase;
  late MockGetInterviewsSectionUseCase mockGetInterviewsSectionUseCase;
  late MockSetInterviewSavedUseCase mockSetInterviewSavedUseCase;
  late MockStartInterviewSessionUseCase mockStartInterviewSessionUseCase;
  late MockGetInterviewFeedbackUseCase mockGetInterviewFeedbackUseCase;
  late MockGetJobDetailUseCase mockGetJobDetailUseCase;
  late MockGetMyApplicationsUseCase mockGetMyApplicationsUseCase;
  late MockApplyToJobUseCase mockApplyToJobUseCase;
  late MockGetMyBookmarksUseCase mockGetMyBookmarksUseCase;
  late MockSaveJobBookmarkUseCase mockSaveJobBookmarkUseCase;
  late MockUnsaveJobBookmarkUseCase mockUnsaveJobBookmarkUseCase;
  late MockGetLeaderboardUseCase mockGetLeaderboardUseCase;
  late MockListMyResumesUseCase mockListMyResumesUseCase;
  late MockDashboardRepository mockDashboardRepository;
  late ProviderContainer container;

  setUpAll(() {
    registerFallbackValue(const GetOverviewUseCaseParams(monthKey: '2026-03'));
    registerFallbackValue(const GetJobsSectionParams());
    registerFallbackValue(const GetInterviewsSectionUseCaseParams());
    registerFallbackValue(
      const SetInterviewSavedUseCaseParams(
        interviewId: 'interview-1',
        isSaved: true,
      ),
    );
    registerFallbackValue(
      const StartInterviewSessionUseCaseParams(interviewId: 'interview-1'),
    );
    registerFallbackValue(
      const GetInterviewFeedbackUseCaseParams(sessionId: 'session-1'),
    );
    registerFallbackValue(const GetJobDetailParams(jobId: 'job-1'));
    registerFallbackValue(const GetMyApplicationsUseCaseParams());
    registerFallbackValue(const ApplyToJobUseCaseParams(jobId: 'job-1'));
    registerFallbackValue(const GetMyBookmarksParams());
    registerFallbackValue(const GetLeaderboardParams());
    registerFallbackValue(const ListMyResumesUseCaseParams());
  });

  setUp(() {
    mockGetOverviewUseCase = MockGetOverviewUseCase();
    mockGetJobsSectionUseCase = MockGetJobsSectionUseCase();
    mockGetInterviewsSectionUseCase = MockGetInterviewsSectionUseCase();
    mockSetInterviewSavedUseCase = MockSetInterviewSavedUseCase();
    mockStartInterviewSessionUseCase = MockStartInterviewSessionUseCase();
    mockGetInterviewFeedbackUseCase = MockGetInterviewFeedbackUseCase();
    mockGetJobDetailUseCase = MockGetJobDetailUseCase();
    mockGetMyApplicationsUseCase = MockGetMyApplicationsUseCase();
    mockApplyToJobUseCase = MockApplyToJobUseCase();
    mockGetMyBookmarksUseCase = MockGetMyBookmarksUseCase();
    mockSaveJobBookmarkUseCase = MockSaveJobBookmarkUseCase();
    mockUnsaveJobBookmarkUseCase = MockUnsaveJobBookmarkUseCase();
    mockGetLeaderboardUseCase = MockGetLeaderboardUseCase();
    mockListMyResumesUseCase = MockListMyResumesUseCase();
    mockDashboardRepository = MockDashboardRepository();

    container = ProviderContainer(
      overrides: [
        getOverviewUseCaseProvider.overrideWithValue(mockGetOverviewUseCase),
        getJobsSectionUseCaseProvider.overrideWithValue(
          mockGetJobsSectionUseCase,
        ),
        getInterviewsSectionUseCaseProvider.overrideWithValue(
          mockGetInterviewsSectionUseCase,
        ),
        setInterviewSavedUseCaseProvider.overrideWithValue(
          mockSetInterviewSavedUseCase,
        ),
        startInterviewSessionUseCaseProvider.overrideWithValue(
          mockStartInterviewSessionUseCase,
        ),
        getInterviewFeedbackUseCaseProvider.overrideWithValue(
          mockGetInterviewFeedbackUseCase,
        ),
        getJobDetailUseCaseProvider.overrideWithValue(mockGetJobDetailUseCase),
        getMyApplicationsUseCaseProvider.overrideWithValue(
          mockGetMyApplicationsUseCase,
        ),
        applyToJobUseCaseProvider.overrideWithValue(mockApplyToJobUseCase),
        getMyBookmarksUseCaseProvider.overrideWithValue(
          mockGetMyBookmarksUseCase,
        ),
        saveJobBookmarkUseCaseProvider.overrideWithValue(
          mockSaveJobBookmarkUseCase,
        ),
        unsaveJobBookmarkUseCaseProvider.overrideWithValue(
          mockUnsaveJobBookmarkUseCase,
        ),
        getLeaderboardUseCaseProvider.overrideWithValue(
          mockGetLeaderboardUseCase,
        ),
        listMyResumesUseCaseProvider.overrideWithValue(mockListMyResumesUseCase),
        dashboardRepositoryProvider.overrideWithValue(mockDashboardRepository),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('DashboardViewModel', () {
    test('should load overview successfully', () async {
      final overview = buildDashboardOverviewEntity();
      when(
        () => mockGetOverviewUseCase(any()),
      ).thenAnswer((_) async => Right(overview));

      final viewModel = container.read(dashboardViewModelProvider.notifier);
      await viewModel.loadOverview(monthKey: '2026-03');

      final state = container.read(dashboardViewModelProvider);
      expect(state.overviewStatus, DashboardLoadStatus.loaded);
      expect(state.overviewData, overview);
      expect(state.overviewMonthKey, '2026-03');
    });

    test('should keep stale overview data when refresh fails', () async {
      final overview = buildDashboardOverviewEntity();
      when(
        () => mockGetOverviewUseCase(any()),
      ).thenAnswer((_) async => Right(overview));

      final viewModel = container.read(dashboardViewModelProvider.notifier);
      await viewModel.loadOverview();

      when(
        () => mockGetOverviewUseCase(any()),
      ).thenAnswer((_) async => const Left(ApiFailure(message: 'Failed')));

      await viewModel.loadOverview(forceRefresh: true);

      expect(container.read(dashboardViewModelProvider).overviewData, overview);
      expect(
        container.read(dashboardViewModelProvider).overviewStatus,
        DashboardLoadStatus.loading,
      );
    });

    test('should load jobs and update saved bookmark state', () async {
      final jobs = buildJobsSectionEntity();
      when(
        () => mockGetJobsSectionUseCase(any()),
      ).thenAnswer((_) async => Right(jobs));
      when(() => mockSaveJobBookmarkUseCase(any())).thenAnswer(
        (_) async => const Right(true),
      );

      final viewModel = container.read(dashboardViewModelProvider.notifier);
      await viewModel.loadJobs(searchQuery: 'flutter');
      final failure = await viewModel.toggleJobBookmark('job-1', true);

      expect(failure, isNull);
      expect(
        container.read(dashboardViewModelProvider).jobsData?.jobs.forYou.first.isSaved,
        isTrue,
      );
    });

    test('should roll back optimistic bookmark update on failure', () async {
      when(
        () => mockGetJobsSectionUseCase(any()),
      ).thenAnswer((_) async => Right(buildJobsSectionEntity()));
      when(() => mockSaveJobBookmarkUseCase(any())).thenAnswer(
        (_) async => const Left(ApiFailure(message: 'Save failed')),
      );

      final viewModel = container.read(dashboardViewModelProvider.notifier);
      await viewModel.loadJobs();
      final failure = await viewModel.toggleJobBookmark('job-1', true);

      expect(failure?.message, 'Save failed');
      expect(
        container.read(dashboardViewModelProvider).jobsData?.jobs.forYou.first.isSaved,
        isFalse,
      );
    });

    test('should load interviews successfully', () async {
      final interviews = buildInterviewsSectionEntity();
      when(
        () => mockGetInterviewsSectionUseCase(any()),
      ).thenAnswer((_) async => Right(interviews));

      final viewModel = container.read(dashboardViewModelProvider.notifier);
      await viewModel.loadInterviews();

      expect(
        container.read(dashboardViewModelProvider).interviewsData,
        interviews,
      );
    });

    test('should return interview session start result', () async {
      final session = buildInterviewSessionStartEntity();
      when(
        () => mockStartInterviewSessionUseCase(any()),
      ).thenAnswer((_) async => Right(session));

      final viewModel = container.read(dashboardViewModelProvider.notifier);
      final (result, failure) = await viewModel.startInterviewSession(
        'interview-1',
      );

      expect(result, session);
      expect(failure, isNull);
    });

    test('should return interview feedback result', () async {
      final feedback = buildInterviewFeedbackEntity();
      when(
        () => mockGetInterviewFeedbackUseCase(any()),
      ).thenAnswer((_) async => Right(feedback));

      final viewModel = container.read(dashboardViewModelProvider.notifier);
      final (result, failure) = await viewModel.getInterviewFeedback(
        'session-1',
      );

      expect(result, feedback);
      expect(failure, isNull);
    });

    test('should load job detail successfully', () async {
      final detail = buildJobDetailEntity();
      when(
        () => mockGetJobDetailUseCase(any()),
      ).thenAnswer((_) async => Right(detail));

      final viewModel = container.read(dashboardViewModelProvider.notifier);
      await viewModel.loadJobDetail('job-1');

      expect(container.read(dashboardViewModelProvider).jobDetailData, detail);
    });

    test('should load my applications and bookmarks', () async {
      when(
        () => mockGetMyApplicationsUseCase(any()),
      ).thenAnswer((_) async => Right(buildApplicationsListEntity()));
      when(
        () => mockGetMyBookmarksUseCase(any()),
      ).thenAnswer((_) async => Right(buildBookmarksListEntity()));

      final viewModel = container.read(dashboardViewModelProvider.notifier);
      await viewModel.loadMyApplications();
      await viewModel.loadMyBookmarks();

      final state = container.read(dashboardViewModelProvider);
      expect(state.applicationsData, isNotNull);
      expect(state.bookmarksData, isNotNull);
    });

    test('should return failure when applying to job fails', () async {
      const failure = ApiFailure(message: 'Apply failed');
      when(
        () => mockApplyToJobUseCase(any()),
      ).thenAnswer((_) async => const Left(failure));

      final viewModel = container.read(dashboardViewModelProvider.notifier);
      final result = await viewModel.applyToJob('job-1');

      expect(result, failure);
    });

    test('should load leaderboard and resumes', () async {
      when(
        () => mockGetLeaderboardUseCase(any()),
      ).thenAnswer((_) async => Right(buildLeaderboardEntity()));
      when(
        () => mockListMyResumesUseCase(any()),
      ).thenAnswer((_) async => Right([buildResumeEntity()]));

      final viewModel = container.read(dashboardViewModelProvider.notifier);
      await viewModel.loadLeaderboard();
      await viewModel.loadMyResumes();

      final state = container.read(dashboardViewModelProvider);
      expect(state.leaderboardData, isNotNull);
      expect(state.resumesData, isNotNull);
    });

    test('should load profile preferences', () async {
      const preferences = ProfilePreferences(
        defaultResumeId: 'resume-1',
        portfolioLinks: ['https://portfolio.example.com'],
      );
      when(
        () => mockDashboardRepository.getProfilePreferences(),
      ).thenAnswer((_) async => const Right(preferences));

      final viewModel = container.read(dashboardViewModelProvider.notifier);
      await viewModel.loadProfilePreferences();

      expect(
        container.read(dashboardViewModelProvider).profilePrefs,
        preferences,
      );
    });

    test('should reset state', () {
      final viewModel = container.read(dashboardViewModelProvider.notifier);
      viewModel.resetState();

      expect(container.read(dashboardViewModelProvider), const DashboardState());
    });
  });
}
