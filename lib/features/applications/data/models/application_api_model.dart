import 'package:json_annotation/json_annotation.dart';
import 'package:kaarya/core/utils/json_parse_helpers.dart';
import 'package:kaarya/features/applications/domain/entities/application_entity.dart';
import 'package:kaarya/features/applications/domain/entities/application_summary_entity.dart';
import 'package:kaarya/features/applications/domain/entities/job_applicant_entity.dart';
import 'package:kaarya/features/applications/domain/entities/resume_entity.dart';

part 'application_api_model.g.dart';

@JsonSerializable()
class ApplicationApiModel {
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

  const ApplicationApiModel({
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

  factory ApplicationApiModel.fromApiResponse(Map<String, dynamic> json) {
    final job = jsonAsMap(json['job']) ?? const <String, dynamic>{};
    final companyData = jsonAsMap(job['company']) ?? jsonAsMap(job['college']);

    return ApplicationApiModel(
      id: jsonString(json['id'] ?? json['_id']),
      jobId: jsonString(json['jobId'] ?? job['id'] ?? job['_id']),
      jobTitle: jsonString(job['title'], fallback: 'Untitled Job'),
      companyName: jsonString(companyData?['name'], fallback: 'Company'),
      companyLogo: jsonNullableString(companyData?['logo']),
      status: jsonString(json['status'], fallback: 'applied'),
      appliedAt: jsonString(json['appliedAt'] ?? json['createdAt']),
      updatedAt: jsonString(json['updatedAt'] ?? json['createdAt']),
      nextStep: jsonNullableString(json['nextStep']),
      location: jsonString(job['location'], fallback: 'Remote'),
      employmentType: jsonString(job['employmentType'], fallback: 'Full-Time'),
      workMode: jsonString(job['workMode'], fallback: 'onsite'),
      salaryRange: jsonString(job['salaryRange'], fallback: 'Not specified'),
    );
  }

  factory ApplicationApiModel.fromJson(Map<String, dynamic> json) =>
      _$ApplicationApiModelFromJson(json);

  Map<String, dynamic> toJson() => _$ApplicationApiModelToJson(this);

  ApplicationEntity toEntity() => ApplicationEntity(
    id: id,
    jobId: jobId,
    jobTitle: jobTitle,
    companyName: companyName,
    companyLogo: companyLogo,
    status: status,
    appliedAt: appliedAt,
    updatedAt: updatedAt,
    nextStep: nextStep,
    location: location,
    employmentType: employmentType,
    workMode: workMode,
    salaryRange: salaryRange,
  );

  static List<ApplicationApiModel> fromApiList(dynamic items) {
    if (items is! List) return const <ApplicationApiModel>[];
    return items
        .whereType<Map>()
        .map((e) => ApplicationApiModel.fromApiResponse(jsonCastMap(e)))
        .toList();
  }
}

@JsonSerializable()
class ApplicationSummaryApiModel {
  final int total;
  final int delta;
  final int todayCount;
  final String monthKey;
  final String monthLabel;
  final int appliedCount;
  final int reviewingCount;
  final int shortlistedCount;
  final int interviewCount;
  final int acceptedCount;
  final int rejectedCount;
  final int withdrawnCount;

  const ApplicationSummaryApiModel({
    required this.total,
    required this.delta,
    required this.todayCount,
    required this.monthKey,
    required this.monthLabel,
    required this.appliedCount,
    required this.reviewingCount,
    required this.shortlistedCount,
    required this.interviewCount,
    required this.acceptedCount,
    required this.rejectedCount,
    required this.withdrawnCount,
  });

  factory ApplicationSummaryApiModel.fromApiResponse(
    Map<String, dynamic> json,
  ) {
    final statusBreakdown =
        jsonAsMap(json['statusBreakdown']) ?? const <String, dynamic>{};

    return ApplicationSummaryApiModel(
      total: jsonInt(json['total']),
      delta: jsonInt(json['delta']),
      todayCount: jsonInt(json['todayCount']),
      monthKey: jsonString(json['monthKey']),
      monthLabel: jsonString(json['monthLabel']),
      appliedCount: jsonInt(statusBreakdown['applied']),
      reviewingCount: jsonInt(statusBreakdown['reviewing']),
      shortlistedCount: jsonInt(statusBreakdown['shortlisted']),
      interviewCount: jsonInt(statusBreakdown['interview']),
      acceptedCount: jsonInt(statusBreakdown['accepted']),
      rejectedCount: jsonInt(statusBreakdown['rejected']),
      withdrawnCount: jsonInt(statusBreakdown['withdrawn']),
    );
  }

  factory ApplicationSummaryApiModel.fromJson(Map<String, dynamic> json) =>
      _$ApplicationSummaryApiModelFromJson(json);

  Map<String, dynamic> toJson() => _$ApplicationSummaryApiModelToJson(this);

  ApplicationSummaryEntity toEntity() => ApplicationSummaryEntity(
    total: total,
    delta: delta,
    todayCount: todayCount,
    monthKey: monthKey,
    monthLabel: monthLabel,
    appliedCount: appliedCount,
    reviewingCount: reviewingCount,
    shortlistedCount: shortlistedCount,
    interviewCount: interviewCount,
    acceptedCount: acceptedCount,
    rejectedCount: rejectedCount,
    withdrawnCount: withdrawnCount,
  );
}

@JsonSerializable()
class ResumeApiModel {
  final String id;
  final String fileName;
  final String url;
  final String uploadedAt;
  final double? atsScore;

  const ResumeApiModel({
    required this.id,
    required this.fileName,
    required this.url,
    required this.uploadedAt,
    this.atsScore,
  });

  factory ResumeApiModel.fromApiResponse(Map<String, dynamic> json) {
    return ResumeApiModel(
      id: jsonString(json['id'] ?? json['_id']),
      fileName: jsonString(
        json['fileName'] ?? json['originalName'],
        fallback: 'Resume',
      ),
      url: jsonString(json['url'] ?? json['fileUrl']),
      uploadedAt: jsonString(json['createdAt'] ?? json['uploadedAt']),
      atsScore: jsonDoubleOrNull(json['atsScore']),
    );
  }

  factory ResumeApiModel.fromJson(Map<String, dynamic> json) =>
      _$ResumeApiModelFromJson(json);

  Map<String, dynamic> toJson() => _$ResumeApiModelToJson(this);

  ResumeEntity toEntity() => ResumeEntity(
    id: id,
    fileName: fileName,
    url: url,
    uploadedAt: uploadedAt,
    atsScore: atsScore,
  );

  static List<ResumeApiModel> fromApiList(dynamic items) {
    if (items is! List) return const <ResumeApiModel>[];
    return items
        .whereType<Map>()
        .map((e) => ResumeApiModel.fromApiResponse(jsonCastMap(e)))
        .toList();
  }
}

class JobApplicantApiModel {
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

  const JobApplicantApiModel({
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

  factory JobApplicantApiModel.fromApiResponse(Map<String, dynamic> json) {
    final candidate = jsonAsMap(json['candidate']);
    final resume = jsonAsMap(json['resume']);
    final resumeActivity = jsonAsMap(json['resumeActivity']);
    final candidateProfile = jsonAsMap(candidate?['candidateProfile']);
    final interviewMeta = jsonAsMap(json['interviewMetadata']);

    return JobApplicantApiModel(
      id: jsonString(json['id'] ?? json['_id']),
      status: jsonString(json['status'], fallback: 'applied'),
      appliedAt: jsonString(json['appliedAt'] ?? json['createdAt']),
      updatedAt: jsonString(json['updatedAt'] ?? json['createdAt']),
      coverLetter: jsonNullableString(json['coverLetter']),
      candidateId: jsonNullableString(candidate?['id'] ?? json['studentId']),
      candidateName: jsonString(candidate?['name'], fallback: 'Candidate'),
      candidateEmail: jsonNullableString(candidate?['email']),
      candidatePhoto: jsonNullableString(candidate?['photo']),
      candidateOpenToWork: jsonBool(candidateProfile?['openToWork']),
      resumeId: jsonNullableString(resume?['id'] ?? json['resumeId']),
      resumeFileName: jsonNullableString(
        resume?['fileName'] ??
            resume?['originalName'] ??
            json['resumeFileName'],
      ),
      resumeUrl: jsonNullableString(resume?['url'] ?? resume?['fileUrl']),
      resumeViewCount: jsonInt(resumeActivity?['viewCount']),
      resumeDownloadCount: jsonInt(resumeActivity?['downloadCount']),
      interviewDate: jsonNullableString(interviewMeta?['date']),
      interviewNote: jsonNullableString(
        interviewMeta?['note'] ?? interviewMeta?['meetingLink'],
      ),
    );
  }

  JobApplicantEntity toEntity() => JobApplicantEntity(
    id: id,
    status: status,
    appliedAt: appliedAt,
    updatedAt: updatedAt,
    coverLetter: coverLetter,
    candidateId: candidateId,
    candidateName: candidateName,
    candidateEmail: candidateEmail,
    candidatePhoto: candidatePhoto,
    candidateOpenToWork: candidateOpenToWork,
    resumeId: resumeId,
    resumeFileName: resumeFileName,
    resumeUrl: resumeUrl,
    resumeViewCount: resumeViewCount,
    resumeDownloadCount: resumeDownloadCount,
    interviewDate: interviewDate,
    interviewNote: interviewNote,
  );

  static List<JobApplicantApiModel> fromApiList(dynamic items) {
    if (items is! List) return const <JobApplicantApiModel>[];
    return items
        .whereType<Map>()
        .map((e) => JobApplicantApiModel.fromApiResponse(jsonCastMap(e)))
        .toList();
  }
}
