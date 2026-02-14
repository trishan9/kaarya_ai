import 'package:equatable/equatable.dart';

class ResourceCourseEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final String category;
  final String difficulty;
  final List<String> targetRoles;
  final String visibility;
  final String source;
  final String generationMode;
  final List<CourseChapterEntity> chapters;
  final int chaptersCount;
  final String createdAt;
  final String updatedAt;

  const ResourceCourseEntity({
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
  });

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    category,
    difficulty,
    targetRoles,
    visibility,
    source,
    generationMode,
    chapters,
    chaptersCount,
    createdAt,
    updatedAt,
  ];
}

class CourseChapterEntity extends Equatable {
  final String title;
  final List<ChapterSectionEntity> sections;
  final List<ChapterVideoEntity> videos;
  final List<CoreConceptEntity> coreConcepts;
  final List<InterviewQuestionEntity> interviewQuestions;
  final List<String> practicePrompts;

  const CourseChapterEntity({
    required this.title,
    required this.sections,
    required this.videos,
    required this.coreConcepts,
    required this.interviewQuestions,
    required this.practicePrompts,
  });

  @override
  List<Object?> get props => [
    title,
    sections,
    videos,
    coreConcepts,
    interviewQuestions,
    practicePrompts,
  ];
}

class ChapterSectionEntity extends Equatable {
  final String heading;
  final List<String> subheadings;

  const ChapterSectionEntity({
    required this.heading,
    required this.subheadings,
  });

  @override
  List<Object?> get props => [heading, subheadings];
}

class ChapterVideoEntity extends Equatable {
  final String title;
  final String url;
  final String thumbnail;

  const ChapterVideoEntity({
    required this.title,
    required this.url,
    required this.thumbnail,
  });

  @override
  List<Object?> get props => [title, url, thumbnail];
}

class CoreConceptEntity extends Equatable {
  final String title;
  final String explanation;

  const CoreConceptEntity({required this.title, required this.explanation});

  @override
  List<Object?> get props => [title, explanation];
}

class InterviewQuestionEntity extends Equatable {
  final String question;
  final String sampleAnswer;

  const InterviewQuestionEntity({
    required this.question,
    required this.sampleAnswer,
  });

  @override
  List<Object?> get props => [question, sampleAnswer];
}

class ResourceCoursesListEntity extends Equatable {
  final List<ResourceCourseEntity> courses;
  final int totalCount;
  final int page;
  final int size;

  const ResourceCoursesListEntity({
    required this.courses,
    required this.totalCount,
    required this.page,
    required this.size,
  });

  @override
  List<Object?> get props => [courses, totalCount, page, size];
}
