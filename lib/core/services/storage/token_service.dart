import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kaarya/core/services/storage/user_session_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

final tokenServiceProvider = Provider<TokenService>((ref) {
  return TokenService(
    secureStorage: ref.read(secureStorageProvider),
    prefs: ref.read(sharedPreferencesProvider),
  );
});

class TokenService {
  static const String _tokenKey = 'auth_token';

  final FlutterSecureStorage _secureStorage;
  final SharedPreferences _prefs;

  TokenService({
    required FlutterSecureStorage secureStorage,
    required SharedPreferences prefs,
  }) : _secureStorage = secureStorage,
       _prefs = prefs;

  Future<void> saveToken(String token) async {
    final normalized = token.trim();
    if (normalized.isEmpty) return;

    await _secureStorage.write(key: _tokenKey, value: normalized);
    await _prefs.remove(_tokenKey);
  }

  Future<String?> getToken() async {
    final secureToken = await _secureStorage.read(key: _tokenKey);
    if (secureToken != null && secureToken.trim().isNotEmpty) {
      return secureToken;
    }

    final legacyToken = _prefs.getString(_tokenKey);
    if (legacyToken != null && legacyToken.trim().isNotEmpty) {
      await _secureStorage.write(key: _tokenKey, value: legacyToken.trim());
      await _prefs.remove(_tokenKey);
      return legacyToken.trim();
    }

    return null;
  }

  Future<void> removeToken() async {
    await _secureStorage.delete(key: _tokenKey);
    await _prefs.remove(_tokenKey);
  }
}
