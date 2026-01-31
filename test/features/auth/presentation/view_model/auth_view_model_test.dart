import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaarya/core/error/failures.dart';
import 'package:kaarya/features/auth/domain/entities/auth_entity.dart';
import 'package:kaarya/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:kaarya/features/auth/domain/usecases/login_usecase.dart';
import 'package:kaarya/features/auth/domain/usecases/logout_usecase.dart';
import 'package:kaarya/features/auth/domain/usecases/register_usecase.dart';
import 'package:kaarya/features/auth/domain/usecases/update_profile_usecase.dart';
import 'package:kaarya/features/auth/presentation/state/auth_state.dart';
import 'package:kaarya/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:mocktail/mocktail.dart';

class MockRegisterUseCase extends Mock implements RegisterUseCase {}

class MockLoginUseCase extends Mock implements LoginUseCase {}

class MockGetCurrentUserUseCase extends Mock implements GetCurrentUserUseCase {}

class MockLogoutUseCase extends Mock implements LogoutUseCase {}

class MockUpdateProfileUsecase extends Mock implements UpdateProfileUsecase {}

void main() {
  late MockRegisterUseCase mockRegisterUseCase;
  late MockLoginUseCase mockLoginUseCase;
  late MockGetCurrentUserUseCase mockGetCurrentUserUseCase;
  late MockLogoutUseCase mockLogoutUseCase;
  late MockUpdateProfileUsecase mockUpdateProfileUsecase;
  late ProviderContainer container;

  setUpAll(() {
    registerFallbackValue(
      const RegisterUseCaseParams(
        name: 'fallback',
        email: 'fallback@email.com',
        password: 'fallback',
      ),
    );
    registerFallbackValue(
      const LoginUseCaseParams(
        email: 'fallback@email.com',
        password: 'fallback',
      ),
    );
    registerFallbackValue(const UpdateProfileUsecaseParams());
  });

  setUp(() {
    mockRegisterUseCase = MockRegisterUseCase();
    mockLoginUseCase = MockLoginUseCase();
    mockGetCurrentUserUseCase = MockGetCurrentUserUseCase();
    mockLogoutUseCase = MockLogoutUseCase();
    mockUpdateProfileUsecase = MockUpdateProfileUsecase();

    container = ProviderContainer(
      overrides: [
        registerUseCaseProvider.overrideWithValue(mockRegisterUseCase),
        loginUseCaseProvider.overrideWithValue(mockLoginUseCase),
        getCurrentUserUseCaseProvider.overrideWithValue(
          mockGetCurrentUserUseCase,
        ),
        logoutUseCaseProvider.overrideWithValue(mockLogoutUseCase),
        updateProfileUseCaseProvider.overrideWithValue(
          mockUpdateProfileUsecase,
        ),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  const tEmail = 'test@example.com';
  const tPassword = 'password123';
  const tName = 'Test User';
  const tUser = AuthEntity(
    authId: '1',
    name: tName,
    email: tEmail,
    provider: 'email',
    role: 'user',
    profilePicture: 'https://example.com/pic.jpg',
  );
  final tPhoto = File('test_assets/profile.png');

  group('AuthViewModel', () {
    group('Initial state', () {
      test('Should have initial state when created', () {
        final state = container.read(authViewModelProvider);

        expect(state.status, AuthStatus.initial);
        expect(state.user, isNull);
        expect(state.errorMessage, isNull);
      });
    });

    group('registerUser', () {
      test(
        'Should emit registered state when registration is successful',
        () async {
          when(
            () => mockRegisterUseCase(any()),
          ).thenAnswer((_) async => const Right(true));

          final viewModel = container.read(authViewModelProvider.notifier);

          await viewModel.registerUser(
            name: tName,
            email: tEmail,
            password: tPassword,
          );

          final state = container.read(authViewModelProvider);
          expect(state.status, AuthStatus.registered);
          expect(state.errorMessage, isNull);
          verify(() => mockRegisterUseCase(any())).called(1);
        },
      );

      test('Should emit error state when registration fails', () async {
        const failure = ApiFailure(message: 'Email already exists');
        when(
          () => mockRegisterUseCase(any()),
        ).thenAnswer((_) async => const Left(failure));

        final viewModel = container.read(authViewModelProvider.notifier);

        await viewModel.registerUser(
          name: tName,
          email: tEmail,
          password: tPassword,
        );

        final state = container.read(authViewModelProvider);
        expect(state.status, AuthStatus.error);
        expect(state.errorMessage, 'Email already exists');
        verify(() => mockRegisterUseCase(any())).called(1);
      });

      test('Should pass correct params to usecase', () async {
        RegisterUseCaseParams? capturedParams;
        when(() => mockRegisterUseCase(any())).thenAnswer((invocation) {
          capturedParams =
              invocation.positionalArguments[0] as RegisterUseCaseParams;
          return Future.value(const Right(true));
        });

        final viewModel = container.read(authViewModelProvider.notifier);

        await viewModel.registerUser(
          name: tName,
          email: tEmail,
          password: tPassword,
        );

        expect(capturedParams?.name, tName);
        expect(capturedParams?.email, tEmail);
        expect(capturedParams?.password, tPassword);
      });
    });

    group('loginUser', () {
      test(
        'Should emit authenticated state with user when login is successful',
        () async {
          when(
            () => mockLoginUseCase(any()),
          ).thenAnswer((_) async => const Right(tUser));

          final viewModel = container.read(authViewModelProvider.notifier);

          await viewModel.loginUser(email: tEmail, password: tPassword);

          final state = container.read(authViewModelProvider);
          expect(state.status, AuthStatus.authenticated);
          expect(state.user, tUser);
          verify(() => mockLoginUseCase(any())).called(1);
        },
      );

      test('Should emit error state when login fails', () async {
        const failure = ApiFailure(message: 'Invalid credentials');
        when(
          () => mockLoginUseCase(any()),
        ).thenAnswer((_) async => const Left(failure));

        final viewModel = container.read(authViewModelProvider.notifier);

        await viewModel.loginUser(email: tEmail, password: tPassword);

        final state = container.read(authViewModelProvider);
        expect(state.status, AuthStatus.error);
        expect(state.errorMessage, 'Invalid credentials');
        verify(() => mockLoginUseCase(any())).called(1);
      });

      test('Should pass correct credentials to usecase', () async {
        LoginUseCaseParams? capturedParams;
        when(() => mockLoginUseCase(any())).thenAnswer((invocation) {
          capturedParams =
              invocation.positionalArguments[0] as LoginUseCaseParams;
          return Future.value(const Right(tUser));
        });

        final viewModel = container.read(authViewModelProvider.notifier);

        await viewModel.loginUser(email: tEmail, password: tPassword);

        expect(capturedParams?.email, tEmail);
        expect(capturedParams?.password, tPassword);
      });
    });

    group('getCurrentUser', () {
      test(
        'Should emit authenticated state with user when user is found',
        () async {
          when(
            () => mockGetCurrentUserUseCase(),
          ).thenAnswer((_) async => const Right(tUser));

          final viewModel = container.read(authViewModelProvider.notifier);

          await viewModel.getCurrentUser();

          final state = container.read(authViewModelProvider);
          expect(state.status, AuthStatus.authenticated);
          expect(state.user, tUser);
          verify(() => mockGetCurrentUserUseCase()).called(1);
        },
      );

      test(
        'Should emit unauthenticated state when user is not found',
        () async {
          const failure = ApiFailure(message: 'User not found');
          when(
            () => mockGetCurrentUserUseCase(),
          ).thenAnswer((_) async => const Left(failure));

          final viewModel = container.read(authViewModelProvider.notifier);

          await viewModel.getCurrentUser();

          final state = container.read(authViewModelProvider);
          expect(state.status, AuthStatus.unauthenticated);
          expect(state.errorMessage, 'User not found');
          verify(() => mockGetCurrentUserUseCase()).called(1);
        },
      );
    });

    group('logoutUser', () {
      test(
        'Should emit unauthenticated state with null user when successful',
        () async {
          when(
            () => mockLogoutUseCase(),
          ).thenAnswer((_) async => const Right(true));

          final viewModel = container.read(authViewModelProvider.notifier);

          await viewModel.logoutUser();

          final state = container.read(authViewModelProvider);
          expect(state.status, AuthStatus.unauthenticated);
          expect(state.user, isNull);
          verify(() => mockLogoutUseCase()).called(1);
        },
      );

      test('Should emit error state when logout fails', () async {
        const failure = ApiFailure(message: 'Logout failed');
        when(
          () => mockLogoutUseCase(),
        ).thenAnswer((_) async => const Left(failure));

        final viewModel = container.read(authViewModelProvider.notifier);

        await viewModel.logoutUser();

        final state = container.read(authViewModelProvider);
        expect(state.status, AuthStatus.error);
        expect(state.errorMessage, 'Logout failed');
        verify(() => mockLogoutUseCase()).called(1);
      });
    });

    group('updateProfile', () {
      test('Should emit updated state when update is successful', () async {
        when(
          () => mockUpdateProfileUsecase(any()),
        ).thenAnswer((_) async => const Right(tUser));

        final viewModel = container.read(authViewModelProvider.notifier);

        await viewModel.updateProfile(
          name: tName,
          email: tEmail,
          photo: tPhoto,
        );

        final state = container.read(authViewModelProvider);
        expect(state.status, AuthStatus.updated);
        verify(() => mockUpdateProfileUsecase(any())).called(1);
      });

      test('Should emit error state when update fails', () async {
        const failure = ApiFailure(message: 'Update failed');
        when(
          () => mockUpdateProfileUsecase(any()),
        ).thenAnswer((_) async => const Left(failure));

        final viewModel = container.read(authViewModelProvider.notifier);

        await viewModel.updateProfile(
          name: tName,
          email: tEmail,
          photo: tPhoto,
        );

        final state = container.read(authViewModelProvider);
        expect(state.status, AuthStatus.error);
        expect(state.errorMessage, 'Update failed');
        verify(() => mockUpdateProfileUsecase(any())).called(1);
      });

      test('Should pass correct params to usecase', () async {
        UpdateProfileUsecaseParams? capturedParams;
        when(() => mockUpdateProfileUsecase(any())).thenAnswer((invocation) {
          capturedParams =
              invocation.positionalArguments[0] as UpdateProfileUsecaseParams;
          return Future.value(const Right(tUser));
        });

        final viewModel = container.read(authViewModelProvider.notifier);

        await viewModel.updateProfile(
          name: tName,
          email: tEmail,
          photo: tPhoto,
        );

        expect(capturedParams?.name, tName);
        expect(capturedParams?.email, tEmail);
        expect(capturedParams?.photo?.path, tPhoto.path);
      });
    });

    group('clearError', () {
      test('Should clear error without throwing', () async {
        const failure = ApiFailure(message: 'Some error');
        when(
          () => mockGetCurrentUserUseCase(),
        ).thenAnswer((_) async => const Left(failure));

        final viewModel = container.read(authViewModelProvider.notifier);
        await viewModel.getCurrentUser();

        expect(container.read(authViewModelProvider).errorMessage, isNotNull);

        expect(() => viewModel.clearError(), returnsNormally);
        expect(container.read(authViewModelProvider).errorMessage, isNull);
      });
    });

    group('resetState', () {
      test('Should reset state to initial', () async {
        const failure = ApiFailure(message: 'User not authenticated');
        when(
          () => mockGetCurrentUserUseCase(),
        ).thenAnswer((_) async => const Left(failure));

        final viewModel = container.read(authViewModelProvider.notifier);
        await viewModel.getCurrentUser();

        expect(
          container.read(authViewModelProvider).status,
          isNot(AuthStatus.initial),
        );

        viewModel.resetState();

        expect(container.read(authViewModelProvider), const AuthState());
      });
    });
  });

  group('AuthState', () {
    test('Should have correct initial values', () {
      const state = AuthState();

      expect(state.status, AuthStatus.initial);
      expect(state.user, isNull);
      expect(state.errorMessage, isNull);
    });

    test('copyWith should update specified fields', () {
      const state = AuthState();

      final newState = state.copyWith(
        status: AuthStatus.authenticated,
        user: tUser,
      );

      expect(newState.status, AuthStatus.authenticated);
      expect(newState.user, tUser);
      expect(newState.errorMessage, isNull);
    });

    test('copyWith should preserve existing values when not specified', () {
      const state = AuthState(
        status: AuthStatus.authenticated,
        user: tUser,
        errorMessage: 'error',
      );

      final newState = state.copyWith(status: AuthStatus.loading);

      expect(newState.status, AuthStatus.loading);
      expect(newState.user, tUser);
      expect(newState.errorMessage, 'error');
    });

    test('Props should contain all fields', () {
      const state = AuthState(
        status: AuthStatus.authenticated,
        user: tUser,
        errorMessage: 'error',
      );

      expect(state.props, [AuthStatus.authenticated, tUser, 'error']);
    });

    test('Two states with same values should be equal', () {
      const state1 = AuthState(status: AuthStatus.authenticated, user: tUser);
      const state2 = AuthState(status: AuthStatus.authenticated, user: tUser);

      expect(state1, state2);
    });
  });
}
