import 'dart:io';

import 'package:kaarya/core/api/api_endpoints.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/features/auth/domain/usecases/exchange_oauth_result_usecase.dart';
import 'package:kaarya/features/auth/domain/usecases/change_password_usecase.dart';
import 'package:kaarya/features/auth/domain/usecases/get_oauth_provider_status_usecase.dart';
import 'package:kaarya/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:kaarya/features/auth/domain/usecases/login_usecase.dart';
import 'package:kaarya/features/auth/domain/usecases/login_with_google_usecase.dart';
import 'package:kaarya/features/auth/domain/usecases/logout_usecase.dart';
import 'package:kaarya/features/auth/domain/usecases/register_usecase.dart';
import 'package:kaarya/features/auth/domain/usecases/update_profile_usecase.dart';
import 'package:kaarya/features/auth/presentation/state/auth_state.dart';

final authViewModelProvider = NotifierProvider<AuthViewModel, AuthState>(
  AuthViewModel.new,
);

class AuthViewModel extends Notifier<AuthState> {
  late final RegisterUseCase _registerUseCase;
  late final LoginUseCase _loginUseCase;
  late final GetCurrentUserUseCase _getCurrentUserUseCase;
  late final LogoutUseCase _logoutUseCase;
  late final UpdateProfileUsecase _updateProfileUsecase;
  late final ChangePasswordUseCase _changePasswordUseCase;
  late final GetOAuthProviderStatusUseCase _getOAuthProviderStatusUseCase;
  late final LoginWithGoogleUseCase _loginWithGoogleUseCase;
  late final ExchangeOAuthResultUseCase _exchangeOAuthResultUseCase;

  @override
  AuthState build() {
    _registerUseCase = ref.read(registerUseCaseProvider);
    _loginUseCase = ref.read(loginUseCaseProvider);
    _getCurrentUserUseCase = ref.read(getCurrentUserUseCaseProvider);
    _logoutUseCase = ref.read(logoutUseCaseProvider);
    _updateProfileUsecase = ref.read(updateProfileUseCaseProvider);
    _changePasswordUseCase = ref.read(changePasswordUseCaseProvider);
    _getOAuthProviderStatusUseCase = ref.read(
      getOAuthProviderStatusUseCaseProvider,
    );
    _loginWithGoogleUseCase = ref.read(loginWithGoogleUseCaseProvider);
    _exchangeOAuthResultUseCase = ref.read(exchangeOAuthResultUseCaseProvider);
    return const AuthState();
  }

  Future<void> registerUser({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
    required String role,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

    final result = await _registerUseCase(
      RegisterUseCaseParams(
        name: name,
        email: email,
        password: password,
        confirmPassword: confirmPassword,
        role: role,
      ),
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      ),
      (success) => state = state.copyWith(
        status: AuthStatus.registered,
        errorMessage: null,
      ),
    );
  }

  Future<void> loginUser({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

    final result = await _loginUseCase(
      LoginUseCaseParams(email: email, password: password),
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      ),
      (user) => state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
        errorMessage: null,
      ),
    );
  }

  Future<void> loginWithGoogle() async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

    final statusResult = await _getOAuthProviderStatusUseCase(
      const GetOAuthProviderStatusParams(provider: 'google'),
    );

    await statusResult.fold(
      (failure) async {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.message,
        );
      },
      (status) async {
        final serverClientId = status.serverClientId?.trim();
        if (!status.enabled ||
            serverClientId == null ||
            serverClientId.isEmpty) {
          state = state.copyWith(
            status: AuthStatus.error,
            errorMessage: 'Google login is not configured on the server.',
          );
          return;
        }

        final result = await _loginWithGoogleUseCase(
          LoginWithGoogleUseCaseParams(serverClientId: serverClientId),
        );

        result.fold(
          (failure) => state = state.copyWith(
            status: AuthStatus.error,
            errorMessage: failure.message,
          ),
          (user) => state = state.copyWith(
            status: AuthStatus.authenticated,
            user: user,
            errorMessage: null,
          ),
        );
      },
    );
  }

  Future<String?> prepareOAuthLogin(String provider) async {
    final normalizedProvider = provider.trim().toLowerCase();
    if (normalizedProvider.isEmpty) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'OAuth provider is required.',
      );
      return null;
    }

    final statusResult = await _getOAuthProviderStatusUseCase(
      GetOAuthProviderStatusParams(provider: normalizedProvider),
    );

    return await statusResult.fold(
      (failure) async {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.message,
        );
        return null;
      },
      (status) async {
        if (!status.enabled) {
          state = state.copyWith(
            status: AuthStatus.error,
            errorMessage:
                '${_formatProviderName(normalizedProvider)} login is not configured on the server.',
          );
          return null;
        }

        state = state.copyWith(errorMessage: null);
        return ApiEndpoints.oauthAuthorizeUrl(
          normalizedProvider,
          redirectUri: ApiEndpoints.oauthRedirectUri(normalizedProvider),
        );
      },
    );
  }

  Future<void> completeOAuthLogin(String resultToken) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

    final result = await _exchangeOAuthResultUseCase(
      ExchangeOAuthResultUseCaseParams(resultToken: resultToken),
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      ),
      (user) => state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
        errorMessage: null,
      ),
    );
  }

  Future<void> getCurrentUser() async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

    final result = await _getCurrentUserUseCase();

    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: failure.message,
      ),
      (user) => state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
        errorMessage: null,
      ),
    );
  }

  Future<void> logoutUser() async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

    final result = await _logoutUseCase();

    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      ),
      (success) => state = state.copyWith(
        status: AuthStatus.unauthenticated,
        user: null,
        errorMessage: null,
      ),
    );
  }

  Future<void> updateProfile({
    String? name,
    String? email,
    File? photo,
    Map<String, dynamic>? candidateProfile,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

    final result = await _updateProfileUsecase(
      UpdateProfileUsecaseParams(
        name: name,
        email: email,
        photo: photo,
        candidateProfile: candidateProfile,
      ),
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      ),
      (success) => state = state.copyWith(
        status: AuthStatus.updated,
        errorMessage: null,
      ),
    );
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmNewPassword,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

    final result = await _changePasswordUseCase(
      ChangePasswordParams(
        currentPassword: currentPassword,
        newPassword: newPassword,
        confirmNewPassword: confirmNewPassword,
      ),
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      ),
      (success) => state = state.copyWith(
        status: AuthStatus.passwordChanged,
        errorMessage: null,
      ),
    );
  }

  void resetState() {
    state = const AuthState(status: AuthStatus.initial, errorMessage: null);
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  String _formatProviderName(String provider) {
    switch (provider) {
      case 'google':
        return 'Google';
      case 'github':
        return 'GitHub';
      default:
        return provider;
    }
  }
}
