import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/core/error/failures.dart';
import 'package:kaarya/features/applications/domain/usecases/apply_to_job_usecase.dart';
import 'package:kaarya/features/applications/domain/usecases/get_my_applications_usecase.dart';
import 'package:kaarya/features/applications/domain/usecases/list_my_resumes_usecase.dart';
import 'package:kaarya/features/bookmarks/domain/usecases/get_my_bookmarks_usecase.dart';
import 'package:kaarya/features/bookmarks/domain/usecases/save_job_bookmark_usecase.dart';
import 'package:kaarya/features/bookmarks/domain/usecases/unsave_job_bookmark_usecase.dart';
import 'package:kaarya/features/interviews/domain/entities/interview_feedback_entity.dart';
import 'package:kaarya/features/interviews/domain/entities/interview_session_entity.dart';
import 'package:kaarya/features/interviews/domain/usecases/get_interview_feedback_usecase.dart';
import 'package:kaarya/features/interviews/domain/usecases/get_interviews_section_usecase.dart';
import 'package:kaarya/features/interviews/domain/usecases/set_interview_saved_usecase.dart';
import 'package:kaarya/features/interviews/domain/usecases/start_interview_session_usecase.dart';
import 'package:kaarya/features/jobs/domain/entities/job_entity.dart';
import 'package:kaarya/features/jobs/domain/entities/jobs_section_entity.dart'
    show JobsBucketEntity, JobsSectionEntity;
import 'package:kaarya/features/jobs/domain/usecases/get_job_detail_usecase.dart';
import 'package:kaarya/features/jobs/domain/usecases/get_jobs_section_usecase.dart';
import 'package:kaarya/features/leaderboard/domain/usecases/get_leaderboard_usecase.dart';
import 'package:kaarya/features/dashboard/domain/usecases/get_overview_usecase.dart';
import 'package:kaarya/features/dashboard/data/repositories/dashboard_repository.dart';
import 'package:kaarya/features/dashboard/presentation/state/dashboard_state.dart';

final dashboardViewModelProvider =
    NotifierProvider<DashboardViewModel, DashboardState>(
      DashboardViewModel.new,
    );

class DashboardViewModel extends Notifier<DashboardState> {
  late final GetOverviewUseCase _getOverviewUseCase;
  late final GetJobsSectionUseCase _getJobsSectionUseCase;
  late final GetInterviewsSectionUseCase _getInterviewsSectionUseCase;
  late final SetInterviewSavedUseCase _setInterviewSavedUseCase;
  late final StartInterviewSessionUseCase _startInterviewSessionUseCase;
  late final GetInterviewFeedbackUseCase _getInterviewFeedbackUseCase;
  late final GetJobDetailUseCase _getJobDetailUseCase;
  late final GetMyApplicationsUseCase _getMyApplicationsUseCase;
  late final ApplyToJobUseCase _applyToJobUseCase;
  late final GetMyBookmarksUseCase _getMyBookmarksUseCase;
  late final SaveJobBookmarkUseCase _saveJobBookmarkUseCase;
  late final UnsaveJobBookmarkUseCase _unsaveJobBookmarkUseCase;
  late final GetLeaderboardUseCase _getLeaderboardUseCase;
  late final ListMyResumesUseCase _listMyResumesUseCase;

