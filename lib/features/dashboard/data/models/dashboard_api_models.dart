import 'package:kaarya/core/utils/json_parse_helpers.dart';
import 'package:kaarya/features/dashboard/domain/entities/dashboard_overview_entity.dart';
import 'package:kaarya/features/interviews/domain/entities/interview_entity.dart';
import 'package:kaarya/features/interviews/domain/entities/interview_feedback_entity.dart';
import 'package:kaarya/features/interviews/domain/entities/interview_section_entity.dart';
import 'package:kaarya/features/interviews/domain/entities/interview_session_entity.dart';
import 'package:kaarya/features/jobs/domain/entities/job_entity.dart';
import 'package:kaarya/features/jobs/domain/entities/jobs_section_entity.dart';

class DashboardJobApiModel {
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

  const DashboardJobApiModel({
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

  factory DashboardJobApiModel.fromJson(Map<String, dynamic> json) {
    final companyData =
        jsonAsMap(json['company']) ?? jsonAsMap(json['college']);

    return DashboardJobApiModel(
      id: jsonString(json['id']),
      title: jsonString(json['title'], fallback: 'Untitled Job'),
      companyName: jsonString(companyData?['name'], fallback: 'Company'),
      companyLogo: jsonNullableString(companyData?['logo']),
      location: jsonString(json['location'], fallback: 'Remote'),
      employmentType: jsonString(json['employmentType'], fallback: 'Full-Time'),
      engagementType: jsonString(
        json['engagementType'],
        fallback: 'Internship',
      ),
      workMode: jsonString(json['workMode'], fallback: 'onsite'),
      salaryRange: jsonString(
        json['salaryRange'],
        fallback: 'Compensation not specified',
      ),
      status: jsonString(json['status'], fallback: 'open'),
      deadline: jsonString(json['deadline']),
      createdAt: jsonString(json['createdAt']),
      applicationsCount: jsonInt(json['applicationsCount']),
      viewsCount: jsonInt(json['viewsCount']),
      isSaved: jsonBool(json['isSaved']),
      hasApplied: jsonBool(json['hasApplied']),
      myApplicationId: jsonNullableString(json['myApplicationId']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'companyName': companyName,
      'companyLogo': companyLogo,
      'location': location,
      'employmentType': employmentType,
      'engagementType': engagementType,
      'workMode': workMode,
      'salaryRange': salaryRange,
      'status': status,
      'deadline': deadline,
      'createdAt': createdAt,
      'applicationsCount': applicationsCount,
      'viewsCount': viewsCount,
      'isSaved': isSaved,
      'hasApplied': hasApplied,
      'myApplicationId': myApplicationId,
    };
  }

  factory DashboardJobApiModel.fromCacheJson(Map<String, dynamic> json) {
    return DashboardJobApiModel(
      id: jsonString(json['id']),
      title: jsonString(json['title'], fallback: 'Untitled Job'),
      companyName: jsonString(json['companyName'], fallback: 'Company'),
      companyLogo: jsonNullableString(json['companyLogo']),
      location: jsonString(json['location'], fallback: 'Remote'),
      employmentType: jsonString(json['employmentType'], fallback: 'Full-Time'),
      engagementType: jsonString(
        json['engagementType'],
        fallback: 'Internship',
      ),
      workMode: jsonString(json['workMode'], fallback: 'onsite'),
      salaryRange: jsonString(
        json['salaryRange'],
        fallback: 'Compensation not specified',
      ),
      status: jsonString(json['status'], fallback: 'open'),
      deadline: jsonString(json['deadline']),
      createdAt: jsonString(json['createdAt']),
      applicationsCount: jsonInt(json['applicationsCount']),
      viewsCount: jsonInt(json['viewsCount']),
      isSaved: jsonBool(json['isSaved']),
      hasApplied: jsonBool(json['hasApplied']),
      myApplicationId: jsonNullableString(json['myApplicationId']),
    );
  }

  JobEntity toEntity() {
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
      isSaved: isSaved,
      hasApplied: hasApplied,
      myApplicationId: myApplicationId,
    );
  }

  static List<DashboardJobApiModel> fromApiList(dynamic jobs) {
    if (jobs is! List) return const <DashboardJobApiModel>[];

    return jobs
        .whereType<Map>()
        .map((item) => DashboardJobApiModel.fromJson(jsonCastMap(item)))
        .toList();
  }

  static List<DashboardJobApiModel> fromCacheList(dynamic jobs) {
    if (jobs is! List) return const <DashboardJobApiModel>[];

    return jobs
        .whereType<Map>()
        .map((item) => DashboardJobApiModel.fromCacheJson(jsonCastMap(item)))
        .toList();
  }
}

class DashboardJobsBucketApiModel {
  final List<DashboardJobApiModel> forYou;
  final List<DashboardJobApiModel> trending;
  final List<DashboardJobApiModel> newThisWeek;
  final List<DashboardJobApiModel> remote;
  final List<DashboardJobApiModel> urgent;

  const DashboardJobsBucketApiModel({
    required this.forYou,
    required this.trending,
    required this.newThisWeek,
    required this.remote,
    required this.urgent,
  });

  factory DashboardJobsBucketApiModel.empty() {
    return const DashboardJobsBucketApiModel(
      forYou: <DashboardJobApiModel>[],
      trending: <DashboardJobApiModel>[],
      newThisWeek: <DashboardJobApiModel>[],
      remote: <DashboardJobApiModel>[],
      urgent: <DashboardJobApiModel>[],
    );
  }

  factory DashboardJobsBucketApiModel.fromJson(Map<String, dynamic> json) {
    return DashboardJobsBucketApiModel(
      forYou: DashboardJobApiModel.fromCacheList(json['forYou']),
      trending: DashboardJobApiModel.fromCacheList(json['trending']),
      newThisWeek: DashboardJobApiModel.fromCacheList(json['newThisWeek']),
      remote: DashboardJobApiModel.fromCacheList(json['remote']),
      urgent: DashboardJobApiModel.fromCacheList(json['urgent']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'forYou': forYou.map((item) => item.toJson()).toList(),
      'trending': trending.map((item) => item.toJson()).toList(),
      'newThisWeek': newThisWeek.map((item) => item.toJson()).toList(),
      'remote': remote.map((item) => item.toJson()).toList(),
      'urgent': urgent.map((item) => item.toJson()).toList(),
    };
  }

  JobsBucketEntity toEntity() {
    return JobsBucketEntity(
      forYou: forYou.map((item) => item.toEntity()).toList(),
      trending: trending.map((item) => item.toEntity()).toList(),
      newThisWeek: newThisWeek.map((item) => item.toEntity()).toList(),
      remote: remote.map((item) => item.toEntity()).toList(),
      urgent: urgent.map((item) => item.toEntity()).toList(),
    );
  }
}

class DashboardApplicationsSummaryApiModel {
  final int total;
  final int delta;
  final int todayCount;
  final String monthKey;
  final String monthLabel;
  final List<DashboardRecentCompanyApiModel> recentCompanies;
  final int appliedCount;
  final int reviewingCount;
  final int shortlistedCount;
  final int interviewCount;
  final int acceptedCount;
  final int rejectedCount;
  final int withdrawnCount;

  const DashboardApplicationsSummaryApiModel({
    required this.total,
    required this.delta,
    required this.todayCount,
    required this.monthKey,
    required this.monthLabel,
    required this.recentCompanies,
    required this.appliedCount,
    required this.reviewingCount,
    required this.shortlistedCount,
    required this.interviewCount,
    required this.acceptedCount,
    required this.rejectedCount,
    required this.withdrawnCount,
  });

  factory DashboardApplicationsSummaryApiModel.empty() {
    return const DashboardApplicationsSummaryApiModel(
      total: 0,
      delta: 0,
      todayCount: 0,
      monthKey: '',
      monthLabel: 'Current Month',
      recentCompanies: <DashboardRecentCompanyApiModel>[],
      appliedCount: 0,
      reviewingCount: 0,
      shortlistedCount: 0,
      interviewCount: 0,
      acceptedCount: 0,
      rejectedCount: 0,
      withdrawnCount: 0,
    );
  }

  factory DashboardApplicationsSummaryApiModel.fromSummaryData(
    Map<String, dynamic> json,
  ) {
    final summary = jsonAsMap(json['summary']) ?? const <String, dynamic>{};
    final month = jsonAsMap(json['month']) ?? const <String, dynamic>{};
    final statusCounts =
        jsonAsMap(json['statusCounts']) ?? const <String, dynamic>{};

    return DashboardApplicationsSummaryApiModel(
      total: jsonInt(summary['total']),
      delta: jsonInt(summary['delta']),
      todayCount: jsonInt(summary['todayCount']),
      monthKey: jsonString(month['key']),
      monthLabel: jsonString(month['label'], fallback: 'Current Month'),
      recentCompanies: DashboardRecentCompanyApiModel.fromSummaryDataList(
        json['recentCompanies'],
      ),
      appliedCount: jsonInt(statusCounts['applied']),
      reviewingCount: jsonInt(statusCounts['reviewing']),
      shortlistedCount: jsonInt(statusCounts['shortlisted']),
      interviewCount: jsonInt(statusCounts['interviewScheduled']),
      acceptedCount: jsonInt(statusCounts['accepted']),
      rejectedCount: jsonInt(statusCounts['rejected']),
      withdrawnCount: jsonInt(statusCounts['withdrawn']),
    );
  }

  factory DashboardApplicationsSummaryApiModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return DashboardApplicationsSummaryApiModel(
      total: jsonInt(json['total']),
      delta: jsonInt(json['delta']),
      todayCount: jsonInt(json['todayCount']),
      monthKey: jsonString(json['monthKey']),
      monthLabel: jsonString(json['monthLabel'], fallback: 'Current Month'),
      recentCompanies: DashboardRecentCompanyApiModel.fromCacheList(
        json['recentCompanies'],
      ),
      appliedCount: jsonInt(json['appliedCount']),
      reviewingCount: jsonInt(json['reviewingCount']),
      shortlistedCount: jsonInt(json['shortlistedCount']),
      interviewCount: jsonInt(json['interviewCount']),
      acceptedCount: jsonInt(json['acceptedCount']),
      rejectedCount: jsonInt(json['rejectedCount']),
      withdrawnCount: jsonInt(json['withdrawnCount']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'delta': delta,
      'todayCount': todayCount,
      'monthKey': monthKey,
      'monthLabel': monthLabel,
      'recentCompanies': recentCompanies.map((item) => item.toJson()).toList(),
      'appliedCount': appliedCount,
      'reviewingCount': reviewingCount,
      'shortlistedCount': shortlistedCount,
      'interviewCount': interviewCount,
      'acceptedCount': acceptedCount,
      'rejectedCount': rejectedCount,
      'withdrawnCount': withdrawnCount,
    };
  }

  DashboardApplicationsSummaryEntity toEntity() {
    return DashboardApplicationsSummaryEntity(
      total: total,
      delta: delta,
      todayCount: todayCount,
      monthKey: monthKey,
      monthLabel: monthLabel,
      recentCompanies: recentCompanies.map((item) => item.toEntity()).toList(),
      appliedCount: appliedCount,
      reviewingCount: reviewingCount,
      shortlistedCount: shortlistedCount,
      interviewCount: interviewCount,
      acceptedCount: acceptedCount,
      rejectedCount: rejectedCount,
      withdrawnCount: withdrawnCount,
    );
  }
}

class DashboardRecentCompanyApiModel {
  final String workspaceId;
  final String workspaceType;
  final String name;
  final String? logo;
  final int applicationsCount;

  const DashboardRecentCompanyApiModel({
    required this.workspaceId,
    required this.workspaceType,
    required this.name,
    required this.logo,
    required this.applicationsCount,
  });

  factory DashboardRecentCompanyApiModel.fromSummaryData(
    Map<String, dynamic> json,
  ) {
    return DashboardRecentCompanyApiModel(
      workspaceId: jsonString(json['workspaceId']),
      workspaceType: jsonString(json['workspaceType'], fallback: 'company'),
      name: jsonString(json['name']),
      logo: jsonNullableString(json['logo']),
      applicationsCount: jsonInt(json['applicationsCount']),
    );
  }

  factory DashboardRecentCompanyApiModel.fromJson(Map<String, dynamic> json) {
    return DashboardRecentCompanyApiModel(
      workspaceId: jsonString(json['workspaceId']),
      workspaceType: jsonString(json['workspaceType'], fallback: 'company'),
      name: jsonString(json['name']),
      logo: jsonNullableString(json['logo']),
      applicationsCount: jsonInt(json['applicationsCount']),
    );
  }

  static List<DashboardRecentCompanyApiModel> fromSummaryDataList(
    dynamic companies,
  ) {
    if (companies is! List) {
      return const <DashboardRecentCompanyApiModel>[];
    }

    return companies
        .whereType<Map>()
        .map(
          (item) =>
              DashboardRecentCompanyApiModel.fromSummaryData(jsonCastMap(item)),
        )
        .where((item) => item.workspaceId.isNotEmpty && item.name.isNotEmpty)
        .toList();
  }

  static List<DashboardRecentCompanyApiModel> fromCacheList(dynamic companies) {
    if (companies is! List) {
      return const <DashboardRecentCompanyApiModel>[];
    }

    return companies
        .whereType<Map>()
        .map(
          (item) => DashboardRecentCompanyApiModel.fromJson(jsonCastMap(item)),
        )
        .where((item) => item.workspaceId.isNotEmpty && item.name.isNotEmpty)
        .toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'workspaceId': workspaceId,
      'workspaceType': workspaceType,
      'name': name,
      'logo': logo,
      'applicationsCount': applicationsCount,
    };
  }

  DashboardRecentCompanyEntity toEntity() {
    return DashboardRecentCompanyEntity(
      workspaceId: workspaceId,
      workspaceType: workspaceType,
      name: name,
      logo: logo,
      applicationsCount: applicationsCount,
    );
  }
}

class DashboardInvitationApiModel {
  final String title;
  final String description;
  final String eventTitle;
  final String eventTime;
  final String? companyName;
  final String? companyLogo;
  final String? interviewScheduledAt;

  const DashboardInvitationApiModel({
    required this.title,
    required this.description,
    required this.eventTitle,
    required this.eventTime,
    required this.companyName,
    required this.companyLogo,
    required this.interviewScheduledAt,
  });

  factory DashboardInvitationApiModel.fromJson(Map<String, dynamic> json) {
    return DashboardInvitationApiModel(
      title: jsonString(json['title']),
      description: jsonString(json['description']),
      eventTitle: jsonString(json['eventTitle']),
      eventTime: jsonString(json['eventTime']),
      companyName: jsonNullableString(json['companyName']),
      companyLogo: jsonNullableString(json['companyLogo']),
      interviewScheduledAt: jsonNullableString(json['interviewScheduledAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'eventTitle': eventTitle,
      'eventTime': eventTime,
      'companyName': companyName,
      'companyLogo': companyLogo,
      'interviewScheduledAt': interviewScheduledAt,
    };
  }

  DashboardInvitationEntity toEntity() {
    return DashboardInvitationEntity(
      title: title,
      description: description,
      eventTitle: eventTitle,
      eventTime: eventTime,
      companyName: companyName,
      companyLogo: companyLogo,
      interviewScheduledAt: interviewScheduledAt,
    );
  }
}

class DashboardInterviewReadinessPointApiModel {
  final String label;
  final double score;

  const DashboardInterviewReadinessPointApiModel({
    required this.label,
    required this.score,
  });

  factory DashboardInterviewReadinessPointApiModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return DashboardInterviewReadinessPointApiModel(
      label: jsonString(json['label']),
      score: jsonDouble(json['score']),
    );
  }

  Map<String, dynamic> toJson() {
    return {'label': label, 'score': score};
  }

  DashboardInterviewReadinessPointEntity toEntity() {
    return DashboardInterviewReadinessPointEntity(label: label, score: score);
  }
}

class DashboardMomentumPointApiModel {
  final String label;
  final int applications;
  final int interviews;

  const DashboardMomentumPointApiModel({
    required this.label,
    required this.applications,
    required this.interviews,
  });

  factory DashboardMomentumPointApiModel.fromJson(Map<String, dynamic> json) {
    return DashboardMomentumPointApiModel(
      label: jsonString(json['label']),
      applications: jsonInt(json['applications']),
      interviews: jsonInt(json['interviews']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'applications': applications,
      'interviews': interviews,
    };
  }

  DashboardMomentumPointEntity toEntity() {
    return DashboardMomentumPointEntity(
      label: label,
      applications: applications,
      interviews: interviews,
    );
  }
}

class DashboardPipelinePointApiModel {
  final String stage;
  final int thisWeek;
  final int lastWeek;

  const DashboardPipelinePointApiModel({
    required this.stage,
    required this.thisWeek,
    required this.lastWeek,
  });

  factory DashboardPipelinePointApiModel.fromJson(Map<String, dynamic> json) {
    return DashboardPipelinePointApiModel(
      stage: jsonString(json['stage']),
      thisWeek: jsonInt(json['thisWeek']),
      lastWeek: jsonInt(json['lastWeek']),
    );
  }

  Map<String, dynamic> toJson() {
    return {'stage': stage, 'thisWeek': thisWeek, 'lastWeek': lastWeek};
  }

  DashboardPipelinePointEntity toEntity() {
    return DashboardPipelinePointEntity(
      stage: stage,
      thisWeek: thisWeek,
      lastWeek: lastWeek,
    );
  }
}

class DashboardInvitationMixPointApiModel {
  final String name;
  final double value;
  final String? fill;

  const DashboardInvitationMixPointApiModel({
    required this.name,
    required this.value,
    required this.fill,
  });

  factory DashboardInvitationMixPointApiModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return DashboardInvitationMixPointApiModel(
      name: jsonString(json['name']),
      value: jsonDouble(json['value']),
      fill: jsonNullableString(json['fill']),
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'value': value, 'fill': fill};
  }

  DashboardInvitationMixPointEntity toEntity() {
    return DashboardInvitationMixPointEntity(
      name: name,
      value: value,
      fill: fill,
    );
  }
}

class DashboardAnalyticsApiModel {
  final int applicationsThisWeek;
  final double interviewConversion;
  final List<DashboardMomentumPointApiModel> momentum;
  final List<DashboardPipelinePointApiModel> pipeline;
  final List<DashboardInvitationMixPointApiModel> invitationMix;

  const DashboardAnalyticsApiModel({
    required this.applicationsThisWeek,
    required this.interviewConversion,
    required this.momentum,
    required this.pipeline,
    required this.invitationMix,
  });

  factory DashboardAnalyticsApiModel.empty() {
    return const DashboardAnalyticsApiModel(
      applicationsThisWeek: 0,
      interviewConversion: 0,
      momentum: <DashboardMomentumPointApiModel>[],
      pipeline: <DashboardPipelinePointApiModel>[],
      invitationMix: <DashboardInvitationMixPointApiModel>[],
    );
  }

  factory DashboardAnalyticsApiModel.fromSummaryData(
    Map<String, dynamic> json,
  ) {
    final analytics = jsonAsMap(json['analytics']) ?? const <String, dynamic>{};
    final summary =
        jsonAsMap(analytics['summary']) ?? const <String, dynamic>{};

    return DashboardAnalyticsApiModel(
      applicationsThisWeek: jsonInt(summary['applicationsThisWeek']),
      interviewConversion: jsonDouble(summary['interviewConversion']),
      momentum: jsonAsList(
        analytics['momentum'],
      ).map((item) => DashboardMomentumPointApiModel.fromJson(item)).toList(),
      pipeline: jsonAsList(
        analytics['pipeline'],
      ).map((item) => DashboardPipelinePointApiModel.fromJson(item)).toList(),
      invitationMix: jsonAsList(analytics['invitationMix'])
          .map((item) => DashboardInvitationMixPointApiModel.fromJson(item))
          .toList(),
    );
  }

  factory DashboardAnalyticsApiModel.fromJson(Map<String, dynamic> json) {
    return DashboardAnalyticsApiModel(
      applicationsThisWeek: jsonInt(json['applicationsThisWeek']),
      interviewConversion: jsonDouble(json['interviewConversion']),
      momentum: jsonAsList(
        json['momentum'],
      ).map((item) => DashboardMomentumPointApiModel.fromJson(item)).toList(),
      pipeline: jsonAsList(
        json['pipeline'],
      ).map((item) => DashboardPipelinePointApiModel.fromJson(item)).toList(),
      invitationMix: jsonAsList(json['invitationMix'])
          .map((item) => DashboardInvitationMixPointApiModel.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'applicationsThisWeek': applicationsThisWeek,
      'interviewConversion': interviewConversion,
      'momentum': momentum.map((item) => item.toJson()).toList(),
      'pipeline': pipeline.map((item) => item.toJson()).toList(),
      'invitationMix': invitationMix.map((item) => item.toJson()).toList(),
    };
  }

  DashboardAnalyticsEntity toEntity() {
    return DashboardAnalyticsEntity(
      applicationsThisWeek: applicationsThisWeek,
      interviewConversion: interviewConversion,
      momentum: momentum.map((item) => item.toEntity()).toList(),
      pipeline: pipeline.map((item) => item.toEntity()).toList(),
      invitationMix: invitationMix.map((item) => item.toEntity()).toList(),
    );
  }
}

class DashboardOverviewApiModel {
  final DashboardApplicationsSummaryApiModel summary;
  final DashboardJobApiModel? deadlineJob;
  final DashboardInvitationApiModel? invitation;
  final DashboardJobsBucketApiModel jobs;
  final List<DashboardInterviewReadinessPointApiModel> readinessPoints;
  final DashboardAnalyticsApiModel analytics;
  final double profileRating;
  final double interviewOverallRating;

  const DashboardOverviewApiModel({
    required this.summary,
    required this.deadlineJob,
    required this.invitation,
    required this.jobs,
    required this.readinessPoints,
    required this.analytics,
    required this.profileRating,
    required this.interviewOverallRating,
  });

  factory DashboardOverviewApiModel.fromJson(Map<String, dynamic> json) {
    return DashboardOverviewApiModel(
      summary: DashboardApplicationsSummaryApiModel.fromJson(
        jsonAsMap(json['summary']) ?? const <String, dynamic>{},
      ),
      deadlineJob: jsonAsMap(json['deadlineJob']) == null
          ? null
          : DashboardJobApiModel.fromCacheJson(
              jsonCastMap(json['deadlineJob']),
            ),
      invitation: jsonAsMap(json['invitation']) == null
          ? null
          : DashboardInvitationApiModel.fromJson(
              jsonCastMap(json['invitation']),
            ),
      jobs: DashboardJobsBucketApiModel.fromJson(
        jsonAsMap(json['jobs']) ?? const <String, dynamic>{},
      ),
      readinessPoints: jsonAsList(json['readinessPoints'])
          .map(
            (item) => DashboardInterviewReadinessPointApiModel.fromJson(item),
          )
          .toList(),
      analytics: DashboardAnalyticsApiModel.fromJson(
        jsonAsMap(json['analytics']) ?? const <String, dynamic>{},
      ),
      profileRating: jsonDouble(json['profileRating']),
      interviewOverallRating: jsonDouble(json['interviewOverallRating']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'summary': summary.toJson(),
      'deadlineJob': deadlineJob?.toJson(),
      'invitation': invitation?.toJson(),
      'jobs': jobs.toJson(),
      'readinessPoints': readinessPoints.map((item) => item.toJson()).toList(),
      'analytics': analytics.toJson(),
      'profileRating': profileRating,
      'interviewOverallRating': interviewOverallRating,
    };
  }

  DashboardOverviewEntity toEntity() {
    return DashboardOverviewEntity(
      summary: summary.toEntity(),
      deadlineJob: deadlineJob?.toEntity(),
      invitation: invitation?.toEntity(),
      jobs: jobs.toEntity(),
      readinessPoints: readinessPoints.map((item) => item.toEntity()).toList(),
      analytics: analytics.toEntity(),
      profileRating: profileRating,
      interviewOverallRating: interviewOverallRating,
    );
  }
}

class DashboardJobsSectionApiModel {
  final String searchQuery;
  final String locationQuery;
  final DashboardJobsBucketApiModel jobs;

  const DashboardJobsSectionApiModel({
    required this.searchQuery,
    required this.locationQuery,
    required this.jobs,
  });

  factory DashboardJobsSectionApiModel.fromJson(Map<String, dynamic> json) {
    return DashboardJobsSectionApiModel(
      searchQuery: jsonString(json['searchQuery']),
      locationQuery: jsonString(json['locationQuery']),
      jobs: DashboardJobsBucketApiModel.fromJson(
        jsonAsMap(json['jobs']) ?? const <String, dynamic>{},
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'searchQuery': searchQuery,
      'locationQuery': locationQuery,
      'jobs': jobs.toJson(),
    };
  }

  JobsSectionEntity toEntity() {
    return JobsSectionEntity(
      searchQuery: searchQuery,
      locationQuery: locationQuery,
      jobs: jobs.toEntity(),
    );
  }
}

class DashboardInterviewApiModel {
  final String id;
  final String title;
  final String role;
  final String interviewType;
  final String status;
  final String source;
  final String companyName;
  final String? companyLogo;
  final int attemptsCount;
  final double? myLatestScore;
  final String? myLatestSessionId;
  final bool hasAttempted;
  final bool isSaved;
  final List<String> techStack;
  final List<String> techStackIconUrls;
  final String createdAt;
  final String updatedAt;

  const DashboardInterviewApiModel({
    required this.id,
    required this.title,
    required this.role,
    required this.interviewType,
    required this.status,
    required this.source,
    required this.companyName,
    required this.companyLogo,
    required this.attemptsCount,
    required this.myLatestScore,
    required this.myLatestSessionId,
    required this.hasAttempted,
    required this.isSaved,
    required this.techStack,
    this.techStackIconUrls = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory DashboardInterviewApiModel.fromJson(Map<String, dynamic> json) {
    final company = jsonAsMap(json['company']);
    final college = jsonAsMap(json['college']);
    final (techNames, techIconUrls) = jsonTechStack(json['techStack']);

    return DashboardInterviewApiModel(
      id: jsonString(json['id']),
      title: jsonString(json['title'], fallback: 'Untitled Interview'),
      role: jsonString(json['role']),
      interviewType: jsonString(json['interviewType'], fallback: 'mixed'),
      status: jsonString(json['status'], fallback: 'draft'),
      source: jsonString(json['source'], fallback: 'candidate'),
      companyName:
          jsonNullableString(company?['name']) ??
          jsonNullableString(college?['name']) ??
          'Kaarya',
      companyLogo:
          jsonNullableString(company?['logo']) ??
          jsonNullableString(college?['logo']),
      attemptsCount: jsonInt(json['attemptsCount']),
      myLatestScore: jsonDoubleOrNull(json['myLatestScore']),
      myLatestSessionId: jsonNullableString(json['myLatestSessionId']),
      hasAttempted: jsonBool(json['hasAttempted']),
      isSaved: jsonBool(json['isSaved']),
      techStack: techNames,
      techStackIconUrls: techIconUrls,
      createdAt: jsonString(json['createdAt']),
      updatedAt: jsonString(json['updatedAt']),
    );
  }

  factory DashboardInterviewApiModel.fromCacheJson(Map<String, dynamic> json) {
    final (techNames, techIconUrls) = jsonTechStack(json['techStack']);

    return DashboardInterviewApiModel(
      id: jsonString(json['id']),
      title: jsonString(json['title'], fallback: 'Untitled Interview'),
      role: jsonString(json['role']),
      interviewType: jsonString(json['interviewType'], fallback: 'mixed'),
      status: jsonString(json['status'], fallback: 'draft'),
      source: jsonString(json['source'], fallback: 'candidate'),
      companyName: jsonString(json['companyName'], fallback: 'Kaarya'),
      companyLogo: jsonNullableString(json['companyLogo']),
      attemptsCount: jsonInt(json['attemptsCount']),
      myLatestScore: jsonDoubleOrNull(json['myLatestScore']),
      myLatestSessionId: jsonNullableString(json['myLatestSessionId']),
      hasAttempted: jsonBool(json['hasAttempted']),
      isSaved: jsonBool(json['isSaved']),
      techStack: techNames,
      techStackIconUrls: techIconUrls,
      createdAt: jsonString(json['createdAt']),
      updatedAt: jsonString(json['updatedAt']),
    );
  }

  static List<DashboardInterviewApiModel> fromApiList(dynamic interviews) {
    if (interviews is! List) return const <DashboardInterviewApiModel>[];

    return interviews
        .whereType<Map>()
        .map((item) => DashboardInterviewApiModel.fromJson(jsonCastMap(item)))
        .toList();
  }

  static List<DashboardInterviewApiModel> fromCacheList(dynamic interviews) {
    if (interviews is! List) return const <DashboardInterviewApiModel>[];

    return interviews
        .whereType<Map>()
        .map(
          (item) => DashboardInterviewApiModel.fromCacheJson(jsonCastMap(item)),
        )
        .toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'role': role,
      'interviewType': interviewType,
      'status': status,
      'source': source,
      'companyName': companyName,
      'companyLogo': companyLogo,
      'attemptsCount': attemptsCount,
      'myLatestScore': myLatestScore,
      'myLatestSessionId': myLatestSessionId,
      'hasAttempted': hasAttempted,
      'isSaved': isSaved,
      'techStack': techStack,
      'techStackIconUrls': techStackIconUrls,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  InterviewEntity toEntity() {
    return InterviewEntity(
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
      techStackIconUrls: techStackIconUrls,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

class DashboardInterviewsSectionApiModel {
  final List<DashboardInterviewApiModel> forYou;
  final List<DashboardInterviewApiModel> trending;
  final List<DashboardInterviewApiModel> newThisWeek;
  final List<DashboardInterviewApiModel> allTimePopular;
  final List<DashboardInterviewApiModel> byYou;
  final List<DashboardInterviewApiModel> all;
  final List<DashboardInterviewApiModel> createdByMe;
  final List<DashboardInterviewApiModel> takenByMe;
  final List<DashboardInterviewApiModel> drafts;
  final double averageScore;
  final String? lastUpdatedAt;

  const DashboardInterviewsSectionApiModel({
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
    required this.lastUpdatedAt,
  });

  factory DashboardInterviewsSectionApiModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return DashboardInterviewsSectionApiModel(
      forYou: DashboardInterviewApiModel.fromCacheList(json['forYou']),
      trending: DashboardInterviewApiModel.fromCacheList(json['trending']),
      newThisWeek: DashboardInterviewApiModel.fromCacheList(
        json['newThisWeek'],
      ),
      allTimePopular: DashboardInterviewApiModel.fromCacheList(
        json['allTimePopular'],
      ),
      byYou: DashboardInterviewApiModel.fromCacheList(json['byYou']),
      all: DashboardInterviewApiModel.fromCacheList(json['all']),
      createdByMe: DashboardInterviewApiModel.fromCacheList(
        json['createdByMe'],
      ),
      takenByMe: DashboardInterviewApiModel.fromCacheList(json['takenByMe']),
      drafts: DashboardInterviewApiModel.fromCacheList(json['drafts']),
      averageScore: jsonDouble(json['averageScore']),
      lastUpdatedAt: jsonNullableString(json['lastUpdatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'forYou': forYou.map((item) => item.toJson()).toList(),
      'trending': trending.map((item) => item.toJson()).toList(),
      'newThisWeek': newThisWeek.map((item) => item.toJson()).toList(),
      'allTimePopular': allTimePopular.map((item) => item.toJson()).toList(),
      'byYou': byYou.map((item) => item.toJson()).toList(),
      'all': all.map((item) => item.toJson()).toList(),
      'createdByMe': createdByMe.map((item) => item.toJson()).toList(),
      'takenByMe': takenByMe.map((item) => item.toJson()).toList(),
      'drafts': drafts.map((item) => item.toJson()).toList(),
      'averageScore': averageScore,
      'lastUpdatedAt': lastUpdatedAt,
    };
  }

  InterviewsSectionEntity toEntity() {
    return InterviewsSectionEntity(
      forYou: forYou.map((item) => item.toEntity()).toList(),
      trending: trending.map((item) => item.toEntity()).toList(),
      newThisWeek: newThisWeek.map((item) => item.toEntity()).toList(),
      allTimePopular: allTimePopular.map((item) => item.toEntity()).toList(),
      byYou: byYou.map((item) => item.toEntity()).toList(),
      all: all.map((item) => item.toEntity()).toList(),
      createdByMe: createdByMe.map((item) => item.toEntity()).toList(),
      takenByMe: takenByMe.map((item) => item.toEntity()).toList(),
      drafts: drafts.map((item) => item.toEntity()).toList(),
      averageScore: averageScore,
      lastUpdatedAt: lastUpdatedAt,
    );
  }
}

class DashboardInterviewSessionStartApiModel {
  final String sessionId;
  final String? interviewId;

  const DashboardInterviewSessionStartApiModel({
    required this.sessionId,
    required this.interviewId,
  });

  factory DashboardInterviewSessionStartApiModel.fromResponseData(
    Map<String, dynamic> data,
  ) {
    final session = jsonAsMap(data['session']) ?? const <String, dynamic>{};
    final interview = jsonAsMap(data['interview']) ?? const <String, dynamic>{};
    return DashboardInterviewSessionStartApiModel(
      sessionId: jsonString(session['id']),
      interviewId: jsonNullableString(interview['id']),
    );
  }

  InterviewSessionStartEntity toEntity() {
    return InterviewSessionStartEntity(
      sessionId: sessionId,
      interviewId: interviewId,
    );
  }
}

class DashboardInterviewFeedbackApiModel {
  final String sessionId;
  final String interviewTitle;
  final double? totalScore;
  final String? finalAssessment;

  const DashboardInterviewFeedbackApiModel({
    required this.sessionId,
    required this.interviewTitle,
    required this.totalScore,
    required this.finalAssessment,
  });

  factory DashboardInterviewFeedbackApiModel.fromResponseData(
    Map<String, dynamic> data,
  ) {
    final interview = jsonAsMap(data['interview']) ?? const <String, dynamic>{};
    final session = jsonAsMap(data['session']) ?? const <String, dynamic>{};
    final evaluation =
        jsonAsMap(data['evaluation']) ?? const <String, dynamic>{};

    return DashboardInterviewFeedbackApiModel(
      sessionId: jsonString(session['id']),
      interviewTitle: jsonString(interview['title'], fallback: 'Interview'),
      totalScore: jsonDoubleOrNull(evaluation['totalScore']),
      finalAssessment: jsonNullableString(evaluation['finalAssessment']),
    );
  }

  InterviewFeedbackEntity toEntity() {
    return InterviewFeedbackEntity(
      sessionId: sessionId,
      interviewTitle: interviewTitle,
      totalScore: totalScore,
      finalAssessment: finalAssessment,
      categoryScores: const [],
    );
  }
}
