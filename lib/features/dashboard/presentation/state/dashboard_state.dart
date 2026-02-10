import 'package:equatable/equatable.dart';
import 'package:kaarya/features/applications/domain/entities/application_entity.dart';
import 'package:kaarya/features/applications/domain/entities/resume_entity.dart';
import 'package:kaarya/features/bookmarks/domain/entities/bookmark_entity.dart';
import 'package:kaarya/features/interviews/domain/entities/interview_section_entity.dart';
import 'package:kaarya/features/dashboard/domain/entities/dashboard_overview_entity.dart';
import 'package:kaarya/features/jobs/domain/entities/job_detail_entity.dart';
import 'package:kaarya/features/jobs/domain/entities/jobs_section_entity.dart';
import 'package:kaarya/features/leaderboard/domain/entities/leaderboard_entity.dart';
import 'package:kaarya/features/dashboard/domain/repositories/dashboard_repository.dart';

enum DashboardLoadStatus { initial, loading, loaded, error }

class DashboardState extends Equatable {
  static const Object _unset = Object();

  final DashboardLoadStatus overviewStatus;
  final DashboardLoadStatus jobsStatus;
  final DashboardLoadStatus interviewsStatus;
  final DashboardLoadStatus applicationsStatus;
  final DashboardLoadStatus bookmarksStatus;
  final DashboardLoadStatus leaderboardStatus;
  final DashboardLoadStatus jobDetailStatus;
  final DashboardLoadStatus resumesStatus;

  final DashboardOverviewEntity? overviewData;
  final JobsSectionEntity? jobsData;
  final InterviewsSectionEntity? interviewsData;
  final ApplicationsListEntity? applicationsData;
  final BookmarksListEntity? bookmarksData;
  final LeaderboardEntity? leaderboardData;
  final JobDetailEntity? jobDetailData;
  final List<ResumeEntity>? resumesData;
  final ProfilePreferences? profilePrefs;

  final String? overviewErrorMessage;
  final String? jobsErrorMessage;
  final String? interviewsErrorMessage;
  final String? applicationsErrorMessage;
  final String? bookmarksErrorMessage;
  final String? leaderboardErrorMessage;
  final String? jobDetailErrorMessage;

  final String overviewMonthKey;
  final String jobsSearchQuery;
  final String jobsLocationQuery;

  const DashboardState({
    this.overviewStatus = DashboardLoadStatus.initial,
    this.jobsStatus = DashboardLoadStatus.initial,
    this.interviewsStatus = DashboardLoadStatus.initial,
    this.applicationsStatus = DashboardLoadStatus.initial,
    this.bookmarksStatus = DashboardLoadStatus.initial,
    this.leaderboardStatus = DashboardLoadStatus.initial,
    this.jobDetailStatus = DashboardLoadStatus.initial,
    this.resumesStatus = DashboardLoadStatus.initial,
    this.overviewData,
    this.jobsData,
    this.interviewsData,
    this.applicationsData,
    this.bookmarksData,
    this.leaderboardData,
    this.jobDetailData,
    this.resumesData,
    this.profilePrefs,
    this.overviewErrorMessage,
    this.jobsErrorMessage,
    this.interviewsErrorMessage,
    this.applicationsErrorMessage,
    this.bookmarksErrorMessage,
    this.leaderboardErrorMessage,
    this.jobDetailErrorMessage,
    this.overviewMonthKey = '',
    this.jobsSearchQuery = '',
    this.jobsLocationQuery = '',
  });

