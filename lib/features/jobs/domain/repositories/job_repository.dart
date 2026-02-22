import 'package:dartz/dartz.dart';
import 'package:kaarya/core/error/failures.dart';
import 'package:kaarya/features/jobs/domain/entities/job_detail_entity.dart';
import 'package:kaarya/features/jobs/domain/entities/job_entity.dart';
import 'package:kaarya/features/jobs/domain/entities/job_metrics_entity.dart';
import 'package:kaarya/features/jobs/domain/entities/jobs_section_entity.dart';

abstract interface class IJobRepository {
  /// Returns cached jobs section if available (for cache-first loading).
  Future<JobsSectionEntity?> getJobsSectionFromCache();

  Future<Either<Failure, JobsSectionEntity>> getJobsSection({
    String? searchQuery,
    String? locationQuery,
    String? status,
    String? employmentType,
    String? engagementType,
  });

  Future<Either<Failure, JobDetailEntity>> getJobDetail(String jobId);
  Future<Either<Failure, void>> recordJobView(String jobId);

  Future<Either<Failure, JobEntity>> createJob(Map<String, dynamic> data);
  Future<Either<Failure, JobEntity>> updateJob(
    String jobId,
    Map<String, dynamic> data,
  );
  Future<Either<Failure, bool>> deleteJob(String jobId);
  Future<Either<Failure, JobMetricsEntity>> getJobMetrics(String jobId);

  Future<Either<Failure, bool>> applyToJob(
    String jobId, {
    String? resumeId,
    String? coverLetter,
    List<String>? portfolioLinks,
  });
  Future<Either<Failure, bool>> toggleJobBookmark(String jobId, bool save);

  Future<Either<Failure, List<JobEntity>>> listCompanyJobs({
    required String companyId,
    String? status,
    String? search,
    int page,
    int size,
  });
}