  @override
  DashboardState build() {
    _getOverviewUseCase = ref.read(getOverviewUseCaseProvider);
    _getJobsSectionUseCase = ref.read(getJobsSectionUseCaseProvider);
    _getInterviewsSectionUseCase = ref.read(
      getInterviewsSectionUseCaseProvider,
    );
    _setInterviewSavedUseCase = ref.read(setInterviewSavedUseCaseProvider);
    _startInterviewSessionUseCase = ref.read(
      startInterviewSessionUseCaseProvider,
    );
    _getInterviewFeedbackUseCase = ref.read(
      getInterviewFeedbackUseCaseProvider,
    );
    _getJobDetailUseCase = ref.read(getJobDetailUseCaseProvider);
    _getMyApplicationsUseCase = ref.read(getMyApplicationsUseCaseProvider);
    _applyToJobUseCase = ref.read(applyToJobUseCaseProvider);
    _getMyBookmarksUseCase = ref.read(getMyBookmarksUseCaseProvider);
    _saveJobBookmarkUseCase = ref.read(saveJobBookmarkUseCaseProvider);
    _unsaveJobBookmarkUseCase = ref.read(unsaveJobBookmarkUseCaseProvider);
    _getLeaderboardUseCase = ref.read(getLeaderboardUseCaseProvider);
    _listMyResumesUseCase = ref.read(listMyResumesUseCaseProvider);
    return const DashboardState();
  }

  void resetState() {
    state = const DashboardState();
  }

  Future<void> loadOverview({
    String? monthKey,
    bool forceRefresh = false,
  }) async {
    final nextMonthKey = (monthKey ?? state.overviewMonthKey).trim();
    final monthChanged = nextMonthKey != state.overviewMonthKey;

    if (!forceRefresh &&
        !monthChanged &&
        state.overviewStatus == DashboardLoadStatus.loaded &&
        state.overviewData != null) {
      return;
    }

    state = state.copyWith(
      overviewStatus: DashboardLoadStatus.loading,
      overviewErrorMessage: null,
      overviewMonthKey: nextMonthKey,
    );

    final result = await _getOverviewUseCase(
      GetOverviewUseCaseParams(
        monthKey: nextMonthKey.isEmpty ? null : nextMonthKey,
      ),
    );
    result.fold(
      (failure) => state = state.copyWith(
        overviewStatus: DashboardLoadStatus.error,
        overviewErrorMessage: failure.message,
      ),
      (overview) => state = state.copyWith(
        overviewStatus: DashboardLoadStatus.loaded,
        overviewData: overview,
        overviewErrorMessage: null,
      ),
    );
  }

  Future<void> loadJobs({
    String? searchQuery,
    String? locationQuery,
    String? status,
    String? employmentType,
    String? engagementType,
    bool forceRefresh = false,
  }) async {
    final nextSearch = (searchQuery ?? state.jobsSearchQuery).trim();
    final nextLocation = (locationQuery ?? state.jobsLocationQuery).trim();
    final queryChanged =
        nextSearch != state.jobsSearchQuery ||
        nextLocation != state.jobsLocationQuery;

    if (!forceRefresh &&
        !queryChanged &&
        state.jobsStatus == DashboardLoadStatus.loaded &&
        state.jobsData != null) {
      return;
    }

    state = state.copyWith(
      jobsStatus: DashboardLoadStatus.loading,
      jobsSearchQuery: nextSearch,
      jobsLocationQuery: nextLocation,
      jobsErrorMessage: null,
    );

    final result = await _getJobsSectionUseCase(
      GetJobsSectionParams(
        searchQuery: nextSearch,
        locationQuery: nextLocation,
        status: status,
        employmentType: employmentType,
        engagementType: engagementType,
      ),
    );
    result.fold(
      (failure) => state = state.copyWith(
        jobsStatus: DashboardLoadStatus.error,
        jobsErrorMessage: failure.message,
      ),
      (jobsData) => state = state.copyWith(
        jobsStatus: DashboardLoadStatus.loaded,
        jobsData: jobsData,
        jobsErrorMessage: null,
      ),
    );
  }

