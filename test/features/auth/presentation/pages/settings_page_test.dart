import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaarya/core/error/failures.dart';
import 'package:kaarya/core/services/storage/user_session_service.dart';
import 'package:kaarya/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:kaarya/features/auth/domain/usecases/login_usecase.dart';
import 'package:kaarya/features/auth/domain/usecases/logout_usecase.dart';
import 'package:kaarya/features/auth/domain/usecases/register_usecase.dart';
import 'package:kaarya/features/auth/domain/usecases/update_profile_usecase.dart';
import 'package:kaarya/features/auth/presentation/pages/settings_page.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  late SharedPreferences prefs;

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

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'name': 'Test User',
      'email': 'test@kaarya.com',
      'photo': '',
    });
    prefs = await SharedPreferences.getInstance();

    mockRegisterUseCase = MockRegisterUseCase();
    mockLoginUseCase = MockLoginUseCase();
    mockGetCurrentUserUseCase = MockGetCurrentUserUseCase();
    mockLogoutUseCase = MockLogoutUseCase();
    mockUpdateProfileUsecase = MockUpdateProfileUsecase();
  });

  Widget createTestWidget() {
    return ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
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
      child: const MaterialApp(home: SettingsPage()),
    );
  }

  group('SettingsPage - UI Elements', () {
    testWidgets('should display profile and form sections', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Profile Overview'), findsOneWidget);
      expect(find.text('Detail Information'), findsOneWidget);
      expect(find.text('Generate Resume with AI'), findsOneWidget);
      expect(find.text('Save Changes'), findsOneWidget);
    });

    testWidgets('should prefill name and email from session', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final fields = find.byType(TextFormField);
      final nameField = tester.widget<TextFormField>(fields.at(0));
      final emailField = tester.widget<TextFormField>(fields.at(1));

      expect(nameField.controller?.text, 'Test User');
      expect(emailField.controller?.text, 'test@kaarya.com');
    });
  });

  group('SettingsPage - Form Validation', () {
    testWidgets('should show error when full name is empty', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), '');

      await tester.ensureVisible(find.text('Save Changes'));
      await tester.tap(find.text('Save Changes'));
      await tester.pumpAndSettle();

      expect(find.text('Full name is required'), findsOneWidget);
    });
  });

  group('SettingsPage - Form Submission', () {
    testWidgets('should call update profile usecase when form is valid', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      when(
        () => mockUpdateProfileUsecase(any()),
      ).thenAnswer((_) async => const Left(ApiFailure(message: 'Test')));

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'Updated User');
      await tester.enterText(fields.at(1), 'updated@kaarya.com');

      await tester.ensureVisible(find.text('Save Changes'));
      await tester.tap(find.text('Save Changes'));
      await tester.pumpAndSettle();

      verify(() => mockUpdateProfileUsecase(any())).called(1);
    });

    testWidgets('should pass correct params to update profile usecase', (
      tester,
    ) async {
      UpdateProfileUsecaseParams? capturedParams;
      when(() => mockUpdateProfileUsecase(any())).thenAnswer((
        invocation,
      ) async {
        capturedParams =
            invocation.positionalArguments.first as UpdateProfileUsecaseParams;
        return const Left(ApiFailure(message: 'Test'));
      });

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'Updated User');
      await tester.enterText(fields.at(1), 'updated@kaarya.com');

      await tester.ensureVisible(find.text('Save Changes'));
      await tester.tap(find.text('Save Changes'));
      await tester.pumpAndSettle();

      expect(capturedParams?.name, 'Updated User');
      expect(capturedParams?.email, 'updated@kaarya.com');
    });
  });
}
