// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'linked_account_api_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LinkedAccountApiModel _$LinkedAccountApiModelFromJson(
        Map<String, dynamic> json) =>
    LinkedAccountApiModel(
      provider: json['provider'] as String,
      email: json['email'] as String?,
      name: json['name'] as String?,
      linkedAt: json['linkedAt'] as String?,
    );

Map<String, dynamic> _$LinkedAccountApiModelToJson(
        LinkedAccountApiModel instance) =>
    <String, dynamic>{
      'provider': instance.provider,
      'email': instance.email,
      'name': instance.name,
      'linkedAt': instance.linkedAt,
    };
