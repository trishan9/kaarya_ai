import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/core/services/storage/user_session_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

final tokenServiceProvider = Provider<TokenService>((ref) {
  return TokenService(prefs: ref.read(sharedPreferencesProvider));
});

class TokenService {
  static const String _tokenKey = 'auth_token';
  final SharedPreferences _prefs;

  TokenService({required SharedPreferences prefs}) : _prefs = prefs;

  Future<void> saveToken(String token) async {
    if (token.trim().isEmpty) return;
    await _prefs.setString(_tokenKey, token);
  }

  Future<String?> getToken() async {
    final primary = _prefs.getString(_tokenKey);
    if (primary != null && primary.trim().isNotEmpty) {
      return primary;
    }

    return null;
  }

  Future<void> removeToken() async {
    await _prefs.remove(_tokenKey);
  }
}
