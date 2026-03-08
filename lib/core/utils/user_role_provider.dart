import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/core/services/storage/user_session_service.dart';

final isRecruiterProvider = Provider<bool>((ref) {
  final session = ref.watch(userSessionServiceProvider);
  final role = session.getCurrentUserRole();
  if (role == null || role.trim().isEmpty) return false;
  return role.trim().toLowerCase() == 'recruiter';
});

final isCollegeProvider = Provider<bool>((ref) {
  final session = ref.watch(userSessionServiceProvider);
  final role = session.getCurrentUserRole();
  if (role == null || role.trim().isEmpty) return false;
  return role.trim().toLowerCase() == 'college';
});
