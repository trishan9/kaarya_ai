import 'package:json_annotation/json_annotation.dart';
import 'package:kaarya/core/utils/json_parse_helpers.dart';
import 'package:kaarya/features/resources/domain/entities/resource_course_entity.dart';

part 'resource_course_api_model.g.dart';

@JsonSerializable()
class ResourceCourseApiModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final String difficulty;
  final List<String> targetRoles;
  final String visibility;
  final String source;
  final String generationMode;
  final List<CourseChapterApiModel> chapters;
  final int chaptersCount;
  final String createdAt;
  final String updatedAt;
  @JsonKey(includeFromJson: false, includeToJson: false)
  final String? createdBy;

  const ResourceCourseApiModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.difficulty,
    required this.targetRoles,
    required this.visibility,
    required this.source,
    required this.generationMode,
    required this.chapters,
    required this.chaptersCount,
    required this.createdAt,
    required this.updatedAt,
    this.createdBy,
  });

  factory ResourceCourseApiModel.fromApiResponse(Map<String, dynamic> json) {
    final chaptersRaw = jsonAsList(json['chapters']);
    final createdByRaw = json['createdBy'];
    final createdById = createdByRaw is Map
        ? jsonString(createdByRaw['_id'] ?? createdByRaw['id'])
        : jsonNullableString(createdByRaw);
    return ResourceCourseApiModel(
      id: jsonString(json['_id'] ?? json['id']),
      title: jsonString(json['title']),
      description: jsonString(json['description']),
      category: jsonString(json['category']),
      difficulty: jsonString(json['difficulty']),
      targetRoles: jsonStringList(json['targetRoles']),
      visibility: jsonString(json['visibility'], fallback: 'private'),
      source: jsonString(json['source']),
      generationMode: jsonString(json['generationMode']),
      chapters: chaptersRaw
          .map((e) => CourseChapterApiModel.fromApiResponse(jsonAsMap(e) ?? {}))
          .toList(),
      chaptersCount: jsonInt(json['chaptersCount']),
      createdAt: jsonString(json['createdAt']),
      updatedAt: jsonString(json['updatedAt']),
      createdBy: createdById,
    );
  }

  factory ResourceCourseApiModel.fromJson(Map<String, dynamic> json) =>
      _$ResourceCourseApiModelFromJson(json);

  Map<String, dynamic> toJson() => _$ResourceCourseApiModelToJson(this);

  ResourceCourseEntity toEntity() {
    return ResourceCourseEntity(
      id: id,
      title: title,
      description: description,
      category: category,
      difficulty: difficulty,
      targetRoles: targetRoles,
      visibility: visibility,
      source: source,
      generationMode: generationMode,
      chapters: chapters.map((e) => e.toEntity()).toList(),
      chaptersCount: chaptersCount,
      createdAt: createdAt,
      updatedAt: updatedAt,
      createdBy: createdBy,
    );
  }

  static List<ResourceCourseApiModel> fromApiList(dynamic value) {
    if (value is! List) return const <ResourceCourseApiModel>[];
    return value
        .whereType<Map>()
        .map(
          (e) => ResourceCourseApiModel.fromApiResponse(
            e.map((key, val) => MapEntry(key.toString(), val)),
          ),
        )
        .toList();
  }
}

@JsonSerializable()
class CourseChapterApiModel {
  final String title;
  final List<ChapterSectionApiModel> sections;
  final List<ChapterVideoApiModel> videos;
  final List<CoreConceptApiModel> coreConcepts;
  final List<InterviewQuestionApiModel> interviewQuestions;
  final List<String> practicePrompts;

  const CourseChapterApiModel({
    required this.title,
    required this.sections,
    required this.videos,
    required this.coreConcepts,
    required this.interviewQuestions,
    required this.practicePrompts,
  });

  factory CourseChapterApiModel.fromApiResponse(Map<String, dynamic> json) {
    return CourseChapterApiModel(
      title: jsonString(json['title']),
      sections: jsonAsList(json['sections'])
          .map(
            (e) => ChapterSectionApiModel.fromApiResponse(jsonAsMap(e) ?? {}),
          )
          .toList(),
      videos: jsonAsList(json['videos'])
          .map((e) => ChapterVideoApiModel.fromApiResponse(jsonAsMap(e) ?? {}))
          .toList(),
      coreConcepts: jsonAsList(json['coreConcepts'])
          .map((e) => CoreConceptApiModel.fromApiResponse(jsonAsMap(e) ?? {}))
          .toList(),
      interviewQuestions: jsonAsList(json['interviewQuestions'])
          .map(
            (e) =>
                InterviewQuestionApiModel.fromApiResponse(jsonAsMap(e) ?? {}),
          )
          .toList(),
      practicePrompts: jsonStringList(json['practicePrompts']),
    );
  }

