import 'package:equatable/equatable.dart';

class JobMetricsEntity extends Equatable {
  final int viewCount;
  final int applicationsCount;
  final int uniqueViewers;
  final int shortlistedCount;
  final int interviewScheduledCount;
  final int acceptedCount;
  final int rejectedCount;

  const JobMetricsEntity({
    required this.viewCount,
    required this.applicationsCount,
    required this.uniqueViewers,
    required this.shortlistedCount,
    required this.interviewScheduledCount,
    required this.acceptedCount,
    required this.rejectedCount,
  });

  @override
  List<Object?> get props => [
    viewCount,
    applicationsCount,
    uniqueViewers,
    shortlistedCount,
    interviewScheduledCount,
    acceptedCount,
    rejectedCount,
  ];
}
