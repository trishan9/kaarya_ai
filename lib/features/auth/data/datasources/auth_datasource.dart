import 'dart:io';

import 'package:kaarya/features/auth/data/models/auth_api_model.dart';
import 'package:kaarya/features/auth/data/models/auth_hive_model.dart';
import 'package:kaarya/features/auth/data/models/linked_account_api_model.dart';
import 'package:kaarya/features/auth/data/models/oauth_provider_status_api_model.dart';

abstract interface class IAuthLocalDataSource {
  Future<AuthHiveModel> registerUser(AuthHiveModel user);
  Future<AuthHiveModel?> loginUser(String email, String password);
  Future<AuthHiveModel?> getCurrentUser();
  Future<bool> logoutUser();

  Future<AuthHiveModel?> getUserById(String authId);
  Future<AuthHiveModel?> getUserByEmail(String email);
  Future<bool> deleteUser(String authId);
}

abstract interface class IAuthRemoteDataSource {
  Future<AuthApiModel> registerUser(AuthApiModel user);
  Future<AuthApiModel?> loginUser(String email, String password);
  Future<AuthApiModel?> loginWithGoogle(String serverClientId);
  Future<AuthApiModel?> exchangeOAuthResult(String resultToken);
  Future<OAuthProviderStatusApiModel> getOAuthProviderStatus(String provider);
  Future<AuthApiModel?> getCurrentUser();
  Future<bool> logoutUser();

  Future<AuthApiModel?> updateProfile(
    String? name,
    String? email,
    File? photo,
    Map<String, dynamic>? candidateProfile,
  );
  Future<bool> changePassword(
    String currentPassword,
    String newPassword,
    String confirmNewPassword,
  );
  Future<bool> requestPasswordReset(String email);
  Future<String> verifyPasswordResetOtp(String email, String otp);
  Future<bool> confirmPasswordReset(
    String token,
    String password,
    String confirmPassword,
  );
  Future<List<LinkedAccountApiModel>> getLinkedAccounts();
  Future<bool> unlinkOAuth(String provider);
  Future<String> uploadCertification(String filePath);
}
