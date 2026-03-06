import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaarya/core/error/failures.dart';
import 'package:kaarya/features/auth/domain/usecases/change_password_usecase.dart';
import 'package:kaarya/features/auth/domain/usecases/exchange_oauth_result_usecase.dart';
import 'package:kaarya/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:kaarya/features/auth/domain/usecases/get_oauth_provider_status_usecase.dart';
import 'package:kaarya/features/auth/domain/usecases/login_usecase.dart';
import 'package:kaarya/features/auth/domain/usecases/login_with_google_usecase.dart';
import 'package:kaarya/features/auth/domain/usecases/logout_usecase.dart';
import 'package:kaarya/features/auth/domain/usecases/register_usecase.dart';
import 'package:kaarya/features/auth/domain/usecases/update_profile_usecase.dart';
import 'package:kaarya/features/auth/presentation/pages/signup_page.dart';
import 'package:mocktail/mocktail.dart';

class MockRegisterUseCase extends Mock implements RegisterUseCase {}

class MockLoginUseCase extends Mock implements LoginUseCase {}

class MockGetCurrentUserUseCase extends Mock implements GetCurrentUserUseCase {}

class MockLogoutUseCase extends Mock implements LogoutUseCase {}

class MockUpdateProfileUsecase extends Mock implements UpdateProfileUsecase {}

class MockChangePasswordUseCase extends Mock implements ChangePasswordUseCase {}

class MockGetOAuthProviderStatusUseCase extends Mock
    implements GetOAuthProviderStatusUseCase {}

class MockLoginWithGoogleUseCase extends Mock
    implements LoginWithGoogleUseCase {}

