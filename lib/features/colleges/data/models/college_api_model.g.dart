// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'college_api_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CollegeApiModel _$CollegeApiModelFromJson(Map<String, dynamic> json) =>
    CollegeApiModel(
      id: json['id'] as String,
      name: json['name'] as String,
      institutionType: json['institutionType'] as String,
      location: json['location'] as String,
      logo: json['logo'] as String?,
      inviteCode: json['inviteCode'] as String?,
      studentsCount: (json['studentsCount'] as num).toInt(),
      createdAt: json['createdAt'] as String,
    );

Map<String, dynamic> _$CollegeApiModelToJson(CollegeApiModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'institutionType': instance.institutionType,
      'location': instance.location,
      'logo': instance.logo,
      'inviteCode': instance.inviteCode,
      'studentsCount': instance.studentsCount,
      'createdAt': instance.createdAt,
    };

CollegeWorkspaceApiModel _$CollegeWorkspaceApiModelFromJson(
  Map<String, dynamic> json,
) => CollegeWorkspaceApiModel(
  collegeId: json['collegeId'] as String,
  collegeName: json['collegeName'] as String,
  collegeLogo: json['collegeLogo'] as String?,
  joinedAt: json['joinedAt'] as String,
);

Map<String, dynamic> _$CollegeWorkspaceApiModelToJson(
  CollegeWorkspaceApiModel instance,
) => <String, dynamic>{
  'collegeId': instance.collegeId,
  'collegeName': instance.collegeName,
  'collegeLogo': instance.collegeLogo,
  'joinedAt': instance.joinedAt,
};

StudentMemberApiModel _$StudentMemberApiModelFromJson(
  Map<String, dynamic> json,
) => StudentMemberApiModel(
  userId: json['userId'] as String,
  name: json['name'] as String,
  email: json['email'] as String,
  photo: json['photo'] as String?,
  program: json['program'] as String?,
  year: (json['year'] as num?)?.toInt(),
  joinedAt: json['joinedAt'] as String,
);

Map<String, dynamic> _$StudentMemberApiModelToJson(
  StudentMemberApiModel instance,
) => <String, dynamic>{
  'userId': instance.userId,
  'name': instance.name,
  'email': instance.email,
  'photo': instance.photo,
  'program': instance.program,
  'year': instance.year,
  'joinedAt': instance.joinedAt,
};

CollegeMetricsApiModel _$CollegeMetricsApiModelFromJson(
  Map<String, dynamic> json,
) => CollegeMetricsApiModel(
  totalStudents: (json['totalStudents'] as num).toInt(),
  totalJobs: (json['totalJobs'] as num).toInt(),
  totalInterviews: (json['totalInterviews'] as num).toInt(),
  totalApplications: (json['totalApplications'] as num).toInt(),
  averageInterviewScore: (json['averageInterviewScore'] as num).toDouble(),
  averageAtsScore: (json['averageAtsScore'] as num).toDouble(),
  topStudents: (json['topStudents'] as List<dynamic>)
      .map((e) => StudentMemberApiModel.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$CollegeMetricsApiModelToJson(
  CollegeMetricsApiModel instance,
) => <String, dynamic>{
  'totalStudents': instance.totalStudents,
  'totalJobs': instance.totalJobs,
  'totalInterviews': instance.totalInterviews,
  'totalApplications': instance.totalApplications,
  'averageInterviewScore': instance.averageInterviewScore,
  'averageAtsScore': instance.averageAtsScore,
  'topStudents': instance.topStudents,
};
