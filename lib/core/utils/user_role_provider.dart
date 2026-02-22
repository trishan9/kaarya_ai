import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/core/services/storage/user_session_service.dart';

/// Provider that returns true if the current user has recruiter role.
/// Handles various API formats: "recruiter", "RECRUITER", "Recruiter", etc.
final isRecruiterProvider = Provider<bool>((ref) {
  final session = ref.watch(userSessionServiceProvider);
  final role = session.getCurrentUserRole();
  if (role == null || role.trim().isEmpty) return false;
  return role.trim().toLowerCase() == 'recruiter';
});
