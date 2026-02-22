import 'package:equatable/equatable.dart';

class JobApplicantEntity extends Equatable {
  final String id;
  final String status;
  final String appliedAt;
  final String updatedAt;
  final String? coverLetter;
  final String? candidateId;
  final String candidateName;
  final String? candidateEmail;
  final String? candidatePhoto;
  final bool candidateOpenToWork;
  final String? resumeId;
  final String? resumeFileName;
  final String? resumeUrl;
  final int resumeViewCount;
  final int resumeDownloadCount;
  final String? interviewDate;
  final String? interviewNote;

  const JobApplicantEntity({
    required this.id,
    required this.status,
    required this.appliedAt,
    required this.updatedAt,
    this.coverLetter,
    this.candidateId,
    required this.candidateName,
    this.candidateEmail,
    this.candidatePhoto,
    this.candidateOpenToWork = false,
    this.resumeId,
    this.resumeFileName,
    this.resumeUrl,
    this.resumeViewCount = 0,
    this.resumeDownloadCount = 0,
    this.interviewDate,
    this.interviewNote,
  });

  @override
  List<Object?> get props => [id, status, candidateId];
}

class JobApplicantsListEntity extends Equatable {
  final List<JobApplicantEntity> applicants;
  final String jobId;

  const JobApplicantsListEntity({
    required this.applicants,
    required this.jobId,
  });

  @override
  List<Object?> get props => [applicants, jobId];
}
