import 'package:json_annotation/json_annotation.dart';
import 'package:kaarya/core/utils/json_parse_helpers.dart';
import 'package:kaarya/features/colleges/domain/entities/college_entity.dart';
import 'package:kaarya/features/colleges/domain/entities/college_metrics_entity.dart';
import 'package:kaarya/features/colleges/domain/entities/college_workspace_entity.dart';
import 'package:kaarya/features/colleges/domain/entities/student_member_entity.dart';

part 'college_api_model.g.dart';

@JsonSerializable()
class CollegeApiModel {
  final String id;
  final String name;
  final String institutionType;
  final String location;
  final String? logo;
  final String? inviteCode;
  final int studentsCount;
  final String createdAt;

  const CollegeApiModel({
    required this.id,
    required this.name,
    required this.institutionType,
    required this.location,
    this.logo,
    this.inviteCode,
    required this.studentsCount,
    required this.createdAt,
  });

  factory CollegeApiModel.fromApiResponse(Map<String, dynamic> json) {
    return CollegeApiModel(
      id: jsonString(json['_id'] ?? json['id']),
      name: jsonString(json['name']),
      institutionType: jsonString(
        json['institutionType'] ?? json['institution_type'],
        fallback: 'Other',
      ),
      location: jsonString(json['location']),
      logo: jsonNullableString(json['logo']),
      inviteCode: jsonNullableString(json['inviteCode'] ?? json['invite_code']),
      studentsCount: jsonInt(json['studentsCount'] ?? json['students_count']),
      createdAt: jsonString(json['createdAt'] ?? json['created_at']),
    );
  }

  factory CollegeApiModel.fromJson(Map<String, dynamic> json) =>
      _$CollegeApiModelFromJson(json);

  Map<String, dynamic> toJson() => _$CollegeApiModelToJson(this);

  CollegeEntity toEntity() => CollegeEntity(
    id: id,
    name: name,
    institutionType: institutionType,
    location: location,
    logo: logo,
    inviteCode: inviteCode,
    studentsCount: studentsCount,
    createdAt: createdAt,
  );

  static List<CollegeApiModel> fromApiList(dynamic value) {
    if (value is! List) return const <CollegeApiModel>[];
    return value
        .whereType<Map>()
        .map(
          (e) => CollegeApiModel.fromApiResponse(
            e.map((key, item) => MapEntry(key.toString(), item)),
          ),
        )
        .toList();
  }
}

@JsonSerializable()
class CollegeWorkspaceApiModel {
  final String collegeId;
  final String collegeName;
  final String? collegeLogo;
  final String joinedAt;

  const CollegeWorkspaceApiModel({
    required this.collegeId,
    required this.collegeName,
    this.collegeLogo,
    required this.joinedAt,
  });

  factory CollegeWorkspaceApiModel.fromApiResponse(Map<String, dynamic> json) {
    final college = jsonAsMap(json['college']);
    if (college != null) {
      return CollegeWorkspaceApiModel(
        collegeId: jsonString(college['_id'] ?? college['id']),
        collegeName: jsonString(college['name']),
        collegeLogo: jsonNullableString(college['logo']),
        joinedAt: jsonString(json['joinedAt'] ?? json['createdAt']),
      );
    }
    return CollegeWorkspaceApiModel(
      collegeId: jsonString(json['collegeId'] ?? json['_id'] ?? json['id']),
      collegeName: jsonString(json['collegeName'] ?? json['name']),
      collegeLogo: jsonNullableString(json['collegeLogo'] ?? json['logo']),
      joinedAt: jsonString(json['joinedAt'] ?? json['createdAt']),
    );
  }

  factory CollegeWorkspaceApiModel.fromJson(Map<String, dynamic> json) =>
      _$CollegeWorkspaceApiModelFromJson(json);

  Map<String, dynamic> toJson() => _$CollegeWorkspaceApiModelToJson(this);

  CollegeWorkspaceEntity toEntity() => CollegeWorkspaceEntity(
    collegeId: collegeId,
    collegeName: collegeName,
    collegeLogo: collegeLogo,
    joinedAt: joinedAt,
  );