  factory CourseChapterApiModel.fromJson(Map<String, dynamic> json) =>
      _$CourseChapterApiModelFromJson(json);

  Map<String, dynamic> toJson() => _$CourseChapterApiModelToJson(this);

  CourseChapterEntity toEntity() {
    return CourseChapterEntity(
      title: title,
      sections: sections.map((e) => e.toEntity()).toList(),
      videos: videos.map((e) => e.toEntity()).toList(),
      coreConcepts: coreConcepts.map((e) => e.toEntity()).toList(),
      interviewQuestions: interviewQuestions.map((e) => e.toEntity()).toList(),
      practicePrompts: practicePrompts,
    );
  }
}

@JsonSerializable()
class ChapterSectionApiModel {
  final String heading;
  final List<String> subheadings;

  const ChapterSectionApiModel({
    required this.heading,
    required this.subheadings,
  });

  factory ChapterSectionApiModel.fromApiResponse(Map<String, dynamic> json) {
    return ChapterSectionApiModel(
      heading: jsonString(json['heading']),
      subheadings: jsonStringList(json['subheadings']),
    );
  }

  factory ChapterSectionApiModel.fromJson(Map<String, dynamic> json) =>
      _$ChapterSectionApiModelFromJson(json);

  Map<String, dynamic> toJson() => _$ChapterSectionApiModelToJson(this);

  ChapterSectionEntity toEntity() {
    return ChapterSectionEntity(heading: heading, subheadings: subheadings);
  }
}

@JsonSerializable()
class ChapterVideoApiModel {
  final String title;
  final String url;
  final String thumbnail;

  const ChapterVideoApiModel({
    required this.title,
    required this.url,
    required this.thumbnail,
  });

  factory ChapterVideoApiModel.fromApiResponse(Map<String, dynamic> json) {
    return ChapterVideoApiModel(
      title: jsonString(json['title']),
      url: jsonString(json['url']),
      thumbnail: jsonString(json['thumbnail']),
    );
  }

  factory ChapterVideoApiModel.fromJson(Map<String, dynamic> json) =>
      _$ChapterVideoApiModelFromJson(json);

  Map<String, dynamic> toJson() => _$ChapterVideoApiModelToJson(this);

  ChapterVideoEntity toEntity() {
    return ChapterVideoEntity(title: title, url: url, thumbnail: thumbnail);
  }
}

@JsonSerializable()
class CoreConceptApiModel {
  final String title;
  final String explanation;

  const CoreConceptApiModel({required this.title, required this.explanation});

  factory CoreConceptApiModel.fromApiResponse(Map<String, dynamic> json) {
    return CoreConceptApiModel(
      title: jsonString(json['title']),
      explanation: jsonString(json['explanation']),
    );
  }

  factory CoreConceptApiModel.fromJson(Map<String, dynamic> json) =>
      _$CoreConceptApiModelFromJson(json);

  Map<String, dynamic> toJson() => _$CoreConceptApiModelToJson(this);

  CoreConceptEntity toEntity() {
    return CoreConceptEntity(title: title, explanation: explanation);
  }
}

@JsonSerializable()
class InterviewQuestionApiModel {
  final String question;
  final String sampleAnswer;

  const InterviewQuestionApiModel({
    required this.question,
    required this.sampleAnswer,
  });

  factory InterviewQuestionApiModel.fromApiResponse(Map<String, dynamic> json) {
    return InterviewQuestionApiModel(
      question: jsonString(json['question']),
      sampleAnswer: jsonString(json['sampleAnswer']),
    );
  }

  factory InterviewQuestionApiModel.fromJson(Map<String, dynamic> json) =>
      _$InterviewQuestionApiModelFromJson(json);

  Map<String, dynamic> toJson() => _$InterviewQuestionApiModelToJson(this);

  InterviewQuestionEntity toEntity() {
    return InterviewQuestionEntity(
      question: question,
      sampleAnswer: sampleAnswer,
    );
  }
}
