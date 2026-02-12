import 'package:json_annotation/json_annotation.dart';
import 'package:kaarya/features/jobs/domain/entities/job_entity.dart';
import 'package:kaarya/features/jobs/domain/entities/job_detail_entity.dart';
import 'package:kaarya/features/jobs/domain/entities/job_metrics_entity.dart';
import 'package:kaarya/features/jobs/domain/entities/jobs_section_entity.dart';

part 'job_api_models.g.dart';

Map<String, dynamic> _castMap(Map v) =>
    v.map((k, v2) => MapEntry(k.toString(), v2));
Map<String, dynamic>? _asMap(dynamic v) {
  if (v is Map<String, dynamic>) return v;
  if (v is Map) return _castMap(v);
  return null;
}

String _string(dynamic v, {String fallback = ''}) =>
    (v is String && v.trim().isNotEmpty) ? v.trim() : fallback;
String? _nullableString(dynamic v) =>
    (v is String && v.trim().isNotEmpty) ? v.trim() : null;
int _intValue(dynamic v, {int fallback = 0}) {
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v) ?? fallback;
  return fallback;
}

bool _boolValue(dynamic v, {bool fallback = false}) {
  if (v is bool) return v;
  if (v is String) return v.toLowerCase() == 'true';
  return fallback;
}

List<String> _strList(dynamic v) {
  if (v is! List) return const <String>[];
  return v
      .map((e) => e is String ? e.trim() : '')
      .where((e) => e.isNotEmpty)
      .toList();
}

@JsonSerializable()
class JobApiModel {
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

