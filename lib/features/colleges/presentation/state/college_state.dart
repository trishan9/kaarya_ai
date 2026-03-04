import 'package:equatable/equatable.dart';
import 'package:kaarya/features/colleges/domain/entities/college_entity.dart';
import 'package:kaarya/features/colleges/domain/entities/college_metrics_entity.dart';
import 'package:kaarya/features/colleges/domain/entities/college_workspace_entity.dart';
import 'package:kaarya/features/colleges/domain/entities/student_member_entity.dart';

enum CollegeLoadStatus { initial, loading, loaded, error }

class CollegeState extends Equatable {
  static const Object _unset = Object();

  final CollegeLoadStatus collegesStatus;
  final CollegeLoadStatus collegeDetailStatus;
  final CollegeLoadStatus workspacesStatus;
  final CollegeLoadStatus studentsStatus;
  final CollegeLoadStatus metricsStatus;

  final List<CollegeEntity>? colleges;
  final CollegeEntity? collegeDetail;
  final List<CollegeWorkspaceEntity>? workspaces;
  final List<StudentMemberEntity>? students;
  final CollegeMetricsEntity? metrics;

  final String? collegesErrorMessage;
  final String? collegeDetailErrorMessage;
  final String? workspacesErrorMessage;
  final String? studentsErrorMessage;
  final String? metricsErrorMessage;

  final String searchQuery;

  const CollegeState({
    this.collegesStatus = CollegeLoadStatus.initial,
    this.collegeDetailStatus = CollegeLoadStatus.initial,
    this.workspacesStatus = CollegeLoadStatus.initial,
    this.studentsStatus = CollegeLoadStatus.initial,
    this.metricsStatus = CollegeLoadStatus.initial,
    this.colleges,
    this.collegeDetail,
    this.workspaces,
    this.students,
    this.metrics,
    this.collegesErrorMessage,
    this.collegeDetailErrorMessage,
    this.workspacesErrorMessage,
    this.studentsErrorMessage,
    this.metricsErrorMessage,
    this.searchQuery = '',
  });

  CollegeState copyWith({
    CollegeLoadStatus? collegesStatus,
    CollegeLoadStatus? collegeDetailStatus,
    CollegeLoadStatus? workspacesStatus,
    CollegeLoadStatus? studentsStatus,
    CollegeLoadStatus? metricsStatus,
    Object? colleges = _unset,
    Object? collegeDetail = _unset,
    Object? workspaces = _unset,
    Object? students = _unset,
    Object? metrics = _unset,
    Object? collegesErrorMessage = _unset,
    Object? collegeDetailErrorMessage = _unset,
    Object? workspacesErrorMessage = _unset,
    Object? studentsErrorMessage = _unset,
    Object? metricsErrorMessage = _unset,
    String? searchQuery,
  }) {
    return CollegeState(
      collegesStatus: collegesStatus ?? this.collegesStatus,
      collegeDetailStatus: collegeDetailStatus ?? this.collegeDetailStatus,
      workspacesStatus: workspacesStatus ?? this.workspacesStatus,
      studentsStatus: studentsStatus ?? this.studentsStatus,
      metricsStatus: metricsStatus ?? this.metricsStatus,
      colleges: colleges == _unset
          ? this.colleges
          : colleges as List<CollegeEntity>?,
      collegeDetail: collegeDetail == _unset
          ? this.collegeDetail
          : collegeDetail as CollegeEntity?,
      workspaces: workspaces == _unset
          ? this.workspaces
          : workspaces as List<CollegeWorkspaceEntity>?,
      students: students == _unset
          ? this.students
          : students as List<StudentMemberEntity>?,
      metrics: metrics == _unset
          ? this.metrics
          : metrics as CollegeMetricsEntity?,
      collegesErrorMessage: collegesErrorMessage == _unset
          ? this.collegesErrorMessage
          : collegesErrorMessage as String?,
      collegeDetailErrorMessage: collegeDetailErrorMessage == _unset
          ? this.collegeDetailErrorMessage
          : collegeDetailErrorMessage as String?,
      workspacesErrorMessage: workspacesErrorMessage == _unset
          ? this.workspacesErrorMessage
          : workspacesErrorMessage as String?,
      studentsErrorMessage: studentsErrorMessage == _unset
          ? this.studentsErrorMessage
          : studentsErrorMessage as String?,
      metricsErrorMessage: metricsErrorMessage == _unset
          ? this.metricsErrorMessage
          : metricsErrorMessage as String?,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [
    collegesStatus,
    collegeDetailStatus,
    workspacesStatus,
    studentsStatus,
    metricsStatus,
    colleges,
    collegeDetail,
    workspaces,
    students,
    metrics,
    collegesErrorMessage,
    collegeDetailErrorMessage,
    workspacesErrorMessage,
    studentsErrorMessage,
    metricsErrorMessage,
    searchQuery,
  ];
}
