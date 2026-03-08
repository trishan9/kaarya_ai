import 'package:json_annotation/json_annotation.dart';
import 'package:kaarya/core/utils/json_parse_helpers.dart';
import 'package:kaarya/features/bookmarks/domain/entities/bookmark_entity.dart';
import 'package:kaarya/features/interviews/domain/entities/interview_entity.dart';
import 'package:kaarya/features/jobs/domain/entities/job_entity.dart';

part 'bookmarks_api_model.g.dart';

@JsonSerializable()
class JobBookmarkApiModel {
  final String id;
  final String title;
  final String companyName;
  final String? companyLogo;
  final String location;
  final String employmentType;
  final String engagementType;
  final String workMode;
  final String salaryRange;
  final String status;
  final String deadline;
  final String createdAt;
  final int applicationsCount;
  final int viewsCount;
  final bool isSaved;
  final bool hasApplied;
  final String? myApplicationId;

  const JobBookmarkApiModel({
    required this.id,
    required this.title,
    required this.companyName,
    required this.companyLogo,
    required this.location,
    required this.employmentType,
    required this.engagementType,
    required this.workMode,
    required this.salaryRange,
    required this.status,
    required this.deadline,
    required this.createdAt,
    required this.applicationsCount,
    required this.viewsCount,
    required this.isSaved,
    required this.hasApplied,
    required this.myApplicationId,
  });

  factory JobBookmarkApiModel.fromJson(Map<String, dynamic> json) =>
      _$JobBookmarkApiModelFromJson(json);

  factory JobBookmarkApiModel.fromApiResponse(Map<String, dynamic> json) {
    final jobData = jsonAsMap(json['job']) ?? json;
    final companyData =
        jsonAsMap(jobData['company']) ?? jsonAsMap(jobData['college']);

    return JobBookmarkApiModel(
      id: jsonString(jobData['id']),
      title: jsonString(jobData['title'], fallback: 'Untitled Job'),
      companyName: jsonString(companyData?['name'], fallback: 'Company'),
      companyLogo: jsonNullableString(companyData?['logo']),
      location: jsonString(jobData['location'], fallback: 'Remote'),
      employmentType: jsonString(
        jobData['employmentType'],
        fallback: 'Full-Time',
      ),
      engagementType: jsonString(
        jobData['engagementType'],
        fallback: 'Internship',
      ),
      workMode: jsonString(jobData['workMode'], fallback: 'onsite'),
      salaryRange: jsonString(
        jobData['salaryRange'],
        fallback: 'Compensation not specified',
      ),
      status: jsonString(jobData['status'], fallback: 'open'),
      deadline: jsonString(jobData['deadline']),
      createdAt: jsonString(jobData['createdAt']),
      applicationsCount: jsonInt(jobData['applicationsCount']),
      viewsCount: jsonInt(jobData['viewsCount']),
      isSaved: jsonBool(jobData['isSaved'], fallback: true),
      hasApplied: jsonBool(jobData['hasApplied']),
      myApplicationId: jsonNullableString(jobData['myApplicationId']),
    );
  }

  Map<String, dynamic> toJson() => _$JobBookmarkApiModelToJson(this);

  JobEntity toEntity() {
    return JobEntity(
      id: id,
      title: title,
      companyName: companyName,
      companyLogo: companyLogo,
      location: location,
      employmentType: employmentType,
      engagementType: engagementType,
      workMode: workMode,
      salaryRange: salaryRange,
      status: status,
      deadline: deadline,
      createdAt: createdAt,
      applicationsCount: applicationsCount,
      viewsCount: viewsCount,
      isSaved: isSaved,
      hasApplied: hasApplied,
      myApplicationId: myApplicationId,
    );
  }

  static List<JobBookmarkApiModel> fromApiList(dynamic items) {
    if (items is! List) return const <JobBookmarkApiModel>[];
    return items
        .whereType<Map>()
        .map((item) => JobBookmarkApiModel.fromApiResponse(jsonCastMap(item)))
        .toList();
  }

  static List<JobBookmarkApiModel> fromCacheList(dynamic items) {
    if (items is! List) return const <JobBookmarkApiModel>[];
    return items
        .whereType<Map>()
        .map((item) => JobBookmarkApiModel.fromJson(jsonCastMap(item)))
        .toList();
  }
}

@JsonSerializable()
class InterviewBookmarkApiModel {
  final String id;
  final String title;
  final String role;
  final String interviewType;
  final String status;
  final String source;
  final String companyName;
  final String? companyLogo;
  final int attemptsCount;
  final double? myLatestScore;
  final String? myLatestSessionId;
  final bool hasAttempted;
  final bool isSaved;
  final List<String> techStack;
  final String createdAt;
  final String updatedAt;

