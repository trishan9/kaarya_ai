import 'package:flutter_riverpod/legacy.dart';

enum AppDestination {
  overview,
  explore,
  interviewHub,
  leaderboard,
  resumeBuilder,
}

/// Recruiter-specific bottom nav destinations.
enum RecruiterDestination {
  overview,
  companyJobs,
  postNewJob,
  interviewManagement,
  leaderboard,
  settings,
}

/// College-specific bottom nav destinations.
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

/// Recruiter bottom nav selection.
final recruiterNavProvider = StateProvider<RecruiterDestination>(
  (ref) => RecruiterDestination.overview,
);

/// College bottom nav selection.
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

/// Tracks the name of the currently active pushed page (e.g. 'resources').
/// Null when no extra page is on the stack.
final pushedPageProvider = StateProvider<String?>((ref) => null);
