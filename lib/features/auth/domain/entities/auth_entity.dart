import 'package:equatable/equatable.dart';

class AuthEntity extends Equatable {
  final String? authId;
  final String? name;
  final String? email;
  final String? password;
  final String? confirmPassword;
  final String? provider;
  final String? socialId;
  final String? role;
  final String? profilePicture;

  const AuthEntity({
    this.authId,
    required this.name,
    required this.email,
    this.password,
    this.confirmPassword,
    this.provider,
    this.socialId,
    this.role,
    this.profilePicture,
  });

  @override
  List<Object?> get props => [
    authId,
    name,
    email,
    password,
    confirmPassword,
    provider,
    socialId,
    role,
    profilePicture,
  ];
}
