import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaarya/core/error/failures.dart';
import 'package:kaarya/features/auth/domain/entities/auth_entity.dart';
import 'package:kaarya/features/auth/domain/usecases/change_password_usecase.dart';
import 'package:kaarya/features/auth/domain/usecases/exchange_oauth_result_usecase.dart';
import 'package:kaarya/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:kaarya/features/auth/domain/usecases/get_oauth_provider_status_usecase.dart';
import 'package:kaarya/features/auth/domain/usecases/login_usecase.dart';
import 'package:kaarya/features/auth/domain/usecases/login_with_google_usecase.dart';
import 'package:kaarya/features/auth/domain/usecases/logout_usecase.dart';
import 'package:kaarya/features/auth/domain/usecases/register_usecase.dart';
import 'package:kaarya/features/auth/domain/usecases/update_profile_usecase.dart';
import 'package:kaarya/features/auth/presentation/pages/login_page.dart';
import 'package:kaarya/features/auth/presentation/widgets/signup_text_widget.dart';
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
        password: 'fallback',
        confirmPassword: 'fallback',
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
      child: const MaterialApp(home: LoginPage()),
    );
  }

  group('LoginPage - UI Elements', () {
    testWidgets('should display header and intro texts', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1600));

      await tester.pumpWidget(createTestWidget());

      expect(find.text('Kaarya'), findsOneWidget);
      expect(find.text('Welcome back to Kaarya!'), findsOneWidget);
      expect(
        find.text('Enter your username and password to access your account'),
        findsOneWidget,
      );

      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('should display form fields and icons', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1600));

      await tester.pumpWidget(createTestWidget());

      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.text('Enter your email address'), findsOneWidget);
      expect(find.text('Enter your password'), findsOneWidget);
      expect(find.byIcon(Icons.mail_outline_rounded), findsOneWidget);
      expect(find.byIcon(Icons.lock_outline_rounded), findsOneWidget);
      expect(find.byIcon(Icons.visibility_off), findsOneWidget);

      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('should toggle password visibility', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1600));

      await tester.pumpWidget(createTestWidget());

      await tester.tap(find.byIcon(Icons.visibility_off));
      await tester.pump();

      expect(find.byIcon(Icons.visibility), findsOneWidget);

      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('should display action buttons and links', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1600));

      await tester.pumpWidget(createTestWidget());

      expect(find.text('Login'), findsOneWidget);
      expect(find.text('Forgot Password?'), findsOneWidget);
      expect(find.text('Or'), findsOneWidget);
      expect(find.byType(SignupText), findsOneWidget);
      expect(find.text('Login with Google'), findsOneWidget);
      expect(find.text('Login with GitHub'), findsNothing);

      await tester.binding.setSurfaceSize(null);
    });
  });

  group('LoginPage - Form Validation', () {
    testWidgets('should show validation errors when fields are empty', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(800, 1600));

      await tester.pumpWidget(createTestWidget());

      await tester.tap(find.text('Login'));
      await tester.pump();

      expect(find.text('Email address is required'), findsOneWidget);
      expect(find.text('Password is required'), findsOneWidget);

      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('should show email error when email is empty', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1600));

      await tester.pumpWidget(createTestWidget());

      await tester.enterText(find.byType(TextFormField).last, 'password123');
      await tester.tap(find.text('Login'));
      await tester.pump();

      expect(find.text('Email address is required'), findsOneWidget);

      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('should show password error when password is empty', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(800, 1600));

      await tester.pumpWidget(createTestWidget());

      await tester.enterText(find.byType(TextFormField).first, 'user@test.com');
      await tester.tap(find.text('Login'));
      await tester.pump();

      expect(find.text('Password is required'), findsOneWidget);

      await tester.binding.setSurfaceSize(null);
    });
  });

  group('LoginPage - Form Submission', () {
    testWidgets('should call login usecase when form is valid', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1600));

      when(
        () => mockLoginUseCase(any()),
      ).thenAnswer((_) async => const Left(ApiFailure(message: 'Test')));

      await tester.pumpWidget(createTestWidget());

      await tester.enterText(
        find.byType(TextFormField).first,
        'test@example.com',
      );
      await tester.enterText(find.byType(TextFormField).last, 'password123');

      await tester.tap(find.text('Login'));
      await tester.pump();

      verify(() => mockLoginUseCase(any())).called(1);

      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('should pass correct params to login usecase', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1600));

      LoginUseCaseParams? capturedParams;
      when(() => mockLoginUseCase(any())).thenAnswer((invocation) async {
        capturedParams =
            invocation.positionalArguments.first as LoginUseCaseParams;
        return const Left(ApiFailure(message: 'Test'));
      });

      await tester.pumpWidget(createTestWidget());

      await tester.enterText(find.byType(TextFormField).first, 'user@test.com');
      await tester.enterText(find.byType(TextFormField).last, 'mypassword');

      await tester.tap(find.text('Login'));
      await tester.pump();

      expect(capturedParams?.email, 'user@test.com');
      expect(capturedParams?.password, 'mypassword');

      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('should not call login usecase when form is invalid', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(800, 1600));

      await tester.pumpWidget(createTestWidget());

      await tester.enterText(
        find.byType(TextFormField).first,
        'test@example.com',
      );

      await tester.tap(find.text('Login'));
      await tester.pump();

      verifyNever(() => mockLoginUseCase(any()));

      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('should show loading indicator while logging in', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(800, 1600));

      final completer = Completer<Either<Failure, AuthEntity>>();

      when(() => mockLoginUseCase(any())).thenAnswer((_) => completer.future);

      await tester.pumpWidget(createTestWidget());

      await tester.enterText(
        find.byType(TextFormField).first,
        'test@example.com',
      );
      await tester.enterText(find.byType(TextFormField).last, 'password123');

      await tester.tap(find.text('Login'));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsAtLeastNWidgets(1));

      await tester.binding.setSurfaceSize(null);
    });
  });
}
