import 'package:hive/hive.dart';
import 'package:kaarya/features/auth/domain/entities/auth_entity.dart';
import 'package:kaarya/core/constants/hive_table_constant.dart';
import 'package:uuid/uuid.dart';

part 'auth_hive_model.g.dart';

@HiveType(typeId: HiveTableConstant.userTypeId)
class AuthHiveModel extends HiveObject {
  @HiveField(0)
  final String? authId;

  @HiveField(1)
  final String? name;

  @HiveField(2)
  final String? email;

  @HiveField(3)
  final String? provider;

  @HiveField(4)
  final String? socialId;

  @HiveField(5)
  final String? role;

  @HiveField(6)
  final String? password;

  @HiveField(7)
  final String? photo;

  AuthHiveModel({
    String? authId,
    this.name,
    this.email,
    this.provider,
    this.role,
    this.socialId,
    this.password,
    this.photo,
  }) : authId = authId ?? const Uuid().v4();

  AuthEntity toEntity({AuthEntity? auth}) {
    return AuthEntity(
      authId: authId,
      name: name,
      email: email,
      provider: provider,
      socialId: socialId,
      role: role,
      profilePicture: photo,
    );
  }

  factory AuthHiveModel.fromEntity(AuthEntity entity) {
    return AuthHiveModel(
      authId: entity.authId!,
      name: entity.name,
      email: entity.email,
      provider: entity.provider,
      socialId: entity.socialId,
      role: entity.role,
      photo: entity.profilePicture,
    );
  }

  static List<AuthEntity> toEntityList(List<AuthHiveModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }
}
