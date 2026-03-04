import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/core/error/failures.dart';
import 'package:kaarya/features/applications/domain/entities/resume_entity.dart';
import 'package:kaarya/features/applications/domain/usecases/apply_to_job_usecase.dart';
import 'package:kaarya/features/applications/domain/usecases/delete_resume_usecase.dart';
import 'package:kaarya/features/applications/domain/usecases/get_application_for_job_usecase.dart';
import 'package:kaarya/features/applications/domain/usecases/get_applications_summary_usecase.dart';
import 'package:kaarya/features/applications/domain/usecases/get_job_applications_usecase.dart';
import 'package:kaarya/features/applications/domain/usecases/get_my_applications_usecase.dart';
import 'package:kaarya/features/applications/domain/usecases/list_my_resumes_usecase.dart';
import 'package:kaarya/features/applications/domain/usecases/update_application_usecase.dart';
import 'package:kaarya/features/applications/domain/usecases/update_resume_activity_usecase.dart';
import 'package:kaarya/features/applications/domain/usecases/upload_resume_usecase.dart';
import 'package:kaarya/features/applications/presentation/state/application_state.dart';

final applicationViewModelProvider =
    NotifierProvider<ApplicationViewModel, ApplicationState>(
      () => ApplicationViewModel(),
    );

class ApplicationViewModel extends Notifier<ApplicationState> {
  late final GetMyApplicationsUseCase _getMyApplicationsUseCase;
  late final GetApplicationsSummaryUseCase _getApplicationsSummaryUseCase;
  late final GetApplicationForJobUseCase _getApplicationForJobUseCase;
  late final ApplyToJobUseCase _applyToJobUseCase;
  late final GetJobApplicationsUseCase _getJobApplicationsUseCase;
  late final UpdateApplicationUseCase _updateApplicationUseCase;
  late final ListMyResumesUseCase _listMyResumesUseCase;
  late final UploadResumeUseCase _uploadResumeUseCase;
  late final DeleteResumeUseCase _deleteResumeUseCase;
  late final UpdateResumeActivityUseCase _updateResumeActivityUseCase;

  @override
  ApplicationState build() {
    _getMyApplicationsUseCase = ref.read(getMyApplicationsUseCaseProvider);
    _getApplicationsSummaryUseCase = ref.read(
      getApplicationsSummaryUseCaseProvider,
    );
    _getApplicationForJobUseCase = ref.read(
      getApplicationForJobUseCaseProvider,
    );
    _applyToJobUseCase = ref.read(applyToJobUseCaseProvider);
    _getJobApplicationsUseCase = ref.read(getJobApplicationsUseCaseProvider);
    _updateApplicationUseCase = ref.read(updateApplicationUseCaseProvider);
    _listMyResumesUseCase = ref.read(listMyResumesUseCaseProvider);
    _uploadResumeUseCase = ref.read(uploadResumeUseCaseProvider);
    _deleteResumeUseCase = ref.read(deleteResumeUseCaseProvider);
    _updateResumeActivityUseCase = ref.read(
      updateResumeActivityUseCaseProvider,
    );
    return const ApplicationState();
  }

  void resetState() {
    state = const ApplicationState();
  }

  Future<void> loadMyApplications({
    int page = 1,
    int size = 50,
    String? status,
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh &&
        state.applicationsStatus == ApplicationLoadStatus.loaded &&
        state.applicationsData != null) {
      return;
    }

    state = state.copyWith(
      applicationsStatus: ApplicationLoadStatus.loading,
      applicationsErrorMessage: null,
    );

    final result = await _getMyApplicationsUseCase(
      GetMyApplicationsUseCaseParams(page: page, size: size, status: status),
    );

    result.fold(
      (failure) => state = state.copyWith(
        applicationsStatus: ApplicationLoadStatus.error,
        applicationsErrorMessage: failure.message,
      ),
      (data) => state = state.copyWith(
        applicationsStatus: ApplicationLoadStatus.loaded,
        applicationsData: data,
        applicationsErrorMessage: null,
      ),
    );
  }

  Future<void> loadApplicationsSummary({
    String? month,
    String? statuses,
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh &&
        state.summaryStatus == ApplicationLoadStatus.loaded &&
        state.summaryData != null) {
      return;
    }

    state = state.copyWith(
      summaryStatus: ApplicationLoadStatus.loading,
      summaryErrorMessage: null,
    );

    final result = await _getApplicationsSummaryUseCase(
      GetApplicationsSummaryUseCaseParams(month: month, statuses: statuses),
    );

    result.fold(
      (failure) => state = state.copyWith(
        summaryStatus: ApplicationLoadStatus.error,
        summaryErrorMessage: failure.message,
      ),
      (data) => state = state.copyWith(
        summaryStatus: ApplicationLoadStatus.loaded,
        summaryData: data,
        summaryErrorMessage: null,
      ),
    );
  }

  Future<void> loadApplicationForJob({required String jobId}) async {
    state = state.copyWith(
      applicationForJobStatus: ApplicationLoadStatus.loading,
      applicationForJobData: null,
      applicationForJobErrorMessage: null,
    );

    final result = await _getApplicationForJobUseCase(
      GetApplicationForJobUseCaseParams(jobId: jobId),
    );

    result.fold(
      (failure) => state = state.copyWith(
        applicationForJobStatus: ApplicationLoadStatus.error,
        applicationForJobErrorMessage: failure.message,
      ),
      (data) => state = state.copyWith(
        applicationForJobStatus: ApplicationLoadStatus.loaded,
        applicationForJobData: data,
        applicationForJobErrorMessage: null,
      ),
    );
  }

