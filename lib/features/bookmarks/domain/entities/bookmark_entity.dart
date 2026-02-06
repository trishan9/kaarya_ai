import 'package:equatable/equatable.dart';
import 'package:kaarya/features/interviews/domain/entities/interview_entity.dart';
import 'package:kaarya/features/jobs/domain/entities/job_entity.dart';

class BookmarksListEntity extends Equatable {
  final List<JobEntity> jobs;
  final List<InterviewEntity> interviews;
  final int totalSaved;
  final int bookmarkedJobs;
  final int savedInterviews;

  const BookmarksListEntity({
    required this.jobs,
    required this.interviews,
    required this.totalSaved,
    required this.bookmarkedJobs,
    required this.savedInterviews,
  });

  @override
  List<Object?> get props => [
    jobs,
    interviews,
    totalSaved,
    bookmarkedJobs,
    savedInterviews,
  ];
}
