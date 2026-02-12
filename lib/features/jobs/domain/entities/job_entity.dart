import 'package:equatable/equatable.dart';

class JobEntity extends Equatable {
  final String id;
  final String title;
  final String companyName;
  final String? companyLogo;
  final String location;
  final String employmentType;
  final String engagementType;
  final String workMode;
  final String salaryRange;
  final String status;
  final String deadline;
  final String createdAt;
  final int applicationsCount;
  final int viewsCount;
  final bool isSaved;
  final bool hasApplied;
  final String? myApplicationId;

  const JobEntity({
    required this.id,
    required this.title,
    required this.companyName,
    required this.companyLogo,
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
    required this.myApplicationId,
  });

  JobEntity copyWith({bool? isSaved}) {
    return JobEntity(
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
      isSaved: isSaved ?? this.isSaved,
      hasApplied: hasApplied,
      myApplicationId: myApplicationId,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    companyName,
    companyLogo,
    location,
    employmentType,
    engagementType,
    workMode,
    salaryRange,
    status,
    deadline,
    createdAt,
    applicationsCount,
    viewsCount,
    isSaved,
    hasApplied,
    myApplicationId,
  ];
}
