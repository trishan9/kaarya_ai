import 'package:equatable/equatable.dart';
import 'package:kaarya/features/applications/domain/entities/application_entity.dart';
import 'package:kaarya/features/applications/domain/entities/application_summary_entity.dart';
import 'package:kaarya/features/applications/domain/entities/resume_entity.dart';

enum ApplicationLoadStatus { initial, loading, loaded, error }

class ApplicationState extends Equatable {
  static const Object _unset = Object();

  final ApplicationLoadStatus applicationsStatus;
  final ApplicationsListEntity? applicationsData;
  final String? applicationsErrorMessage;

  final ApplicationLoadStatus summaryStatus;
  final ApplicationSummaryEntity? summaryData;
  final String? summaryErrorMessage;

  final ApplicationLoadStatus applicationForJobStatus;
  final ApplicationEntity? applicationForJobData;
  final String? applicationForJobErrorMessage;

  final ApplicationLoadStatus jobApplicationsStatus;
  final ApplicationsListEntity? jobApplicationsData;
  final String? jobApplicationsErrorMessage;

  final ApplicationLoadStatus resumesStatus;
  final List<ResumeEntity>? resumesData;
  final String? resumesErrorMessage;

  final ApplicationLoadStatus applyStatus;
  final ApplicationLoadStatus updateApplicationStatus;
  final ApplicationLoadStatus uploadResumeStatus;
  final ApplicationLoadStatus deleteResumeStatus;
  final ApplicationLoadStatus resumeActivityStatus;

  const ApplicationState({
    this.applicationsStatus = ApplicationLoadStatus.initial,
    this.applicationsData,
    this.applicationsErrorMessage,
    this.summaryStatus = ApplicationLoadStatus.initial,
    this.summaryData,
    this.summaryErrorMessage,
    this.applicationForJobStatus = ApplicationLoadStatus.initial,
    this.applicationForJobData,
    this.applicationForJobErrorMessage,
    this.jobApplicationsStatus = ApplicationLoadStatus.initial,
    this.jobApplicationsData,
    this.jobApplicationsErrorMessage,
    this.resumesStatus = ApplicationLoadStatus.initial,
    this.resumesData,
    this.resumesErrorMessage,
    this.applyStatus = ApplicationLoadStatus.initial,
    this.updateApplicationStatus = ApplicationLoadStatus.initial,
    this.uploadResumeStatus = ApplicationLoadStatus.initial,
    this.deleteResumeStatus = ApplicationLoadStatus.initial,
    this.resumeActivityStatus = ApplicationLoadStatus.initial,
  });

  ApplicationState copyWith({
    ApplicationLoadStatus? applicationsStatus,
    Object? applicationsData = _unset,
    Object? applicationsErrorMessage = _unset,
    ApplicationLoadStatus? summaryStatus,
    Object? summaryData = _unset,
    Object? summaryErrorMessage = _unset,
    ApplicationLoadStatus? applicationForJobStatus,
    Object? applicationForJobData = _unset,
    Object? applicationForJobErrorMessage = _unset,
    ApplicationLoadStatus? jobApplicationsStatus,
    Object? jobApplicationsData = _unset,
    Object? jobApplicationsErrorMessage = _unset,
    ApplicationLoadStatus? resumesStatus,
    Object? resumesData = _unset,
    Object? resumesErrorMessage = _unset,
    ApplicationLoadStatus? applyStatus,
    ApplicationLoadStatus? updateApplicationStatus,
    ApplicationLoadStatus? uploadResumeStatus,
    ApplicationLoadStatus? deleteResumeStatus,
    ApplicationLoadStatus? resumeActivityStatus,
  }) {
    return ApplicationState(
      applicationsStatus: applicationsStatus ?? this.applicationsStatus,
      applicationsData: applicationsData == _unset
          ? this.applicationsData
          : applicationsData as ApplicationsListEntity?,
      applicationsErrorMessage: applicationsErrorMessage == _unset
          ? this.applicationsErrorMessage
          : applicationsErrorMessage as String?,
      summaryStatus: summaryStatus ?? this.summaryStatus,
      summaryData: summaryData == _unset
          ? this.summaryData
          : summaryData as ApplicationSummaryEntity?,
      summaryErrorMessage: summaryErrorMessage == _unset
          ? this.summaryErrorMessage
          : summaryErrorMessage as String?,
      applicationForJobStatus:
          applicationForJobStatus ?? this.applicationForJobStatus,
      applicationForJobData: applicationForJobData == _unset
          ? this.applicationForJobData
          : applicationForJobData as ApplicationEntity?,
      applicationForJobErrorMessage: applicationForJobErrorMessage == _unset
          ? this.applicationForJobErrorMessage
          : applicationForJobErrorMessage as String?,
      jobApplicationsStatus:
          jobApplicationsStatus ?? this.jobApplicationsStatus,
      jobApplicationsData: jobApplicationsData == _unset
          ? this.jobApplicationsData
          : jobApplicationsData as ApplicationsListEntity?,
      jobApplicationsErrorMessage: jobApplicationsErrorMessage == _unset
          ? this.jobApplicationsErrorMessage
          : jobApplicationsErrorMessage as String?,
      resumesStatus: resumesStatus ?? this.resumesStatus,
      resumesData: resumesData == _unset
          ? this.resumesData
          : resumesData as List<ResumeEntity>?,
      resumesErrorMessage: resumesErrorMessage == _unset
          ? this.resumesErrorMessage
          : resumesErrorMessage as String?,
      applyStatus: applyStatus ?? this.applyStatus,
      updateApplicationStatus:
          updateApplicationStatus ?? this.updateApplicationStatus,
      uploadResumeStatus: uploadResumeStatus ?? this.uploadResumeStatus,
      deleteResumeStatus: deleteResumeStatus ?? this.deleteResumeStatus,
      resumeActivityStatus: resumeActivityStatus ?? this.resumeActivityStatus,
    );
  }

  @override
  List<Object?> get props => [
    applicationsStatus,
    applicationsData,
    applicationsErrorMessage,
    summaryStatus,
    summaryData,
    summaryErrorMessage,
    applicationForJobStatus,
    applicationForJobData,
    applicationForJobErrorMessage,
    jobApplicationsStatus,
    jobApplicationsData,
    jobApplicationsErrorMessage,
    resumesStatus,
    resumesData,
    resumesErrorMessage,
    applyStatus,
    updateApplicationStatus,
    uploadResumeStatus,
    deleteResumeStatus,
    resumeActivityStatus,
  ];
}
