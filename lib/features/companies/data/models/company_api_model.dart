import 'package:json_annotation/json_annotation.dart';
import 'package:kaarya/core/utils/json_parse_helpers.dart';
import 'package:kaarya/features/companies/domain/entities/company_entity.dart';
import 'package:kaarya/features/companies/domain/entities/recruiter_workspace_entity.dart';
import 'package:kaarya/features/companies/domain/entities/workspace_member_entity.dart';

part 'company_api_model.g.dart';

@JsonSerializable()
class CompanyApiModel {
  final String id;
  final String name;
  final String industry;
  final String location;
  final String? logo;
  final String verifiedStatus;
  final String? inviteCode;
  final int recruitersCount;
  final String createdAt;

  const CompanyApiModel({
    required this.id,
    required this.name,
    required this.industry,
    required this.location,
    this.logo,
    required this.verifiedStatus,
    this.inviteCode,
    required this.recruitersCount,
    required this.createdAt,
  });

  factory CompanyApiModel.fromApiResponse(Map<String, dynamic> json) {
    return CompanyApiModel(
      id: jsonString(json['id'] ?? json['_id']),
      name: jsonString(json['name']),
      industry: jsonString(json['industry']),
      location: jsonString(json['location']),
      logo: jsonNullableString(json['logo']),
      verifiedStatus: jsonString(json['verifiedStatus'], fallback: 'pending'),
      inviteCode: jsonNullableString(json['inviteCode']),
      recruitersCount: jsonInt(json['recruitersCount']),
      createdAt: jsonString(json['createdAt']),
    );
  }

  factory CompanyApiModel.fromJson(Map<String, dynamic> json) =>
      _$CompanyApiModelFromJson(json);

  Map<String, dynamic> toJson() => _$CompanyApiModelToJson(this);

  CompanyEntity toEntity() {
    return CompanyEntity(
      id: id,
      name: name,
      industry: industry,
      location: location,
      logo: logo,
      verifiedStatus: verifiedStatus,
      inviteCode: inviteCode,
      recruitersCount: recruitersCount,
      createdAt: createdAt,
    );
  }

  static List<CompanyApiModel> fromApiList(dynamic value) {
    if (value is! List) return const <CompanyApiModel>[];
    return value
        .whereType<Map>()
        .map((e) => CompanyApiModel.fromApiResponse(jsonCastMap(e)))
        .toList();
  }
}

@JsonSerializable()
class RecruiterWorkspaceApiModel {
  final String companyId;
  final String companyName;
  final String? companyLogo;
  final String designation;
  final String joinedAt;

  const RecruiterWorkspaceApiModel({
    required this.companyId,
    required this.companyName,
    this.companyLogo,
    required this.designation,
    required this.joinedAt,
  });

  factory RecruiterWorkspaceApiModel.fromApiResponse(
    Map<String, dynamic> json,
  ) {
    final company = jsonAsMap(json['company']);
    return RecruiterWorkspaceApiModel(
      companyId: jsonString(
        json['companyId'] ?? company?['id'] ?? company?['_id'],
      ),
      companyName: jsonString(json['companyName'] ?? company?['name']),
      companyLogo: jsonNullableString(json['companyLogo'] ?? company?['logo']),
      designation: jsonString(json['designation']),
      joinedAt: jsonString(json['joinedAt'] ?? json['createdAt']),
    );
  }

  factory RecruiterWorkspaceApiModel.fromJson(Map<String, dynamic> json) =>
      _$RecruiterWorkspaceApiModelFromJson(json);

  Map<String, dynamic> toJson() => _$RecruiterWorkspaceApiModelToJson(this);

  RecruiterWorkspaceEntity toEntity() {
    return RecruiterWorkspaceEntity(
      companyId: companyId,
      companyName: companyName,
      companyLogo: companyLogo,
      designation: designation,
      joinedAt: joinedAt,
    );
  }

  static List<RecruiterWorkspaceApiModel> fromApiList(dynamic value) {
    if (value is! List) return const <RecruiterWorkspaceApiModel>[];
    return value
        .whereType<Map>()
        .map((e) => RecruiterWorkspaceApiModel.fromApiResponse(jsonCastMap(e)))
        .toList();
  }
}

@JsonSerializable()
class WorkspaceMemberApiModel {
  final String userId;
  final String name;
  final String email;
  final String? photo;
  final String designation;
  final String joinedAt;

  const WorkspaceMemberApiModel({
    required this.userId,
    required this.name,
    required this.email,
    this.photo,
    required this.designation,
    required this.joinedAt,
  });

  factory WorkspaceMemberApiModel.fromApiResponse(Map<String, dynamic> json) {
    final user = jsonAsMap(json['user']);
    return WorkspaceMemberApiModel(
      userId: jsonString(
        json['userId'] ??
            user?['id'] ??
            user?['_id'] ??
            json['id'] ??
            json['_id'],
      ),
      name: jsonString(json['name'] ?? user?['name']),
      email: jsonString(json['email'] ?? user?['email']),
      photo: jsonNullableString(json['photo'] ?? user?['photo']),
      designation: jsonString(json['designation']),
      joinedAt: jsonString(json['joinedAt'] ?? json['createdAt']),
    );
  }

  factory WorkspaceMemberApiModel.fromJson(Map<String, dynamic> json) =>
      _$WorkspaceMemberApiModelFromJson(json);

  Map<String, dynamic> toJson() => _$WorkspaceMemberApiModelToJson(this);

  WorkspaceMemberEntity toEntity() {
    return WorkspaceMemberEntity(
      userId: userId,
      name: name,
      email: email,
      photo: photo,
      designation: designation,
      joinedAt: joinedAt,
    );
  }

  static List<WorkspaceMemberApiModel> fromApiList(dynamic value) {
    if (value is! List) return const <WorkspaceMemberApiModel>[];
    return value
        .whereType<Map>()
        .map((e) => WorkspaceMemberApiModel.fromApiResponse(jsonCastMap(e)))
        .toList();
  }
}
