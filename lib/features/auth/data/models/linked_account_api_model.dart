import 'package:json_annotation/json_annotation.dart';
import 'package:kaarya/features/auth/domain/entities/linked_account_entity.dart';

part 'linked_account_api_model.g.dart';

@JsonSerializable()
class LinkedAccountApiModel {
  final String provider;
  final String? email;
  final String? name;
  final String? linkedAt;

  const LinkedAccountApiModel({
    required this.provider,
    this.email,
    this.name,
    this.linkedAt,
  });

  factory LinkedAccountApiModel.fromJson(Map<String, dynamic> json) =>
      _$LinkedAccountApiModelFromJson(json);

  Map<String, dynamic> toJson() => _$LinkedAccountApiModelToJson(this);

  LinkedAccountEntity toEntity() => LinkedAccountEntity(
    provider: provider,
    email: email,
    name: name,
    linkedAt: linkedAt,
  );

  static List<LinkedAccountApiModel> fromApiList(List<dynamic> list) {
    return list
        .whereType<Map<String, dynamic>>()
        .map(LinkedAccountApiModel.fromJson)
        .toList();
  }
}
