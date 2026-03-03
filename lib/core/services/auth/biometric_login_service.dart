import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/core/services/storage/token_service.dart';
import 'package:local_auth/local_auth.dart';

final localAuthenticationProvider = Provider<LocalAuthentication>((ref) {
  return LocalAuthentication();
});

final biometricLoginServiceProvider = Provider<BiometricLoginService>((ref) {
  return BiometricLoginService(
    localAuth: ref.read(localAuthenticationProvider),
    secureStorage: ref.read(secureStorageProvider),
  );
});

class BiometricLoginAvailability {
  const BiometricLoginAvailability({
    required this.isDeviceSupported,
    required this.canCheckBiometrics,
    required this.hasSavedCredentials,
    required this.availableBiometrics,
    this.savedEmail,
  });

  final bool isDeviceSupported;
  final bool canCheckBiometrics;
  final bool hasSavedCredentials;
  final List<BiometricType> availableBiometrics;
  final String? savedEmail;

  bool get isReadyForLogin =>
      isDeviceSupported && canCheckBiometrics && hasSavedCredentials;
}

class SavedBiometricCredentials {
  const SavedBiometricCredentials({
    required this.email,
    required this.password,
  });

  final String email;
  final String password;
}

class BiometricLoginService {
  static const _emailKey = 'biometric_login_email';
  static const _passwordKey = 'biometric_login_password';

  final LocalAuthentication _localAuth;
  final FlutterSecureStorage _secureStorage;

  BiometricLoginService({
    required LocalAuthentication localAuth,
    required FlutterSecureStorage secureStorage,
  }) : _localAuth = localAuth,
       _secureStorage = secureStorage;

  Future<BiometricLoginAvailability> getAvailability() async {
    final isSupported = await _isDeviceSupported();
    final canCheck = await _canCheckBiometrics();
    final biometrics = canCheck
        ? await _safeAvailableBiometrics()
        : const <BiometricType>[];
    final email = await _secureStorage.read(key: _emailKey);
    final password = await _secureStorage.read(key: _passwordKey);
    final hasSavedCredentials =
        (email?.trim().isNotEmpty ?? false) &&
        (password?.trim().isNotEmpty ?? false);

    return BiometricLoginAvailability(
      isDeviceSupported: isSupported,
      canCheckBiometrics: canCheck && biometrics.isNotEmpty,
      hasSavedCredentials: hasSavedCredentials,
      availableBiometrics: biometrics,
      savedEmail: email?.trim().isNotEmpty == true ? email!.trim() : null,
    );
  }

  Future<void> saveCredentials({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim();
    final normalizedPassword = password.trim();
    if (normalizedEmail.isEmpty || normalizedPassword.isEmpty) return;

    await _secureStorage.write(key: _emailKey, value: normalizedEmail);
    await _secureStorage.write(key: _passwordKey, value: normalizedPassword);
  }

  Future<void> clearCredentials() async {
    await _secureStorage.delete(key: _emailKey);
    await _secureStorage.delete(key: _passwordKey);
  }

  Future<bool> authenticateForEnrollment() async {
    final availability = await getAvailability();
    if (!availability.isDeviceSupported || !availability.canCheckBiometrics) {
      return false;
    }

    try {
      return await _localAuth.authenticate(
        localizedReason: 'Confirm biometrics to enable fast sign in on Kaarya',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
          sensitiveTransaction: true,
        ),
      );
    } on PlatformException {
      return false;
    }
  }

  Future<SavedBiometricCredentials?> authenticateAndGetCredentials() async {
    final availability = await getAvailability();
    if (!availability.isReadyForLogin) {
      return null;
    }

    final didAuthenticate = await _authenticate();
    if (!didAuthenticate) {
      return null;
    }

    final email = await _secureStorage.read(key: _emailKey);
    final password = await _secureStorage.read(key: _passwordKey);
    if (email == null ||
        password == null ||
        email.trim().isEmpty ||
        password.trim().isEmpty) {
      return null;
    }

    return SavedBiometricCredentials(
      email: email.trim(),
      password: password.trim(),
    );
  }

  Future<bool> _authenticate() async {
    try {
      return await _localAuth.authenticate(
        localizedReason: 'Authenticate to sign in to Kaarya',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
          sensitiveTransaction: true,
        ),
      );
    } on PlatformException {
      return false;
    }
  }

  Future<bool> _isDeviceSupported() async {
    try {
      return await _localAuth.isDeviceSupported();
    } on PlatformException {
      return false;
    }
  }

  Future<bool> _canCheckBiometrics() async {
    try {
      return await _localAuth.canCheckBiometrics;
    } on PlatformException {
      return false;
    }
  }

  Future<List<BiometricType>> _safeAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } on PlatformException {
      return const [];
    }
  }
}
