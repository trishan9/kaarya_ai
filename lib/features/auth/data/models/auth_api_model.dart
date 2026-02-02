import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kaarya/features/auth/domain/entities/auth_entity.dart';

part 'auth_api_model.g.dart';

@JsonSerializable()
class AuthApiModel {
  final String? id;
  final String? name;
  final String? email;
  final String? password;
  final String? provider;
  final String? socialId;
  final String? role;
  final String? photo;

  AuthApiModel({
    this.id,
    this.name,
    this.email,
    this.password,
    this.provider,
    this.socialId,
    this.role,
    this.photo,
  });

  factory AuthApiModel.fromJson(Map<String, dynamic> json) =>
      _$AuthApiModelFromJson(json);

  Map<String, dynamic> toJson() => _$AuthApiModelToJson(this);

  AuthEntity toEntity() {
    return AuthEntity(
      authId: id,
      name: name,
      email: email,
      provider: provider,
      socialId: socialId,
      role: role,
      profilePicture: photo,
    );
  }

  factory AuthApiModel.fromEntity(AuthEntity entity) {
    return AuthApiModel(
      name: entity.name,
      email: entity.email,
      password: entity.password,
      provider: entity.provider,
      socialId: entity.socialId,
      photo: entity.profilePicture,
    );
  }
}
