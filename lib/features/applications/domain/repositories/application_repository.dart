import 'package:dartz/dartz.dart';
import 'package:kaarya/core/error/failures.dart';
import 'package:kaarya/features/applications/domain/entities/application_entity.dart';
import 'package:kaarya/features/applications/domain/entities/application_summary_entity.dart';
import 'package:kaarya/features/applications/domain/entities/job_applicant_entity.dart';
import 'package:kaarya/features/applications/domain/entities/resume_entity.dart';

abstract interface class IApplicationRepository {
  Future<Either<Failure, ApplicationsListEntity>> getMyApplications({
    int page,
    int size,
    String? status,
  });

  Future<Either<Failure, ApplicationSummaryEntity>> getApplicationsSummary({
    String? month,
    String? statuses,
  });

  Future<Either<Failure, ApplicationEntity>> getApplicationForJob({
    required String jobId,
  });

  Future<Either<Failure, bool>> applyToJob({
    required String jobId,
    String? resumeId,
    String? resumeFilePath,
    List<int>? resumeBytes,
    String? resumeFilename,
    String? coverLetter,
    List<String>? portfolioLinks,
  });

  Future<Either<Failure, ApplicationsListEntity>> getJobApplications({
    required String jobId,
    int page,
    int size,
    String? status,
  });

  Future<Either<Failure, JobApplicantsListEntity>> getJobApplicants({
    required String jobId,
    int page,
    int size,
    String? status,
  });

  Future<Either<Failure, bool>> updateApplication({
    required String jobId,
    required String applicationId,
    String? status,
    DateTime? interviewScheduledAt,
    String? interviewNote,
  });

  Future<Either<Failure, List<ResumeEntity>>> listMyResumes({
    int page,
    int size,
  });

  Future<Either<Failure, ResumeEntity>> uploadResume({
    required String filePath,
  });

  Future<Either<Failure, bool>> deleteResume({required String resumeId});

  Future<Either<Failure, bool>> updateResumeActivity({
    required String jobId,
    required String applicationId,
    required String action,
  });
}
