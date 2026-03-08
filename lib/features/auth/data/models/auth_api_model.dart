import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kaarya/features/auth/domain/entities/auth_entity.dart';

part 'auth_api_model.g.dart';

@JsonSerializable()
class AuthApiModel {
  final String? id;
  final String? name;
  final String? email;
  final String? password;
  final String? confirmPassword;
  final String? provider;
  final String? socialId;
  final String? role;
  final String? photo;

  AuthApiModel({
    this.id,
    this.name,
    this.email,
    this.password,
    this.confirmPassword,
    this.provider,
    this.socialId,
    this.role,
    this.photo,
  });

  factory AuthApiModel.fromJson(Map<String, dynamic> json) {
    final model = _$AuthApiModelFromJson(json);
    final role = _parseRole(json) ?? model.role;
    return AuthApiModel(
      id: model.id,
      name: model.name,
      email: model.email,
      password: model.password,
      confirmPassword: model.confirmPassword,
      provider: model.provider,
      socialId: model.socialId,
      role: role,
      photo: model.photo,
    );
  }

  static String? _parseRole(Map<String, dynamic> json) {
    final v = json['role'] ?? json['userRole'] ?? json['user_role'];
    if (v is String && v.trim().isNotEmpty) return v.trim();
    return null;
  }

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
      confirmPassword: entity.confirmPassword,
      provider: entity.provider,
      socialId: entity.socialId,
      role: entity.role,
      photo: entity.profilePicture,
    );
  }
}
