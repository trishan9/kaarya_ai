// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bookmarks_api_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

JobBookmarkApiModel _$JobBookmarkApiModelFromJson(Map<String, dynamic> json) =>
    JobBookmarkApiModel(
      id: json['id'] as String,
      title: json['title'] as String,
      companyName: json['companyName'] as String,
      companyLogo: json['companyLogo'] as String?,
      location: json['location'] as String,
      employmentType: json['employmentType'] as String,
      engagementType: json['engagementType'] as String,
      workMode: json['workMode'] as String,
      salaryRange: json['salaryRange'] as String,
      status: json['status'] as String,
      deadline: json['deadline'] as String,
      createdAt: json['createdAt'] as String,
      applicationsCount: (json['applicationsCount'] as num).toInt(),
      viewsCount: (json['viewsCount'] as num).toInt(),
      isSaved: json['isSaved'] as bool,
      hasApplied: json['hasApplied'] as bool,
      myApplicationId: json['myApplicationId'] as String?,
    );

Map<String, dynamic> _$JobBookmarkApiModelToJson(
        JobBookmarkApiModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'companyName': instance.companyName,
      'companyLogo': instance.companyLogo,
      'location': instance.location,
      'employmentType': instance.employmentType,
      'engagementType': instance.engagementType,
      'workMode': instance.workMode,
      'salaryRange': instance.salaryRange,
      'status': instance.status,
      'deadline': instance.deadline,
      'createdAt': instance.createdAt,
      'applicationsCount': instance.applicationsCount,
      'viewsCount': instance.viewsCount,
      'isSaved': instance.isSaved,
      'hasApplied': instance.hasApplied,
      'myApplicationId': instance.myApplicationId,
    };

InterviewBookmarkApiModel _$InterviewBookmarkApiModelFromJson(
        Map<String, dynamic> json) =>
    InterviewBookmarkApiModel(
      id: json['id'] as String,
      title: json['title'] as String,
      role: json['role'] as String,
      interviewType: json['interviewType'] as String,
      status: json['status'] as String,
      source: json['source'] as String,
      companyName: json['companyName'] as String,
      companyLogo: json['companyLogo'] as String?,
      attemptsCount: (json['attemptsCount'] as num).toInt(),
      myLatestScore: (json['myLatestScore'] as num?)?.toDouble(),
      myLatestSessionId: json['myLatestSessionId'] as String?,
      hasAttempted: json['hasAttempted'] as bool,
      isSaved: json['isSaved'] as bool,
      techStack:
          (json['techStack'] as List<dynamic>).map((e) => e as String).toList(),
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );

Map<String, dynamic> _$InterviewBookmarkApiModelToJson(
        InterviewBookmarkApiModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'role': instance.role,
      'interviewType': instance.interviewType,
      'status': instance.status,
      'source': instance.source,
      'companyName': instance.companyName,
      'companyLogo': instance.companyLogo,
      'attemptsCount': instance.attemptsCount,
      'myLatestScore': instance.myLatestScore,
      'myLatestSessionId': instance.myLatestSessionId,
      'hasAttempted': instance.hasAttempted,
      'isSaved': instance.isSaved,
      'techStack': instance.techStack,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
    };

BookmarksApiModel _$BookmarksApiModelFromJson(Map<String, dynamic> json) =>
    BookmarksApiModel(
      jobs: (json['jobs'] as List<dynamic>)
          .map((e) => JobBookmarkApiModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      interviews: (json['interviews'] as List<dynamic>)
          .map((e) =>
              InterviewBookmarkApiModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$BookmarksApiModelToJson(BookmarksApiModel instance) =>
    <String, dynamic>{
      'jobs': instance.jobs,
      'interviews': instance.interviews,
    };
