// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'job_api_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

JobApiModel _$JobApiModelFromJson(Map<String, dynamic> json) => JobApiModel(
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

Map<String, dynamic> _$JobApiModelToJson(JobApiModel instance) =>
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

JobDetailApiModel _$JobDetailApiModelFromJson(Map<String, dynamic> json) =>
    JobDetailApiModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      companyName: json['companyName'] as String,
      companyLogo: json['companyLogo'] as String?,
      companyId: json['companyId'] as String?,
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
      level: json['level'] as String,
      experience: json['experience'] as String,
      requirements: (json['requirements'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      company: json['company'] == null
          ? null
          : CompanyDetailApiModel.fromJson(
              json['company'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$JobDetailApiModelToJson(JobDetailApiModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'companyName': instance.companyName,
      'companyLogo': instance.companyLogo,
      'companyId': instance.companyId,
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
      'level': instance.level,
      'experience': instance.experience,
      'requirements': instance.requirements,
      'company': instance.company,
    };

CompanyDetailApiModel _$CompanyDetailApiModelFromJson(
        Map<String, dynamic> json) =>
    CompanyDetailApiModel(
      id: json['id'] as String,
      name: json['name'] as String,
      logo: json['logo'] as String?,
      location: json['location'] as String?,
      description: json['description'] as String?,
      industry: json['industry'] as String?,
      teamSize: json['teamSize'] as String?,
    );

Map<String, dynamic> _$CompanyDetailApiModelToJson(
        CompanyDetailApiModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'logo': instance.logo,
      'location': instance.location,
      'description': instance.description,
      'industry': instance.industry,
      'teamSize': instance.teamSize,
    };

JobsSectionApiModel _$JobsSectionApiModelFromJson(Map<String, dynamic> json) =>
    JobsSectionApiModel(
      searchQuery: json['searchQuery'] as String,
      locationQuery: json['locationQuery'] as String,
      jobs: JobsBucketApiModel.fromJson(json['jobs'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$JobsSectionApiModelToJson(
        JobsSectionApiModel instance) =>
    <String, dynamic>{
      'searchQuery': instance.searchQuery,
      'locationQuery': instance.locationQuery,
      'jobs': instance.jobs,
    };

JobsBucketApiModel _$JobsBucketApiModelFromJson(Map<String, dynamic> json) =>
    JobsBucketApiModel(
      forYou: (json['forYou'] as List<dynamic>)
          .map((e) => JobApiModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      trending: (json['trending'] as List<dynamic>)
          .map((e) => JobApiModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      newThisWeek: (json['newThisWeek'] as List<dynamic>)
          .map((e) => JobApiModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      remote: (json['remote'] as List<dynamic>)
          .map((e) => JobApiModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      urgent: (json['urgent'] as List<dynamic>)
          .map((e) => JobApiModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$JobsBucketApiModelToJson(JobsBucketApiModel instance) =>
    <String, dynamic>{
      'forYou': instance.forYou,
      'trending': instance.trending,
      'newThisWeek': instance.newThisWeek,
      'remote': instance.remote,
      'urgent': instance.urgent,
    };