  static List<CollegeWorkspaceApiModel> fromApiList(dynamic value) {
    if (value is! List) return const <CollegeWorkspaceApiModel>[];
    return value
        .whereType<Map>()
        .map(
          (e) => CollegeWorkspaceApiModel.fromApiResponse(
            e.map((key, item) => MapEntry(key.toString(), item)),
          ),
        )
        .toList();
  }
}

@JsonSerializable()
class StudentMemberApiModel {
  final String userId;
  final String name;
  final String email;
  final String? photo;
  final String? program;
  final int? year;
  final String joinedAt;

  const StudentMemberApiModel({
    required this.userId,
    required this.name,
    required this.email,
    this.photo,
    this.program,
    this.year,
    required this.joinedAt,
  });

  factory StudentMemberApiModel.fromApiResponse(Map<String, dynamic> json) {
    final user =
        jsonAsMap(json['user']) ??
        jsonAsMap(json['student']) ??
        jsonAsMap(json['studentId']);
    if (user != null) {
      return StudentMemberApiModel(
        userId: jsonString(user['_id'] ?? user['id']),
        name: jsonString(user['name']),
        email: jsonString(user['email']),
        photo: jsonNullableString(user['photo']),
        program: jsonNullableString(json['program']),
        year: json['year'] == null ? null : jsonInt(json['year']),
        joinedAt: jsonString(json['joinedAt'] ?? json['createdAt']),
      );
    }
    return StudentMemberApiModel(
      userId: jsonString(
        json['userId'] ?? json['studentId'] ?? json['_id'] ?? json['id'],
      ),
      name: jsonString(json['name']),
      email: jsonString(json['email']),
      photo: jsonNullableString(json['photo']),
      program: jsonNullableString(json['program']),
      year: json['year'] == null ? null : jsonInt(json['year']),
      joinedAt: jsonString(json['joinedAt'] ?? json['createdAt']),
    );
  }

  factory StudentMemberApiModel.fromJson(Map<String, dynamic> json) =>
      _$StudentMemberApiModelFromJson(json);

  Map<String, dynamic> toJson() => _$StudentMemberApiModelToJson(this);

  StudentMemberEntity toEntity() => StudentMemberEntity(
    userId: userId,
    name: name,
    email: email,
    photo: photo,
    program: program,
    year: year,
    joinedAt: joinedAt,
  );

  static List<StudentMemberApiModel> fromApiList(dynamic value) {
    if (value is! List) return const <StudentMemberApiModel>[];
    return value
        .whereType<Map>()
        .map(
          (e) => StudentMemberApiModel.fromApiResponse(
            e.map((key, item) => MapEntry(key.toString(), item)),
          ),
        )
        .toList();
  }
}

@JsonSerializable()
class CollegeMetricsApiModel {
  final int totalStudents;
  final int totalJobs;
  final int totalInterviews;
  final int totalApplications;
  final double averageInterviewScore;
  final double averageAtsScore;
  final List<StudentMemberApiModel> topStudents;

  const CollegeMetricsApiModel({
    required this.totalStudents,
    required this.totalJobs,
    required this.totalInterviews,
    required this.totalApplications,
    required this.averageInterviewScore,
    required this.averageAtsScore,
    required this.topStudents,
  });

  factory CollegeMetricsApiModel.fromApiResponse(Map<String, dynamic> json) {
    return CollegeMetricsApiModel(
      totalStudents: jsonInt(json['totalStudents']),
      totalJobs: jsonInt(json['totalJobs']),
      totalInterviews: jsonInt(json['totalInterviews']),
      totalApplications: jsonInt(json['totalApplications']),
      averageInterviewScore: jsonDouble(json['averageInterviewScore']),
      averageAtsScore: jsonDouble(json['averageAtsScore']),
      topStudents: StudentMemberApiModel.fromApiList(json['topStudents']),
    );
  }

  factory CollegeMetricsApiModel.fromJson(Map<String, dynamic> json) =>
      _$CollegeMetricsApiModelFromJson(json);

  Map<String, dynamic> toJson() => _$CollegeMetricsApiModelToJson(this);

  CollegeMetricsEntity toEntity() => CollegeMetricsEntity(
    totalStudents: totalStudents,
    totalJobs: totalJobs,
    totalInterviews: totalInterviews,
    totalApplications: totalApplications,
    averageInterviewScore: averageInterviewScore,
    averageAtsScore: averageAtsScore,
    topStudents: topStudents.map((e) => e.toEntity()).toList(),
  );
}
