import 'package:kaarya/features/applications/data/models/application_api_model.dart';
import 'package:kaarya/features/applications/data/models/application_hive_model.dart';
import 'package:kaarya/features/applications/data/models/resume_hive_model.dart';

abstract interface class IApplicationRemoteDataSource {
  Future<List<ApplicationApiModel>> getMyApplications({
    int page = 1,
    int size = 50,
    String? status,
  });

  Future<ApplicationSummaryApiModel> getApplicationsSummary({
    String? month,
    String? statuses,
  });

  Future<ApplicationApiModel> getApplicationForJob({required String jobId});

  Future<bool> applyToJob(
    String jobId, {
    String? resumeId,
    String? resumeFilePath,
    List<int>? resumeBytes,
    String? resumeFilename,
    String? coverLetter,
    List<String>? portfolioLinks,
  });

  Future<List<ApplicationApiModel>> getJobApplications({
    required String jobId,
    int page = 1,
    int size = 50,
    String? status,
  });

  Future<List<JobApplicantApiModel>> getJobApplicants({
    required String jobId,
    int page = 1,
    int size = 50,
    String? status,
  });

  Future<bool> updateApplication({
    required String jobId,
    required String applicationId,
    String? status,
    DateTime? interviewScheduledAt,
    String? interviewNote,
  });

  Future<List<ResumeApiModel>> listMyResumes({int page = 1, int size = 50});

  Future<ResumeApiModel> uploadResume({required String filePath});

  Future<bool> deleteResume({required String resumeId});

  Future<bool> updateResumeActivity({
    required String jobId,
    required String applicationId,
    required String action,
  });
}

abstract interface class IApplicationLocalDataSource {
  Future<void> saveMyApplications(List<ApplicationHiveModel> data);
  Future<List<ApplicationHiveModel>> getMyApplications();

  Future<void> saveResumes(List<ResumeHiveModel> data);
  Future<List<ResumeHiveModel>> listMyResumes();
}