  DashboardState copyWith({
    DashboardLoadStatus? overviewStatus,
    DashboardLoadStatus? jobsStatus,
    DashboardLoadStatus? interviewsStatus,
    DashboardLoadStatus? applicationsStatus,
    DashboardLoadStatus? bookmarksStatus,
    DashboardLoadStatus? leaderboardStatus,
    DashboardLoadStatus? jobDetailStatus,
    DashboardLoadStatus? resumesStatus,
    Object? overviewData = _unset,
    Object? jobsData = _unset,
    Object? interviewsData = _unset,
    Object? applicationsData = _unset,
    Object? bookmarksData = _unset,
    Object? leaderboardData = _unset,
    Object? jobDetailData = _unset,
    Object? resumesData = _unset,
    Object? profilePrefs = _unset,
    Object? overviewErrorMessage = _unset,
    Object? jobsErrorMessage = _unset,
    Object? interviewsErrorMessage = _unset,
    Object? applicationsErrorMessage = _unset,
    Object? bookmarksErrorMessage = _unset,
    Object? leaderboardErrorMessage = _unset,
    Object? jobDetailErrorMessage = _unset,
    String? overviewMonthKey,
    String? jobsSearchQuery,
    String? jobsLocationQuery,
  }) {
    return DashboardState(
      overviewStatus: overviewStatus ?? this.overviewStatus,
      jobsStatus: jobsStatus ?? this.jobsStatus,
      interviewsStatus: interviewsStatus ?? this.interviewsStatus,
      applicationsStatus: applicationsStatus ?? this.applicationsStatus,
      bookmarksStatus: bookmarksStatus ?? this.bookmarksStatus,
      leaderboardStatus: leaderboardStatus ?? this.leaderboardStatus,
      jobDetailStatus: jobDetailStatus ?? this.jobDetailStatus,
      resumesStatus: resumesStatus ?? this.resumesStatus,
      overviewData: overviewData == _unset
          ? this.overviewData
          : overviewData as DashboardOverviewEntity?,
      jobsData: jobsData == _unset
          ? this.jobsData
          : jobsData as JobsSectionEntity?,
      interviewsData: interviewsData == _unset
          ? this.interviewsData
          : interviewsData as InterviewsSectionEntity?,
      applicationsData: applicationsData == _unset
          ? this.applicationsData
          : applicationsData as ApplicationsListEntity?,
      bookmarksData: bookmarksData == _unset
          ? this.bookmarksData
          : bookmarksData as BookmarksListEntity?,
      leaderboardData: leaderboardData == _unset
          ? this.leaderboardData
          : leaderboardData as LeaderboardEntity?,
      jobDetailData: jobDetailData == _unset
          ? this.jobDetailData
          : jobDetailData as JobDetailEntity?,
      resumesData: resumesData == _unset
          ? this.resumesData
          : resumesData as List<ResumeEntity>?,
      profilePrefs: profilePrefs == _unset
          ? this.profilePrefs
          : profilePrefs as ProfilePreferences?,
      overviewErrorMessage: overviewErrorMessage == _unset
          ? this.overviewErrorMessage
          : overviewErrorMessage as String?,
      jobsErrorMessage: jobsErrorMessage == _unset
          ? this.jobsErrorMessage
          : jobsErrorMessage as String?,
      interviewsErrorMessage: interviewsErrorMessage == _unset
          ? this.interviewsErrorMessage
          : interviewsErrorMessage as String?,
      applicationsErrorMessage: applicationsErrorMessage == _unset
          ? this.applicationsErrorMessage
          : applicationsErrorMessage as String?,
      bookmarksErrorMessage: bookmarksErrorMessage == _unset
          ? this.bookmarksErrorMessage
          : bookmarksErrorMessage as String?,
      leaderboardErrorMessage: leaderboardErrorMessage == _unset
          ? this.leaderboardErrorMessage
          : leaderboardErrorMessage as String?,
      jobDetailErrorMessage: jobDetailErrorMessage == _unset
          ? this.jobDetailErrorMessage
          : jobDetailErrorMessage as String?,
      overviewMonthKey: overviewMonthKey ?? this.overviewMonthKey,
      jobsSearchQuery: jobsSearchQuery ?? this.jobsSearchQuery,
      jobsLocationQuery: jobsLocationQuery ?? this.jobsLocationQuery,
    );
  }

  @override
  List<Object?> get props => [
    overviewStatus,
    jobsStatus,
    interviewsStatus,
    applicationsStatus,
    bookmarksStatus,
    leaderboardStatus,
    jobDetailStatus,
    resumesStatus,
    overviewData,
    jobsData,
    interviewsData,
    applicationsData,
    bookmarksData,
    leaderboardData,
    jobDetailData,
    resumesData,
    profilePrefs,
    overviewErrorMessage,
    jobsErrorMessage,
    interviewsErrorMessage,
    applicationsErrorMessage,
    bookmarksErrorMessage,
    leaderboardErrorMessage,
    jobDetailErrorMessage,
    overviewMonthKey,
    jobsSearchQuery,
    jobsLocationQuery,
  ];
}
