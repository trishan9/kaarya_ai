import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/core/api/api_client.dart';
import 'package:kaarya/core/api/api_endpoints.dart';
import 'package:kaarya/core/services/storage/token_service.dart';
import 'package:kaarya/core/services/storage/user_session_service.dart';
import 'package:kaarya/features/auth/data/datasources/auth_datasource.dart';
import 'package:kaarya/features/auth/data/models/auth_api_model.dart';

final authRemoteDataSourceProvider = Provider<IAuthRemoteDataSource>((ref) {
  return AuthRemoteDatasource(
    apiClient: ref.read(apiClientProvider),
    userSessionService: ref.read(userSessionServiceProvider),
    tokenService: ref.read(tokenServiceProvider),
  );
});

class AuthRemoteDatasource implements IAuthRemoteDataSource {
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
      final user = AuthApiModel.fromJson(data['user']);

      await _userSessionService.saveUserSession(
        userId: user.id!,
        email: user.email,
        name: user.name,
        role: user.role,
        provider: user.provider,
        photo: user.photo,
      );

      final token = response.data['data']['accessToken'];
      await _tokenService.saveToken(token);

      return user;
    }

    return null;
  }

  @override
  Future<AuthApiModel> registerUser(AuthApiModel user) async {
    final response = await _apiClient.post(
      ApiEndpoints.userSignup,
      data: user.toJson(),
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
      final response = await _apiClient.get(
        ApiEndpoints.me,
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      if (response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>;
        final currentUser = AuthApiModel.fromJson(data);

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
}
