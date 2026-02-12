import 'package:equatable/equatable.dart';
import 'package:kaarya/features/jobs/domain/entities/job_entity.dart';

class JobsSectionEntity extends Equatable {
  final String searchQuery;
  final String locationQuery;
  final JobsBucketEntity jobs;

  const JobsSectionEntity({
    required this.searchQuery,
    required this.locationQuery,
    required this.jobs,
  });

  @override
  List<Object?> get props => [searchQuery, locationQuery, jobs];
}

class JobsBucketEntity extends Equatable {
  final List<JobEntity> forYou;
  final List<JobEntity> trending;
  final List<JobEntity> newThisWeek;
  final List<JobEntity> remote;
  final List<JobEntity> urgent;

  const JobsBucketEntity({
    required this.forYou,
    required this.trending,
    required this.newThisWeek,
    required this.remote,
    required this.urgent,
  });

  @override
  List<Object?> get props => [forYou, trending, newThisWeek, remote, urgent];
}
