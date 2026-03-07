import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be overridden in main.dart');
});

final userSessionServiceProvider = Provider<UserSessionService>((ref) {
  final prefs = ref.read(sharedPreferencesProvider);
  return UserSessionService(prefs: prefs);
});

class UserSessionService {
  final SharedPreferences _prefs;

  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyUserId = 'user_id';
  static const String _keyEmail = 'email';
  static const String _keyName = 'name';
  static const String _keyRole = 'role';
  static const String _keyProvider = 'provider';
  static const String _keyPhoto = 'photo';

  UserSessionService({required SharedPreferences prefs}) : _prefs = prefs;

  Future<void> saveUserSession({
    required String userId,
    String? email,
    String? name,
    String? role,
    String? provider,
    String? photo,
  }) async {
    await _prefs.setBool(_keyIsLoggedIn, true);
    await _prefs.setString(_keyUserId, userId);

    if (email != null) {
      await _prefs.setString(_keyEmail, email);
    }

    if (name != null) {
      await _prefs.setString(_keyName, name);
    }

    // Always update role - never leave stale value from previous session
    if (role != null && role.trim().isNotEmpty) {
      await _prefs.setString(_keyRole, role.trim());
    } else {
      await _prefs.remove(_keyRole);
    }

    if (provider != null) {
      await _prefs.setString(_keyProvider, provider);
    }

    if (photo != null) {
      await _prefs.setString(_keyPhoto, photo);
    }
  }

  bool isLoggedIn() {
    return _prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  String? getCurrentUserId() {
    return _prefs.getString(_keyUserId);
  }

  String? getCurrentUserEmail() {
    return _prefs.getString(_keyEmail);
  }

  String? getCurrentUserFullName() {
    return _prefs.getString(_keyName);
  }

  String? getCurrentUserProfilePicture() {
    return _prefs.getString(_keyPhoto);
  }

  String? getCurrentUserRole() {
    return _prefs.getString(_keyRole);
  }

  String? getCurrentUserProvider() {
    return _prefs.getString(_keyProvider);
  }

  Future<void> clearSession() async {
    await _prefs.remove(_keyIsLoggedIn);
    await _prefs.remove(_keyUserId);
    await _prefs.remove(_keyEmail);
    await _prefs.remove(_keyName);
    await _prefs.remove(_keyPhoto);
    await _prefs.remove(_keyRole);
    await _prefs.remove(_keyProvider);
  }
}
