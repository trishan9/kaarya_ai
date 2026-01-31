import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaarya/core/error/failures.dart';
import 'package:kaarya/features/auth/domain/entities/auth_entity.dart';
import 'package:kaarya/features/auth/domain/repositories/auth_repository.dart';
import 'package:kaarya/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late GetCurrentUserUseCase usecase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    usecase = GetCurrentUserUseCase(authRepository: mockRepository);
  });

  const tUser = AuthEntity(
    authId: '1',
    name: 'Test User',
    email: 'test@example.com',
    provider: 'email',
    role: 'user',
    profilePicture: 'https://example.com/pic.jpg',
  );

  group('GetCurrentUserUseCase', () {
    test('Should return AuthEntity when user is authenticated', () async {
      when(
        () => mockRepository.getCurrentUser(),
      ).thenAnswer((_) async => const Right(tUser));

      final result = await usecase();

      expect(result, const Right(tUser));
      verify(() => mockRepository.getCurrentUser()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('Should return failure when user is not authenticated', () async {
      const failure = ApiFailure(message: 'User not authenticated');
      when(
        () => mockRepository.getCurrentUser(),
      ).thenAnswer((_) async => const Left(failure));

      final result = await usecase();

      expect(result, const Left(failure));
      verify(() => mockRepository.getCurrentUser()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('Should return NetworkFailure when there is no internet', () async {
      const failure = NetworkFailure();
      when(
        () => mockRepository.getCurrentUser(),
      ).thenAnswer((_) async => const Left(failure));

      final result = await usecase();

      expect(result, const Left(failure));
      verify(() => mockRepository.getCurrentUser()).called(1);
    });

    test('Should return LocalDatabaseFailure when local cache fails', () async {
      const failure = LocalDatabaseFailure(message: 'Failed to read user data');
      when(
        () => mockRepository.getCurrentUser(),
      ).thenAnswer((_) async => const Left(failure));

      final result = await usecase();

      expect(result, const Left(failure));
      verify(() => mockRepository.getCurrentUser()).called(1);
    });

    test('Should return user with expected fields', () async {
      const userWithFields = AuthEntity(
        authId: '2',
        name: 'Jane Doe',
        email: 'jane@example.com',
        provider: 'email',
        role: 'admin',
        profilePicture: 'https://example.com/jane.jpg',
      );
      when(
        () => mockRepository.getCurrentUser(),
      ).thenAnswer((_) async => const Right(userWithFields));

      final result = await usecase();

      result.fold((failure) => fail('Expected user but got failure'), (user) {
        expect(user.authId, '2');
        expect(user.name, 'Jane Doe');
        expect(user.email, 'jane@example.com');
        expect(user.provider, 'email');
        expect(user.role, 'admin');
        expect(user.profilePicture, 'https://example.com/jane.jpg');
      });
    });
  });
}
