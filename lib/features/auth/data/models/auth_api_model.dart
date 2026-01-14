import 'package:kaarya/features/auth/domain/entities/auth_entity.dart';

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

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};

    if (name != null) data['name'] = name;
    if (email != null) data['email'] = email;
    if (password != null) data['password'] = password;
    if (provider != null) data['provider'] = provider;
    if (socialId != null) data['socialId'] = socialId;
    if (photo != null) data['photo'] = photo;

    return data;
  }

  factory AuthApiModel.fromJson(Map<String, dynamic> json) {
    return AuthApiModel(
      id: json['_id'],
      name: json['name'],
      email: json['email'],
      provider: json['provider'],
      socialId: json['socialId'],
      role: json['role'],
      photo: json['photo'],
    );
  }

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
