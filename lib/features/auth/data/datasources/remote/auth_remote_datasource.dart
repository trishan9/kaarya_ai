import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kaarya/core/api/api_client.dart';
import 'package:kaarya/core/api/api_endpoints.dart';
import 'package:kaarya/core/services/storage/token_service.dart';
import 'package:kaarya/core/services/storage/user_session_service.dart';
import 'package:kaarya/features/auth/data/datasources/auth_datasource.dart';
import 'package:kaarya/features/auth/data/models/auth_api_model.dart';
import 'package:kaarya/features/auth/data/models/linked_account_api_model.dart';
import 'package:kaarya/features/auth/data/models/oauth_provider_status_api_model.dart';

final authRemoteDataSourceProvider = Provider<IAuthRemoteDataSource>((ref) {
  return AuthRemoteDatasource(
    apiClient: ref.read(apiClientProvider),
    userSessionService: ref.read(userSessionServiceProvider),
    tokenService: ref.read(tokenServiceProvider),
  );
});

class AuthRemoteDatasource implements IAuthRemoteDataSource {
  static const Map<String, dynamic> _passwordResetHeaders = {
    'x-client-user-agent': 'kaarya-flutter',
    'x-request-source': 'flutter-app',
  };
  static final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  static bool _googleInitialized = false;
  static String? _googleServerClientId;

  final ApiClient _apiClient;
  final UserSessionService _userSessionService;
  final TokenService _tokenService;

  AuthRemoteDatasource({
    required ApiClient apiClient,
    required UserSessionService userSessionService,
    required TokenService tokenService,
  }) : _apiClient = apiClient,
       _userSessionService = userSessionService,
       _tokenService = tokenService;

  @override
  Future<AuthApiModel?> loginUser(String email, String password) async {
    final response = await _apiClient.post(
      ApiEndpoints.userLogin,
      data: {'email': email, 'password': password},
    );

    if (response.data['success'] == true) {
      final data = response.data['data'] as Map<String, dynamic>;
      final token = _extractAccessToken(data);
      if (token == null || token.isEmpty) {
        await _userSessionService.clearSession();
        await _tokenService.removeToken();
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Login succeeded but access token is missing.',
        );
      }

      final userData = data['user'] as Map<String, dynamic>? ?? data;
      final user = AuthApiModel.fromJson(userData);

      await _userSessionService.clearSession();
      await _tokenService.saveToken(token);
      await _userSessionService.saveUserSession(
        userId: user.id!,
        email: user.email,
        name: user.name,
        role: user.role,
        provider: user.provider,
        photo: user.photo,
      );

      return user;
    }