  const InterviewBookmarkApiModel({
    required this.id,
    required this.title,
    required this.role,
    required this.interviewType,
    required this.status,
    required this.source,
    required this.companyName,
    required this.companyLogo,
    required this.attemptsCount,
    required this.myLatestScore,
    required this.myLatestSessionId,
    required this.hasAttempted,
    required this.isSaved,
    required this.techStack,
    required this.createdAt,
    required this.updatedAt,
  });

  factory InterviewBookmarkApiModel.fromJson(Map<String, dynamic> json) =>
      _$InterviewBookmarkApiModelFromJson(json);

  factory InterviewBookmarkApiModel.fromApiResponse(Map<String, dynamic> json) {
    final interviewData = jsonAsMap(json['interview']) ?? json;
    final company = jsonAsMap(interviewData['company']);
    final college = jsonAsMap(interviewData['college']);

    return InterviewBookmarkApiModel(
      id: jsonString(interviewData['id']),
      title: jsonString(interviewData['title'], fallback: 'Untitled Interview'),
      role: jsonString(interviewData['role']),
      interviewType: jsonString(
        interviewData['interviewType'],
        fallback: 'mixed',
      ),
      status: jsonString(interviewData['status'], fallback: 'draft'),
      source: jsonString(interviewData['source'], fallback: 'candidate'),
      companyName:
          jsonNullableString(company?['name']) ??
          jsonNullableString(college?['name']) ??
          'Kaarya',
      companyLogo:
          jsonNullableString(company?['logo']) ??
          jsonNullableString(college?['logo']),
      attemptsCount: jsonInt(interviewData['attemptsCount']),
      myLatestScore: jsonDoubleOrNull(interviewData['myLatestScore']),
      myLatestSessionId: jsonNullableString(interviewData['myLatestSessionId']),
      hasAttempted: jsonBool(interviewData['hasAttempted']),
      isSaved: jsonBool(interviewData['isSaved'], fallback: true),
      techStack: jsonStringList(interviewData['techStack']),
      createdAt: jsonString(interviewData['createdAt']),
      updatedAt: jsonString(interviewData['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() => _$InterviewBookmarkApiModelToJson(this);

  InterviewEntity toEntity() {
    return InterviewEntity(
      id: id,
      title: title,
      role: role,
      interviewType: interviewType,
      status: status,
      source: source,
      companyName: companyName,
      companyLogo: companyLogo,
      attemptsCount: attemptsCount,
      myLatestScore: myLatestScore,
      myLatestSessionId: myLatestSessionId,
      hasAttempted: hasAttempted,
      isSaved: isSaved,
      techStack: techStack,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  static List<InterviewBookmarkApiModel> fromApiList(dynamic items) {
    if (items is! List) return const <InterviewBookmarkApiModel>[];
    return items
        .whereType<Map>()
        .map(
          (item) =>
              InterviewBookmarkApiModel.fromApiResponse(jsonCastMap(item)),
        )
        .toList();
  }

  static List<InterviewBookmarkApiModel> fromCacheList(dynamic items) {
    if (items is! List) return const <InterviewBookmarkApiModel>[];
    return items
        .whereType<Map>()
        .map((item) => InterviewBookmarkApiModel.fromJson(jsonCastMap(item)))
        .toList();
  }
}

@JsonSerializable()
class BookmarksApiModel {
  final List<JobBookmarkApiModel> jobs;
  final List<InterviewBookmarkApiModel> interviews;

  const BookmarksApiModel({required this.jobs, required this.interviews});

  factory BookmarksApiModel.fromJson(Map<String, dynamic> json) =>
      _$BookmarksApiModelFromJson(json);

  factory BookmarksApiModel.fromApiResponse(Map<String, dynamic> data) {
    return BookmarksApiModel(
      jobs: JobBookmarkApiModel.fromApiList(data['jobs']),
      interviews: InterviewBookmarkApiModel.fromApiList(data['interviews']),
    );
  }

  Map<String, dynamic> toJson() => _$BookmarksApiModelToJson(this);

  BookmarksListEntity toEntity() {
    final jobEntities = jobs.map((j) => j.toEntity()).toList();
    final interviewEntities = interviews.map((i) => i.toEntity()).toList();
    return BookmarksListEntity(
      jobs: jobEntities,
      interviews: interviewEntities,
      totalSaved: jobEntities.length + interviewEntities.length,
      bookmarkedJobs: jobEntities.length,
      savedInterviews: interviewEntities.length,
    );
  }
}