  Future<void> loadInterviews({
    bool forceRefresh = false,
    String? searchQuery,
    String? interviewType,
    String? status,
    String? sortBy,
    String? attemptFilter,
  }) async {
    if (!forceRefresh &&
        state.interviewsStatus == DashboardLoadStatus.loaded &&
        state.interviewsData != null) {
      return;
    }

    state = state.copyWith(
      interviewsStatus: DashboardLoadStatus.loading,
      interviewsErrorMessage: null,
    );

    final result = await _getInterviewsSectionUseCase(
      GetInterviewsSectionUseCaseParams(
        searchQuery: searchQuery,
        interviewType: interviewType,
        status: status,
        sortBy: sortBy,
        attemptFilter: attemptFilter,
      ),
    );
    result.fold(
      (failure) => state = state.copyWith(
        interviewsStatus: DashboardLoadStatus.error,
        interviewsErrorMessage: failure.message,
      ),
      (interviewsData) => state = state.copyWith(
        interviewsStatus: DashboardLoadStatus.loaded,
        interviewsData: interviewsData,
        interviewsErrorMessage: null,
      ),
    );
  }

  Future<Failure?> setInterviewSaved({
    required String interviewId,
    required bool isSaved,
  }) async {
    final result = await _setInterviewSavedUseCase(
      SetInterviewSavedUseCaseParams(
        interviewId: interviewId,
        isSaved: isSaved,
      ),
    );

    return result.fold((failure) => failure, (_) => null);
  }

  Future<(InterviewSessionStartEntity?, Failure?)> startInterviewSession(
    String interviewId,
  ) async {
    final result = await _startInterviewSessionUseCase(
      StartInterviewSessionUseCaseParams(interviewId: interviewId),
    );
    return result.fold((failure) => (null, failure), (data) => (data, null));
  }

  Future<(InterviewFeedbackEntity?, Failure?)> getInterviewFeedback(
    String sessionId,
  ) async {
    final result = await _getInterviewFeedbackUseCase(
      GetInterviewFeedbackUseCaseParams(sessionId: sessionId),
    );
    return result.fold((failure) => (null, failure), (data) => (data, null));
  }

  Future<void> loadJobDetail(String jobId) async {
    state = state.copyWith(
      jobDetailStatus: DashboardLoadStatus.loading,
      jobDetailData: null,
      jobDetailErrorMessage: null,
    );
    final result = await _getJobDetailUseCase(GetJobDetailParams(jobId: jobId));
    result.fold(
      (failure) => state = state.copyWith(
        jobDetailStatus: DashboardLoadStatus.error,
        jobDetailErrorMessage: failure.message,
      ),
      (data) => state = state.copyWith(
        jobDetailStatus: DashboardLoadStatus.loaded,
        jobDetailData: data,
        jobDetailErrorMessage: null,
      ),
    );
  }

  Future<void> loadMyApplications({
    String? status,
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh &&
        state.applicationsStatus == DashboardLoadStatus.loaded &&
        state.applicationsData != null)
      return;
    state = state.copyWith(
      applicationsStatus: DashboardLoadStatus.loading,
      applicationsErrorMessage: null,
    );
    final result = await _getMyApplicationsUseCase(
      GetMyApplicationsUseCaseParams(status: status),
    );
    result.fold(
      (failure) => state = state.copyWith(
        applicationsStatus: DashboardLoadStatus.error,
        applicationsErrorMessage: failure.message,
      ),
      (data) => state = state.copyWith(
        applicationsStatus: DashboardLoadStatus.loaded,
        applicationsData: data,
        applicationsErrorMessage: null,
      ),
    );
  }

  Future<Failure?> applyToJob(
    String jobId, {
    String? resumeId,
    String? resumeFilePath,
    List<int>? resumeBytes,
    String? resumeFilename,
    String? coverLetter,
    List<String>? portfolioLinks,
  }) async {
    final result = await _applyToJobUseCase(
      ApplyToJobUseCaseParams(
        jobId: jobId,
        resumeId: resumeId,
        resumeFilePath: resumeFilePath,
        resumeBytes: resumeBytes,
        resumeFilename: resumeFilename,
        coverLetter: coverLetter,
        portfolioLinks: portfolioLinks,
      ),
    );
    return result.fold((failure) => failure, (_) => null);
  }

