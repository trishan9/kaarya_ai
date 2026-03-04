// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'interview_api_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InterviewApiModel _$InterviewApiModelFromJson(Map<String, dynamic> json) =>
    InterviewApiModel(
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
      techStackIconUrls: (json['techStackIconUrls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );

Map<String, dynamic> _$InterviewApiModelToJson(InterviewApiModel instance) =>
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
      'techStackIconUrls': instance.techStackIconUrls,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
    };
