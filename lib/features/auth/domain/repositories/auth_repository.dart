import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:kaarya/core/error/failures.dart';
import 'package:kaarya/features/auth/domain/entities/auth_entity.dart';
import 'package:kaarya/features/auth/domain/entities/linked_account_entity.dart';
import 'package:kaarya/features/auth/domain/entities/oauth_provider_status_entity.dart';

abstract interface class IAuthRepository {
  Future<Either<Failure, bool>> registerUser(AuthEntity user);
  Future<Either<Failure, AuthEntity>> loginUser(String email, String password);
  Future<Either<Failure, AuthEntity>> loginWithGoogle(String serverClientId);
  Future<Either<Failure, AuthEntity>> exchangeOAuthResult(String resultToken);
  Future<Either<Failure, OAuthProviderStatusEntity>> getOAuthProviderStatus(
    String provider,
  );
  Future<Either<Failure, bool>> logoutUser();
  Future<Either<Failure, AuthEntity>> getCurrentUser();
  Future<Either<Failure, AuthEntity>> updateProfile(
    String? name,
    String? email,
    File? photo,
    Map<String, dynamic>? candidateProfile,
  );
  Future<Either<Failure, bool>> changePassword(
    String currentPassword,
    String newPassword,
    String confirmNewPassword,
  );
  Future<Either<Failure, bool>> requestPasswordReset(String email);
  Future<Either<Failure, String>> verifyPasswordResetOtp(
    String email,
    String otp,
  );
  Future<Either<Failure, bool>> confirmPasswordReset(
    String token,
    String password,
    String confirmPassword,
  );
  Future<Either<Failure, List<LinkedAccountEntity>>> getLinkedAccounts();
  Future<Either<Failure, bool>> unlinkOAuth(String provider);
  Future<Either<Failure, String>> uploadCertification(String filePath);
}
