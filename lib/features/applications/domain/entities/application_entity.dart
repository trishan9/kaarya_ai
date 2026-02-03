import 'package:equatable/equatable.dart';

class ApplicationEntity extends Equatable {
  final String id;
  final String jobId;
  final String jobTitle;
  final String companyName;
  final String? companyLogo;
  final String status;
  final String appliedAt;
  final String updatedAt;
  final String? nextStep;
  final String location;
  final String employmentType;
  final String workMode;
  final String salaryRange;

  const ApplicationEntity({
    required this.id,
    required this.jobId,
    required this.jobTitle,
    required this.companyName,
    this.companyLogo,
    required this.status,
    required this.appliedAt,
    required this.updatedAt,
    this.nextStep,
    required this.location,
    required this.employmentType,
    required this.workMode,
    required this.salaryRange,
  });

  @override
  List<Object?> get props => [id, jobId, status];
}

class ApplicationsListEntity extends Equatable {
  final List<ApplicationEntity> applications;
  final int totalSubmissions;
  final int inProgressCount;
  final int interviewCount;
  final int acceptedCount;

  const ApplicationsListEntity({
    required this.applications,
    required this.totalSubmissions,
    required this.inProgressCount,
    required this.interviewCount,
    required this.acceptedCount,
  });

  @override
  List<Object?> get props => [applications, totalSubmissions];
}
