import 'package:equatable/equatable.dart';
import 'package:kaarya/features/jobs/domain/entities/job_entity.dart';

class JobDetailEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final String companyName;
  final String? companyLogo;
  final String? companyId;
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
  final String level;
  final String experience;
  final List<String> requirements;
  final CompanyDetailEntity? company;
  final List<JobEntity> similarJobs;

  const JobDetailEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.companyName,
    this.companyLogo,
    this.companyId,
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
    required this.level,
    required this.experience,
    required this.requirements,
    this.company,
    required this.similarJobs,
  });

  @override
  List<Object?> get props => [id, title, description, companyName, status];
}

class CompanyDetailEntity extends Equatable {
  final String id;
  final String name;
  final String? logo;
  final String? location;
  final String? description;
  final String? industry;
  final String? teamSize;

  const CompanyDetailEntity({
    required this.id,
    required this.name,
    this.logo,
    this.location,
    this.description,
    this.industry,
    this.teamSize,
  });

  @override
  List<Object?> get props => [id, name];
}
