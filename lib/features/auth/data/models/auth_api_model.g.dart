// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_api_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuthApiModel _$AuthApiModelFromJson(Map<String, dynamic> json) => AuthApiModel(
  id: json['id'] as String?,
  name: json['name'] as String?,
  email: json['email'] as String?,
  password: json['password'] as String?,
  provider: json['provider'] as String?,
  socialId: json['socialId'] as String?,
  role: json['role'] as String?,
  photo: json['photo'] as String?,
);

Map<String, dynamic> _$AuthApiModelToJson(AuthApiModel instance) {
  final data = <String, dynamic>{};
  if (instance.name != null) data['name'] = instance.name;
  if (instance.email != null) data['email'] = instance.email;
  if (instance.password != null) {
    data['password'] = instance.password;
    data['confirmPassword'] = instance.password;
  }
  if (instance.provider != null) data['provider'] = instance.provider;
  if (instance.socialId != null) data['socialId'] = instance.socialId;
  if (instance.photo != null) data['photo'] = instance.photo;
  return data;
}