    return null;
  }

  @override
  Future<AuthApiModel?> loginWithGoogle(String serverClientId) async {
    await _initializeGoogleSignIn(serverClientId);

    if (!_googleSignIn.supportsAuthenticate()) {
      throw const OAuthAuthenticationException(
        'Google login is not supported on this platform.',
      );
    }

    await _googleSignIn.signOut();

    GoogleSignInAccount account;
    try {
      account = await _googleSignIn.authenticate();
    } on GoogleSignInException catch (error) {
      throw OAuthAuthenticationException(_mapGoogleSignInError(error));
    }

    final idToken = account.authentication.idToken?.trim();
    if (idToken == null || idToken.isEmpty) {
      throw const OAuthAuthenticationException(
        'Google did not return an ID token.',
      );
    }

    final response = await _apiClient.post(
      ApiEndpoints.googleMobileLogin,
      data: {'idToken': idToken},
    );

    return _consumeOAuthAuthenticationResponse(response);
  }

  @override
  Future<AuthApiModel?> exchangeOAuthResult(String resultToken) async {
    final response = await _apiClient.post(
      ApiEndpoints.oauthExchange,
      data: {'resultToken': resultToken},
    );

    return _consumeOAuthAuthenticationResponse(response);
  }

  @override
  Future<OAuthProviderStatusApiModel> getOAuthProviderStatus(
    String provider,
  ) async {
    final response = await _apiClient.get(ApiEndpoints.oauthStatus(provider));
    if (response.data['success'] == true) {
      final data = response.data['data'] as Map<String, dynamic>? ?? const {};
      return OAuthProviderStatusApiModel.fromJson(data);
    }

    throw DioException(
      requestOptions: response.requestOptions,
      response: response,
      message: 'Unable to fetch social login status.',
    );
  }

  @override
  Future<AuthApiModel> registerUser(AuthApiModel user) async {
    final payload = Map<String, dynamic>.from(user.toJson())
      ..removeWhere((key, value) => value == null);

    final response = await _apiClient.post(
      ApiEndpoints.userSignup,
      data: payload,
    );

    if (response.data['success'] == true) {
      final data = response.data['data'] as Map<String, dynamic>;
      final registeredUser = AuthApiModel.fromJson(data);
      return registeredUser;
    }

    return user;
  }

  @override
  Future<bool> logoutUser() async {
    try {
      await _userSessionService.clearSession();
      await _tokenService.removeToken();
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<AuthApiModel?> getCurrentUser() async {
    try {
      if (!_userSessionService.isLoggedIn()) {
        return null;
      }

      final userId = _userSessionService.getCurrentUserId();
      if (userId == null) {
        return null;
      }

      final token = await _tokenService.getToken();
      if (token == null || token.trim().isEmpty) {
        await _userSessionService.clearSession();
        await _tokenService.removeToken();
        return null;
      }
      final response = await _apiClient.get(
        ApiEndpoints.me,
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      if (response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>;
        final userData = data['user'] as Map<String, dynamic>? ?? data;
        final currentUser = AuthApiModel.fromJson(userData);

        await _userSessionService.saveUserSession(
          userId: currentUser.id!,
          email: currentUser.email,
          name: currentUser.name,
          role: currentUser.role,
          provider: currentUser.provider,
          photo: currentUser.photo,
        );

        return currentUser;
      }

      return null;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<AuthApiModel?> updateProfile(
    String? name,
    String? email,
    File? photo,
    Map<String, dynamic>? candidateProfile,
  ) async {
    if (!_userSessionService.isLoggedIn()) {
      return null;
    }

    final token = await _tokenService.getToken();
    if (token == null || token.trim().isEmpty) {
      await _userSessionService.clearSession();
      await _tokenService.removeToken();
      return null;
    }

    final Map<String, dynamic> data = {};
    if (name != null) {
      data["name"] = name;
    }
    if (email != null) {
      data["email"] = email;
    }
    if (photo != null) {
      data["photo"] = await MultipartFile.fromFile(photo.path);
    }
    if (candidateProfile != null && candidateProfile.isNotEmpty) {
      data["candidateProfile"] = jsonEncode(candidateProfile);
    }

    if (data.isEmpty) {
      return getCurrentUser();
    }

    final formData = FormData.fromMap(data);

    final response = await _apiClient.put(
      ApiEndpoints.updateProfile,
      data: formData,
      options: Options(
        headers: {"Authorization": "Bearer $token"},
        contentType: "multipart/form-data",
      ),
    );

    if (response.data['success'] == true) {
      final data = response.data['data'] as Map<String, dynamic>;
      final user = AuthApiModel.fromJson(data);

      await _userSessionService.saveUserSession(
        userId: user.id!,
        email: user.email,
        name: user.name,
        role: user.role,
        provider: user.provider,
        photo: user.photo,
      );

      return user;
    }

    return null;
  }

  @override
  Future<bool> changePassword(
    String currentPassword,
    String newPassword,
    String confirmNewPassword,
  ) async {
    final response = await _apiClient.post(
      ApiEndpoints.changePassword,
      data: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
        'confirmNewPassword': confirmNewPassword,
      },
    );
    return response.data['success'] == true;
  }

  @override
  Future<bool> requestPasswordReset(String email) async {
    final response = await _postPasswordResetWithRetry(
      ApiEndpoints.requestPasswordReset,
      data: {'email': email},
    );
    return response.data['success'] == true;
  }

  @override
  Future<String> verifyPasswordResetOtp(String email, String otp) async {
    final response = await _postPasswordResetWithRetry(
      ApiEndpoints.verifyPasswordResetOtp,
      data: {'email': email, 'otp': otp},
    );
    if (response.data['success'] == true) {
      final data = response.data['data'] as Map<String, dynamic>? ?? const {};
      return data['resetToken'] as String? ?? data['token'] as String? ?? '';
    }
    return '';
  }

  @override
  Future<bool> confirmPasswordReset(
    String token,
    String password,
    String confirmPassword,
  ) async {
    final response = await _postPasswordResetWithRetry(
      ApiEndpoints.confirmPasswordReset,
      data: {
        'token': token,
        'password': password,
        'confirmPassword': confirmPassword,
      },
    );
    return response.data['success'] == true;
  }

  @override
  Future<List<LinkedAccountApiModel>> getLinkedAccounts() async {
    final response = await _apiClient.get(ApiEndpoints.linkedAccounts);
    if (response.data['success'] == true) {
      final data = response.data['data'] as List<dynamic>? ?? [];
      return LinkedAccountApiModel.fromApiList(data);
    }
    return [];
  }

  @override
  Future<bool> unlinkOAuth(String provider) async {
    final response = await _apiClient.delete(
      ApiEndpoints.oauthUnlink(provider),
    );
    return response.data['success'] == true;
  }

  @override
  Future<String> uploadCertification(String filePath) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath),
    });
    final response = await _apiClient.post(
      ApiEndpoints.uploadCertification,
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );
    if (response.data['success'] == true) {
      final data = response.data['data'] as Map<String, dynamic>?;
      return data?['url'] as String? ?? '';
    }
    return '';
  }

  Future<void> _initializeGoogleSignIn(String serverClientId) async {
    final normalizedClientId = serverClientId.trim();
    if (normalizedClientId.isEmpty) {
      throw const OAuthAuthenticationException(
        'Google login is not configured on the server.',
      );
    }

    if (_googleInitialized && _googleServerClientId == normalizedClientId) {
      return;
    }

    if (_googleInitialized && _googleServerClientId != normalizedClientId) {
      throw const OAuthAuthenticationException(
        'Google login client configuration changed. Restart the app and try again.',
      );
    }

    await _googleSignIn.initialize(serverClientId: normalizedClientId);
    _googleInitialized = true;
    _googleServerClientId = normalizedClientId;
  }

  String? _extractAccessToken(Map<String, dynamic> data) {
    final candidates = <dynamic>[
      data['accessToken'],
      data['token'],
      data['jwt'],
      data['access_token'],
      (data['tokens'] is Map<String, dynamic>)
          ? (data['tokens'] as Map<String, dynamic>)['accessToken']
          : null,
    ];

    for (final candidate in candidates) {
      if (candidate is String && candidate.trim().isNotEmpty) {
        return candidate.trim();
      }
    }

    return null;
  }

  Future<AuthApiModel?> _consumeOAuthAuthenticationResponse(
    Response<dynamic> response,
  ) async {
    if (response.data['success'] != true) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: 'Social login failed.',
      );
    }

    final data = response.data['data'] as Map<String, dynamic>? ?? const {};
    final status = (data['status'] as String? ?? '').trim().toLowerCase();

    if (status != 'authenticated') {
      final message = (data['message'] as String?)?.trim().isNotEmpty == true
          ? (data['message'] as String).trim()
          : 'Social login failed.';
      throw OAuthAuthenticationException(message);
    }

    final token = _extractAccessToken(data);
    if (token == null || token.isEmpty) {
      await _userSessionService.clearSession();
      await _tokenService.removeToken();
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: 'Social login succeeded but access token is missing.',
      );
    }

    final userData = data['user'] as Map<String, dynamic>? ?? data;
    final user = AuthApiModel.fromJson(userData);

    if (user.id == null || user.id!.trim().isEmpty) {
      throw const OAuthAuthenticationException(
        'Social login succeeded but user details are incomplete.',
      );
    }

    await _userSessionService.clearSession();
    await _tokenService.saveToken(token);
    await _userSessionService.saveUserSession(
      userId: user.id!,
      email: user.email,
      name: user.name,
      role: user.role,
      provider: user.provider,
      photo: user.photo,
    );

    return user;
  }

  String _mapGoogleSignInError(GoogleSignInException error) {
    switch (error.code) {
      case GoogleSignInExceptionCode.canceled:
      case GoogleSignInExceptionCode.interrupted:
        return 'Google sign-in was cancelled.';
      case GoogleSignInExceptionCode.clientConfigurationError:
        return 'Google sign-in is not configured correctly for this app.';
      case GoogleSignInExceptionCode.uiUnavailable:
        return 'Google sign-in is unavailable right now.';
      default:
        return error.description?.trim().isNotEmpty == true
            ? error.description!.trim()
            : 'Google sign-in failed.';
    }
  }

  Future<Response<dynamic>> _postPasswordResetWithRetry(
    String path, {
    required Map<String, dynamic> data,
  }) async {
    try {
      return await _apiClient.post(
        path,
        data: data,
        options: Options(headers: _passwordResetHeaders),
      );
    } on DioException catch (error) {
      if (!_shouldRetryPasswordReset(error)) {
        rethrow;
      }

      await Future<void>.delayed(const Duration(milliseconds: 700));

      return _apiClient.post(
        path,
        data: data,
        options: Options(headers: _passwordResetHeaders),
      );
    }
  }

  bool _shouldRetryPasswordReset(DioException error) {
    final statusCode = error.response?.statusCode ?? 0;
    if (statusCode >= 500 && statusCode < 600) {
      return true;
    }

    return error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.connectionError;
  }
}

class OAuthAuthenticationException implements Exception {
  const OAuthAuthenticationException(this.message);

  final String message;

  @override
  String toString() => message;
}
