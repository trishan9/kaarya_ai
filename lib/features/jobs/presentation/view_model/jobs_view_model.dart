import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/features/jobs/data/repositories/job_repository.dart';
import 'package:kaarya/features/jobs/domain/entities/job_detail_entity.dart';
import 'package:kaarya/features/jobs/domain/entities/job_entity.dart';
import 'package:kaarya/features/jobs/domain/entities/job_metrics_entity.dart';
import 'package:kaarya/features/jobs/domain/entities/jobs_section_entity.dart';
import 'package:kaarya/features/jobs/domain/repositories/job_repository.dart';

final jobsViewModelProvider = NotifierProvider<JobsViewModel, JobsState>(
  JobsViewModel.new,
);

class JobsViewModel extends Notifier<JobsState> {
  @override
  JobsState build() => JobsState.initial();

  IJobRepository get _repo => ref.read(jobRepositoryProvider);

  Future<void> loadJobsSection({
    String? searchQuery,
    String? locationQuery,
    String? status,
    String? employmentType,
    String? engagementType,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _repo.getJobsSection(
      searchQuery: searchQuery,
      locationQuery: locationQuery,
      status: status,
      employmentType: employmentType,
      engagementType: engagementType,
    );
    result.fold(
      (f) => state = state.copyWith(
        isLoading: false,
        error: f.message,
        section: null,
      ),
      (section) => state = state.copyWith(
        isLoading: false,
        error: null,
        section: section,
      ),
    );
  }

  Future<void> loadJobDetail(String jobId) async {
    state = state.copyWith(jobDetailLoading: true, jobDetailError: null);
    final result = await _repo.getJobDetail(jobId);
    result.fold(
      (f) => state = state.copyWith(
        jobDetailLoading: false,
        jobDetailError: f.message,
        clearJobDetail: true,
      ),
      (d) => state = state.copyWith(
        jobDetailLoading: false,
        jobDetailError: null,
        jobDetail: d,
      ),
    );
  }

  Future<void> recordJobView(String jobId) async {
    await _repo.recordJobView(jobId);
  }

  Future<bool?> applyToJob(
    String jobId, {
    String? resumeId,
    String? coverLetter,
    List<String>? portfolioLinks,
  }) async {
    final result = await _repo.applyToJob(
      jobId,
      resumeId: resumeId,
      coverLetter: coverLetter,
      portfolioLinks: portfolioLinks,
    );
    return result.fold((_) => null, (ok) => ok);
  }

  Future<bool?> toggleBookmark(String jobId, bool save) async {
    final result = await _repo.toggleJobBookmark(jobId, save);
    return result.fold((_) => null, (ok) => ok);
  }

  Future<JobEntity?> createJob(Map<String, dynamic> data) async {
    final result = await _repo.createJob(data);
    return result.fold((_) => null, (job) => job);
  }

  Future<JobEntity?> updateJob(String jobId, Map<String, dynamic> data) async {
    final result = await _repo.updateJob(jobId, data);
    return result.fold((_) => null, (job) => job);
  }

  Future<bool?> deleteJob(String jobId) async {
    final result = await _repo.deleteJob(jobId);
    return result.fold((_) => null, (ok) => ok);
  }

  Future<void> loadJobMetrics(String jobId) async {
    state = state.copyWith(metricsLoading: true, metricsError: null);
    final result = await _repo.getJobMetrics(jobId);
    result.fold(
      (f) => state = state.copyWith(
        metricsLoading: false,
        metricsError: f.message,
      ),
      (metrics) => state = state.copyWith(
        metricsLoading: false,
        metricsError: null,
        jobMetrics: metrics,
      ),
    );
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

class JobsState {
  final bool isLoading;
  final String? error;
  final JobsSectionEntity? section;
  final bool jobDetailLoading;
  final String? jobDetailError;
  final JobDetailEntity? jobDetail;
  final bool metricsLoading;
  final String? metricsError;
  final JobMetricsEntity? jobMetrics;

  const JobsState({
    this.isLoading = false,
    this.error,
    this.section,
    this.jobDetailLoading = false,
    this.jobDetailError,
    this.jobDetail,
    this.metricsLoading = false,
    this.metricsError,
    this.jobMetrics,
  });

  factory JobsState.initial() => const JobsState();

  JobsState copyWith({
    bool? isLoading,
    String? error,
    JobsSectionEntity? section,
    bool? jobDetailLoading,
    String? jobDetailError,
    JobDetailEntity? jobDetail,
    bool clearJobDetail = false,
    bool? metricsLoading,
    String? metricsError,
    JobMetricsEntity? jobMetrics,
  }) => JobsState(
    isLoading: isLoading ?? this.isLoading,
    error: error,
    section: section ?? this.section,
    jobDetailLoading: jobDetailLoading ?? this.jobDetailLoading,
    jobDetailError: jobDetailError,
    jobDetail: clearJobDetail ? null : (jobDetail ?? this.jobDetail),
    metricsLoading: metricsLoading ?? this.metricsLoading,
    metricsError: metricsError,
    jobMetrics: jobMetrics ?? this.jobMetrics,
  );
}
