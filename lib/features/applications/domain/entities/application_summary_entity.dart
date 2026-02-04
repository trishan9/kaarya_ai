import 'package:equatable/equatable.dart';

class ApplicationSummaryEntity extends Equatable {
  final int total;
  final int delta;
  final int todayCount;
  final String monthKey;
  final String monthLabel;
  final int appliedCount;
  final int reviewingCount;
  final int shortlistedCount;
  final int interviewCount;
  final int acceptedCount;
  final int rejectedCount;
  final int withdrawnCount;

  const ApplicationSummaryEntity({
    required this.total,
    required this.delta,
    required this.todayCount,
    required this.monthKey,
    required this.monthLabel,
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
    appliedCount,
    reviewingCount,
    shortlistedCount,
    interviewCount,
    acceptedCount,
    rejectedCount,
    withdrawnCount,
  ];
}
