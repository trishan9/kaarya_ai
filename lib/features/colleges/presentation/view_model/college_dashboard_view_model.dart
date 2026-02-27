import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/features/colleges/data/repositories/college_repository.dart';
import 'package:kaarya/features/colleges/domain/entities/college_workspace_entity.dart';
import 'package:kaarya/features/colleges/domain/repositories/college_repository.dart';
import 'package:kaarya/features/jobs/data/repositories/job_repository.dart';
import 'package:kaarya/features/jobs/domain/entities/job_entity.dart';
import 'package:kaarya/features/jobs/domain/repositories/job_repository.dart';

final collegeDashboardViewModelProvider =
    NotifierProvider<CollegeDashboardViewModel, CollegeDashboardState>(
      CollegeDashboardViewModel.new,
    );

class CollegeDashboardViewModel extends Notifier<CollegeDashboardState> {
  @override
  CollegeDashboardState build() => const CollegeDashboardState();

  ICollegeRepository get _collegeRepo => ref.read(collegeRepositoryProvider);
  IJobRepository get _jobRepo => ref.read(jobRepositoryProvider);

  /// Load college workspace(s). For college role: single workspace. For candidate: joined colleges.
  Future<void> loadWorkspaces({bool forceRefresh = false}) async {
    if (!forceRefresh &&
        state.workspacesStatus == CollegeDashboardLoadStatus.loaded &&
        state.workspaces != null) {
      return;
    }

    state = state.copyWith(
      workspacesStatus: CollegeDashboardLoadStatus.loading,
      workspacesError: null,
    );

    final result = await _collegeRepo.listCollegeWorkspaces(page: 1, size: 50);

    result.fold(
      (f) => state = state.copyWith(
        workspacesStatus: CollegeDashboardLoadStatus.error,
        workspacesError: f.message,
        workspaces: null,
      ),
      (workspaces) {
        final currentSelectedId = state.selectedWorkspace?.collegeId;
        final refreshedSelected = currentSelectedId == null
            ? (workspaces.isNotEmpty ? workspaces.first : null)
            : workspaces
                      .where((w) => w.collegeId == currentSelectedId)
                      .firstOrNull ??
                  (workspaces.isNotEmpty ? workspaces.first : null);

        state = state.copyWith(
          workspacesStatus: CollegeDashboardLoadStatus.loaded,
          workspaces: workspaces,
          workspacesError: null,
          selectedWorkspace: refreshedSelected,
        );
      },
    );
  }

  void selectWorkspace(CollegeWorkspaceEntity? workspace) {
    state = state.copyWith(selectedWorkspace: workspace);
  }

  void resetState() {
    state = const CollegeDashboardState();
  }

  /// Join college by invite code. Returns error message on failure, null on success.
  Future<String?> joinWorkspace({required String inviteCode}) async {
    final result = await _collegeRepo.joinByCode(inviteCode.trim());

    return result.fold<Future<String?>>((f) => Future.value(f.message), (
      college,
    ) async {
      await loadWorkspaces(forceRefresh: true);
      final ws = state.workspaces?.firstWhere(
        (w) => w.collegeId == college.id,
        orElse: () => CollegeWorkspaceEntity(
          collegeId: college.id,
          collegeName: college.name,
          collegeLogo: college.logo,
          joinedAt: college.createdAt,
        ),
      );
      selectWorkspace(ws);
      return null;
    });
  }

  /// Switch workspace and refresh college jobs.
  Future<void> switchWorkspaceAndRefresh(
    CollegeWorkspaceEntity workspace,
  ) async {
    selectWorkspace(workspace);
    await loadCollegeJobs(collegeId: workspace.collegeId, forceRefresh: true);
  }

  Future<void> loadCollegeJobs({
    required String collegeId,
    String? status,
    String? search,
    bool forceRefresh = false,
  }) async {
    state = state.copyWith(
      collegeJobsStatus: CollegeDashboardLoadStatus.loading,
      collegeJobsError: null,
    );

    final result = await _jobRepo.listCollegeJobs(
      collegeId: collegeId,
      status: status,
      search: search,
      page: 1,
      size: 100,
    );

    result.fold(
      (f) => state = state.copyWith(
        collegeJobsStatus: CollegeDashboardLoadStatus.error,
        collegeJobsError: f.message,
        collegeJobs: null,
      ),
      (jobs) => state = state.copyWith(
        collegeJobsStatus: CollegeDashboardLoadStatus.loaded,
        collegeJobs: jobs,
        collegeJobsError: null,
      ),
    );
  }

  void clearCollegeJobs() {
    state = state.copyWith(
      collegeJobs: null,
      collegeJobsStatus: CollegeDashboardLoadStatus.initial,
    );
  }