  const JobApiModel({
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

  factory JobApiModel.fromJson(Map<String, dynamic> json) =>
      _$JobApiModelFromJson(json);

  Map<String, dynamic> toJson() => _$JobApiModelToJson(this);

  /// API response has nested company/college; use for remote parsing.
  factory JobApiModel.fromApiResponse(Map<String, dynamic> json) {
    final companyData = _asMap(json['company']) ?? _asMap(json['college']);
    return JobApiModel(
      id: _string(json['id']),
      title: _string(json['title'], fallback: 'Untitled Job'),
      companyName: _string(companyData?['name'], fallback: 'Company'),
      companyLogo: _nullableString(companyData?['logo']),
      location: _string(json['location'], fallback: 'Remote'),
      employmentType: _string(json['employmentType'], fallback: 'Full-Time'),
      engagementType: _string(json['engagementType'], fallback: 'Internship'),
      workMode: _string(json['workMode'], fallback: 'onsite'),
      salaryRange: _string(
        json['salaryRange'],
        fallback: 'Compensation not specified',
      ),
      status: _string(json['status'], fallback: 'open'),
      deadline: _string(json['deadline']),
      createdAt: _string(json['createdAt']),
      applicationsCount: _intValue(json['applicationsCount']),
      viewsCount: _intValue(json['viewsCount']),
      isSaved: _boolValue(json['isSaved']),
      hasApplied: _boolValue(json['hasApplied']),
      myApplicationId: _nullableString(json['myApplicationId']),
    );
  }

  JobEntity toEntity() => JobEntity(
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

  static List<JobApiModel> fromApiList(dynamic jobs) {
    if (jobs is! List) return const <JobApiModel>[];
    return jobs
        .whereType<Map>()
        .map((item) => JobApiModel.fromApiResponse(_castMap(item)))
        .toList();
  }
}

@JsonSerializable()
class JobDetailApiModel {
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
  final CompanyDetailApiModel? company;

  const JobDetailApiModel({
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
  });

  factory JobDetailApiModel.fromJson(Map<String, dynamic> json) =>
      _$JobDetailApiModelFromJson(json);

  Map<String, dynamic> toJson() => _$JobDetailApiModelToJson(this);

  /// API response has nested company/college.
  factory JobDetailApiModel.fromApiResponse(Map<String, dynamic> json) {
    final companyData = _asMap(json['company']) ?? _asMap(json['college']);
    final companyModel = companyData != null
        ? CompanyDetailApiModel.fromJson(companyData)
        : null;
    return JobDetailApiModel(
      id: _string(json['id'] ?? json['_id']),
      title: _string(json['title'], fallback: 'Untitled Job'),
      description: _string(json['description']),
      companyName: _string(companyData?['name'], fallback: 'Company'),
      companyLogo: _nullableString(companyData?['logo']),
      companyId: _nullableString(companyData?['id'] ?? companyData?['_id']),
      location: _string(json['location'], fallback: 'Remote'),
      employmentType: _string(json['employmentType'], fallback: 'Full-Time'),
      engagementType: _string(json['engagementType'], fallback: 'Internship'),
      workMode: _string(json['workMode'], fallback: 'onsite'),
      salaryRange: _string(json['salaryRange'], fallback: 'Not specified'),
      status: _string(json['status'], fallback: 'open'),
      deadline: _string(json['deadline']),
      createdAt: _string(json['createdAt']),
      applicationsCount: _intValue(json['applicationsCount']),
      viewsCount: _intValue(json['viewsCount']),
      isSaved: _boolValue(json['isSaved']),
      hasApplied: _boolValue(json['hasApplied']),
      myApplicationId: _nullableString(json['myApplicationId']),
      level: _string(json['level'], fallback: 'Mid Level'),
      experience: _string(json['experience'], fallback: '1+ years'),
      requirements: _strList(json['requirements']),
      company: companyModel,
    );
  }

  JobDetailEntity toEntity({List<JobEntity> similarJobs = const []}) =>
      JobDetailEntity(
        id: id,
        title: title,
        description: description,
        companyName: companyName,
        companyLogo: companyLogo,
        companyId: companyId,
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
        level: level,
        experience: experience,
        requirements: requirements,
        company: company?.toEntity(),
        similarJobs: similarJobs,
      );
}

@JsonSerializable(fieldRename: FieldRename.none)
class CompanyDetailApiModel {
  final String id;
  final String name;
  final String? logo;
  final String? location;
  final String? description;
  final String? industry;
  final String? teamSize;

  const CompanyDetailApiModel({
    required this.id,
    required this.name,
    this.logo,
    this.location,
    this.description,
    this.industry,
    this.teamSize,
  });

  factory CompanyDetailApiModel.fromJson(Map<String, dynamic> json) =>
      _$CompanyDetailApiModelFromJson(json);

  Map<String, dynamic> toJson() => _$CompanyDetailApiModelToJson(this);

  CompanyDetailEntity toEntity() => CompanyDetailEntity(
    id: id,
    name: name,
    logo: logo,
    location: location,
    description: description,
    industry: industry,
    teamSize: teamSize,
  );
}

@JsonSerializable()
class JobsSectionApiModel {
  final String searchQuery;
  final String locationQuery;
  final JobsBucketApiModel jobs;

  const JobsSectionApiModel({
    required this.searchQuery,
    required this.locationQuery,
    required this.jobs,
  });

  factory JobsSectionApiModel.fromJson(Map<String, dynamic> json) =>
      _$JobsSectionApiModelFromJson(json);

  Map<String, dynamic> toJson() => _$JobsSectionApiModelToJson(this);

  JobsSectionEntity toEntity() => JobsSectionEntity(
    searchQuery: searchQuery,
    locationQuery: locationQuery,
    jobs: jobs.toEntity(),
  );
}

@JsonSerializable()
class JobsBucketApiModel {
  final List<JobApiModel> forYou;
  final List<JobApiModel> trending;
  final List<JobApiModel> newThisWeek;
  final List<JobApiModel> remote;
  final List<JobApiModel> urgent;

  const JobsBucketApiModel({
    required this.forYou,
    required this.trending,
    required this.newThisWeek,
    required this.remote,
    required this.urgent,
  });

  factory JobsBucketApiModel.fromJson(Map<String, dynamic> json) =>
      _$JobsBucketApiModelFromJson(json);

  Map<String, dynamic> toJson() => _$JobsBucketApiModelToJson(this);

  JobsBucketEntity toEntity() => JobsBucketEntity(
    forYou: forYou.map((e) => e.toEntity()).toList(),
    trending: trending.map((e) => e.toEntity()).toList(),
    newThisWeek: newThisWeek.map((e) => e.toEntity()).toList(),
    remote: remote.map((e) => e.toEntity()).toList(),
    urgent: urgent.map((e) => e.toEntity()).toList(),
  );
}

class JobMetricsApiModel {
  final int viewCount;
  final int applicationsCount;
  final int uniqueViewers;
  final int shortlistedCount;
  final int interviewScheduledCount;
  final int acceptedCount;
  final int rejectedCount;

  const JobMetricsApiModel({
    required this.viewCount,
    required this.applicationsCount,
    required this.uniqueViewers,
    required this.shortlistedCount,
    required this.interviewScheduledCount,
    required this.acceptedCount,
    required this.rejectedCount,
  });

  factory JobMetricsApiModel.fromJson(Map<String, dynamic> json) {
    return JobMetricsApiModel(
      viewCount: _intValue(json['viewCount']),
      applicationsCount: _intValue(json['applicationsCount']),
      uniqueViewers: _intValue(json['uniqueViewers']),
      shortlistedCount: _intValue(json['shortlistedCount']),
      interviewScheduledCount: _intValue(json['interviewScheduledCount']),
      acceptedCount: _intValue(json['acceptedCount']),
      rejectedCount: _intValue(json['rejectedCount']),
    );
  }

  JobMetricsEntity toEntity() => JobMetricsEntity(
    viewCount: viewCount,
    applicationsCount: applicationsCount,
    uniqueViewers: uniqueViewers,
    shortlistedCount: shortlistedCount,
    interviewScheduledCount: interviewScheduledCount,
    acceptedCount: acceptedCount,
    rejectedCount: rejectedCount,
  );
}
