import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaarya/core/error/failures.dart';
import 'package:kaarya/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:kaarya/features/auth/domain/usecases/login_usecase.dart';
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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockRegisterUseCase mockRegisterUseCase;
  late MockLoginUseCase mockLoginUseCase;
  late MockGetCurrentUserUseCase mockGetCurrentUserUseCase;
  late MockLogoutUseCase mockLogoutUseCase;
  late MockUpdateProfileUsecase mockUpdateProfileUsecase;

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
      ],
      child: const MaterialApp(home: SignupPage()),
    );
  }

  group('SignupPage - UI Elements', () {
    testWidgets('should display header, form fields, and actions', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(800, 1600));

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Create Your Account'), findsOneWidget);
      expect(
        find.text(
          "Welcome to Kaarya! Let's get started by creating your account.",
        ),
        findsOneWidget,
      );

      expect(find.byType(TextFormField), findsNWidgets(4));
      expect(find.text('Enter your full name'), findsOneWidget);
      expect(find.text('Enter your email address'), findsOneWidget);
      expect(find.text('Enter your password'), findsOneWidget);
      expect(find.text('Confirm your password'), findsOneWidget);

      expect(find.byIcon(Icons.person_outline_rounded), findsOneWidget);
      expect(find.byIcon(Icons.mail_outline_rounded), findsOneWidget);
      expect(find.byIcon(Icons.lock_outline_rounded), findsNWidgets(2));

      expect(find.text('Sign Up'), findsOneWidget);
      expect(find.text('Or'), findsOneWidget);
      expect(find.text('Signup with Google'), findsOneWidget);
      expect(find.text('Signup with GitHub'), findsOneWidget);

      await tester.binding.setSurfaceSize(null);
    });
  });

  group('SignupPage - Form Validation', () {
    testWidgets('should show validation errors when fields are empty', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(800, 1200));

      await tester.pumpWidget(createTestWidget());

      await tester.tap(find.text('Sign Up'));
      await tester.pump();

      expect(find.text('Full name is required'), findsOneWidget);
      expect(find.text('Email address is required'), findsOneWidget);
      expect(find.text('Password is required'), findsOneWidget);
      expect(find.text('Confirm Password is required'), findsOneWidget);

      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('should show error when passwords do not match', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(800, 1200));

      await tester.pumpWidget(createTestWidget());

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'Test User');
      await tester.enterText(fields.at(1), 'test@example.com');
      await tester.enterText(fields.at(2), 'password123');
      await tester.enterText(fields.at(3), 'password321');

      await tester.tap(find.text('Sign Up'));
      await tester.pump();

      expect(
        find.text('Password and Confirm Password must be same!'),
        findsOneWidget,
      );

      await tester.binding.setSurfaceSize(null);
    });
  });

  group('SignupPage - Form Submission', () {
    testWidgets('should call register usecase when form is valid', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(800, 1200));

      when(
        () => mockRegisterUseCase(any()),
      ).thenAnswer((_) async => const Left(ApiFailure(message: 'Test')));

      await tester.pumpWidget(createTestWidget());

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'Test User');
      await tester.enterText(fields.at(1), 'test@example.com');
      await tester.enterText(fields.at(2), 'password123');
      await tester.enterText(fields.at(3), 'password123');

      await tester.tap(find.text('Sign Up'));
      await tester.pump();

      verify(() => mockRegisterUseCase(any())).called(1);

      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('should pass correct params to register usecase', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(800, 1200));

      RegisterUseCaseParams? capturedParams;
      when(() => mockRegisterUseCase(any())).thenAnswer((invocation) async {
        capturedParams =
            invocation.positionalArguments.first as RegisterUseCaseParams;
        return const Left(ApiFailure(message: 'Test'));
      });

      await tester.pumpWidget(createTestWidget());

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'Jane Doe');
      await tester.enterText(fields.at(1), 'jane@example.com');
      await tester.enterText(fields.at(2), 'mypassword');
      await tester.enterText(fields.at(3), 'mypassword');

      await tester.tap(find.text('Sign Up'));
      await tester.pump();

      expect(capturedParams?.name, 'Jane Doe');
      expect(capturedParams?.email, 'jane@example.com');
      expect(capturedParams?.password, 'mypassword');

      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('should show loading indicator while signing up', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(800, 1200));

      final completer = Completer<Either<Failure, bool>>();

      when(
        () => mockRegisterUseCase(any()),
      ).thenAnswer((_) => completer.future);

      await tester.pumpWidget(createTestWidget());

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'Test User');
      await tester.enterText(fields.at(1), 'test@example.com');
      await tester.enterText(fields.at(2), 'password123');
      await tester.enterText(fields.at(3), 'password123');

      await tester.tap(find.text('Sign Up'));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.binding.setSurfaceSize(null);
    });
  });
}
