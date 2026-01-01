import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:kaarya/features/auth/domain/usecases/login_usecase.dart';
import 'package:kaarya/features/auth/domain/usecases/logout_usecase.dart';
import 'package:kaarya/features/auth/domain/usecases/register_usecase.dart';
import 'package:kaarya/features/auth/presentation/state/auth_state.dart';

final authViewModelProvider = NotifierProvider<AuthViewModel, AuthState>(
  AuthViewModel.new,
);

class AuthViewModel extends Notifier<AuthState> {
  late final RegisterUseCase _registerUseCase;
  late final LoginUseCase _loginUseCase;
  late final GetCurrentUserUseCase _getCurrentUserUseCase;
  late final LogoutUseCase _logoutUseCase;

  @override
  AuthState build() {
    _registerUseCase = ref.read(registerUseCaseProvider);
    _loginUseCase = ref.read(loginUseCaseProvider);
    _getCurrentUserUseCase = ref.read(getCurrentUserUseCaseProvider);
    _logoutUseCase = ref.read(logoutUseCaseProvider);
    return const AuthState();
  }

  Future<void> registerUser({
    required String fullName,
    required String email,
    required String username,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

    await Future.delayed(Duration(seconds: 2));

    final result = await _registerUseCase(
      RegisterUseCaseParams(
        fullName: fullName,
        email: email,
        username: username,
        password: password,
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

  void resetState() {
    state = const AuthState(status: AuthStatus.initial, errorMessage: null);
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}
