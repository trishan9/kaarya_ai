// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'company_api_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CompanyApiModel _$CompanyApiModelFromJson(Map<String, dynamic> json) =>
    CompanyApiModel(
      id: json['id'] as String,
      name: json['name'] as String,
      industry: json['industry'] as String,
      location: json['location'] as String,
      logo: json['logo'] as String?,
      verifiedStatus: json['verifiedStatus'] as String,
      inviteCode: json['inviteCode'] as String?,
      recruitersCount: (json['recruitersCount'] as num).toInt(),
      createdAt: json['createdAt'] as String,
    );

Map<String, dynamic> _$CompanyApiModelToJson(CompanyApiModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'industry': instance.industry,
      'location': instance.location,
      'logo': instance.logo,
      'verifiedStatus': instance.verifiedStatus,
      'inviteCode': instance.inviteCode,
      'recruitersCount': instance.recruitersCount,
      'createdAt': instance.createdAt,
    };

RecruiterWorkspaceApiModel _$RecruiterWorkspaceApiModelFromJson(
        Map<String, dynamic> json) =>
    RecruiterWorkspaceApiModel(
      companyId: json['companyId'] as String,
      companyName: json['companyName'] as String,
      companyLogo: json['companyLogo'] as String?,
      designation: json['designation'] as String,
      joinedAt: json['joinedAt'] as String,
    );

Map<String, dynamic> _$RecruiterWorkspaceApiModelToJson(
        RecruiterWorkspaceApiModel instance) =>
    <String, dynamic>{
      'companyId': instance.companyId,
      'companyName': instance.companyName,
      'companyLogo': instance.companyLogo,
      'designation': instance.designation,
      'joinedAt': instance.joinedAt,
    };

WorkspaceMemberApiModel _$WorkspaceMemberApiModelFromJson(
        Map<String, dynamic> json) =>
    WorkspaceMemberApiModel(
      userId: json['userId'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      photo: json['photo'] as String?,
      designation: json['designation'] as String,
      joinedAt: json['joinedAt'] as String,
    );

Map<String, dynamic> _$WorkspaceMemberApiModelToJson(
        WorkspaceMemberApiModel instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'name': instance.name,
      'email': instance.email,
      'photo': instance.photo,
      'designation': instance.designation,
      'joinedAt': instance.joinedAt,
    };
