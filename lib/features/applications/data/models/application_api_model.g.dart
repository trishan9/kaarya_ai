// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'application_api_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApplicationApiModel _$ApplicationApiModelFromJson(Map<String, dynamic> json) =>
    ApplicationApiModel(
      id: json['id'] as String,
      jobId: json['jobId'] as String,
      jobTitle: json['jobTitle'] as String,
      companyName: json['companyName'] as String,
      companyLogo: json['companyLogo'] as String?,
      status: json['status'] as String,
      appliedAt: json['appliedAt'] as String,
      updatedAt: json['updatedAt'] as String,
      nextStep: json['nextStep'] as String?,
      location: json['location'] as String,
      employmentType: json['employmentType'] as String,
      workMode: json['workMode'] as String,
      salaryRange: json['salaryRange'] as String,
    );

Map<String, dynamic> _$ApplicationApiModelToJson(
        ApplicationApiModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'jobId': instance.jobId,
      'jobTitle': instance.jobTitle,
      'companyName': instance.companyName,
      'companyLogo': instance.companyLogo,
      'status': instance.status,
      'appliedAt': instance.appliedAt,
      'updatedAt': instance.updatedAt,
      'nextStep': instance.nextStep,
      'location': instance.location,
      'employmentType': instance.employmentType,
      'workMode': instance.workMode,
      'salaryRange': instance.salaryRange,
    };

ApplicationSummaryApiModel _$ApplicationSummaryApiModelFromJson(
        Map<String, dynamic> json) =>
    ApplicationSummaryApiModel(
      total: (json['total'] as num).toInt(),
      delta: (json['delta'] as num).toInt(),
      todayCount: (json['todayCount'] as num).toInt(),
      monthKey: json['monthKey'] as String,
      monthLabel: json['monthLabel'] as String,
      appliedCount: (json['appliedCount'] as num).toInt(),
      reviewingCount: (json['reviewingCount'] as num).toInt(),
      shortlistedCount: (json['shortlistedCount'] as num).toInt(),
      interviewCount: (json['interviewCount'] as num).toInt(),
      acceptedCount: (json['acceptedCount'] as num).toInt(),
      rejectedCount: (json['rejectedCount'] as num).toInt(),
      withdrawnCount: (json['withdrawnCount'] as num).toInt(),
    );

Map<String, dynamic> _$ApplicationSummaryApiModelToJson(
        ApplicationSummaryApiModel instance) =>
    <String, dynamic>{
      'total': instance.total,
      'delta': instance.delta,
      'todayCount': instance.todayCount,
      'monthKey': instance.monthKey,
      'monthLabel': instance.monthLabel,
      'appliedCount': instance.appliedCount,
      'reviewingCount': instance.reviewingCount,
      'shortlistedCount': instance.shortlistedCount,
      'interviewCount': instance.interviewCount,
      'acceptedCount': instance.acceptedCount,
      'rejectedCount': instance.rejectedCount,
      'withdrawnCount': instance.withdrawnCount,
    };

ResumeApiModel _$ResumeApiModelFromJson(Map<String, dynamic> json) =>
    ResumeApiModel(
      id: json['id'] as String,
      fileName: json['fileName'] as String,
      url: json['url'] as String,
      uploadedAt: json['uploadedAt'] as String,
      atsScore: (json['atsScore'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$ResumeApiModelToJson(ResumeApiModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'fileName': instance.fileName,
      'url': instance.url,
      'uploadedAt': instance.uploadedAt,
      'atsScore': instance.atsScore,
    };
