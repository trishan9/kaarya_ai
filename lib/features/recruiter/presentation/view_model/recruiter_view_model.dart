import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/features/companies/data/repositories/company_repository.dart';
import 'package:kaarya/features/companies/domain/entities/recruiter_workspace_entity.dart';
import 'package:kaarya/features/companies/domain/repositories/company_repository.dart';
import 'package:kaarya/features/jobs/data/repositories/job_repository.dart';
import 'package:kaarya/features/jobs/domain/entities/job_entity.dart';
import 'package:kaarya/features/jobs/domain/repositories/job_repository.dart';

final recruiterViewModelProvider =
    NotifierProvider<RecruiterViewModel, RecruiterState>(
  RecruiterViewModel.new,
);

class RecruiterViewModel extends Notifier<RecruiterState> {
  @override
  RecruiterState build() => const RecruiterState();

  ICompanyRepository get _companyRepo => ref.read(companyRepositoryProvider);
  IJobRepository get _jobRepo => ref.read(jobRepositoryProvider);

  Future<void> loadWorkspaces({bool forceRefresh = false}) async {
    if (!forceRefresh &&
        state.workspacesStatus == RecruiterLoadStatus.loaded &&
        state.workspaces != null) {
      return;
    }

    state = state.copyWith(
      workspacesStatus: RecruiterLoadStatus.loading,
      workspacesError: null,
    );

    final result = await _companyRepo.listRecruiterWorkspaces(
      page: 1,
      size: 50,
    );

    result.fold(
      (f) => state = state.copyWith(
        workspacesStatus: RecruiterLoadStatus.error,
        workspacesError: f.message,
        workspaces: null,
      ),
      (workspaces) => state = state.copyWith(
        workspacesStatus: RecruiterLoadStatus.loaded,
        workspaces: workspaces,
        workspacesError: null,
        selectedWorkspace: state.selectedWorkspace ??
            (workspaces.isNotEmpty ? workspaces.first : null),
      ),
    );
  }

  void selectWorkspace(RecruiterWorkspaceEntity? workspace) {
    state = state.copyWith(selectedWorkspace: workspace);
  }

  /// Create a new company workspace. On success, refreshes workspaces and selects the new one.
  /// Returns error message on failure, null on success.
  Future<String?> createWorkspace({
    required String name,
    required String industry,
    required String location,
    required String designation,
    String? logoPath,
  }) async {
    final result = await _companyRepo.createCompany(
      name: name,
      industry: industry,
      location: location,
      designation: designation,
      logoPath: logoPath,
    );
    return result.fold<Future<String?>>(
      (f) => Future.value(f.message),
      (company) async {
        await loadWorkspaces(forceRefresh: true);
        final ws = state.workspaces?.firstWhere(
          (w) => w.companyId == company.id,
          orElse: () => RecruiterWorkspaceEntity(
            companyId: company.id,
            companyName: company.name,
            companyLogo: company.logo,
            designation: designation,
            joinedAt: company.createdAt,
          ),
        );
        selectWorkspace(ws);
        return null;
      },
    );
  }

  Future<void> loadCompanyJobs({
    required String companyId,
    String? companyName,
    String? status,
    String? search,
    bool forceRefresh = false,
  }) async {
    state = state.copyWith(
      companyJobsStatus: RecruiterLoadStatus.loading,
      companyJobsError: null,
    );

    final result = await _jobRepo.listCompanyJobs(
      companyId: companyId,
      status: status,
      search: search,
      page: 1,
      size: 100,
    );

    result.fold(
      (f) => state = state.copyWith(
        companyJobsStatus: RecruiterLoadStatus.error,
        companyJobsError: f.message,
        companyJobs: null,
      ),
      (jobs) {
        // Ensure recruiter only sees own company's jobs (defense in depth)
        final filtered = companyName != null
            ? jobs.where((j) =>
                j.companyName.toLowerCase() == companyName.toLowerCase())
                .toList()
            : jobs;
        state = state.copyWith(
          companyJobsStatus: RecruiterLoadStatus.loaded,
          companyJobs: filtered,
          companyJobsError: null,
        );
      },
    );
  }

  void clearCompanyJobs() {
    state = state.copyWith(
      companyJobs: null,
      companyJobsStatus: RecruiterLoadStatus.initial,
    );
  }

  RecruiterOverviewData computeOverviewData() {
    final jobs = state.companyJobs ?? [];
    final openJobs = jobs.where((j) => j.status.toLowerCase() == 'open');
    final draftJobs = jobs.where((j) => j.status.toLowerCase() == 'draft');

    final totalApplicants = jobs.fold<int>(0, (s, j) => s + j.applicationsCount);
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

    final upcomingDeadlines = openJobs
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

    return RecruiterOverviewData(
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

enum RecruiterLoadStatus { initial, loading, loaded, error }

class RecruiterState {
  final RecruiterLoadStatus workspacesStatus;
  final RecruiterLoadStatus companyJobsStatus;
  final List<RecruiterWorkspaceEntity>? workspaces;
  final RecruiterWorkspaceEntity? selectedWorkspace;
  final List<JobEntity>? companyJobs;
  final String? workspacesError;
  final String? companyJobsError;

  const RecruiterState({
    this.workspacesStatus = RecruiterLoadStatus.initial,
    this.companyJobsStatus = RecruiterLoadStatus.initial,
    this.workspaces,
    this.selectedWorkspace,
    this.companyJobs,
    this.workspacesError,
    this.companyJobsError,
  });

  RecruiterState copyWith({
    RecruiterLoadStatus? workspacesStatus,
    RecruiterLoadStatus? companyJobsStatus,
    List<RecruiterWorkspaceEntity>? workspaces,
    RecruiterWorkspaceEntity? selectedWorkspace,
    List<JobEntity>? companyJobs,
    String? workspacesError,
    String? companyJobsError,
  }) =>
      RecruiterState(
        workspacesStatus: workspacesStatus ?? this.workspacesStatus,
        companyJobsStatus: companyJobsStatus ?? this.companyJobsStatus,
        workspaces: workspaces ?? this.workspaces,
        selectedWorkspace: selectedWorkspace ?? this.selectedWorkspace,
        companyJobs: companyJobs ?? this.companyJobs,
        workspacesError: workspacesError ?? this.workspacesError,
        companyJobsError: companyJobsError ?? this.companyJobsError,
      );
}

class RecruiterOverviewData {
  final int openJobsCount;
  final int draftJobsCount;
  final int totalApplicants;
  final int totalViews;
  final int closingSoonCount;
  final List<WorkModeItem> workModeDistribution;
  final List<UpcomingDeadlineItem> upcomingDeadlines;
  final List<JobEntity> jobs;

  RecruiterOverviewData({
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
