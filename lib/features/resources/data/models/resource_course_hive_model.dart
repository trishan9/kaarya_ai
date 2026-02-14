import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:kaarya/core/constants/hive_table_constant.dart';
import 'package:kaarya/features/resources/data/models/resource_course_api_model.dart';

part 'resource_course_hive_model.g.dart';

@HiveType(typeId: HiveTableConstant.resourceCourseHiveTypeId)
class ResourceCourseHiveModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final String category;

  @HiveField(4)
  final String difficulty;

  @HiveField(5)
  final List<String> targetRoles;

  @HiveField(6)
  final String visibility;

  @HiveField(7)
  final String source;

  @HiveField(8)
  final String generationMode;

  @HiveField(9)
  final String chaptersJson;

  @HiveField(10)
  final int chaptersCount;

  @HiveField(11)
  final String createdAt;

  @HiveField(12)
  final String updatedAt;

  ResourceCourseHiveModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.difficulty,
    required this.targetRoles,
    required this.visibility,
    required this.source,
    required this.generationMode,
    required this.chaptersJson,
    required this.chaptersCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ResourceCourseHiveModel.fromApiModel(ResourceCourseApiModel model) =>
      ResourceCourseHiveModel(
        id: model.id,
        title: model.title,
        description: model.description,
        category: model.category,
        difficulty: model.difficulty,
        targetRoles: model.targetRoles,
        visibility: model.visibility,
        source: model.source,
        generationMode: model.generationMode,
        chaptersJson: jsonEncode(
          model.chapters.map((c) => c.toJson()).toList(),
        ),
        chaptersCount: model.chaptersCount,
        createdAt: model.createdAt,
        updatedAt: model.updatedAt,
      );

  ResourceCourseApiModel toApiModel() {
    final chaptersList = (jsonDecode(chaptersJson) as List)
        .map(
          (e) => CourseChapterApiModel.fromJson(
            (e as Map).map((k, v) => MapEntry(k.toString(), v)),
          ),
        )
        .toList();
    return ResourceCourseApiModel(
      id: id,
      title: title,
      description: description,
      category: category,
      difficulty: difficulty,
      targetRoles: targetRoles,
      visibility: visibility,
      source: source,
      generationMode: generationMode,
      chapters: chaptersList,
      chaptersCount: chaptersCount,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
