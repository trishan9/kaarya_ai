import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaarya/core/error/failures.dart';
import 'package:kaarya/features/auth/domain/entities/auth_entity.dart';
import 'package:kaarya/features/auth/domain/repositories/auth_repository.dart';
import 'package:kaarya/features/auth/domain/usecases/login_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late LoginUseCase usecase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    usecase = LoginUseCase(authRepository: mockRepository);
  });

  const tEmail = 'test@example.com';
  const tPassword = 'password123';
  const tAuthEntity = AuthEntity(
    authId: 'auth1',
    name: 'Test User',
    email: tEmail,
  );

  group('LoginUseCase', () {
    test('Should return AuthEntity when login is successful', () async {
      when(
        () => mockRepository.loginUser(tEmail, tPassword),
      ).thenAnswer((_) async => const Right(tAuthEntity));

      final result = await usecase(
        const LoginUseCaseParams(email: tEmail, password: tPassword),
      );

      expect(result, const Right(tAuthEntity));
      verify(() => mockRepository.loginUser(tEmail, tPassword)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('Should pass correct email and password to repository', () async {
      String? capturedEmail;
      String? capturedPassword;
      when(() => mockRepository.loginUser(any(), any())).thenAnswer((
        invocation,
      ) {
        capturedEmail = invocation.positionalArguments[0] as String;
        capturedPassword = invocation.positionalArguments[1] as String;
        return Future.value(const Right(tAuthEntity));
      });

      await usecase(
        const LoginUseCaseParams(email: tEmail, password: tPassword),
      );

      expect(capturedEmail, tEmail);
      expect(capturedPassword, tPassword);
    });

    test('Should return failure when login fails', () async {
      const failure = ApiFailure(message: 'Invalid credentials');
      when(
        () => mockRepository.loginUser(any(), any()),
      ).thenAnswer((_) async => const Left(failure));

      final result = await usecase(
        const LoginUseCaseParams(email: tEmail, password: tPassword),
      );

      expect(result, const Left(failure));
      verify(() => mockRepository.loginUser(tEmail, tPassword)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('Should return NetworkFailure when there is no internet', () async {
      const failure = NetworkFailure();
      when(
        () => mockRepository.loginUser(any(), any()),
      ).thenAnswer((_) async => const Left(failure));

      final result = await usecase(
        const LoginUseCaseParams(email: tEmail, password: tPassword),
      );

      expect(result, const Left(failure));
      verify(() => mockRepository.loginUser(tEmail, tPassword)).called(1);
    });
  });

  group('LoginUseCaseParams', () {
    test('Should have correct props', () {
      const params = LoginUseCaseParams(email: tEmail, password: tPassword);

      expect(params.props, [tEmail, tPassword]);
    });

    test('Two params with same values should be equal', () {
      const params1 = LoginUseCaseParams(email: tEmail, password: tPassword);
      const params2 = LoginUseCaseParams(email: tEmail, password: tPassword);

      expect(params1, params2);
    });
  });
}
