import 'package:hive/hive.dart';
import 'package:kaarya/core/constants/hive_table_constant.dart';
import 'package:kaarya/features/jobs/data/models/job_api_models.dart';

part 'job_hive_model.g.dart';

@HiveType(typeId: HiveTableConstant.jobHiveTypeId)
class JobHiveModel extends HiveObject {
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

  JobHiveModel({
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

  factory JobHiveModel.fromApiModel(JobApiModel model) => JobHiveModel(
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

  JobApiModel toApiModel() => JobApiModel(
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

@HiveType(typeId: HiveTableConstant.jobsSectionHiveTypeId)
class JobsSectionHiveModel extends HiveObject {
  @HiveField(0)
  final String searchQuery;

  @HiveField(1)
  final String locationQuery;

  @HiveField(2)
  final List<JobHiveModel> forYou;

  @HiveField(3)
  final List<JobHiveModel> trending;

  @HiveField(4)
  final List<JobHiveModel> newThisWeek;

  @HiveField(5)
  final List<JobHiveModel> remote;

  @HiveField(6)
  final List<JobHiveModel> urgent;

  JobsSectionHiveModel({
    required this.searchQuery,
    required this.locationQuery,
    required this.forYou,
    required this.trending,
    required this.newThisWeek,
    required this.remote,
    required this.urgent,
  });

  factory JobsSectionHiveModel.fromApiModel(JobsSectionApiModel model) =>
      JobsSectionHiveModel(
        searchQuery: model.searchQuery,
        locationQuery: model.locationQuery,
        forYou: model.jobs.forYou.map(JobHiveModel.fromApiModel).toList(),
        trending: model.jobs.trending.map(JobHiveModel.fromApiModel).toList(),
        newThisWeek: model.jobs.newThisWeek
            .map(JobHiveModel.fromApiModel)
            .toList(),
        remote: model.jobs.remote.map(JobHiveModel.fromApiModel).toList(),
        urgent: model.jobs.urgent.map(JobHiveModel.fromApiModel).toList(),
      );

  JobsSectionApiModel toApiModel() => JobsSectionApiModel(
    searchQuery: searchQuery,
    locationQuery: locationQuery,
    jobs: JobsBucketApiModel(
      forYou: forYou.map((e) => e.toApiModel()).toList(),
      trending: trending.map((e) => e.toApiModel()).toList(),
      newThisWeek: newThisWeek.map((e) => e.toApiModel()).toList(),
      remote: remote.map((e) => e.toApiModel()).toList(),
      urgent: urgent.map((e) => e.toApiModel()).toList(),
    ),
  );
}
