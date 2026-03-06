import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaarya/core/error/failures.dart';
import 'package:kaarya/features/auth/domain/entities/auth_entity.dart';
import 'package:kaarya/features/auth/domain/repositories/auth_repository.dart';
import 'package:kaarya/features/auth/domain/usecases/register_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late RegisterUseCase usecase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    usecase = RegisterUseCase(authRepository: mockRepository);
  });

  setUpAll(() {
    registerFallbackValue(
      const AuthEntity(
        name: 'fallback',
        email: 'fallback@email.com',
        password: 'fallback',
      ),
    );
  });

  const tName = 'Test User';
  const tEmail = 'test@example.com';
  const tPassword = 'password123';
  const tRole = 'candidate';

  group('RegisterUseCase', () {
    test('Should return true when registration is successful', () async {
      when(
        () => mockRepository.registerUser(any()),
      ).thenAnswer((_) async => const Right(true));

      final result = await usecase(
        const RegisterUseCaseParams(
          name: tName,
          email: tEmail,
          password: tPassword,
          confirmPassword: tPassword,
          role: tRole,
        ),
      );

      expect(result, const Right(true));
      verify(() => mockRepository.registerUser(any())).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('Should pass AuthEntity with correct values to repository', () async {
      AuthEntity? capturedEntity;
      when(() => mockRepository.registerUser(any())).thenAnswer((invocation) {
        capturedEntity = invocation.positionalArguments[0] as AuthEntity;
        return Future.value(const Right(true));
      });

      await usecase(
        const RegisterUseCaseParams(
          name: tName,
          email: tEmail,
          password: tPassword,
          confirmPassword: tPassword,
          role: tRole,
        ),
      );

      expect(capturedEntity?.name, tName);
      expect(capturedEntity?.email, tEmail);
      expect(capturedEntity?.password, tPassword);
      expect(capturedEntity?.confirmPassword, tPassword);
      expect(capturedEntity?.role, tRole);
    });

    test('Should return failure when registration fails', () async {
      const failure = ApiFailure(message: 'Email already exists');
      when(
        () => mockRepository.registerUser(any()),
      ).thenAnswer((_) async => const Left(failure));

      final result = await usecase(
        const RegisterUseCaseParams(
          name: tName,
          email: tEmail,
          password: tPassword,
          confirmPassword: tPassword,
          role: tRole,
        ),
      );

      expect(result, const Left(failure));
      verify(() => mockRepository.registerUser(any())).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('Should return NetworkFailure when there is no internet', () async {
      const failure = NetworkFailure();
      when(
        () => mockRepository.registerUser(any()),
      ).thenAnswer((_) async => const Left(failure));

      final result = await usecase(
        const RegisterUseCaseParams(
          name: tName,
          email: tEmail,
          password: tPassword,
          confirmPassword: tPassword,
          role: tRole,
        ),
      );

      expect(result, const Left(failure));
      verify(() => mockRepository.registerUser(any())).called(1);
    });
  });

  group('RegisterUseCaseParams', () {
    test('Should have correct props', () {
      const params = RegisterUseCaseParams(
        name: tName,
        email: tEmail,
        password: tPassword,
        confirmPassword: tPassword,
        role: tRole,
      );

      expect(params.props, [tName, tEmail, tPassword, tPassword, tRole]);
    });

    test('Two params with same values should be equal', () {
      const params1 = RegisterUseCaseParams(
        name: tName,
        email: tEmail,
        password: tPassword,
        confirmPassword: tPassword,
        role: tRole,
      );
      const params2 = RegisterUseCaseParams(
        name: tName,
        email: tEmail,
        password: tPassword,
        confirmPassword: tPassword,
        role: tRole,
      );

      expect(params1, params2);
    });
  });
}
