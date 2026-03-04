import 'package:kaarya/features/jobs/data/models/job_api_models.dart';
import 'package:kaarya/features/jobs/data/models/job_hive_model.dart';

abstract interface class IJobRemoteDataSource {
  Future<JobsSectionApiModel> getJobsSection({
    String? searchQuery,
    String? locationQuery,
    String? status,
    String? employmentType,
    String? engagementType,
  });

  Future<JobDetailApiModel> getJobDetail(String jobId);
  Future<void> recordJobView(String jobId);

  Future<JobApiModel> createJob(Map<String, dynamic> data);
  Future<JobApiModel> updateJob(String jobId, Map<String, dynamic> data);
  Future<bool> deleteJob(String jobId);
  Future<JobMetricsApiModel> getJobMetrics(String jobId);

  Future<bool> applyToJob(
    String jobId, {
    String? resumeId,
    String? coverLetter,
    List<String>? portfolioLinks,
  });
  Future<bool> toggleJobBookmark(String jobId, bool save);
}

abstract interface class IJobLocalDataSource {
  Future<void> saveJobsSection(JobsSectionHiveModel data);
  Future<JobsSectionHiveModel?> getJobsSection();
}