  CollegeOverviewData computeOverviewData() {
    final jobs = state.collegeJobs ?? [];
    final openJobs = jobs.where((j) => j.status.toLowerCase() == 'open');
    final draftJobs = jobs.where((j) => j.status.toLowerCase() == 'draft');

    final totalApplicants = jobs.fold<int>(
      0,
      (s, j) => s + j.applicationsCount,
    );
    final totalViews = jobs.fold<int>(0, (s, j) => s + j.viewsCount);

    final now = DateTime.now();
    final closingSoon = openJobs.where((j) {
      final d = DateTime.tryParse(j.deadline);
      if (d == null) return false;
      final diff = d.difference(now).inDays;
      return diff >= 0 && diff <= 14;
    }).length;

    final workModeCounts = <String, int>{};
    for (final j in jobs) {
      final mode = j.workMode.isEmpty ? 'onsite' : j.workMode;
      workModeCounts[mode] = (workModeCounts[mode] ?? 0) + 1;
    }

    final upcomingDeadlines =
        openJobs
            .map((j) {
              final d = DateTime.tryParse(j.deadline);
              if (d == null || d.isBefore(now)) return null;
              final diff = d.difference(now).inDays;
              if (diff > 30) return null;
              return UpcomingDeadlineItem(
                id: j.id,
                title: j.title,
                deadline: j.deadline,
                applicants: j.applicationsCount,
              );
            })
            .whereType<UpcomingDeadlineItem>()
            .toList()
          ..sort((a, b) {
            final da = DateTime.tryParse(a.deadline) ?? DateTime.now();
            final db = DateTime.tryParse(b.deadline) ?? DateTime.now();
            return da.compareTo(db);
          });

    return CollegeOverviewData(
      openJobsCount: openJobs.length,
      draftJobsCount: draftJobs.length,
      totalApplicants: totalApplicants,
      totalViews: totalViews,
      closingSoonCount: closingSoon,
      workModeDistribution: [
        WorkModeItem('Remote', workModeCounts['remote'] ?? 0),
        WorkModeItem('Hybrid', workModeCounts['hybrid'] ?? 0),
        WorkModeItem('Onsite', workModeCounts['onsite'] ?? 0),
      ],
      upcomingDeadlines: upcomingDeadlines,
      jobs: jobs,
    );
  }
}

enum CollegeDashboardLoadStatus { initial, loading, loaded, error }

class CollegeDashboardState {
  final CollegeDashboardLoadStatus workspacesStatus;
  final CollegeDashboardLoadStatus collegeJobsStatus;
  final List<CollegeWorkspaceEntity>? workspaces;
  final CollegeWorkspaceEntity? selectedWorkspace;
  final List<JobEntity>? collegeJobs;
  final String? workspacesError;
  final String? collegeJobsError;

  const CollegeDashboardState({
    this.workspacesStatus = CollegeDashboardLoadStatus.initial,
    this.collegeJobsStatus = CollegeDashboardLoadStatus.initial,
    this.workspaces,
    this.selectedWorkspace,
    this.collegeJobs,
    this.workspacesError,
    this.collegeJobsError,
  });

  CollegeDashboardState copyWith({
    CollegeDashboardLoadStatus? workspacesStatus,
    CollegeDashboardLoadStatus? collegeJobsStatus,
    List<CollegeWorkspaceEntity>? workspaces,
    CollegeWorkspaceEntity? selectedWorkspace,
    List<JobEntity>? collegeJobs,
    String? workspacesError,
    String? collegeJobsError,
  }) => CollegeDashboardState(
    workspacesStatus: workspacesStatus ?? this.workspacesStatus,
    collegeJobsStatus: collegeJobsStatus ?? this.collegeJobsStatus,
    workspaces: workspaces ?? this.workspaces,
    selectedWorkspace: selectedWorkspace ?? this.selectedWorkspace,
    collegeJobs: collegeJobs ?? this.collegeJobs,
    workspacesError: workspacesError ?? this.workspacesError,
    collegeJobsError: collegeJobsError ?? this.collegeJobsError,
  );
}

class CollegeOverviewData {
  final int openJobsCount;
  final int draftJobsCount;
  final int totalApplicants;
  final int totalViews;
  final int closingSoonCount;
  final List<WorkModeItem> workModeDistribution;
  final List<UpcomingDeadlineItem> upcomingDeadlines;
  final List<JobEntity> jobs;

  CollegeOverviewData({
    required this.openJobsCount,
    required this.draftJobsCount,
    required this.totalApplicants,
    required this.totalViews,
    required this.closingSoonCount,
    required this.workModeDistribution,
    required this.upcomingDeadlines,
    required this.jobs,
  });
}

class UpcomingDeadlineItem {
  final String id;
  final String title;
  final String deadline;
  final int applicants;

  UpcomingDeadlineItem({
    required this.id,
    required this.title,
    required this.deadline,
    required this.applicants,
  });
}

class WorkModeItem {
  final String mode;
  final int count;

  WorkModeItem(this.mode, this.count);
}
