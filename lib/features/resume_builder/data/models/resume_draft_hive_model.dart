import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:kaarya/core/constants/hive_table_constant.dart';
import 'package:kaarya/features/resume_builder/data/models/resume_builder_api_model.dart';

part 'resume_draft_hive_model.g.dart';

@HiveType(typeId: HiveTableConstant.resumeDraftHiveTypeId)
class ResumeDraftHiveModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String template;

  @HiveField(3)
  final String professionalSummary;

  @HiveField(4)
  final String sectionsJson;

  @HiveField(5)
  final String createdAt;

  @HiveField(6)
  final String updatedAt;

  ResumeDraftHiveModel({
    required this.id,
    required this.title,
    required this.template,
    required this.professionalSummary,
    required this.sectionsJson,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ResumeDraftHiveModel.fromApiModel(ResumeDraftApiModel model) =>
      ResumeDraftHiveModel(
        id: model.id,
        title: model.title,
        template: model.template,
        professionalSummary: model.professionalSummary,
        sectionsJson: jsonEncode(model.toJson()),
        createdAt: model.createdAt,
        updatedAt: model.updatedAt,
      );

  ResumeDraftApiModel toApiModel() {
    final decoded = jsonDecode(sectionsJson);
    return ResumeDraftApiModel.fromJson(
      (decoded as Map).map((k, v) => MapEntry(k.toString(), v)),
    );
  }
}
