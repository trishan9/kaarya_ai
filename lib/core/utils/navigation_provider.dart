import 'package:flutter_riverpod/legacy.dart';

enum AppDestination {
  overview,
  explore,
  interviewHub,
  leaderboard,
  resumeBuilder,
}

enum RecruiterDestination {
  overview,
  companyJobs,
  postNewJob,
  interviewManagement,
  leaderboard,
  settings,
}

enum CollegeDestination {
  overview,
  collegeJobs,
  postNewJob,
  interviewManagement,
  createInterview,
  leaderboard,
  collegeSettings,
}

final bottomNavProvider = StateProvider<AppDestination>(
  (ref) => AppDestination.overview,
);

final recruiterNavProvider = StateProvider<RecruiterDestination>(
  (ref) => RecruiterDestination.overview,
);

final collegeNavProvider = StateProvider<CollegeDestination>(
  (ref) => CollegeDestination.overview,
);

abstract final class PushedPageKeys {
  static const resources = 'resources';
  static const inbox = 'inbox';
  static const billing = 'billing';
  static const settings = 'settings';
  static const myApplications = 'myApplications';
  static const myInterviews = 'myInterviews';
  static const saved = 'saved';
  static const postNewJob = 'postNewJob';
  static const interviewManagement = 'interviewManagement';
}

final pushedPageProvider = StateProvider<String?>((ref) => null);
