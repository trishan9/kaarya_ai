import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaarya/core/services/storage/user_session_service.dart';
import 'package:kaarya/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:kaarya/features/auth/domain/usecases/login_usecase.dart';
import 'package:kaarya/features/auth/domain/usecases/logout_usecase.dart';
import 'package:kaarya/features/auth/domain/usecases/register_usecase.dart';
import 'package:kaarya/features/auth/domain/usecases/update_profile_usecase.dart';
import 'package:kaarya/features/dashboard/presentation/pages/dashboard_page.dart';
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
      child: const MaterialApp(home: DashboardPage()),
    );
  }

  group('DashboardPage - UI Elements', () {
    testWidgets('should render app bar, drawer, and bottom navigation', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.text('Overview'),
        ),
        findsOneWidget,
      );
      await tester.tap(find.byTooltip('Open navigation menu'));
      await tester.pumpAndSettle();
      expect(find.byType(Drawer), findsOneWidget);
      expect(find.byType(BottomNavigationBar), findsOneWidget);
      expect(find.text('Explore'), findsOneWidget);
      expect(find.text('Interview Hub'), findsOneWidget);
      expect(find.text('Leaderboard'), findsWidgets);
      expect(find.text('Resume Builder AI'), findsWidgets);
    });
  });

  group('DashboardPage - Navigation', () {
    testWidgets('should switch tabs when bottom nav items are tapped', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Explore'));
      await tester.pumpAndSettle();
      expect(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.text('Explore Jobs & Internships'),
        ),
        findsOneWidget,
      );

      await tester.tap(find.text('Interview Hub'));
      await tester.pumpAndSettle();
      expect(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.text('AI Interview Hub'),
        ),
        findsOneWidget,
      );

      await tester.tap(find.text('Leaderboard'));
      await tester.pumpAndSettle();
      expect(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.text('Leaderboard'),
        ),
        findsOneWidget,
      );

      await tester.tap(find.text('Resume Builder AI'));
      await tester.pumpAndSettle();
      expect(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.text('Resume Builder AI'),
        ),
        findsOneWidget,
      );
    });
  });
}
