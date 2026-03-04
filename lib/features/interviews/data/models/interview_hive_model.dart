import 'package:hive/hive.dart';
import 'package:kaarya/core/constants/hive_table_constant.dart';
import 'package:kaarya/features/interviews/data/models/interview_api_model.dart';

part 'interview_hive_model.g.dart';

@HiveType(typeId: HiveTableConstant.interviewHiveTypeId)
class InterviewHiveModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String role;

  @HiveField(3)
  final String interviewType;

  @HiveField(4)
  final String status;

  @HiveField(5)
  final String source;

  @HiveField(6)
  final String companyName;

  @HiveField(7)
  final String? companyLogo;

  @HiveField(8)
  final int attemptsCount;

  @HiveField(9)
  final double? myLatestScore;

  @HiveField(10)
  final String? myLatestSessionId;

  @HiveField(11)
  final bool hasAttempted;

  @HiveField(12)
  final bool isSaved;

  @HiveField(13)
  final List<String> techStack;

  @HiveField(14)
  final String createdAt;

  @HiveField(15)
  final String updatedAt;

  InterviewHiveModel({
    required this.id,
    required this.title,
    required this.role,
    required this.interviewType,
    required this.status,
    required this.source,
    required this.companyName,
    this.companyLogo,
    required this.attemptsCount,
    this.myLatestScore,
    this.myLatestSessionId,
    required this.hasAttempted,
    required this.isSaved,
    required this.techStack,
    required this.createdAt,
    required this.updatedAt,
  });

  factory InterviewHiveModel.fromApiModel(InterviewApiModel model) =>
      InterviewHiveModel(
        id: model.id,
        title: model.title,
        role: model.role,
        interviewType: model.interviewType,
        status: model.status,
        source: model.source,
        companyName: model.companyName,
        companyLogo: model.companyLogo,
        attemptsCount: model.attemptsCount,
        myLatestScore: model.myLatestScore,
        myLatestSessionId: model.myLatestSessionId,
        hasAttempted: model.hasAttempted,
        isSaved: model.isSaved,
        techStack: model.techStack,
        createdAt: model.createdAt,
        updatedAt: model.updatedAt,
      );

  InterviewApiModel toApiModel() => InterviewApiModel(
    id: id,
    title: title,
    role: role,
    interviewType: interviewType,
    status: status,
    source: source,
    companyName: companyName,
    companyLogo: companyLogo,
    attemptsCount: attemptsCount,
    myLatestScore: myLatestScore,
    myLatestSessionId: myLatestSessionId,
    hasAttempted: hasAttempted,
    isSaved: isSaved,
    techStack: techStack,
    techStackIconUrls: const [], // Cache doesn't store icon URLs; fall back to client mapping
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}

@HiveType(typeId: HiveTableConstant.interviewsSectionHiveTypeId)
class InterviewsSectionHiveModel extends HiveObject {
  @HiveField(0)
  final List<InterviewHiveModel> forYou;

  @HiveField(1)
  final List<InterviewHiveModel> trending;

  @HiveField(2)
  final List<InterviewHiveModel> newThisWeek;

  @HiveField(3)
  final List<InterviewHiveModel> allTimePopular;

  @HiveField(4)
  final List<InterviewHiveModel> byYou;

  @HiveField(5)
  final List<InterviewHiveModel> all;

  @HiveField(6)
  final List<InterviewHiveModel> createdByMe;

  @HiveField(7)
  final List<InterviewHiveModel> takenByMe;

  @HiveField(8)
  final List<InterviewHiveModel> drafts;

  @HiveField(9)
  final double averageScore;

  @HiveField(10)
  final String? lastUpdatedAt;

  InterviewsSectionHiveModel({
    required this.forYou,
    required this.trending,
    required this.newThisWeek,
    required this.allTimePopular,
    required this.byYou,
    required this.all,
    required this.createdByMe,
    required this.takenByMe,
    required this.drafts,
    required this.averageScore,
    this.lastUpdatedAt,
  });

  factory InterviewsSectionHiveModel.fromApiModel(
    InterviewsSectionApiModel model,
  ) => InterviewsSectionHiveModel(
    forYou: model.forYou.map(InterviewHiveModel.fromApiModel).toList(),
    trending: model.trending.map(InterviewHiveModel.fromApiModel).toList(),
    newThisWeek: model.newThisWeek
        .map(InterviewHiveModel.fromApiModel)
        .toList(),
    allTimePopular: model.allTimePopular
        .map(InterviewHiveModel.fromApiModel)
        .toList(),
    byYou: model.byYou.map(InterviewHiveModel.fromApiModel).toList(),
    all: model.all.map(InterviewHiveModel.fromApiModel).toList(),
    createdByMe: model.createdByMe
        .map(InterviewHiveModel.fromApiModel)
        .toList(),
    takenByMe: model.takenByMe.map(InterviewHiveModel.fromApiModel).toList(),
    drafts: model.drafts.map(InterviewHiveModel.fromApiModel).toList(),
    averageScore: model.averageScore,
    lastUpdatedAt: model.lastUpdatedAt,
  );

  InterviewsSectionApiModel toApiModel() => InterviewsSectionApiModel(
    forYou: forYou.map((e) => e.toApiModel()).toList(),
    trending: trending.map((e) => e.toApiModel()).toList(),
    newThisWeek: newThisWeek.map((e) => e.toApiModel()).toList(),
    allTimePopular: allTimePopular.map((e) => e.toApiModel()).toList(),
    byYou: byYou.map((e) => e.toApiModel()).toList(),
    all: all.map((e) => e.toApiModel()).toList(),
    createdByMe: createdByMe.map((e) => e.toApiModel()).toList(),
    takenByMe: takenByMe.map((e) => e.toApiModel()).toList(),
    drafts: drafts.map((e) => e.toApiModel()).toList(),
    averageScore: averageScore,
    lastUpdatedAt: lastUpdatedAt,
  );
}
