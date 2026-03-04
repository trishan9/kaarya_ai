import 'package:equatable/equatable.dart';

import 'package:kaarya/features/colleges/domain/entities/student_member_entity.dart';

class CollegeMetricsEntity extends Equatable {
  final int totalStudents;
  final int totalJobs;
  final int totalInterviews;
  final int totalApplications;
  final double averageInterviewScore;
  final double averageAtsScore;
  final List<StudentMemberEntity> topStudents;

  const CollegeMetricsEntity({
    required this.totalStudents,
    required this.totalJobs,
    required this.totalInterviews,
    required this.totalApplications,
    required this.averageInterviewScore,
    required this.averageAtsScore,
    required this.topStudents,
  });

  @override
  List<Object?> get props => [
    totalStudents,
    totalJobs,
    totalInterviews,
    totalApplications,
    averageInterviewScore,
    averageAtsScore,
    topStudents,
  ];
}
