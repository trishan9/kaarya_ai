import 'package:flutter_riverpod/legacy.dart';

enum AppDestination {
  overview,
  explore,
  interviewHub,
  leaderboard,
  resumeBuilder,
}

final bottomNavProvider = StateProvider<AppDestination>(
  (ref) => AppDestination.overview,
);
