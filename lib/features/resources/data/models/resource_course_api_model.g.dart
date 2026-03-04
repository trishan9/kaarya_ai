// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'resource_course_api_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ResourceCourseApiModel _$ResourceCourseApiModelFromJson(
        Map<String, dynamic> json) =>
    ResourceCourseApiModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      difficulty: json['difficulty'] as String,
      targetRoles: (json['targetRoles'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      visibility: json['visibility'] as String,
      source: json['source'] as String,
      generationMode: json['generationMode'] as String,
      chapters: (json['chapters'] as List<dynamic>)
          .map((e) => CourseChapterApiModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      chaptersCount: (json['chaptersCount'] as num).toInt(),
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );

Map<String, dynamic> _$ResourceCourseApiModelToJson(
        ResourceCourseApiModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'category': instance.category,
      'difficulty': instance.difficulty,
      'targetRoles': instance.targetRoles,
      'visibility': instance.visibility,
      'source': instance.source,
      'generationMode': instance.generationMode,
      'chapters': instance.chapters,
      'chaptersCount': instance.chaptersCount,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
    };

CourseChapterApiModel _$CourseChapterApiModelFromJson(
        Map<String, dynamic> json) =>
    CourseChapterApiModel(
      title: json['title'] as String,
      sections: (json['sections'] as List<dynamic>)
          .map(
              (e) => ChapterSectionApiModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      videos: (json['videos'] as List<dynamic>)
          .map((e) => ChapterVideoApiModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      coreConcepts: (json['coreConcepts'] as List<dynamic>)
          .map((e) => CoreConceptApiModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      interviewQuestions: (json['interviewQuestions'] as List<dynamic>)
          .map((e) =>
              InterviewQuestionApiModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      practicePrompts: (json['practicePrompts'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$CourseChapterApiModelToJson(
        CourseChapterApiModel instance) =>
    <String, dynamic>{
      'title': instance.title,
      'sections': instance.sections,
      'videos': instance.videos,
      'coreConcepts': instance.coreConcepts,
      'interviewQuestions': instance.interviewQuestions,
      'practicePrompts': instance.practicePrompts,
    };

ChapterSectionApiModel _$ChapterSectionApiModelFromJson(
        Map<String, dynamic> json) =>
    ChapterSectionApiModel(
      heading: json['heading'] as String,
      subheadings: (json['subheadings'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$ChapterSectionApiModelToJson(
        ChapterSectionApiModel instance) =>
    <String, dynamic>{
      'heading': instance.heading,
      'subheadings': instance.subheadings,
    };

ChapterVideoApiModel _$ChapterVideoApiModelFromJson(
        Map<String, dynamic> json) =>
    ChapterVideoApiModel(
      title: json['title'] as String,
      url: json['url'] as String,
      thumbnail: json['thumbnail'] as String,
    );

Map<String, dynamic> _$ChapterVideoApiModelToJson(
        ChapterVideoApiModel instance) =>
    <String, dynamic>{
      'title': instance.title,
      'url': instance.url,
      'thumbnail': instance.thumbnail,
    };

CoreConceptApiModel _$CoreConceptApiModelFromJson(Map<String, dynamic> json) =>
    CoreConceptApiModel(
      title: json['title'] as String,
      explanation: json['explanation'] as String,
    );

Map<String, dynamic> _$CoreConceptApiModelToJson(
        CoreConceptApiModel instance) =>
    <String, dynamic>{
      'title': instance.title,
      'explanation': instance.explanation,
    };

InterviewQuestionApiModel _$InterviewQuestionApiModelFromJson(
        Map<String, dynamic> json) =>
    InterviewQuestionApiModel(
      question: json['question'] as String,
      sampleAnswer: json['sampleAnswer'] as String,
    );

Map<String, dynamic> _$InterviewQuestionApiModelToJson(
        InterviewQuestionApiModel instance) =>
    <String, dynamic>{
      'question': instance.question,
      'sampleAnswer': instance.sampleAnswer,
    };
