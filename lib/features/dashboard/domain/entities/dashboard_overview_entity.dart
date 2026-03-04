import 'package:equatable/equatable.dart';
import 'package:kaarya/features/jobs/domain/entities/job_entity.dart';
import 'package:kaarya/features/jobs/domain/entities/jobs_section_entity.dart';

class DashboardRecentCompanyEntity extends Equatable {
  final String workspaceId;
  final String workspaceType;
  final String name;
  final String? logo;
  final int applicationsCount;

  const DashboardRecentCompanyEntity({
    required this.workspaceId,
    required this.workspaceType,
    required this.name,
    required this.logo,
    required this.applicationsCount,
  });

  @override
  List<Object?> get props => [
    workspaceId,
    workspaceType,
    name,
    logo,
    applicationsCount,
  ];
}

class DashboardApplicationsSummaryEntity extends Equatable {
  final int total;
  final int delta;
  final int todayCount;
  final String monthKey;
  final String monthLabel;
  final List<DashboardRecentCompanyEntity> recentCompanies;
  final int appliedCount;
  final int reviewingCount;
  final int shortlistedCount;
  final int interviewCount;
  final int acceptedCount;
  final int rejectedCount;
  final int withdrawnCount;

  const DashboardApplicationsSummaryEntity({
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

  @override
  List<Object?> get props => [
    total,
    delta,
    todayCount,
    monthKey,
    monthLabel,
    recentCompanies,
    appliedCount,
    reviewingCount,
    shortlistedCount,
    interviewCount,
    acceptedCount,
    rejectedCount,
    withdrawnCount,
  ];
}

class DashboardInvitationEntity extends Equatable {
  final String title;
  final String description;
  final String eventTitle;
  final String eventTime;
  final String? companyName;
  final String? companyLogo;
  final String? interviewScheduledAt;

  const DashboardInvitationEntity({
    required this.title,
    required this.description,
    required this.eventTitle,
    required this.eventTime,
    required this.companyName,
    required this.companyLogo,
    required this.interviewScheduledAt,
  });

  @override
  List<Object?> get props => [
    title,
    description,
    eventTitle,
    eventTime,
    companyName,
    companyLogo,
    interviewScheduledAt,
  ];
}

class DashboardInterviewReadinessPointEntity extends Equatable {
  final String label;
  final double score;

  const DashboardInterviewReadinessPointEntity({
    required this.label,
    required this.score,
  });

  @override
  List<Object?> get props => [label, score];
}

class DashboardMomentumPointEntity extends Equatable {
  final String label;
  final int applications;
  final int interviews;

  const DashboardMomentumPointEntity({
    required this.label,
    required this.applications,
    required this.interviews,
  });

  @override
  List<Object?> get props => [label, applications, interviews];
}

class DashboardPipelinePointEntity extends Equatable {
  final String stage;
  final int thisWeek;
  final int lastWeek;

  const DashboardPipelinePointEntity({
    required this.stage,
    required this.thisWeek,
    required this.lastWeek,
  });

  @override
  List<Object?> get props => [stage, thisWeek, lastWeek];
}

class DashboardInvitationMixPointEntity extends Equatable {
  final String name;
  final double value;
  final String? fill;

  const DashboardInvitationMixPointEntity({
    required this.name,
    required this.value,
    required this.fill,
  });

  @override
  List<Object?> get props => [name, value, fill];
}

class DashboardAnalyticsEntity extends Equatable {
  final int applicationsThisWeek;
  final double interviewConversion;
  final List<DashboardMomentumPointEntity> momentum;
  final List<DashboardPipelinePointEntity> pipeline;
  final List<DashboardInvitationMixPointEntity> invitationMix;

  const DashboardAnalyticsEntity({
    required this.applicationsThisWeek,
    required this.interviewConversion,
    required this.momentum,
    required this.pipeline,
    required this.invitationMix,
  });

  @override
  List<Object?> get props => [
    applicationsThisWeek,
    interviewConversion,
    momentum,
    pipeline,
    invitationMix,
  ];
}

class DashboardOverviewEntity extends Equatable {
  final DashboardApplicationsSummaryEntity summary;
  final JobEntity? deadlineJob;
  final DashboardInvitationEntity? invitation;
  final JobsBucketEntity jobs;
  final List<DashboardInterviewReadinessPointEntity> readinessPoints;
  final DashboardAnalyticsEntity analytics;
  final double profileRating;
  final double interviewOverallRating;

  const DashboardOverviewEntity({
    required this.summary,
    required this.deadlineJob,
    required this.invitation,
    required this.jobs,
    required this.readinessPoints,
    required this.analytics,
    required this.profileRating,
    required this.interviewOverallRating,
  });

  @override
  List<Object?> get props => [
    summary,
    deadlineJob,
    invitation,
    jobs,
    readinessPoints,
    analytics,
    profileRating,
    interviewOverallRating,
  ];
}
