import 'package:hive/hive.dart';
import 'package:kaarya/core/constants/hive_table_constant.dart';
import 'package:kaarya/features/applications/data/models/application_api_model.dart';

part 'application_hive_model.g.dart';

@HiveType(typeId: HiveTableConstant.applicationHiveTypeId)
class ApplicationHiveModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String jobId;

  @HiveField(2)
  final String jobTitle;

  @HiveField(3)
  final String companyName;

  @HiveField(4)
  final String? companyLogo;

  @HiveField(5)
  final String status;

  @HiveField(6)
  final String appliedAt;

  @HiveField(7)
  final String updatedAt;

  @HiveField(8)
  final String? nextStep;

  @HiveField(9)
  final String location;

  @HiveField(10)
  final String employmentType;

  @HiveField(11)
  final String workMode;

  @HiveField(12)
  final String salaryRange;

  ApplicationHiveModel({
    required this.id,
    required this.jobId,
    required this.jobTitle,
    required this.companyName,
    this.companyLogo,
    required this.status,
    required this.appliedAt,
    required this.updatedAt,
    this.nextStep,
    required this.location,
    required this.employmentType,
    required this.workMode,
    required this.salaryRange,
  });

  factory ApplicationHiveModel.fromApiModel(ApplicationApiModel model) =>
      ApplicationHiveModel(
        id: model.id,
        jobId: model.jobId,
        jobTitle: model.jobTitle,
        companyName: model.companyName,
        companyLogo: model.companyLogo,
        status: model.status,
        appliedAt: model.appliedAt,
        updatedAt: model.updatedAt,
        nextStep: model.nextStep,
        location: model.location,
        employmentType: model.employmentType,
        workMode: model.workMode,
        salaryRange: model.salaryRange,
      );

  ApplicationApiModel toApiModel() => ApplicationApiModel(
    id: id,
    jobId: jobId,
    jobTitle: jobTitle,
    companyName: companyName,
    companyLogo: companyLogo,
    status: status,
    appliedAt: appliedAt,
    updatedAt: updatedAt,
    nextStep: nextStep,
    location: location,
    employmentType: employmentType,
    workMode: workMode,
    salaryRange: salaryRange,
  );
}
