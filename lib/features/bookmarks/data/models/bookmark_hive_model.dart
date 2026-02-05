import 'package:hive/hive.dart';
import 'package:kaarya/core/constants/hive_table_constant.dart';
import 'package:kaarya/features/bookmarks/data/models/bookmarks_api_model.dart';

part 'bookmark_hive_model.g.dart';

@HiveType(typeId: HiveTableConstant.jobBookmarkHiveTypeId)
class JobBookmarkHiveModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String companyName;

  @HiveField(3)
  final String? companyLogo;

  @HiveField(4)
  final String location;

  @HiveField(5)
  final String employmentType;

  @HiveField(6)
  final String engagementType;

  @HiveField(7)
  final String workMode;

  @HiveField(8)
  final String salaryRange;

  @HiveField(9)
  final String status;

  @HiveField(10)
  final String deadline;

  @HiveField(11)
  final String createdAt;

  @HiveField(12)
  final int applicationsCount;

  @HiveField(13)
  final int viewsCount;

  @HiveField(14)
  final bool isSaved;

  @HiveField(15)
  final bool hasApplied;

  @HiveField(16)
  final String? myApplicationId;

  JobBookmarkHiveModel({
    required this.id,
    required this.title,
    required this.companyName,
    this.companyLogo,
    required this.location,
    required this.employmentType,
    required this.engagementType,
    required this.workMode,
    required this.salaryRange,
    required this.status,
    required this.deadline,
    required this.createdAt,
    required this.applicationsCount,
    required this.viewsCount,
    required this.isSaved,
    required this.hasApplied,
    this.myApplicationId,
  });

  factory JobBookmarkHiveModel.fromApiModel(JobBookmarkApiModel model) =>
      JobBookmarkHiveModel(
        id: model.id,
        title: model.title,
        companyName: model.companyName,
        companyLogo: model.companyLogo,
        location: model.location,
        employmentType: model.employmentType,
        engagementType: model.engagementType,
        workMode: model.workMode,
        salaryRange: model.salaryRange,
        status: model.status,
        deadline: model.deadline,
        createdAt: model.createdAt,
        applicationsCount: model.applicationsCount,
        viewsCount: model.viewsCount,
        isSaved: model.isSaved,
        hasApplied: model.hasApplied,
        myApplicationId: model.myApplicationId,
      );

  JobBookmarkApiModel toApiModel() => JobBookmarkApiModel(
    id: id,
    title: title,
    companyName: companyName,
    companyLogo: companyLogo,
    location: location,
    employmentType: employmentType,
    engagementType: engagementType,
    workMode: workMode,
    salaryRange: salaryRange,
    status: status,
    deadline: deadline,
    createdAt: createdAt,
    applicationsCount: applicationsCount,
    viewsCount: viewsCount,
    isSaved: isSaved,
    hasApplied: hasApplied,
    myApplicationId: myApplicationId,
  );
}

@HiveType(typeId: HiveTableConstant.interviewBookmarkHiveTypeId)
class InterviewBookmarkHiveModel extends HiveObject {
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

  InterviewBookmarkHiveModel({
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

  factory InterviewBookmarkHiveModel.fromApiModel(
    InterviewBookmarkApiModel model,
  ) => InterviewBookmarkHiveModel(
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

  InterviewBookmarkApiModel toApiModel() => InterviewBookmarkApiModel(
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
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}

@HiveType(typeId: HiveTableConstant.bookmarksHiveTypeId)
class BookmarksHiveModel extends HiveObject {
  @HiveField(0)
  final List<JobBookmarkHiveModel> jobs;

  @HiveField(1)
  final List<InterviewBookmarkHiveModel> interviews;

  BookmarksHiveModel({required this.jobs, required this.interviews});

  factory BookmarksHiveModel.fromApiModel(BookmarksApiModel model) =>
      BookmarksHiveModel(
        jobs: model.jobs.map(JobBookmarkHiveModel.fromApiModel).toList(),
        interviews: model.interviews
            .map(InterviewBookmarkHiveModel.fromApiModel)
            .toList(),
      );

  BookmarksApiModel toApiModel() => BookmarksApiModel(
    jobs: jobs.map((e) => e.toApiModel()).toList(),
    interviews: interviews.map((e) => e.toApiModel()).toList(),
  );
}