  Future<Failure?> applyToJob(
    String jobId, {
    String? resumeId,
    String? coverLetter,
    List<String>? portfolioLinks,
  }) async {
    state = state.copyWith(applyStatus: ApplicationLoadStatus.loading);

    final result = await _applyToJobUseCase(
      ApplyToJobUseCaseParams(
        jobId: jobId,
        resumeId: resumeId,
        coverLetter: coverLetter,
        portfolioLinks: portfolioLinks,
      ),
    );

    return result.fold(
      (failure) {
        state = state.copyWith(applyStatus: ApplicationLoadStatus.error);
        return failure;
      },
      (_) {
        state = state.copyWith(applyStatus: ApplicationLoadStatus.loaded);
        return null;
      },
    );
  }

  Future<void> loadJobApplications({
    required String jobId,
    int page = 1,
    int size = 50,
    String? status,
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh &&
        state.jobApplicationsStatus == ApplicationLoadStatus.loaded &&
        state.jobApplicationsData != null) {
      return;
    }

    state = state.copyWith(
      jobApplicationsStatus: ApplicationLoadStatus.loading,
      jobApplicationsErrorMessage: null,
    );

    final result = await _getJobApplicationsUseCase(
      GetJobApplicationsUseCaseParams(
        jobId: jobId,
        page: page,
        size: size,
        status: status,
      ),
    );

    result.fold(
      (failure) => state = state.copyWith(
        jobApplicationsStatus: ApplicationLoadStatus.error,
        jobApplicationsErrorMessage: failure.message,
      ),
      (data) => state = state.copyWith(
        jobApplicationsStatus: ApplicationLoadStatus.loaded,
        jobApplicationsData: data,
        jobApplicationsErrorMessage: null,
      ),
    );
  }

  Future<Failure?> updateApplication({
    required String jobId,
    required String applicationId,
    required String status,
    Map<String, dynamic>? interviewMetadata,
  }) async {
    state = state.copyWith(
      updateApplicationStatus: ApplicationLoadStatus.loading,
    );

    final result = await _updateApplicationUseCase(
      UpdateApplicationUseCaseParams(
        jobId: jobId,
        applicationId: applicationId,
        status: status,
        interviewMetadata: interviewMetadata,
      ),
    );

    return result.fold(
      (failure) {
        state = state.copyWith(
          updateApplicationStatus: ApplicationLoadStatus.error,
        );
        return failure;
      },
      (_) {
        state = state.copyWith(
          updateApplicationStatus: ApplicationLoadStatus.loaded,
        );
        return null;
      },
    );
  }

  Future<void> loadMyResumes({
    int page = 1,
    int size = 50,
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh &&
        state.resumesStatus == ApplicationLoadStatus.loaded &&
        state.resumesData != null) {
      return;
    }

    state = state.copyWith(
      resumesStatus: ApplicationLoadStatus.loading,
      resumesErrorMessage: null,
    );

    final result = await _listMyResumesUseCase(
      ListMyResumesUseCaseParams(page: page, size: size),
    );

    result.fold(
      (failure) => state = state.copyWith(
        resumesStatus: ApplicationLoadStatus.error,
        resumesErrorMessage: failure.message,
      ),
      (data) => state = state.copyWith(
        resumesStatus: ApplicationLoadStatus.loaded,
        resumesData: data,
        resumesErrorMessage: null,
      ),
    );
  }

  Future<(ResumeEntity?, Failure?)> uploadResume({
    required String filePath,
  }) async {
    state = state.copyWith(uploadResumeStatus: ApplicationLoadStatus.loading);

    final result = await _uploadResumeUseCase(
      UploadResumeUseCaseParams(filePath: filePath),
    );

    return result.fold(
      (failure) {
        state = state.copyWith(uploadResumeStatus: ApplicationLoadStatus.error);
        return (null, failure);
      },
      (resume) {
        final current = state.resumesData ?? <ResumeEntity>[];
        state = state.copyWith(
          uploadResumeStatus: ApplicationLoadStatus.loaded,
          resumesData: [...current, resume],
        );
        return (resume, null);
      },
    );
  }

  Future<Failure?> deleteResume({required String resumeId}) async {
    state = state.copyWith(deleteResumeStatus: ApplicationLoadStatus.loading);

    final result = await _deleteResumeUseCase(
      DeleteResumeUseCaseParams(resumeId: resumeId),
    );

    return result.fold(
      (failure) {
        state = state.copyWith(deleteResumeStatus: ApplicationLoadStatus.error);
        return failure;
      },
      (_) {
        final current = state.resumesData ?? <ResumeEntity>[];
        final updated = current.where((r) => r.id != resumeId).toList();
        state = state.copyWith(
          deleteResumeStatus: ApplicationLoadStatus.loaded,
          resumesData: updated,
        );
        return null;
      },
    );
  }

  Future<Failure?> updateResumeActivity({
    required String jobId,
    required String applicationId,
    required String action,
  }) async {
    state = state.copyWith(resumeActivityStatus: ApplicationLoadStatus.loading);

    final result = await _updateResumeActivityUseCase(
      UpdateResumeActivityUseCaseParams(
        jobId: jobId,
        applicationId: applicationId,
        action: action,
      ),
    );

    return result.fold(
      (failure) {
        state = state.copyWith(
          resumeActivityStatus: ApplicationLoadStatus.error,
        );
        return failure;
      },
      (_) {
        state = state.copyWith(
          resumeActivityStatus: ApplicationLoadStatus.loaded,
        );
        return null;
      },
    );
  }
}