  Future<void> loadMyBookmarks({
    String? type,
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh &&
        state.bookmarksStatus == DashboardLoadStatus.loaded &&
        state.bookmarksData != null)
      return;
    state = state.copyWith(
      bookmarksStatus: DashboardLoadStatus.loading,
      bookmarksErrorMessage: null,
    );
    final result = await _getMyBookmarksUseCase(
      GetMyBookmarksParams(type: type, sortBy: 'saved_at_desc'),
    );
    result.fold(
      (failure) => state = state.copyWith(
        bookmarksStatus: DashboardLoadStatus.error,
        bookmarksErrorMessage: failure.message,
      ),
      (data) => state = state.copyWith(
        bookmarksStatus: DashboardLoadStatus.loaded,
        bookmarksData: data,
        bookmarksErrorMessage: null,
      ),
    );
  }

  Future<Failure?> toggleJobBookmark(String jobId, bool save) async {
    _optimisticallyUpdateJobSaved(jobId, save);
    final result = save
        ? await _saveJobBookmarkUseCase(jobId)
        : await _unsaveJobBookmarkUseCase(jobId);
    return result.fold((failure) {
      _optimisticallyUpdateJobSaved(jobId, !save);
      return failure;
    }, (_) => null);
  }

  void _optimisticallyUpdateJobSaved(String jobId, bool saved) {
    final jobsSection = state.jobsData;
    if (jobsSection == null) return;

    List<JobEntity> _mapList(List<JobEntity> list) => list
        .map((j) => j.id == jobId ? j.copyWith(isSaved: saved) : j)
        .toList();

    final updatedBucket = JobsBucketEntity(
      forYou: _mapList(jobsSection.jobs.forYou),
      trending: _mapList(jobsSection.jobs.trending),
      newThisWeek: _mapList(jobsSection.jobs.newThisWeek),
      remote: _mapList(jobsSection.jobs.remote),
      urgent: _mapList(jobsSection.jobs.urgent),
    );

    state = state.copyWith(
      jobsData: JobsSectionEntity(
        searchQuery: jobsSection.searchQuery,
        locationQuery: jobsSection.locationQuery,
        jobs: updatedBucket,
      ),
    );
  }

  Future<void> loadLeaderboard({
    String? scope,
    String? collegeId,
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh &&
        state.leaderboardStatus == DashboardLoadStatus.loaded &&
        state.leaderboardData != null)
      return;
    state = state.copyWith(
      leaderboardStatus: DashboardLoadStatus.loading,
      leaderboardErrorMessage: null,
    );
    final result = await _getLeaderboardUseCase(
      GetLeaderboardParams(scope: scope, collegeId: collegeId),
    );
    result.fold(
      (failure) => state = state.copyWith(
        leaderboardStatus: DashboardLoadStatus.error,
        leaderboardErrorMessage: failure.message,
      ),
      (data) => state = state.copyWith(
        leaderboardStatus: DashboardLoadStatus.loaded,
        leaderboardData: data,
        leaderboardErrorMessage: null,
      ),
    );
  }

  Future<void> loadMyResumes() async {
    state = state.copyWith(resumesStatus: DashboardLoadStatus.loading);
    final result = await _listMyResumesUseCase(
      const ListMyResumesUseCaseParams(),
    );
    result.fold(
      (failure) =>
          state = state.copyWith(resumesStatus: DashboardLoadStatus.error),
      (data) => state = state.copyWith(
        resumesStatus: DashboardLoadStatus.loaded,
        resumesData: data,
      ),
    );
  }

  Future<void> loadProfilePreferences() async {
    final repo = ref.read(dashboardRepositoryProvider);
    final result = await repo.getProfilePreferences();
    result.fold((_) {}, (prefs) {
      state = state.copyWith(profilePrefs: prefs);
    });
  }
}