class MockExchangeOAuthResultUseCase extends Mock
    implements ExchangeOAuthResultUseCase {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockRegisterUseCase mockRegisterUseCase;
  late MockLoginUseCase mockLoginUseCase;
  late MockGetCurrentUserUseCase mockGetCurrentUserUseCase;
  late MockLogoutUseCase mockLogoutUseCase;
  late MockUpdateProfileUsecase mockUpdateProfileUsecase;
  late MockChangePasswordUseCase mockChangePasswordUseCase;
  late MockGetOAuthProviderStatusUseCase mockGetOAuthProviderStatusUseCase;
  late MockLoginWithGoogleUseCase mockLoginWithGoogleUseCase;
  late MockExchangeOAuthResultUseCase mockExchangeOAuthResultUseCase;

  setUpAll(() {
    registerFallbackValue(
      const RegisterUseCaseParams(
        name: 'fallback',
        email: 'fallback@email.com',
        password: 'fallback123',
        confirmPassword: 'fallback123',
        role: 'user',
      ),
    );
    registerFallbackValue(
      const LoginUseCaseParams(
        email: 'fallback@email.com',
        password: 'fallback',
      ),
    );
    registerFallbackValue(const UpdateProfileUsecaseParams());
    registerFallbackValue(
      const ChangePasswordParams(
        currentPassword: 'fallback',
        newPassword: 'fallback-new',
        confirmNewPassword: 'fallback-new',
      ),
    );
    registerFallbackValue(
      const GetOAuthProviderStatusParams(provider: 'google'),
    );
    registerFallbackValue(
      const LoginWithGoogleUseCaseParams(serverClientId: 'server-client-id'),
    );
    registerFallbackValue(
      const ExchangeOAuthResultUseCaseParams(resultToken: 'result-token'),
    );
  });

  setUp(() {
    mockRegisterUseCase = MockRegisterUseCase();
    mockLoginUseCase = MockLoginUseCase();
    mockGetCurrentUserUseCase = MockGetCurrentUserUseCase();
    mockLogoutUseCase = MockLogoutUseCase();
    mockUpdateProfileUsecase = MockUpdateProfileUsecase();
    mockChangePasswordUseCase = MockChangePasswordUseCase();
    mockGetOAuthProviderStatusUseCase = MockGetOAuthProviderStatusUseCase();
    mockLoginWithGoogleUseCase = MockLoginWithGoogleUseCase();
    mockExchangeOAuthResultUseCase = MockExchangeOAuthResultUseCase();
  });

  Widget createTestWidget() {
    return ProviderScope(
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
        changePasswordUseCaseProvider.overrideWithValue(
          mockChangePasswordUseCase,
        ),
        getOAuthProviderStatusUseCaseProvider.overrideWithValue(
          mockGetOAuthProviderStatusUseCase,
        ),
        loginWithGoogleUseCaseProvider.overrideWithValue(
          mockLoginWithGoogleUseCase,
        ),
        exchangeOAuthResultUseCaseProvider.overrideWithValue(
          mockExchangeOAuthResultUseCase,
        ),
      ],
      child: const MaterialApp(home: SignupPage()),
    );
  }

  Finder firstNameField() => find.byType(TextFormField).at(0);
  Finder lastNameField() => find.byType(TextFormField).at(1);
  Finder emailField() => find.byType(TextFormField).at(2);
  Finder passwordField() => find.byType(TextFormField).at(3);
  Finder confirmPasswordField() => find.byType(TextFormField).at(4);

  group('SignupPage - UI Elements', () {
    testWidgets('should display current signup sections for candidate', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(800, 1600));

      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      expect(find.text('Create your account'), findsOneWidget);
      expect(find.text('Sign up as'), findsOneWidget);
      expect(find.text('Candidate'), findsOneWidget);
      expect(find.text('Recruiter'), findsOneWidget);
      expect(find.text('College'), findsOneWidget);
      expect(find.text('First Name'), findsOneWidget);
      expect(find.text('Last Name'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Confirm Password'), findsOneWidget);
      expect(find.text('Sign Up'), findsOneWidget);
      expect(find.text('Signup with Google'), findsOneWidget);
      expect(find.text('Signup with GitHub'), findsOneWidget);

      await tester.binding.setSurfaceSize(null);
    });
  });

  group('SignupPage - Form Validation', () {
    testWidgets('should show validation errors when required fields are empty', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(800, 1600));
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      await tester.ensureVisible(find.widgetWithText(ElevatedButton, 'Sign Up'));
      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign Up'));
      await tester.pump();

      expect(find.text('First name is required'), findsOneWidget);
      expect(find.text('Last name is required'), findsOneWidget);
      expect(find.text('Email address is required'), findsOneWidget);
      expect(find.text('Password is required'), findsOneWidget);
      expect(find.text('Confirm password is required'), findsOneWidget);

      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('should show mismatch error when passwords differ', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(800, 1600));
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      await tester.enterText(firstNameField(), 'Test');
      await tester.enterText(lastNameField(), 'User');
      await tester.enterText(emailField(), 'test@example.com');
      await tester.enterText(passwordField(), 'password123');
      await tester.enterText(confirmPasswordField(), 'password321');

      await tester.ensureVisible(find.widgetWithText(ElevatedButton, 'Sign Up'));
      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign Up'));
      await tester.pump();

      expect(find.text('Passwords do not match'), findsOneWidget);
      verifyNever(() => mockRegisterUseCase(any()));

      await tester.binding.setSurfaceSize(null);
    });
  });

  group('SignupPage - Form Submission', () {
    testWidgets('should call register usecase with the current candidate data', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(800, 1600));
      RegisterUseCaseParams? capturedParams;
      when(() => mockRegisterUseCase(any())).thenAnswer((invocation) async {
        capturedParams =
            invocation.positionalArguments.first as RegisterUseCaseParams;
        return const Left(ApiFailure(message: 'Test'));
      });

      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      await tester.enterText(firstNameField(), 'Jane');
      await tester.enterText(lastNameField(), 'Doe');
      await tester.enterText(emailField(), 'jane@example.com');
      await tester.enterText(passwordField(), 'mypassword');
      await tester.enterText(confirmPasswordField(), 'mypassword');

      await tester.ensureVisible(find.widgetWithText(ElevatedButton, 'Sign Up'));
      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign Up'));
      await tester.pump();

      verify(() => mockRegisterUseCase(any())).called(1);
      expect(capturedParams?.name, 'Jane Doe');
      expect(capturedParams?.email, 'jane@example.com');
      expect(capturedParams?.password, 'mypassword');
      expect(capturedParams?.confirmPassword, 'mypassword');
      expect(capturedParams?.role, 'user');

      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('should show loading indicator while signup is in progress', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(800, 1600));
      final completer = Completer<Either<Failure, bool>>();
      when(() => mockRegisterUseCase(any())).thenAnswer((_) => completer.future);

      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      await tester.enterText(firstNameField(), 'Jane');
      await tester.enterText(lastNameField(), 'Doe');
      await tester.enterText(emailField(), 'jane@example.com');
      await tester.enterText(passwordField(), 'mypassword');
      await tester.enterText(confirmPasswordField(), 'mypassword');

      await tester.ensureVisible(find.widgetWithText(ElevatedButton, 'Sign Up'));
      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign Up'));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.binding.setSurfaceSize(null);
    });
  });
}
